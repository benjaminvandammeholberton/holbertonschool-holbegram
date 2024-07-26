#!/bin/bash

# Définir le port
PORT=5000

# Libérer le port s'il est déjà utilisé
fuser -k 5000/tcp

# Changer de répertoire vers le dossier de build web
cd build/web/

# Démarrer le serveur
python3 -m http.server $PORT

