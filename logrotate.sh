#!/bin/bash
LOG_FILE="/telegram_bot2/cron.log"
MAX_SIZE=$((10240 * 1024)) # 10MB
MAX_FILES=3

# Check if the log file exceeds the maximum size
if [ $(stat -c%s "$LOG_FILE") -ge $MAX_SIZE ]; then
    # Save the current log file with a new name
    mv $LOG_FILE $LOG_FILE.$(date +%Y%m%d)

    # Create a new log file
    touch $LOG_FILE
fi

# Find and delete old log files (more than 3 generations old)
find $(dirname $LOG_FILE) -name "$(basename $LOG_FILE).*" -type f -mtime +$MAX_FILES -delete
