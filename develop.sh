#!/usr/bin/env bash

trap 'awmtt stop' EXIT
trap 'kill $(jobs -p)' EXIT

awmtt start -C ~/dev/awesomeWM/awesome/awesomei/rc.lua \
  --display 1 \
  --size 1728x972 &

firing=-1
inotifywait --quiet --monitor --recursive \
  --exclude .swp --exclude .idea --exclude .git --exclude .ia \
  -e modify -e close_write -e delete \
  ~/dev/awesomeWM/awesome/awesomei |\
  while read -r path
  do
    echo ":: changed: $path"
    if [[ ! $path =~ lua ]]; then
        echo '    skipping (not a .lua file)'
        continue
    fi

    echo "    ... skipping $(timeout 3 cat | wc -l) further changes"

    [[ $firing -ge 0 ]] && { echo '  d-duping restart'; continue ; }

    echo "----------------------------------------------------------------"
    echo ":: restarting awmtt"
    firing=$(awmtt restart)
    # could do something with the exit status?
    echo ":: restarted awmtt, code: ${firing}"
    firing=-1
    echo ":: done, waiting further changes..."
  done

