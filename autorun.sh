#!/system/bin/sh

MODDIR="/data/adb/modules/red_team"
KEY_SCRIPT="$MODDIR/keybox_auto.sh"
PID_FILE="$MODDIR/autorun.pid"
CHECK_INTERVAL=14400

check_running() {
    if [ -f "$PID_FILE" ]; then
        local old_pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
            return 0
        else
            rm -f "$PID_FILE" 2>/dev/null
            return 1
        fi
    fi
    return 1
}

do_update() {
    if [ -f "$KEY_SCRIPT" ]; then
        sh "$KEY_SCRIPT" --once > /dev/null 2>&1
    elif [ -f "/data/adb/modules/red_team/keybox_auto.sh" ]; then
        KEY_SCRIPT="/data/adb/modules/red_team/keybox_auto.sh"
        sh "$KEY_SCRIPT" --once > /dev/null 2>&1
    fi
}

check_network() {
    if command -v ping >/dev/null 2>&1; then
        ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && return 0
    fi
    if command -v curl >/dev/null 2>&1; then
        curl -s --connect-timeout 3 https://raw.githubusercontent.com >/dev/null 2>&1 && return 0
    fi
    if command -v wget >/dev/null 2>&1; then
        wget -q --spider --timeout=3 https://raw.githubusercontent.com 2>/dev/null && return 0
    fi
    return 1
}

main_loop() {
    if check_running; then
        exit 1
    fi
    
    echo $$ > "$PID_FILE"
    do_update
    
    while true; do
        if [ ! -f "$KEY_SCRIPT" ]; then
            if [ -f "/data/adb/modules/red_team/keybox_auto.sh" ]; then
                KEY_SCRIPT="/data/adb/modules/red_team/keybox_auto.sh"
            else
                rm -f "$PID_FILE"
                exit 1
            fi
        fi
        
        sleep $CHECK_INTERVAL
        
        if check_network; then
            do_update
        fi
    done
}

stop_daemon() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE" 2>/dev/null)
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill -TERM "$pid" 2>/dev/null
            sleep 1
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid" 2>/dev/null
            fi
        fi
        rm -f "$PID_FILE" 2>/dev/null
    fi
}

case "$1" in
    --stop)
        stop_daemon
        ;;
    --status)
        check_running && echo "Running" || echo "Stopped"
        ;;
    --once)
        do_update
        ;;
    --restart)
        stop_daemon
        sleep 2
        main_loop
        ;;
    *)
        main_loop
        ;;
esac
