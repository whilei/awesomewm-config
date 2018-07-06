amixer scontrols | grep -oE "'.*'" | awk -F\' \
 '{print "amixer -c 0 set \""$2"\" unmute 100"}' | sh

# amixer -c 0 set Master 70%
# amixer -c 0 set PCM 100%
