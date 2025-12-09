#!/bin/bash
# Script pour lancer Flutter web avec Chrome sans restrictions CORS

echo "🚀 Lancement de l'application Flutter Web avec Chrome (CORS désactivé)"
echo "⚠️  ATTENTION: Utilisez uniquement pour le développement local"

# Tuer tous les processus Chrome existants
pkill -f "Google Chrome"
sleep 2

# Lancer Flutter avec Chrome et CORS désactivé
flutter run -d chrome --web-browser-flag="--disable-web-security" --web-browser-flag="--user-data-dir=/tmp/chrome_dev_test" --web-browser-flag="--disable-features=VizDisplayCompositor"