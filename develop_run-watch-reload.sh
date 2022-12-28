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

# awesome_prefix is the prefix printed before each log line from the log file.
# The tells the reader that the lines are coming from awesome,
# and not from the (this) script itself.
awesome_prefix="${LIGHT_BLUE}|${NC}"

# ------------------------------------------------------------------------------

# When this script exits I want all child procs to exit too.
# https://stackoverflow.com/a/2173421/4401322
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# ------------------------------------------------------------------------------

# Start tailing the log file before firing up the Xephyr emulator
# so that we don't miss any log messages.
echo ":: Tailing ${log_file} in background..."

# Run a piped tail in the background.
# Read the log lines, highlighting errors and warning in suggestive colors
# that make it a little easier to grok traces.
(
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
tail_pid=$!
echo ":: Tail subshell PID: ${tail_pid}"

# ------------------------------------------------------------------------------

echo ":: Starting awesome emulator..."

size_width=$((1920 - 4))
size_height=$((1080 - 4 - 32))

time awmtt start --notest -C /home/ia/dev/awesomeWM/awesome/awesomei/rc.lua \
  --display 1 \
  --size ${size_width}x${size_height} >"${log_file}" 2>&1

trap 'awmtt stop' SIGINT SIGTERM EXIT

# ------------------------------------------------------------------------------

# Plan to show me the running 'awesome' procs when I exit
# so I can confirm that only my actual current awesome session is running.
cmd_show_awesome_procs='echo :: Remaining awesome procs:;'
cmd_show_awesome_procs+='ps aux | grep -v grep | grep -i -e VSZ -e awesome'
trap "${cmd_show_awesome_procs}" EXIT

echo ":: Starting recursive file watcher for live reload..."

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
		echo ":: Awaiting further changes..."
	done
