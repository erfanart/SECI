#!/bin/bash

# فایل لاگ قابل تنظیم
LOG_FILE="${LOG_FILE:-/dev/null}"

# رنگ‌ها
NC='\033[0m'          # بدون رنگ
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'

# تابع لاگ
log() {
    local LEVEL=$1
    shift
    local MESSAGE="$*"
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # انتخاب رنگ
    local COLOR=$NC
    case "$LEVEL" in
        INFO) COLOR=$GREEN ;;
        WARN|WARNING) COLOR=$YELLOW ;;
        ERROR) COLOR=$RED ;;
        DEBUG) COLOR=$BLUE ;;
        *) COLOR=$GRAY ;;
    esac

    # ساخت خط لاگ
    local LOG_LINE="[$TIMESTAMP] [$LEVEL] $MESSAGE"

    # چاپ در ترمینال با رنگ
    echo -e "${COLOR}${LOG_LINE}${NC}"

    # ذخیره در فایل بدون رنگ
    echo "$LOG_LINE" >> "$LOG_FILE"
}
