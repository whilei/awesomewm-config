#!/usr/bin/env bash

set -e

# from should describe the original color, expected normally to be black
from="#000000"

focus="#00FCEC"
normal="#666666"

originals_dir="/home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals"
generated_dir="/home/ia/.config/awesome/themes/ia/icons/mytitlebar/generated"
mkdir -p "${generated_dir}"

#sans_ext=${filename%.*}
#ext=${filename#$sans_ext.}

for f in "${originals_dir}"/*; do
  echo "@  $f"

  # => /home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals/sticky_inactive.png

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

  echo "=> ${generated_dir}/${sans_ext}_focus.${ext}"
  convert "${f}" -fuzz 80% -fill "${focus}" -opaque "${from}" "${generated_dir}/${sans_ext}_focus.${ext}" # => /home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals/sticky_inactive_focus.png

  echo "=> ${generated_dir}/${sans_ext}_normal.${ext}"
  convert "${f}" -fuzz 80% -fill "${normal}" -opaque "${from}" "${generated_dir}/${sans_ext}_normal.${ext}" # => /home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals/sticky_inactive_normal.png
done

## SCRATCH

# convert "${f}" -fuzz 80% +level-colors "${from}","${focus}" "${generated_dir}/${sans_ext}_focus.${ext}" # => /home/ia/.config/awesome/themes/ia/icons/mytitlebar/originals/sticky_inactive_focus.png