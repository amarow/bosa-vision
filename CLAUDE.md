# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Was das ist

`index.html` ist eine einzelne, in sich geschlossene Datei (~5700 Zeilen), die einen interaktiven 3D-Renovierungsplan für ein Turmhaus ("Bosa Vision") rendert. Es gibt kein Build-System, keinen Package-Manager und keine weiteren Quelldateien im Repo — alles (HTML, CSS, JS) lebt in dieser einen Datei. Three.js (r128) und OrbitControls werden per CDN `<script>`-Tag geladen, keine lokalen Dependencies.

Es gibt kein 3D-Modell-Asset (keine `.glb`/`.gltf`-Datei) — die gesamte Geometrie (Wände, Treppen, Möbel, Installationen, Gerüst usw.) wird prozedural mit primitiven Three.js-Geometrien (`BoxGeometry`, `CylinderGeometry`, `ExtrudeGeometry` ...) im Code aufgebaut.

## Entwickeln & Testen

Kein Build-Schritt nötig. Änderungen direkt in `index.html` vornehmen und die Datei im Browser öffnen (oder z. B. `python3 -m http.server` im Repo-Root starten und `http://localhost:8000` aufrufen — file:// funktioniert wegen CDN-Fetches meist auch direkt).

Es gibt keine automatisierten Tests und keinen Linter. Änderungen werden manuell im Browser verifiziert (Vor-Ort-Prüfung des Renderings, der Etagen-Buttons und der Editor-Modus-Steuerung).

Deployment erfolgt vermutlich über GitHub Pages aus diesem Repo (`amarow/bosa-vision`) — ein Commit auf `main` reicht.

## Architektur der einzelnen Datei

Das `<script>`-Element (ab Zeile ~633) ist in nummerierte Abschnitte gegliedert (per `// --- N. ... ---`-Kommentare durchsuchbar), grob in dieser Reihenfolge:

1. **Übersetzungen** (`translations`, `floorLabelTranslations`, `equipLabelTranslations`, `setLanguage()`) — UI ist dreisprachig (DE/IT/EN), gesteuert über `data-i18n`-Attribute im HTML und `currentLang`.
2. **Globale Variablen & Einstellungen** — Three.js-Objekte (`scene`, `camera`, `renderer`, `controls`), Objekt-Sammlungen pro Kategorie (`installationObjects`, `furnitureObjects`, `craneObjects`, `shaftBackObjects`/`shaftRightObjects`/`shaftDiagObjects`, `bathSideGroup`/`bathBackGroup` ...) sowie Zustandsflags (`wallsTransparent`, `showInstallations`, `bathPosition`, `activeFocusedFloor` usw.). `floorHeights`/`floorSizes` definieren die Y-Koordinaten und Wandhöhen der 5 Etagen (EG, 1.–3. OG, Dachterrasse).
3. **Persistenz** (`loadPersistedState()`) — alle UI-Zustände (Explosionsgrad, Transparenz, Sprache, aktive Etage, Panel-Zustand ...) werden unter `bosa_*`-Keys in `localStorage` gehalten und beim Start wiederhergestellt.
4. **Initialisierung** (`init()`) — Scene/Kamera/Renderer/OrbitControls-Setup, Event-Listener (Resize, Klicks für Objektauswahl im Editor-Modus).
5. **Beleuchtung & Materialien** (`setupLighting()`, `setupMaterials()`) — zentrale `MeshStandardMaterial`/`MeshLambertMaterial`-Instanzen (`wallMat`, `glassMat`, `doorWoodMat`, `chromeMat` usw.), die in den Etagen-Buildern wiederverwendet werden.
6. **Geometriebau** (`buildBuilding()` → `buildFloor0_EG()`, `buildFloor1_Schlaf1()`, `buildFloor2_2OG()`, `buildFloor3_3OG_Kueche()`, `buildFloor4_Terrasse()`) — je eine Funktion pro Etage, die alle Wände, Türen, Sanitär-/Küchenobjekte, Möbel und (bei der Terrasse) Gerüst/Pergola/Kran erzeugt. Enthält viele lokale Helper-Funktionen (z. B. `createWashingMachine`, `createCoupler`, `createWallAnchor` für die Gerüstteile der Terrasse).
7. **Vertikale Installationen** (`buildVerticalInstallations()`) — Steckdosen, Lichtschalter, Lampen, Verteilerdosen, Leitungen (Elektrik) über alle Etagen, mit nummerierten Beschriftungs-Badges (`createNumberBadge`).
8. **Textsprites & Bemaßung** (`createTextSprite()`, `createDimensionSprite()`, `createDimensionLine()`, `addFloorLabels()`, `updateEquipLabels()`) — 2D-Text wird als Sprite/Canvas-Textur ins 3D gerendert, nicht als HTML-Overlay.
9. **Animation & State-Logik** — Toggle-Funktionen hinter den Checkboxen/Slidern im Control-Panel (`adjustExplosion`, `toggleWallsTransparent`, `toggleFloorsTransparent`, `toggleInstallations`, `toggleCraneFold`, `selectShaftPosition`/`toggleShaftPosition`, `selectBathPosition`, `toggleLabels`, `toggleDimensions`, `toggleFurniture`, `togglePanel`, `focusFloor`) sowie die Render-Loop (`animate()`).

### Editor-Modus

Per Doppelklick auf ein Objekt im 3D-Canvas (`onCanvasDblClick`) wird `selectObject()` aufgerufen; ein schwebendes Editor-Panel (`#editor-panel`) erlaubt Verschieben/Rotieren in 5-/1-cm-Schritten (`moveSelectedObject(axis, val)`) und zeigt ein kopierbares `position.set(x, y, z)`-Code-Snippet zum manuellen Übertragen der neuen Koordinaten in den Quellcode.

### Varianten-Logik (Schacht/Bad-Position)

Manche Bauteile existieren in mehreren alternativen Ausführungen, die sich gegenseitig ausschließen und über Buttons im Panel umgeschaltet werden:
- **Treppenschacht**: `shaftBackObjects` / `shaftRightObjects` / `shaftDiagObjects` — gesteuert über `selectShaftPosition('back'|'right'|'diagonal')`.
- **Bad-Position (EG)**: `bathSideGroup` vs. `bathBackGroup` (+ zugehörige Furniture-/Dimension-Gruppen) — gesteuert über `selectBathPosition('side'|'back')`.

Beim Hinzufügen neuer Objekte zu einer dieser Varianten müssen sie in die passende Objekt-Sammlung gepusht werden, damit Sichtbarkeits-Toggles und Fokus-auf-Etage (`focusFloor`) korrekt greifen.

### Vorher/Nachher & Explosionsansicht

Objekte werden je nach Zustand in `beforeObjects` bzw. `afterObjects` einsortiert; `currentProjectState` steuert, welcher Satz sichtbar ist. Der Explosions-Slider (`adjustExplosion`) verschiebt Etagen-Gruppen (`floorGroups`) entlang Y basierend auf `currentExplosion`/`targetExplosion` (in `animate()` sanft interpoliert).
