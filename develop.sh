awmtt start -C ~/.config/awesome/rc.lua \
  --display 1 \
  --size 1728x972 &

inotifywait -q -m \
  --exclude .swp --exclude .idea --exclude .git --exclude .ia \
  -e modify -e close_write -e delete -r \
  . |\
  while read -r path
  do
    echo "changed: $path"
    echo "skipping $(timeout 3 cat | wc -l) further changes"
    awmtt restart 
  done

# awmtt restart
# awmtt stop
