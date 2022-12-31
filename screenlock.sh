#!/usr/bin/env bash

# https://github.com/alfunx/.dotfiles/blob/master/.bin/lock

# pictures_dir="$(xdg-user-dir PICTURES 2>/dev/null)"
# slice="${pictures_dir:-$HOME/Pictures}/slice.png"

# image=$(mktemp --tmpdir --suffix=.png lock.XXXXXXXXXX)
# trap 'rm -f "$image"' SIGINT SIGTERM EXIT

# screens=$(xrandr | grep -Eo '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+')
# declare -a lines

# slice height
# S=160

# line position (from center)
P=0

# for screen in $screens; do
	# read -r W H X Y < <(sed 's/[^0-9]/ /g' <<<"$screen")
	# lines+=(\( "$slice"
		# -resize "${W}x${S}!"
		# -geometry "+${X}+$((Y + H / 2 - P - S / 2))" \)
		# -composite -matte)
# done

# maim -u -m 1 |
	# convert png:- -scale 10% -scale 1000% \
		# -fill "#282828" -colorize 10% \
		# ${lines[*]} "$image"

# set -x
# set -e

# scrot --quality 10 /tmp/lock_screenshot.png
# cp /tmp/lock_screenshot.png /tmp/lock_screenshot_blur.png
# convert /tmp/lock_screenshot.png -blur 0x5 /tmp/lock_screenshot_blur.png

# base_color="282828"
base_color="000000"
base_color_tr="${base_color}FF"
time_date_color=51B41F
verif_color=373737FF
wrong_color=8A2537FF
ring_ver_color="${verif_color}"
ring_wrong_color="${wrong_color}"
line_color=FFFFFFFF
bshl_color=FFFFFFFF

i3lock-color \
	--color=${base_color} \
	--inside-color=${base_color} \
	--insidever-color=${verif_color} \
	--insidewrong-color=${base_color_tr} \
	--ring-color=${base_color_tr} \
	--ringver-color=${ring_ver_color} \
	--ringwrong-color=${ring_wrong_color} \
	--separator-color=${base_color_tr} \
	--line-color=${line_color} \
	--keyhl-color=${line_color} \
	--bshl-color=${bshl_color} \
	--ring-width=4 \
	--radius=32 \
	--ind-pos="x+w/2:y+h/2-$P" \
	--time-color=${time_date_color}FF \
	--time-pos='x+w/2+36:y+h-h/4' \
	--time-str='%_H:%M' \
	--time-font='monospace' \
	--time-align=2 \
	--time-size=32 \
	--date-color=${time_date_color}00 \
	--date-pos='ix+180:iy+12' \
	--date-pos='ix+r+50:iy+12' \
  --date-str='%Y %B %d (%A)' \
	--date-font='monospace' \
	--date-align=1 \
	--date-size=32 \
	--greeter-text='' \
	--greeter-pos='x+100:iy+12' \
	--greeter-color=FFFFFFFF \
	--verif-text='ok' \
	--verif-color=${verif_color} \
	--wrong-color=${wrong_color} \
	--wrong-text='Passphrase incorrect' \
  --wrong-pos='ix+r-48:iy+r+50' \
	--modif-color=00000000 \
	--layout-color=00000000 \
	--noinput-text='no input' \
	--lock-text='Locked' \
	--lockfailed-text='' \
	--ignore-empty-password \
	--pass-media-keys \
	--pass-screen-keys \
	--indicator \
	--clock

# --special-passthrough

# i3lock-color \
	# --color=${base_color} \
	# --inside-color=${base_color} \
	# --insidever-color=${verif_color} \
	# --insidewrong-color=${base_color_tr} \
	# --ring-color=${base_color_tr} \
	# --ringver-color=${ring_ver_color} \
	# --ringwrong-color=${ring_wrong_color} \
	# --separator-color=${base_color_tr} \
	# --line-color=${line_color} \
	# --keyhl-color=${line_color} \
	# --bshl-color=${bshl_color} \
	# --ring-width=4 \
	# --radius=32 \
	# --ind-pos="x+w/2:y+h/2-$P" \
	# --time-color=${time_date_color}FF \
	# --time-pos='ix-180:iy+12' \
	# --time-pos='ix-r-50:iy+12' \
	# --time-str='%H:%M:%S' \
	# --time-font='monospace' \
	# --time-align=2 \
	# --time-size=32 \
	# --date-color=${time_date_color}00 \
	# --date-pos='ix+180:iy+12' \
	# --date-pos='ix+r+50:iy+12' \
  # --date-str='%Y %B %d (%A)' \
	# --date-font='monospace' \
	# --date-align=1 \
	# --date-size=32 \
	# --greeter-pos='x+100:iy+12' \
	# --verif-color=${verif_color} \
	# --wrong-color=${wrong_color} \
	# --modif-color=00000000 \
	# --layout-color=00000000 \
	# --greeter-color=FFFFFFFF \
	# --verif-text='ok' \
	# --wrong-text='bad' \
	# --noinput-text='no input' \
	# --lock-text='Locked' \
	# --lockfailed-text='' \
	# --greeter-text='' \
	# --ignore-empty-password \
	# --pass-media-keys \
	# --pass-screen-keys \
	# --indicator \
	# --clock


# i3lock-color \
  # --image=/tmp/screenshot.png \
	# --color=${base_color} \
	# --inside-color=${base_color} \
	# --insidever-color=${verif_color} \
	# --insidewrong-color=${base_color_tr} \
	# --ring-color=${base_color_tr} \
	# --ringver-color=${ring_ver_color} \
	# --ringwrong-color=${ring_wrong_color} \
	# --separator-color=${base_color_tr} \
	# --line-color=${line_color} \
	# --keyhl-color=${line_color} \
	# --bshl-color=${bshl_color} \
	# --ring-width=4 \
	# --radius=32 \
	# --ind-pos="x+w/2:y+h/2-$P" \
	# --time-color=${time_date_color}FF \
	# --time-pos='ix-180:iy+12' \
	# --time-pos='ix-r-50:iy+12' \
	# --time-str='%H:%M:%S' \
	# --time-font='monospace' \
	# --time-align=2 \
	# --time-size=32 \
	# --date-color=${time_date_color}00 \
	# --date-pos='ix+180:iy+12' \
	# --date-pos='ix+r+50:iy+12' \
  # --date-str='%Y %B %d (%A)' \
	# --date-font='monospace' \
	# --date-align=1 \
	# --date-size=32 \
	# --greeter-pos='x+100:iy+12' \
	# --verif-color=${verif_color} \
	# --wrong-color=${wrong_color} \
	# --modif-color=00000000 \
	# --layout-color=00000000 \
	# --greeter-color=FFFFFFFF \
	# --verif-text='ok' \
	# --wrong-text='bad' \
	# --noinput-text='no input' \
	# --lock-text='Locked' \
	# --lockfailed-text='' \
	# --greeter-text='' \
	# --ignore-empty-password \
	# --pass-media-keys \
	# --pass-screen-keys \
	# --indicator \
	# --clock
