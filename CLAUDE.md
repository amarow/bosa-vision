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

Per Einzelklick auf ein Objekt im 3D-Canvas (`onCanvasClick`) wird `selectObject()` aufgerufen; ein schwebendes Editor-Panel (`#editor-panel`) erlaubt Verschieben/Rotieren in 5-/1-cm-Schritten (`moveSelectedObject(axis, val)`, auch per Pfeiltasten/PageUp/PageDown) sowie Löschen (`deleteSelectedObjectWithConfirm()`, auch per Entf/Backspace, mit Bestätigungsdialog). Doppelklick auf leeren Raum (`onCanvasDblClick`) zentriert stattdessen nur die Kamera neu.

Der Editor-Modus ist nur lokal aktiv (`isEditorAvailable`, gesteuert über `location.protocol`/`location.hostname` — `file://`, `localhost`, `127.0.0.1`), da GitHub Pages die Datei nur schreibgeschützt ausliefert. Objekte haben keine feste ID im Code, nur `userData.name`; nach `buildBuilding()` vergibt `buildSelectableRegistry()` deterministisch eine `userData.overrideId` (Name + Vorkommen-Index) und befüllt `allSelectableObjects`/`selectableById`.

Positions-/Rotationsänderungen und Löschungen werden **nicht mehr per Code-Snippet manuell übertragen**. Jede Änderung landet sofort synchron im `localStorage` (Key `bosa_overrides_draft`, `persistOverridesDraft()`) — bewusst **nicht** bei jeder Änderung in die Datei, da ein Dev-Live-Server (z.B. VS Code Live Server), der den Projektordner beobachtet, sonst bei jedem Schreiben der Datei die Seite neu lädt und den Editor-Zustand killt. Erst ein expliziter Klick auf "In overrides.json speichern" (`saveOverridesToFileNow()`, Button im `#editor-panel`-Status sowie in der immer sichtbaren `#overrides-savebar`) schreibt den aktuellen Stand über die File System Access API in die echte Datei (`writeOverridesFile()`; `connectOverridesFile()` fragt beim allerersten Mal einen Datei-Handle an, der danach in IndexedDB für künftige Sessions gemerkt wird).

Beim Start (`initOverridesPersistence()`, aufgerufen direkt nach `buildBuilding()`/`buildSelectableRegistry()`, in try/catch damit ein Fehler hier nie das Rendering blockiert) wird zuerst der `localStorage`-Draft geprüft (`loadOverridesForSession()`) — existiert er, gewinnt er (überlebt Reloads verlustfrei, auch ungespeicherte Änderungen). Nur wenn noch kein Draft existiert, wird `overrides.json` per `fetch()` gelesen und einmalig in den `localStorage` übernommen. `applyOverrides()` wendet das Ergebnis dann auf die frisch gebaute Szene an — das passiert überall, auch auf GitHub Pages (dort bleibt nur das Schreiben deaktiviert, s.o.). Gelöschte Objekte werden dabei physisch aus dem Szenengraph entfernt (`obj.parent.remove(obj)`), nicht nur ausgeblendet.

### Varianten-Logik (Schacht/Bad-Position)

Manche Bauteile existieren in mehreren alternativen Ausführungen, die sich gegenseitig ausschließen und über Buttons im Panel umgeschaltet werden:
- **Treppenschacht**: `shaftBackObjects` / `shaftRightObjects` / `shaftDiagObjects` — gesteuert über `selectShaftPosition('back'|'right'|'diagonal')`.
- **Bad-Position (EG)**: `bathSideGroup` vs. `bathBackGroup` (+ zugehörige Furniture-/Dimension-Gruppen) — gesteuert über `selectBathPosition('side'|'back')`.

Beim Hinzufügen neuer Objekte zu einer dieser Varianten müssen sie in die passende Objekt-Sammlung gepusht werden, damit Sichtbarkeits-Toggles und Fokus-auf-Etage (`focusFloor`) korrekt greifen.

### Vorher/Nachher & Explosionsansicht

Objekte werden je nach Zustand in `beforeObjects` bzw. `afterObjects` einsortiert; `currentProjectState` steuert, welcher Satz sichtbar ist. Der Explosions-Slider (`adjustExplosion`) verschiebt Etagen-Gruppen (`floorGroups`) entlang Y basierend auf `currentExplosion`/`targetExplosion` (in `animate()` sanft interpoliert).

## Projekttabelle (`projekttabelle/projekttabelle.html`)

Eigenständige, dreisprachige (DE/EN/IT) HTML-Tabelle für die Abstimmung mit dem Geometra, verlinkt von/nach `index.html` (relativ: `../index.html` aus dem Unterordner). Gleiche i18n-Mechanik wie oben beschrieben (`translations`-Objekt, `data-i18n`, `setLanguage()`), zusätzlich ein `rows`-Array mit den Zeileninhalten: `{ id, category, status:{de,en,it}, prio: number|null, topic:{de,en,it}, notes:{de,en,it}, executor:{de,en,it} }`. `id` ist ein kurzes Kürzel (z.B. `EH`, `SI1`), der ausführliche Titel steht im `topic`. Rendering sortiert dynamisch nach `prio` (leer = ans Ende) und filtert nach `category` über die Tab-Leiste (`setCategory()`); Status-Badges werden per `statusStyle()` anhand von `status.de` eingefärbt (offen/in Klärung/in Umsetzung/erledigt, siehe `statusColors`-Map). Spaltenreihenfolge in der Tabelle: ID, Thema, Prio, Status, Anmerkungen, Ausführer, Ausführung. Die Ausführung-Spalte hat kein eigenes Datenfeld, sondern wird per `diyLevel()` aus `executor.de` abgeleitet und als Farbbadge dargestellt (`diyColors`-Map, gleiche Palette wie `statusColors`): exakt "Eigenleistung" → `full` (grün), "Eigenleistung" + weiterer Text → `partial` (gelb), kein "Eigenleistung" → `none`/Fremdleistung (blau). Zusätzlich drei unabhängige Toggle-Buttons `diy-filter-full`/`-partial`/`-none` (`toggleDiyFilter(level)`, State als `diyFilters`-Objekt in `bosa_km_diy_filters`) blenden zusätzlich zur Kategorie-Filterung beliebige Kombinationen der drei Ausführungs-Arten aus; aktive Buttons werden per `applyDiyButtonStyle()` in der jeweiligen `diyColors`-Farbe eingefärbt, inaktive sind gedimmt (gestrichelter Rand).

**Workflow & Quelle:** Der Nutzer pflegt neue/geänderte Einträge nur auf Deutsch, aufgeteilt nach Gewerk in mehrere Dateien im selben Ordner `projekttabelle/` wie die HTML-Datei:

- `projekttabelle/README.md` – nur noch gemeinsame Format-Anleitung + Übersicht der Fach-Dateien, keine Einträge mehr
- `projekttabelle/elektro.md`, `sanitaer.md`, `maurer.md`, `abriss.md`, `terrasse.md`, `fassade.md`, `sonstiges.md` – je Gewerk (= `category`-Wert im `rows`-Array), gleiches Record-Format (`### <Nr.>`-Block mit `Label: Wert`-Zeilen für Status/Prio/Thema/Anmerkungen/Ausführer). `<Nr.>` ist nur das kurze Kürzel, der ausführliche Titel gehört ins `Thema`-Feld.

Auf Zuruf ("übersetze die Quelldateien neu nach `projekttabelle.html`") werden alle `.md`-Dateien in `projekttabelle/` eingelesen, Änderungen (neue/geänderte/gelöschte Einträge, IDs müssen dateiübergreifend eindeutig sein) übernommen und ins Englische/Italienische übersetzt, direkt im `rows`-Array von `projekttabelle/projekttabelle.html`. Die Fach-Dateien sind die alleinige Quelle für die Zeileninhalte; die UI-Texte (Spaltenüberschriften, Seitentitel, Tab-Labels etc.) bleiben im `translations`-Objekt der HTML-Datei gepflegt. Passt ein neues Thema in keine bestehende Fach-Datei, in `sonstiges.md` eintragen oder eine neue Fach-Datei in `projekttabelle/` anlegen und in `README.md` verlinken.
