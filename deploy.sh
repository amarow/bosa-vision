#!/bin/bash
# Skript zur automatischen Veröffentlichung der index.html im öffentlichen Repository bosa-vision

set -e

echo "=== Starte Deployment von index.html nach bosa-vision ==="

# Temporären Ordner erstellen
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# 1. Klonen des öffentlichen Repositories
echo "Klone bosa-vision..."
git clone https://github.com/amarow/bosa-vision.git "$TEMP_DIR"

# 2. Kopieren der index.html
echo "Kopiere index.html..."
cp index.html "$TEMP_DIR/"

# 3. Wechseln in das Verzeichnis
cd "$TEMP_DIR"

# Prüfen, ob das Repository korrekt geklont wurde
if [ ! -d ".git" ]; then
    echo "Fehler beim Klonen."
    exit 1
fi

git add index.html

# Prüfen, ob HEAD existiert (um Fehler bei leeren Repositories zu vermeiden)
if git rev-parse --verify HEAD >/dev/null 2>&1; then
    if git diff-index --quiet HEAD --; then
        echo "Keine Änderungen an index.html feststellbar."
        exit 0
    else
        echo "Erstelle Update-Commit..."
        git commit -m "Update 3D model"
    fi
else
    echo "Erstelle initialen Commit..."
    git commit -m "Initial 3D model deploy"
fi

# Bestimmen des aktuellen Branches (master oder main)
BRANCH=$(git symbolic-ref --short -q HEAD || echo "master")

echo "Pushe Änderungen..."
git push origin "$BRANCH"

echo "=== Deployment erfolgreich abgeschlossen! ==="
