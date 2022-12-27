#!/usr/bin/env bash

# This script is used to develop the awesomei project.
# It will watch the source files and restart the Xephyr instance (managed by `awmtt`)
# when a file changes.

# Configurations.
log_file="/tmp/awesomei.log"

RED='\033[0;31m'
LIGHT_RED='\033[1;31m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
GRAY='\033[0;37m'
NC='\033[0m'

ERROR_COLOR="${RED}"
WARNING_COLOR="${YELLOW}"

# awesome_prefix is the prefix printed before each log line from the log file.
# The tells the reader that the lines are coming from awesome,
# and not from the (this) script itself.
awesome_prefix="${LIGHT_BLUE}|${NC}"


trap 'awmtt stop' EXIT
trap 'kill $(jobs -p)' EXIT

(
  trap 'kill $(jobs -p)' EXIT

  # Start tailing the log file before firing up the Xephyr emulator
  # so that we don't miss any log messages.
  echo ":: Tailing ${log_file} eternally..."

  # Run a tail in the background.
  # Read the log lines, highlighting errors and warning in suggestive colors
  # that make it a little easier to grok traces.
  tail -F "${log_file}" |
    while read -r line; do
      if [[ ${line} =~ "error:" ]] ||
        [[ ${line} =~ "Failed" ]] ||
        [[ ${line} =~ " E: " ]]; then
        # notify-send "AwesomeWM" "$line"
        echo -e "${awesome_prefix} ${ERROR_COLOR}${line}${NC}"
      elif [[ ${line} =~ "stack trace" ]] || [[ ${line} =~ ' W: ' ]]; then
        echo -e "${awesome_prefix} ${WARNING_COLOR}${line}${NC}"
      else
        echo -e "${awesome_prefix} ${line}"
      fi
    done
) &


echo ":: Starting awesome emulator..."

time awmtt start --notest -C /home/ia/dev/awesomeWM/awesome/awesomei/rc.lua \
  --display 1 \
  --size 1728x972 >"${log_file}" 2>&1

echo ":: Starting recursive file watcher for live reload..."

inotifywait --monitor --recursive \
	--exclude '\.swp' --exclude '\.idea' --exclude '\.git' --exclude '\.ia' \
	-e modify -e close_write -e delete \
	/home/ia/dev/awesomeWM/awesome/awesomei/* |
	while read -r event_path; do
		echo -n ":: 🗉 $event_path"

		# Ignore all events that do not match a lua file indicator.
		if [[ ! $event_path =~ '.lua' ]]; then
			echo -e " ${LIGHT_RED}skipping${NC} (not a .lua file)"
			continue
		fi

		echo -e " ${GREEN}match (reload in t-3 seconds...)${NC}"

		# Debounce.
		echo -e "     ${GRAY}... skipping $(timeout 3 cat | wc -l) further changes${NC}"

		echo -e "${GREEN}----------------------------------------------------------------${NC}"
		echo -e "${GREEN}:: Firing restart...${NC}"
		time awmtt restart
		echo
		echo ":: Awaiting further changes..."
	done
