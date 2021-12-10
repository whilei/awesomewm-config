#!/usr/bin/env bash

CATFILE=/tmp/cats.json
AWESOMEFILE=/home/ia/.config/awesome/themes/ia/data.txt

echo "Cats loading..." > "$AWESOMEFILE"

if /usr/bin/curl -s https://api.catonmap.info/lastknown > "$CATFILE"; then
  echo "Rye8:" > "$AWESOMEFILE"
else
  exit 1
fi

logged=$(cat "$CATFILE" | /home/ia/go/bin/jj -p 'Rye8.time')
if [[ -z $logged ]]; then echo "error" >> "$AWESOMEFILE"; fi
d=$(date --date="${logged}" +%s)
ds="$(date +%s)"
diff=$((ds - d))
# echo "d: $d, $((diff)) seconds"
hours=$((diff / 3600))
minutes=$(((diff % 3600) / 60))
seconds=$((diff % 60))
[[ $hours -gt 0 ]] && \
  echo "${hours}h${minutes}m${seconds}s" >> "$AWESOMEFILE" || \
  echo "${minutes}m${seconds}s" >> "$AWESOMEFILE"

cat "$CATFILE" | /home/ia/go/bin/jj -p 'Rye8.notes' | /home/ia/go/bin/jj -p 'activity' >> "$AWESOMEFILE"
echo >> "$AWESOMEFILE"

cat "$CATFILE" | /home/ia/go/bin/jj -p 'Rye8.notes' | /home/ia/go/bin/jj -p 'batteryStatus' | /home/ia/go/bin/jj -p 'level' |\
  cut -c 1-4 >> "$AWESOMEFILE"




