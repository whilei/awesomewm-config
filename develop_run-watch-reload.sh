#!/usr/bin/env bash

# This script is used to develop the awesomei project.
# It will watch the source files and restart the Xephyr instance (managed by `awmtt`)
# when a file changes.

# ------------------------------------------------------------------------------

# Configuration.
log_file="/tmp/awesomei.log"

# Other configurable vars hardcoded below are
# - `awmtt` config file path (/home/ia/dev/awesomeWM/awesome/awesomei/rc.lua)
#   + The default config file path is `~/.config/awesome/rc.lua`.
# - path(s) for inotifywait to watch for changes (/home/ia/dev/awesomeWM/awesome/awesomei/*)

# ------------------------------------------------------------------------------

RED='\033[0;31m'
LIGHT_RED='\033[1;31m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
GREEN='\033[0;32m'
GRAY='\033[0;37m'
NC='\033[0m'

ERROR_COLOR="${RED}"
WARNING_COLOR="${YELLOW}"

# S_LOG_PREFIX is this script's log prefix.
S_LOG_PREFIX=':: '

# AWESOME_LOG_PREFIX is the prefix printed before each log LINE from the log file.
# The tells the reader that the lines are coming from awesome,
# and not from the (this) script itself.
AWESOME_LOG_PREFIX="${LIGHT_BLUE}|${NC} "

# ------------------------------------------------------------------------------

# When this script exits I want all child procs to exit too.
# https://stackoverflow.com/a/2173421/4401322
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# ------------------------------------------------------------------------------

# Start tailing the log file before firing up the Xephyr emulator
# so that we don't miss any log messages.
echo "${S_LOG_PREFIX}Tailing ${log_file} in background..."

# Run a piped tail in the background.
# Read the log lines, highlighting errors and warning in suggestive colors
# that make it a little easier to grok traces.
(
  tail -F "${log_file}" |
    while read -r LINE; do
      if [[ ${LINE} =~ ' E: ' ]] ||
        [[ ${LINE} =~ 'error:' ]] ||
        [[ ${LINE} =~ 'Failed' ]]
        then
        # notify-send "AwesomeWM" "$LINE"
        echo -e "${AWESOME_LOG_PREFIX}${ERROR_COLOR}${LINE}${NC}"
      elif [[ ${LINE} =~ ' W: ' ]] || [[ ${LINE} =~ 'stack trace' ]]; then
        echo -e "${AWESOME_LOG_PREFIX}${WARNING_COLOR}${LINE}${NC}"
      else
        echo -e "${AWESOME_LOG_PREFIX}${LINE}"
      fi
    done
) &
TAIL_PID=$!
echo "${S_LOG_PREFIX}Tail subshell PID: ${TAIL_PID}"

# ------------------------------------------------------------------------------

echo "${S_LOG_PREFIX}Starting awesome emulator..."

SIZE_HEIGHT=$((1920 - 4))
SIZE_WIDTH=$((1080 - 4 - 32))

time awmtt start --notest -C /home/ia/dev/awesomeWM/awesome/awesomei/rc.lua \
  --display 1 \
  --size ${SIZE_HEIGHT}x${SIZE_WIDTH} >"${log_file}" 2>&1

trap 'awmtt stop' SIGINT SIGTERM EXIT

# ------------------------------------------------------------------------------

# Plan to show me the running 'awesome' procs when I exit
# so I can confirm that only my actual current awesome session is running.
CMD_SHOW_AWESOME_PROCS='echo :: Remaining awesome procs:;'
CMD_SHOW_AWESOME_PROCS+='ps aux | grep -v grep | grep -i -e VSZ -e awesome'
trap "${CMD_SHOW_AWESOME_PROCS}" EXIT

echo "${S_LOG_PREFIX}Starting recursive file watcher for live reload..."

inotifywait --monitor --recursive \
	--exclude '\.swp' --exclude '\.idea' --exclude '\.git' --exclude '\.ia' \
	-e modify -e close_write -e delete \
	/home/ia/dev/awesomeWM/awesome/awesomei/* |
	while read -r event_path; do
		# Ignore all events that do not match a lua file indicator.
	  if [[ ! $event_path =~ '.lua' ]]; then
        echo -e "${LIGHT_RED}:: x${NC} '$event_path' skipping (not a .lua file)"
        continue
    else
        echo -e "${GREEN}:: ✓${NC} '$event_path' ${GREEN}match (reload in t-3 seconds...)${NC}"
    fi

		# Debounce.
		echo -e "      ${GRAY}... skipping $(timeout 3 cat | wc -l) further changes${NC}"

		echo -e "${GREEN}:: ----------------------------------------------------------------${NC}"
		echo -e "${GREEN}:: Firing restart...${NC}"
		time awmtt restart
		echo
		echo "${S_LOG_PREFIX}Awaiting further changes..."
	done
