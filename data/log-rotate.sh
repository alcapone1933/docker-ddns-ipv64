#!/bin/bash

LOG_FILE="/data/log/cron.log"
MAX_FILES=${MAX_FILES:-10}
MAX_LINES=${MAX_LINES:-1000}
LINE_COUNT=$(wc -l < "$LOG_FILE")

if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
  for (( i=$MAX_FILES; i>=1; i-- )); do
    if [ -e "$LOG_FILE.$i" ]; then
      next=$((i+1))
      mv "$LOG_FILE.$i" "$LOG_FILE.$next"
    fi
  done

  if [ -e "$LOG_FILE" ]; then
    cp -a "$LOG_FILE" "$LOG_FILE.1.tmp"
    cat /dev/null > "$LOG_FILE"
    mv "$LOG_FILE.1.tmp" "$LOG_FILE.1"
  fi

  if [ -e "$LOG_FILE.$((MAX_FILES+1))" ]; then
    rm "$LOG_FILE.$((MAX_FILES+1))"
  fi
fi
