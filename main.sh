#!/bin/bash
# telegram bot id
export BOT_ID="XXXX:XXXX"

# Today
sh /telegram_bot2/Today/telegram.sh

# Nextday
sleep 60
sh /telegram_bot2/Nextday/telegram.sh 
