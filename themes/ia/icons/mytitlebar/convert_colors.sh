#!/usr/bin/env bash

set -e
set -x

# from="#F1C232"
# to="#00FCEC"

from="#00FCEC"
to="#DDDDDD"

target="${1}"
[[ -z $target ]] && { echo "Missing <target:1>" && exit 1; }

target_basename="$(basename ${target})"

mkdir -p converted
convert "$1" -fuzz 90% +level-colors "${from}","${to}" "converted/${target_basename}"


