awmtt start -C ~/dev/awesomeWM/awesome/awesomei/rc.lua \
  --display 1 \
  --size 1728x972 &

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
    awmtt restart
  done

# awmtt restart
# awmtt stop
