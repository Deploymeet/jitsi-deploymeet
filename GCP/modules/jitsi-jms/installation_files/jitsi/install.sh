#!/bin/bash

if [ ! -f "/etc/jitsi/installation/jitsi_done" ]; then

    mkdir -p /etc/jitsi/installation/

    . "/home/prov/installation_files/variables.sh"
    . "/home/prov/installation_files/versions.sh"

    # Jitsi key
    curl -q https://download.jitsi.org/jitsi-key.gpg.key | apt-key add -
    sh -c "echo 'deb https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list"
    apt-get -qq update

    cat << EOF | sudo debconf-set-selections
jitsi-videobridge     jitsi-videobridge/jvb-hostname    string ${JITSI_HOSTNAME}
jitsi-meet            jitsi-meet/jvb-serve              boolean false
jitsi-meet-prosody    jitsi-videobridge/jvb-hostname    string ${JITSI_HOSTNAME}
jitsi-meet-prosody    jitsi-videobridge/jvbsecret       password ${JITSI_JVB_SECRET}
jitsi-videobridge2    jitsi-videobridge/jvb-hostname    string ${JITSI_HOSTNAME}
jitsi-videobridge2    jitsi-videobridge/jvbsecret       password ${JITSI_JVB_SECRET}
jitsi-meet-web-config jitsi-meet/cert-choice            select "Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)"

EOF

    # Install jitsi
    if [ -n "${JITSI_VIDEOBRIDGE2_VERSION}" ]; then
        res_log=$(apt-get -y install jitsi-videobridge2="${JITSI_VIDEOBRIDGE2_VERSION}")
    else
        res_log=$(apt-get -y install jitsi-videobridge2)
    fi
    res=$?
    if [ "${res}" -ne 0 ]; then
        echo "Failed to install jitsi-videobridge2:" >> "${INSTALLATION_LOGS}"
        echo "${res_log}" >> "${INSTALLATION_LOGS}"
    fi

    if [ -n "${JITSI_JICOFO_VERSION}" ]; then
        res_log=$(apt-get -y install jicofo="${JITSI_JICOFO_VERSION}")
    else
        res_log=$(apt-get -y install jicofo)
    fi
    res=$?
    if [ "${res}" -ne 0 ]; then
        echo "Failed to install jicofo:" >> "${INSTALLATION_LOGS}"
        echo "${res_log}" >> "${INSTALLATION_LOGS}"
    fi

    if [ -n "${JITSI_MEETWEB_VERSION}" ]; then
        res_log=$(apt-get -y install jitsi-meet-web="${JITSI_MEETWEB_VERSION}")
    else
        res_log=$(apt-get -y install jitsi-meet-web)
    fi
    res=$?
    if [ "${res}" -ne 0 ]; then
        echo "Failed to install jitsi-meet-web:" >> "${INSTALLATION_LOGS}"
        echo "${res_log}" >> "${INSTALLATION_LOGS}"
    fi

    if [ -n "${JITSI_MEETWEBCONFIG_VERSION}" ]; then
        res_log=$(apt-get -y install jitsi-meet-web-config="${JITSI_MEETWEBCONFIG_VERSION}")
    else
        res_log=$(apt-get -y install jitsi-meet-web-config)
    fi
    res=$?
    if [ "${res}" -ne 0 ]; then
        echo "Failed to install jitsi-meet-web-config:" >> "${INSTALLATION_LOGS}"
        echo "${res_log}" >> "${INSTALLATION_LOGS}"
    fi

    if [ -n "${JITSI_MEETPROSODY_VERSION}" ]; then
        res_log=$(apt-get -y install jitsi-meet-prosody="${JITSI_MEETPROSODY_VERSION}")
    else
        res_log=$(apt-get -y install jitsi-meet-prosody)
    fi
    res=$?
    if [ "${res}" -ne 0 ]; then
        echo "Failed to install jitsi-meet-prosody:" >> "${INSTALLATION_LOGS}"
        echo "${res_log}" >> "${INSTALLATION_LOGS}"
    fi

    if [ -n "${JITSI_MEETTURNERSERVER_VERSION}" ]; then
        res_log=$(apt-get -y install jitsi-meet-turnserver="${JITSI_MEETTURNERSERVER_VERSION}")
    else
        res_log=$(apt-get -y install jitsi-meet-turnserver)
    fi
    res=$?
    if [ "${res}" -ne 0 ]; then
        echo "Failed to install jitsi-meet-turnserver:" >> "${INSTALLATION_LOGS}"
        echo "${res_log}" >> "${INSTALLATION_LOGS}"
    fi

    if [ -n "${JITSI_MEET_VERSION}" ]; then
        res_log=$(apt-get -y install jitsi-meet="${JITSI_MEET_VERSION}")
    else
        res_log=$(apt-get -y install jitsi-meet)
    fi
    res=$?
    if [ "${res}" -ne 0 ]; then
        echo "Failed to install jitsi-meet:" >> "${INSTALLATION_LOGS}"
        echo "${res_log}" >> "${INSTALLATION_LOGS}"
    fi


    # Enable CORS for BOSH in Prosody Lua config
    sed -i "s|cross_domain_bosh = false;|cross_domain_bosh = true;\ncross_domain_websocket = true;\nconsider_websocket_secure = true;|g" "${CFG_LUA}"

    # Enable websockets
    perl -0777 -pi -e "s|    modules_enabled = {\n        \"bosh\";\n|    modules_enabled = {\n        \"bosh\";\n        \"websocket\";\n        \"smacks\";\n|g" "${CFG_LUA}"
    perl -0777 -pi -e "s|    c2s_require_encryption = false\n|    c2s_require_encryption = false\n    smacks_max_unacked_stanzas = 5;\n    smacks_hibernation_time = 60;\n    smacks_max_hibernated_sessions = 1;\n    smacks_max_old_sessions = 1;\n|g" "${CFG_LUA}"


    # Modify /etc/jitsi/meet/${JITSI_HOSTNAME}-config.js
    echo "config.websocket = 'wss://${JITSI_HOSTNAME}/' + subdir + 'xmpp-websocket';" >> "${CFG_JS}"

    # Flags already added
    # echo "config.flags = config.flags || {};" >> "${CFG_JS}"
    # echo "config.flags.sourceNameSignaling = true;" >> "${CFG_JS}"
    # echo "config.flags.sendMultipleVideoStreams = true;" >> "${CFG_JS}"
    # echo "config.flags.receiveMultipleVideoStreams = true;" >> "${CFG_JS}"

    # Video Constraints
    echo "config.constraints = config.constraints || {};" >> "${CFG_JS}"
    # echo "config.constraints.aspectRatio = 4/3;" >> "${CFG_JS}"
    echo "config.constraints.video = config.constraints.video || {};" >> "${CFG_JS}"
    echo "config.constraints.video.height = config.constraints.video.height || {};" >> "${CFG_JS}"
    echo "config.constraints.video.height.ideal = 720;" >> "${CFG_JS}"
    echo "config.constraints.video.height.max = 720;" >> "${CFG_JS}"
    echo "config.constraints.video.height.min = 240;" >> "${CFG_JS}"
    echo "config.constraints.video.width = config.constraints.video.width || {};" >> "${CFG_JS}"
    echo "config.constraints.video.width.ideal = 1280;" >> "${CFG_JS}"
    echo "config.constraints.video.width.max = 1280;" >> "${CFG_JS}"
    echo "config.constraints.video.width.min = 320;" >> "${CFG_JS}"
    echo "config.constraints.video.frameRate = config.constraints.video.frameRate || {};" >> "${CFG_JS}"
    echo "config.constraints.video.frameRate.min = 5;" >> "${CFG_JS}"
    echo "config.constraints.video.frameRate.max = 30;" >> "${CFG_JS}"

    # Disable p2p
    echo "config.p2p = config.p2p || {};" >> "${CFG_JS}"
    echo "config.p2p.enabled = true;" >> "${CFG_JS}"

    # Stun turn
    echo "// use XEP-0215 to fetch TURN servers for the JVB connection" >> "${CFG_JS}"
    echo "config.useStunTurn = true;" >> "${CFG_JS}"
    echo "config.useTurnUdp = false;" >> "${CFG_JS}"
    echo "config.stunServers = [{ urls: 'stun:${JITSI_HOSTNAME}:3478' }];" >> "${CFG_JS}"

    # Video Quality
    echo "config.disableSimulcast = false;" >> "${CFG_JS}"
    echo "config.videoQuality = config.videoQuality || {};" >> "${CFG_JS}"
    echo "config.videoQuality.codecPreferenceOrder = [ 'VP9', 'VP8', 'H264' ];" >> "${CFG_JS}"
    echo "config.videoQuality.mobileCodecPreferenceOrder = [ 'VP8', 'VP9', 'H264' ];" >> "${CFG_JS}"
    # echo "config.videoQuality.av1 = config.videoQuality.av1 || {};" >> "${CFG_JS}"
    # echo "config.videoQuality.h264 = config.videoQuality.h264 || {};" >> "${CFG_JS}"
    # echo "config.videoQuality.vp8 = config.videoQuality.vp8 || {};" >> "${CFG_JS}"
    # echo "config.videoQuality.vp9 = config.videoQuality.vp9 || {};" >> "${CFG_JS}"
    # echo "config.videoQuality.vp9.maxBitratesVideo = config.videoQuality.vp9.maxBitratesVideo || {};" >> "${CFG_JS}"
    # echo "config.videoQuality.vp9.maxBitratesVideo.low = 100000;" >> "${CFG_JS}"
    # echo "config.videoQuality.vp9.maxBitratesVideo.standard = 300000;" >> "${CFG_JS}"
    # echo "config.videoQuality.vp9.maxBitratesVideo.high = 1200000;" >> "${CFG_JS}"
    # echo "config.videoQuality.vp9.maxBitratesVideo.ssHigh = 2500000;" >> "${CFG_JS}"
    # echo "config.videoQuality.vp9.scalabilityModeEnabled = true;" >> "${CFG_JS}"
    # echo "config.videoQuality.vp9.useSimulcast = false;" >> "${CFG_JS}"
    # echo "config.videoQuality.vp9.useKSVC = true;" >> "${CFG_JS}"

    # Screen sharing framerate
    echo "config.desktopSharingFrameRate = config.desktopSharingFrameRate || {};" >> "${CFG_JS}"
    echo "config.desktopSharingFrameRate.min = 5;" >> "${CFG_JS}"
    echo "config.desktopSharingFrameRate.max = 5;" >> "${CFG_JS}"

    # Miscellaneous
    echo "config.channelLastN = 25;" >> "${CFG_JS}"
    echo "config.enableInsecureRoomNameWarning = false;" >> "${CFG_JS}"
    echo "config.enableForcedReload = true;" >> "${CFG_JS}"
    echo "config.maxFullResolutionParticipants = 1;" >> "${CFG_JS}"

    # Working with localhost
    echo "// BOSH URL. FIXME: use XEP-0156 to discover it." >> "${CFG_JS}"
    echo "config.serviceUrl = 'https://${JITSI_HOSTNAME}/http-bind';" >> "${CFG_JS}"

    # Disable automatic feedback and speaker stats
    echo "config.feedbackPercentage = config.feedbackPercentage || {};" >> "${CFG_JS}"
    echo "config.feedbackPercentage.enabled = 0;" >> "${CFG_JS}"
    echo "config.speakerStats = config.speakerStats || {};" >> "${CFG_JS}"
    echo "config.speakerStats.disabled = true;" >> "${CFG_JS}"

    # Pre Join config
    echo "config.prejoinConfig = config.prejoinConfig || {};" >> "${CFG_JS}"
    echo "config.prejoinConfig.enabled = true;" >> "${CFG_JS}"

    # Logs
    echo "config.apiLogLevels = ['warn', 'log', 'error', 'info', 'debug'];" >> "${CFG_JS}"

    # LetsEncrypt
    # See script: https://github.com/jitsi/jitsi-meet/blob/master/resources/install-letsencrypt-cert.sh
    res_log=$(echo "${LETSENCRYPT_ACCOUNT_MAIL}" | /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh)
    res=$?
    if [ "${res}" -ne 0 ]; then
        echo "Failed to install Let's Encrypt certificate:" >> "${INSTALLATION_LOGS}"
        echo "${res_log}" >> "${INSTALLATION_LOGS}"
    fi

    (echo "${JITSI_JVB_SECRET}"; echo "${JITSI_JVB_SECRET}") | prosodyctl passwd "${JITSI_JVB_USERNAME}@auth.${JITSI_HOSTNAME}"

    JVB_NICKNAME=$(hostname)
    cat << EOF > "/etc/jitsi/videobridge/sip-communicator.properties"
org.ice4j.ice.harvest.DISABLE_AWS_HARVESTER=true
org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES=meet-jit-si-turnrelay.jitsi.net:443
org.jitsi.videobridge.ENABLE_STATISTICS=true
org.jitsi.videobridge.STATISTICS_TRANSPORT=muc
org.jitsi.videobridge.xmpp.user.shard.HOSTNAME=${JITSI_HOSTNAME}
org.jitsi.videobridge.xmpp.user.shard.DOMAIN=auth.${JITSI_HOSTNAME}
org.jitsi.videobridge.xmpp.user.shard.USERNAME=${JITSI_JVB_USERNAME}
org.jitsi.videobridge.xmpp.user.shard.PASSWORD=${JITSI_JVB_SECRET}
org.jitsi.videobridge.xmpp.user.shard.MUC_JIDS=JvbBrewery@internal.auth.${JITSI_HOSTNAME}
org.jitsi.videobridge.xmpp.user.shard.MUC_NICKNAME=${JVB_NICKNAME}

EOF

    # Add CORS headers to websocket
    perl -0777 -pi -e "s|    location = /xmpp-websocket {|    location = /xmpp-websocket {\n        add_header 'Access-Control-Allow-Origin' '*';\n        add_header 'Access-Control-Allow-Credentials' 'true';\n        add_header 'Access-Control-Allow-Methods' 'GET,HEAD,OPTIONS,POST,PUT';\n        add_header 'Access-Control-Allow-Headers' 'Access-Control-Allow-Headers, Origin, Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers, User-Agent, Keep-Alive';|g" "${CFG_NGINX}"

    # Restart services
    if ! /etc/init.d/coturn restart; then
        echo "Failed to restart coturn" >> "${INSTALLATION_LOGS}"
    fi
    if ! /etc/init.d/prosody restart; then
        echo "Failed to restart prosody" >> "${INSTALLATION_LOGS}"
    fi
    if ! /etc/init.d/jicofo restart; then
        echo "Failed to restart jicofo" >> "${INSTALLATION_LOGS}"
    fi
    if ! /etc/init.d/nginx restart; then
        echo "Failed to restart nginx" >> "${INSTALLATION_LOGS}"
    fi
    if ! /etc/init.d/jitsi-videobridge2 restart; then
        echo "Failed to restart jitsi-videobridge2" >> "${INSTALLATION_LOGS}"
    fi

    # write file to end config
    date +"%Y-%m-%dT%H:%M:%S" > "/etc/jitsi/installation/jitsi_done"

fi
