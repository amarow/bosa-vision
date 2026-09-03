# Projekttabelle – deutsche Quelle

Die Teilprojekte sind nach Gewerk auf mehrere Dateien in diesem Ordner (`kommunikation-geometra/`) aufgeteilt. Diese Datei ist nur noch die gemeinsame Anleitung + Übersicht, keine Einträge mehr hier.

- `elektro.md` – Elektroinstallation
- `sanitaer.md` – Sanitär (Wasser/Abwasser/Lüftung, Bäder, WC)
- `maurer.md` – Maurerarbeiten (Versorgungsschacht, Treppenhäuschen/Deckenöffnung, künftige Mauer-/Beton-/Putzarbeiten)
- `abriss.md` – Abriss/Entsorgung alter Bausubstanz (alte Bäder, alte Installationen, alte Geräte)
- `terrasse.md` – Dachterrasse (Abdichtung, Holzdeck, Brüstung, Wendeltreppen-Einbau)
- `fassade.md` – Fassade
- `sonstiges.md` – alles andere (Dach, Innenausbau, künftige Sonderfälle)

**Nur Deutsch eintragen**, jeweils in der passenden Datei. Wenn fertig, Claude bitten:
„Übersetze die Quelldateien neu nach `kommunikation.html`."
Claude liest dann alle `.md`-Dateien in diesem Ordner und überträgt Änderungen (neue/geänderte/gelöschte Einträge) mit englischer und italienischer Übersetzung in `../kommunikation.html`.

Neue Fach-Datei anlegen: Wenn ein Thema in keine bestehende Datei passt, `sonstiges.md` nutzen oder Claude bitten, eine neue Fach-Datei in diesem Ordner anzulegen und hier in der Liste zu ergänzen.

## Format (gilt für alle Fach-Dateien)

Jeder Eintrag ist ein Block, eingeleitet durch `### <Nr.>`. Darunter je Zeile ein Feld als `Label: Wert`. Lange Anmerkungen dürfen über mehrere eingerückte Zeilen umbrechen. Einträge sind durch eine Leerzeile getrennt.

- **Nr.** (wird in der Tabelle als **ID** angezeigt) – kurzes Kürzel (z. B. `EH`, `SI1`, `TA`), steht in der Tabelle allein für sich. Der ausführliche Titel gehört ins **Thema**-Feld, nicht in die Nr. Keine feste Systematik nötig, aber bitte kurz halten. Muss über alle Fach-Dateien hinweg eindeutig sein.
- **Status** – wird in der Tabelle automatisch farbig markiert, wenn einer dieser vier Werte exakt verwendet wird: `offen` (grau) / `in Klärung` (gelb) / `in Umsetzung` (blau) / `erledigt` (grün). Andere Formulierungen sind möglich, erscheinen dann aber neutral (grau).
- **Prio** – 1 (hoch) bis 3 (niedrig). Einträge werden in der Gesamttabelle danach sortiert (fach-übergreifend); leere Prio steht am Ende.
- **Thema** – kurze Überschrift.
- **Anmerkungen** – Kontext, Auflagen, offene Fragen.
- **Ausführer** – wer es macht (Geometra, Handwerker, "noch zu bestimmen" ...). Daraus leitet die Tabelle automatisch eine zusätzliche Spalte **"Ausführung"** ab (farbig, grün/gelb/blau) plus drei einzeln umschaltbare Filter-Buttons "Eigenleistung" / "teilweise" / "Fremdleistung": Steht im Ausführer-Feld exakt das Wort `Eigenleistung` (Groß-/Kleinschreibung beachten) allein, erscheint grün "Eigenleistung"; steht `Eigenleistung` zusammen mit weiterem Text (z. B. "Schlosser + Eigenleistung", "Eigenleistung oder Dienstleister"), erscheint gelb "teilweise"; kommt `Eigenleistung` gar nicht vor, erscheint blau "Fremdleistung". Alle drei Filter-Buttons sind standardmäßig aktiv (nichts ausgeblendet); ein Klick auf einen Button blendet nur dessen Zeilen aus, beliebige Kombinationen sind möglich. Kein eigenes Feld nötig.

Neuen Eintrag anlegen: Block kopieren, `### <Nr.>` anpassen, Felder ausfüllen. Feld leer lassen, wenn (noch) unbekannt.
