#!/bin/bash

# مسیر فایل لاگ
LOG_FILE="/dev/null"

# تابع لاگ‌گیری
log() {
    local LEVEL=$1      # سطح لاگ: INFO, WARN, ERROR, DEBUG
    shift
    local MESSAGE="$*"
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] [$LEVEL] $MESSAGE" >> "$LOG_FILE"
}

# مثال‌ها:
# log "INFO" "شروع اسکریپت"
# log "ERROR" "فایل ورودی پیدا نشد: $filename"
# log "DEBUG" "متغیر X مقدارش هست: $x"
