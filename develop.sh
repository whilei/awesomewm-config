#!/usr/bin/env bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
NC='\033[0m'

(
  log_file="/tmp/awesomei.log"
  echo ":: Log file: $log_file"

  echo ":: Starting awesome emulator..."
  time awmtt start -C \
      ~/dev/awesomeWM/awesome/awesomei/rc.lua \
      --display 1 \
      --size 1728x972 > "${log_file}" 2>&1

  echo ":: Tailing log file eternally..."
  apre="${LIGHT_BLUE}|${NC}"
  tail -F "${log_file}" | while read -r line; do
      if [[ ${line} =~ "error:" ]] ||
      [[ ${line} =~ "Failed" ]] ||
      [[ ${line} =~ " E: " ]]; then
        # notify-send "AwesomeWM" "$line"
        echo -e "${apre} ${RED}${line}${NC}"
      elif [[ ${line} =~ "stack trace" ]] || [[ ${line} =~ ' W: ' ]]; then
        echo -e "${apre} ${YELLOW}${line}${NC}"
      else
        echo -e "${apre} ${line}"
      fi
  done
) &

trap 'awmtt stop' EXIT

echo ":: Starting recursive file watcher for live reload..."

firing=0
inotifywait --monitor --recursive \
	--exclude '\.swp' --exclude '\.idea' --exclude '\.git' --exclude '\.ia' \
    -e modify -e close_write -e delete \
    ~/dev/awesomeWM/awesome/awesomei/* \
    | \
    while read -r event_path; do
        echo ":: 🗉 $event_path"
        if [[ ! $event_path =~ '.lua' ]]; then
            echo '     skipping (not a .lua file)'
            continue
        fi

        # Debounce.
        echo "     ... skipping $(timeout 3 cat | wc -l) further changes"

        # Dedupe.
        [[ $firing -eq 1 ]] && {
            echo '     skipping (d-duping restart)'
            continue
        }

        echo -e "${GREEN}----------------------------------------------------------------${NC}"
        firing=1
        echo ":: Firing restart..."
        time awmtt restart
        echo
        firing=0
        echo ":: Awaiting further changes..."
    done

