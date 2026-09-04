#!/bin/bash
# Skript zur automatischen Veröffentlichung der öffentlichen Seiten (index.html, projekttabelle/
# mit projekttabelle.html darin) im öffentlichen Repository bosa-vision. Hält main als saubere,
# anonymisierte Historie ohne die Zwischenstände des Arbeits-Branches.
#
# Versionsnummer (v-Tag unten links im 3D-Modell, index.html, sowie im Kopf der Projekttabelle):
# wird vor jedem Deploy automatisch um die Patch-Stelle erhöht (z.B. v5.2.0 -> v5.2.1), in beiden
# Dateien synchron gehalten und als eigener Commit im aktuellen (privaten) Repo/Branch abgelegt.
# Andere Bump-Stufe oder eine feste Version:
#   ./deploy.sh              Patch erhöhen (Standard, z.B. v5.2.0 -> v5.2.1)
#   ./deploy.sh --minor      Minor erhöhen, Patch auf 0 (z.B. v5.2.3 -> v5.3.0)
#   ./deploy.sh --major      Major erhöhen, Minor/Patch auf 0 (z.B. v5.2.3 -> v6.0.0)
#   ./deploy.sh 5.5.0        Version fest setzen
#   ./deploy.sh --no-bump    Version unverändert lassen

set -e

# --- 0. Versionsnummer erhöhen (.version-tag in index.html + projekttabelle/projekttabelle.html) ---
VERSION_FILES=("index.html" "projekttabelle/projekttabelle.html")
CURRENT_VERSION=$(grep -ohP '(?<=class="version-tag">v)[0-9]+\.[0-9]+\.[0-9]+' "${VERSION_FILES[@]}" | head -1 || true)

BUMP="patch"
NEW_VERSION=""
for arg in "$@"; do
    case "$arg" in
        --major)   BUMP="major" ;;
        --minor)   BUMP="minor" ;;
        --patch)   BUMP="patch" ;;
        --no-bump) BUMP="none" ;;
        [0-9]*.[0-9]*.[0-9]*) NEW_VERSION="$arg" ;;
        *) echo "Unbekanntes Argument: $arg (erlaubt: --major/--minor/--patch/--no-bump oder X.Y.Z)"; exit 1 ;;
    esac
done

if [ -z "$CURRENT_VERSION" ]; then
    echo "Warnung: Konnte aktuelle Versionsnummer nicht in ${VERSION_FILES[*]} finden - Versions-Bump wird übersprungen."
else
    if [ -z "$NEW_VERSION" ]; then
        if [ "$BUMP" = "none" ]; then
            NEW_VERSION="$CURRENT_VERSION"
        else
            IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
            case "$BUMP" in
                major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
                minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
                patch) PATCH=$((PATCH + 1)) ;;
            esac
            NEW_VERSION="$MAJOR.$MINOR.$PATCH"
        fi
    fi

    if [ "$NEW_VERSION" != "$CURRENT_VERSION" ]; then
        echo "Erhöhe Version: v$CURRENT_VERSION -> v$NEW_VERSION"
        for f in "${VERSION_FILES[@]}"; do
            sed -i "s/class=\"version-tag\">v$CURRENT_VERSION</class=\"version-tag\">v$NEW_VERSION</" "$f"
        done
        git add "${VERSION_FILES[@]}"
        git commit -m "Bump version to v$NEW_VERSION"
    else
        echo "Version bleibt v$CURRENT_VERSION (kein Bump)."
    fi
fi

echo "=== Starte Deployment nach bosa-vision ==="

# Temporären Ordner erstellen
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# 1. Klonen des öffentlichen Repositories
echo "Klone bosa-vision..."
git clone git@github.com-bosa:amarow/bosa-vision.git "$TEMP_DIR"

# 2. Kopieren der öffentlichen Seiten
echo "Kopiere index.html, projekttabelle/..."
cp index.html "$TEMP_DIR/"
rm -rf "$TEMP_DIR/projekttabelle"
cp -r projekttabelle "$TEMP_DIR/"

# Alte Dateinamen/Ordner aus fruaheren Deploys entfernen (Umbenennungen
# kommunikation.html/-geometra -> projekttabelle.html/-geometra -> projekttabelle/)
rm -rf "$TEMP_DIR/kommunikation.html" "$TEMP_DIR/kommunikation-geometra" \
       "$TEMP_DIR/projekttabelle.html" "$TEMP_DIR/projekttabelle-geometra"

# 3. Wechseln in das Verzeichnis
cd "$TEMP_DIR"

# Prüfen, ob das Repository korrekt geklont wurde
if [ ! -d ".git" ]; then
    echo "Fehler beim Klonen."
    exit 1
fi

git add -A

# Prüfen, ob HEAD existiert (um Fehler bei leeren Repositories zu vermeiden)
if git rev-parse --verify HEAD >/dev/null 2>&1; then
    if git diff-index --quiet HEAD --; then
        echo "Keine Änderungen feststellbar."
        exit 0
    else
        echo "Erstelle Update-Commit..."
        git commit -m "Update site content"
    fi
else
    echo "Erstelle initialen Commit..."
    git commit -m "Initial site deploy"
fi

# Bestimmen des aktuellen Branches (master oder main)
BRANCH=$(git symbolic-ref --short -q HEAD || echo "master")

echo "Pushe Änderungen..."
git push origin "$BRANCH"

echo "=== Deployment erfolgreich abgeschlossen! ==="
