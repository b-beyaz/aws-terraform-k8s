#!/bin/bash
URL="$1"
while true; do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 "$URL")
  echo "$(date +%H:%M:%S) $code"
  sleep 0.2
done