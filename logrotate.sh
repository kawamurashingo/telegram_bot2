#!/bin/bash
LOG_FILE="/telegram_bot2/cron.log"
MAX_SIZE=$((10240 * 1024)) # 10MB
MAX_FILES=3

# ログファイルが最大サイズを超えているかチェック
if [ $(stat -c%s "$LOG_FILE") -ge $MAX_SIZE ]; then
    # 現在のログファイルを新しい名前で保存
    mv $LOG_FILE $LOG_FILE.$(date +%Y%m%d)

    # 新しいログファイルを作成
    touch $LOG_FILE
fi

# 古いログファイルを探して削除（3世代以上のもの）
find $(dirname $LOG_FILE) -name "$(basename $LOG_FILE).*" -type f -mtime +$MAX_FILES -delete
