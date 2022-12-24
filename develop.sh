awmtt start -C ~/dev/awesomeWM/awesome/awesomei/rc.lua \
  --display 1 \
  --size 1728x972 &

firing=-1
inotifywait --quiet --monitor --recursive \
  --exclude .swp --exclude .idea --exclude .git --exclude .ia \
  -e modify -e close_write -e delete \
  . |\
  while read -r path
  do
    echo "changed: $path"
    if [[ ! $path =~ lua ]]; then
        echo 'skipping non-lua file'
        continue
    fi
    echo "skipping $(timeout 3 cat | wc -l) further changes"
    [[ $firing -ge 0 ]] && { echo 'd-duping restart'; continue ; }
    firing=$(awmtt restart)
    # could do something with the exit status?
    firing=-1
    echo "done, waiting further changes..."
  done

# awmtt restart
# awmtt stop
