#!/bin/sh

# Current Version: 1.0.0

## How to get and use?
# git clone "https://github.com/hezhijie0327/GFWList2AGH.git" && sh ./GFWList2AGH/dnsproxy.sh -d disable -e enable -v black -s full -m --all-servers -l 0.0.0.0 -r 500 -h 443 -p 53 -q 784 -t 853 -c fullchain.pem -k privkey.pem -b 223.5.5.5:53 -f 223.6.6.6:53

## Parameter
while getopts b:c:d:e:f:h:k:l:m:p:q:r:s:t:u:v: GetParameter; do
    case ${GetParameter} in
        b) BOOTSTRAP="${OPTARG:-223.5.5.5:53}";;
        c) TLSCRT="${OPTARG:-fullchain.pem}";;
        d) DEBUG="${OPTARG:-disable}";;
        e) ENCRYPT="${OPTARG:-disable}";;
        f) FALLBACK="${OPTARG:-223.6.6.6:53}";;
        h) HTTPSPORT="${OPTARG}";;
        k) TLSKEY="${OPTARG:-privkey.pem}";;
        l) LISTEN="${OPTARG:-0.0.0.0}";;
        m) MODE="${OPTARG:---all-servers}";;
        p) PORT="${OPTARG:-53}";;
        q) QUICPORT="${OPTARG}";;
        r) RATELIMIT="${OPTARG:-500}";;
        s) SIZE="${OPTARG:-full}";;
        t) TLSPORT="${OPTARG}";;
        u) UPSTEAM="${OPTARG:127.0.0.1:5353}";;
        v) VERSION="${OPTARG:-black}";;
    esac
done

## Function
# Check Environment
function CheckEnvironment() {
    if [ ! -d "/etc/dnsproxy" ]; then
        mkdir "/etc/dnsproxy"
    fi
    if [ ! -d "/etc/dnsproxy/cert" ]; then
        mkdir "/etc/dnsproxy/cert"
    fi
    if [ ! -d "/etc/dnsproxy/conf" ]; then
        mkdir "/etc/dnsproxy/conf"
    fi
    if [ ! -d "/etc/dnsproxy/work" ]; then
        mkdir "/etc/dnsproxy/work"
    fi
    if [ ! -f "/etc/dnsproxy/conf/runtime.sh" ]; then
        GenerateRuntimeScript && echo "$(($(date '+%s') + 86400))" > "/etc/dnsproxy/work/dnsproxy.exp"
    else
        if [ ! -f "/etc/aria2/work/aria2.exp" ]; then
            echo "$(date '+%s')" > "/etc/dnsproxy/work/dnsproxy.exp"
        fi
        if [ "$(cat '"/etc/dnsproxy/work/dnsproxy.exp"')" -le "$(date '+%s')" ]; then
            GenerateRuntimeScript && echo "$(($(date '+%s') + 86400))" > "/etc/dnsproxy/work/dnsproxy.exp"
        fi
    fi
}
# Generate Debug Runtime Script
function GenerateDebugRuntimeScript() {
    echo '#!/bin/sh' > /etc/dnsproxy/conf/runtime.sh
    echo "dnsproxy ${MODE} --cache --edns --refuse-any --verbose" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --listen=${LISTEN} --ratelimit=${RATELIMIT}" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --cache-max-ttl=86400 --cache-min-ttl=10 --cache-size=67108864" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --https-port=${HTTPSPORT:-0} --port=${PORT} --quic-port=${QUICPORT:-0} --tls-port=${TLSPORT:-0}" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --upstream=${UPSTEAM}" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --bootstrap=${BOOTSTRAP} --fallback=${FALLBACK}" '\' >> /etc/dnsproxy/conf/runtime.sh
}
# Generate Default Runtime Script
function GenerateDefaultRuntimeScript() {
    echo '#!/bin/sh' > /etc/dnsproxy/conf/runtime.sh
    echo "dnsproxy ${MODE} --cache --edns --refuse-any --verbose" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --listen=${LISTEN} --ratelimit=${RATELIMIT}" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --cache-max-ttl=86400 --cache-min-ttl=10 --cache-size=67108864" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --https-port=${HTTPSPORT:-0} --port=${PORT} --quic-port=${QUICPORT:-0} --tls-port=${TLSPORT:-0}" '\' >> /etc/dnsproxy/conf/runtime.sh
    wget -qO- "https://source.zhijie.online/GFWList2AGH/main/gfwlist2adguardhome_${VERSION}list_${SIZE}.txt" | sed "s/$/\ \\\/g;s/^/\ \ \ \ \-\-upstream\=/g" >> /etc/dnsproxy/conf/runtime.sh
    echo "    --bootstrap=${BOOTSTRAP} --fallback=${FALLBACK}" '\' >> /etc/dnsproxy/conf/runtime.sh
}
# Generate Encrypt Runtime Script
function GenerateEncryptRuntimeScript() {
    echo '#!/bin/sh' > /etc/dnsproxy/conf/runtime.sh
    echo "dnsproxy ${MODE} --cache --edns --refuse-any --verbose" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --listen=${LISTEN} --ratelimit=${RATELIMIT}" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --cache-max-ttl=86400 --cache-min-ttl=10 --cache-size=67108864" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --https-port=${HTTPSPORT:-443} --port=${PORT} --quic-port=${QUICPORT:-784} --tls-port=${TLSPORT:-853}" '\' >> /etc/dnsproxy/conf/runtime.sh
    echo "    --tls-crt=/etc/dnsproxy/cert/${TLSCRT} --tls-key=/etc/dnsproxy/cert/${TLSKEY}" '\' >> /etc/dnsproxy/conf/runtime.sh
    wget -qO- "https://source.zhijie.online/GFWList2AGH/main/gfwlist2adguardhome_${VERSION}list_${SIZE}.txt" | sed "s/$/\ \\\/g;s/^/\ \ \ \ \-\-upstream\=/g" >> /etc/dnsproxy/conf/runtime.sh
    echo "    --bootstrap=${BOOTSTRAP} --fallback=${FALLBACK}" '\' >> /etc/dnsproxy/conf/runtime.sh
}
# Generate Runtime Script
function GenerateRuntimeScript() {
    if [ "${DEBUG}" == "disable" ]; then
        if [ "${ENCRYPT}" == "disable" ]; then
            GenerateDefaultRuntimeScript
        elif [ "${ENCRYPT}" == "enable" ]; then
            GenerateEncryptRuntimeScript
        else
            exit 1
        fi
    elif [ "${DEBUG}" == "enable" ]; then
        GenerateDebugRuntimeScript
    else
        exit 1
    fi
}

## Process
# Call CheckEnvironment
CheckEnvironment
# Run dnsproxy
sh /etc/dnsproxy/conf/runtime.sh
