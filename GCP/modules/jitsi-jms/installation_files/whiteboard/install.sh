#!/bin/bash

if [ ! -f "/etc/jitsi/installation/whiteboard_done" ]; then

    mkdir -p /etc/jitsi/installation/

    . "/home/prov/installation_files/variables.sh"
    . "/home/prov/installation_files/versions.sh"

    apt-get -qq update
    apt-get install -qq git npm

    # Installing whiteboard
    cd /opt
    git clone https://github.com/jitsi/excalidraw-backend.git
    cd /opt/excalidraw-backend
    echo "PORT=3002" > "/opt/excalidraw-backend/.env.production"
    npm install
    npm run build
    cd /
    cp /home/prov/installation_files/whiteboard/excalidraw.service /etc/systemd/system/

    if ! systemctl enable excalidraw.service; then
        echo "Failed to enable excalidraw.service" >> "${INSTALLATION_LOGS}"
    fi
    if ! systemctl start excalidraw.service; then
        echo "Failed to start excalidraw.service" >> "${INSTALLATION_LOGS}"
    fi

    # Enable whiteboard
    echo "config.whiteboard = config.whiteboard || {};" >> "${CFG_JS}"
    echo "config.whiteboard.enabled = true;" >> "${CFG_JS}"
    echo "config.whiteboard.collabServerBaseUrl = 'https://${JITSI_HOSTNAME}';" >> "${CFG_JS}"

    # Whiteboard in nginx
    perl -0777 -pi -e "s|    \# colibri \(JVB\) websockets for jvb1|    \# Whiteboard\n    location = \/socket\.io\/ \{\n        proxy_pass http://127.0.0.1:3002/socket.io/?\\\$args;\n        proxy_http_version 1.1;\n        proxy_set_header Upgrade \\\$http_upgrade;\n        proxy_set_header Connection \"upgrade\";\n        proxy_set_header Host \\\$http_host;\n        tcp_nodelay on;\n    \}\n\n    \# colibri \(JVB\) websockets for jvb1|g" "${CFG_NGINX}"

    # write file to end config
    date +"%Y-%m-%dT%H:%M:%S" > "/etc/jitsi/installation/whiteboard_done"

fi
