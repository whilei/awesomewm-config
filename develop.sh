#!/usr/bin/env bash

RED='\033[0;31m'
NOCOLOR='\033[0m'
#echo -e "I ${RED}love${NOCOLOR} Linux"

awmtt start -C \
    ~/dev/awesomeWM/awesome/awesomei/rc.lua \
    --display 1 \
    --size 1728x972 |& while read -r line; do
#        [[ $line =~ "error" ]] && notify-send "AwesomeWM" "$line"
        if [[ $line =~ "error" ]]; then
          echo -e "${RED}${$line}${NOCOLOR}"
        else
          echo "$line"
        fi
    done &

trap 'awmtt stop' EXIT

#    ~/dev/awesomeWM/awesome/awesomei/themes/ia \
#    ~/dev/awesomeWM/awesome/awesomei/modality \
#    ~/dev/awesomeWM/awesome/awesomei/special \
#    ~/dev/awesomeWM/awesome/awesomei/icky \
#     -e modify -e close_write -e delete -e moved_to -e moved_from -e unmount -e create \

firing=0
inotifywait --monitor --recursive \
	--exclude '\.swp' --exclude '\.idea' --exclude '\.git' --exclude '\.ia' \
    -e modify -e close_write -e delete \
    ~/dev/awesomeWM/awesome/awesomei/* \
    | \
    while read -r path; do
        echo ":: changed: $path"
        if [[ ! $path =~ lua ]]; then
            echo '    skipping (not a .lua file)'
            continue
        fi

        echo "    ... skipping $(timeout 3 cat | wc -l) further changes"

        [[ $firing -eq 1 ]] && {
            echo '    d-duping restart'
            continue
        }

        echo "----------------------------------------------------------------"
        echo ":: restarting awmtt"
        firing=$(awmtt restart)
        # could do something with the exit status?
        echo ":: restarted awmtt, code: ${firing}"
        firing=0
        echo ":: done, waiting further changes..."
    done

# while read -r path
# do
    # echo $path changed
# done

awmtt stop
# trap 'awmtt stop' EXIT
