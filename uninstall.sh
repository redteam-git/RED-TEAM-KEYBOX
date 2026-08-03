#!/system/bin/sh
if [ -f "/data/adb/modules/red_team/autorun.pid" ]; then
    kill -TERM $(cat "/data/adb/modules/red_team/autorun.pid") 2>/dev/null
    sleep 1
    kill -9 $(cat "/data/adb/modules/red_team/autorun.pid") 2>/dev/null
fi

rm -rf /data/adb/modules/red_team
rm -rf /data/adb/red_team_logs

ui_print "✅ Модуль и логи удалены"
exit 0