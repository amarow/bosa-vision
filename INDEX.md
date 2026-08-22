# Funktions-Index für index.html

Nachschlagehilfe, damit Funktionen nicht jedes Mal neu gegreppt werden müssen. Zeilennummern verschieben sich bei Edits – bei Bedarf neu generieren mit:

```
grep -n "^\s*function \|^\s*// --- [0-9]" index.html
```

## 1. Globale Variablen & Einstellungen
- 818 `setLanguage(lang)`
- 840 `createWashingMachine(name)`
- 876 `createPipeBetween(p1, p2, radius, material)`
- 887 `createCurvedConduit(points, radius, bendRadius, isLighting, colorOverride)` — globaler Helper für Leitungspfade mit rechtwinkligen, leicht gerundeten Bögen (siehe rules.md); `colorOverride` als Hex-Zahl übersteuert die Standardfarben (grün=Licht/schwarz=Steckdosen)
- 999 `loadPersistedState()` (1000 `getBool`, 1004 `getVal` — lokal)

## 2. Initialisierung
- 1037 `init()`

## 3. Beleuchtung & Materialien
- 1186 `setupLighting()`
- 1206 `setupMaterials()`
- 1292 `registerWall(mesh, isFront, isSideWall)`

## 4. Geometriebau
- 1315 `buildBuilding()`
- 1332 `createVaultMesh(xMin, xMax, zStart, zEnd)`
- 1372 `createDiagonalDoorWall(...)`
- 1411 `buildFloor0_EG()` — EG: Bad, Eingang, Versorgungsschacht (Optionen A/B/C), Hauptverteilung, Warmwasser/Kaltwasser-Anschlüsse
- 2127 `buildFloor1_Schlaf1()` — 1. OG
- 2254 `buildFloor2_2OG()` — 2. OG, Bogendecke, Gäste-WC
- 2404 `buildFloor3_3OG_Kueche()` — Küche, Wendeltreppe, Kühlschrank
- 2795 `buildFloor4_Terrasse()` — Terrasse, Pergola (3121), Kran (3225), `createCoupler` (3265), `createWallAnchor` (3289)
- 3525 `buildVerticalInstallations()` — Elektro über alle Etagen
  - 3533 `createSocket(x, y, z, rotY)`
  - 3555 `createStairwellSwitch(x, y, z, rotY)`
  - 3582 `createLamp(x, y, z, isWall, rotY, distUp, distDown)`
  - 3701 `createJunctionBox(x, y, z, rotY)`
  - 3723 `createConduit(x1, y1, z1, x2, y2, z2)`
  - 3738 `createNumberBadge(num)`
  - 4175 `addSocketWithNumber(x, y, z, rotY, badgeX, badgeY, badgeZ)`
- 4669 `buildDownspout()`
- 4711 `buildBedroomWorkplace(group, Y_start)`
- 4801 `buildWindowWall(group, wallYStart, floorYStart, wallHeight, zPos)`
- 4850 `buildFrenchBalconyWall(group, wallYStart, floorYStart, wallHeight, zPos)`

## 5. Textsprites & Bemaßung
- 4919 `addFloorLabels()`
- 4932 `updateFloorLabels(lang)`
- 4943 `createTextSprite(text)`
- 4975 `createDimensionSprite(text)`
- 4998 `createDimensionLine(p1, p2, text, color, offsetDir, offsetVal)`
- 5054 `updateEquipLabels(lang)`
- 5068 `createTextSpriteSmall(key, accentColor, register)`
- 5113 `showToast(msg)`
- 5141 `setStairwellLamps(isOn, showToastMsg)`
- 5176 `toggleStairwellLamps()`
- 5188 `onCanvasClick(event)`
- 5219 `onCanvasDblClick(event)`
- 5244 `selectObject(obj)`
- 5266 `deselectObject()`
- 5286 `updateSelectionHelper()`
- 5311 `updateEditorUI()`
- 5329 `moveSelectedObject(axis, val)`

## 6. Animation & State-Logik
- 5397 `adjustExplosion(val)`
- 5403 `toggleWallsTransparent(val)`
- 5416 `toggleFloorsTransparent(val)`
- 5424 `toggleInstallations(val)`
- 5452 `toggleCraneFold(val)`
- 5463 `selectShaftPosition(pos)`
- 5495 `toggleShaftPosition(val)`
- 5499 `selectBathPosition(pos)`
- 5527 `toggleLabels(val)`
- 5539 `toggleDimensions(val)`
- 5553 `toggleFurniture(val)`
- 5567 `togglePanel(isCollapsed)`
- 5583 `focusFloor(floorIdx)`
- 5608 `animateCameraTarget(x, y, z)`
- 5613 `onWindowResize()`
- 5621 `animate()`

## Elektro/Wasser-Leitungen: relevante Stellen (siehe rules.md)
Regel: Leitungen nur unten am Boden horizontal (in der Wand/im Fußbodenaufbau) führen, rechtwinklig zu den Endpunkten, mit leichtem Bogen an den Ecken (→ immer `createCurvedConduit` verwenden, nicht mehrere gerade `BoxGeometry`/`CylinderGeometry`-Segmente mit scharfer Ecke).

- Steigleitungen im Schacht (vertikal, alle Optionen): ab ~3762 in `buildVerticalInstallations()`
- Hauptverteilung EG → Steigleitung: Option A/B in `buildVerticalInstallations()` (`elecBoxBack`/`elecBoxRight`), Option C in `buildFloor0_EG()` (`elecBoxDiag`, ab ~1934) — je ein `createCurvedConduit`-Aufruf
- Steckdosen-Daisy-Chains je Etage/Option: `paths`-Arrays in `buildVerticalInstallations()`, Abschnitt "Build the curved conduits" (EG-Block enthält auch die Zuleitung Hauptverteiler→Verteilpunkt für Option 'back')
- Lichtleitungen/Taster/Lampen je Etage/Option: `lightPaths`-Arrays direkt im Anschluss an die jeweiligen `paths`-Arrays
- Warmwasser/Kaltwasser Tank/WP/Autoklav → Steigrohr: `buildFloor0_EG()`, drei Blöcke `equipGrpBack`/`equipGrpRight`/`equipGrpDiag` (ca. 1860–2050) — je `connRedXxx`/`connCyanXxx` als `createCurvedConduit`-Aufruf mit `colorOverride` (0xef4444 warm, 0x06b6d4 kalt); die kurzen Geräte-Stubs (`stubRedXxx`/`stubCyanXxx`) bleiben einfache Zylinder, da sie nur den letzten kurzen Anschluss am Gerät darstellen
