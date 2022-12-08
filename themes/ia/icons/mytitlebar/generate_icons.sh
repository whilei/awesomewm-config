#!/usr/bin/env bash

set -e

# from should describe the original color, expected normally to be black
from="#000000"

# 'inactive' vs. 'active' are/can be different icons
# 'focus' vs. 'normal' are color-only; they are same icons, different colors
inactive_normal="#555555"
active_normal="white"
inactive_focus="white"
active_focus="#00FCEC"
#
# teal (same as taglist active color) #00FCEC

originals_dir="/home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals"
generated_dir="/home/ia/.config/awesome/themes/ia/icons/mytitlebar/generated"
mkdir -p "${generated_dir}"

#sans_ext=${filename%.*}
#ext=${filename#$sans_ext.}

for f in "${originals_dir}"/*; do
  echo "@  $f"
  #  => @  /home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals/sticky_inactive.png

  filename="$(basename ${f})"
  # => sticky_inactive.png

  sans_ext=${filename%.*}
  # => sticky_inactive

  ext=${filename#$sans_ext.}
  # => png

  # The actual color conversion step.
  #
  # magick cow.gif -fuzz 40%  -fill red -opaque black  cow_replace_fuzz.gif
  # > https://www.imagemagick.org/Usage/color_basics/#opaque

  target_color="${active_focus}"
  if grep -q inactive <<< "${sans_ext}"
  then
    target_color="${inactive_focus}"
  fi

  echo "=> ${generated_dir}/${sans_ext}_focus.${ext}"
  convert "${f}" -fuzz 80% -fill "${target_color}" -opaque "${from}" "${generated_dir}/${sans_ext}_focus.${ext}" # => /home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals/sticky_inactive_focus.png

    target_color="${active_normal}"
    if grep -q inactive <<< "${sans_ext}"
    then
      target_color="${inactive_normal}"
    fi

  echo "=> ${generated_dir}/${sans_ext}_normal.${ext}"
  convert "${f}" -fuzz 80% -fill "${target_color}" -opaque "${from}" "${generated_dir}/${sans_ext}_normal.${ext}" # => /home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals/sticky_inactive_normal.png
done

## SCRATCH

# convert "${f}" -fuzz 80% +level-colors "${from}","${focus}" "${generated_dir}/${sans_ext}_focus.${ext}" # => /home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals/sticky_inactive_focus.png