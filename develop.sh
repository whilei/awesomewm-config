awmtt start -C ~/dev/awesomeWM/awesome/awesomei/rc.lua \
  --display 1 \
  --size 1728x972 &

inotifywait -q -m \
  --exclude .swp --exclude .idea --exclude .git --exclude .ia \
  -e modify -e close_write -e delete -r \
  . |\
  while read -r path
  do
    echo "changed: $path"
    base=${path%.*}
    ext=${base#$base.}
    if [[ ! $ext == "lua" ]]; then
        echo 'skipping non-lua file'
        continue
    fi
    echo "skipping $(timeout 3 cat | wc -l) further changes"
    awmtt restart
  done

# awmtt restart
# awmtt stop
