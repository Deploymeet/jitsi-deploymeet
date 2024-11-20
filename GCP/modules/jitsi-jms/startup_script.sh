#!/bin/bash

if [ ! -f "/etc/jitsi/installation/full_installation_done" ]; then

    mkdir -p /etc/jitsi/installation

    # Package repos
    export DEBIAN_FRONTEND=noninteractive
    apt-get -qq update
    apt-get install -qq unzip wget curl
    apt-get install -qq apt-transport-https ca-certificates htop lsof wget vnstat patch debconf-utils socat
    apt-get install -qq nginx-full libnginx-mod-http-geoip

    cat << EOF > "/home/prov/installation_files/variables.sh"
#!/bin/bash
export JITSI_HOSTNAME="${JITSI_HOSTNAME}"
export JITSI_JVB_USERNAME="${JITSI_JVB_USERNAME}"
export JITSI_JVB_SECRET="${JITSI_JVB_SECRET}"
export LETSENCRYPT_ACCOUNT_MAIL="${LETSENCRYPT_ACCOUNT_MAIL}"

export INSTALLATION_LOGS="/etc/jitsi/installation/install.log"

export CFG_LUA="/etc/prosody/conf.avail/${JITSI_HOSTNAME}.cfg.lua"
export CFG_JS="/etc/jitsi/meet/${JITSI_HOSTNAME}-config.js"
export CFG_NGINX="/etc/nginx/sites-available/${JITSI_HOSTNAME}.conf"
export CFG_JICOFO="/etc/jitsi/jicofo/jicofo.conf"
export CFG_JIGASI="/etc/jitsi/jigasi/sip-communicator.properties"

EOF

    . "/home/prov/installation_files/variables.sh"
    . "/home/prov/installation_files/versions.sh"


    # Execute all install.sh
    if [ -f "/home/prov/installation_files/jitsi/install.sh" ]; then
        chmod 755 "/home/prov/installation_files/jitsi/install.sh"
        "/home/prov/installation_files/jitsi/install.sh"
    fi

    if [ -f "/home/prov/installation_files/whiteboard/install.sh" ]; then
        chmod 755 "/home/prov/installation_files/whiteboard/install.sh"
        "/home/prov/installation_files/whiteboard/install.sh"
    fi


    # Restart services
    /etc/init.d/coturn restart
    /etc/init.d/prosody restart
    /etc/init.d/jicofo restart
    /etc/init.d/nginx restart
    # nginx -s reload

    # write file to end config
    date +"%Y-%m-%dT%H:%M:%S" > "/etc/jitsi/installation/full_installation_done"

    # Delete provisioning files and ssh keys
    rm -rf /home/prov/installation_files/
    rm -rf /home/prov/.ssh/
fi
