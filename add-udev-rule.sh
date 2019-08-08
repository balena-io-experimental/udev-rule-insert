#!/bin/bash

set -o errexit -o pipefail

# Don't run anything before this source as it sets PATH here
# shellcheck disable=SC1091
source /etc/profile

# Edit this to add your udev rule:
# `jq -sR . < rulefilename` and replace the outside the outside double quotes " with single quotes '
RULE=''

# Finish up the script
# If message passed as an argument, that means failure.
finish_up() {
  local message=$1
  if [ -n "${message}" ]; then
    echo "FAIL: ${message}"
    exit 1
  else
    echo "DONE"
    exit 0
  fi
}

if [ -z "$RULE" ]; then
  finish_up "No RULE set to be inserted"
fi

BASEFILE="/mnt/boot/config.json"
NEWFILE="$BASEFILE.new"

main() {
  jq  ".os.udevRules.\"70\" = \"$RULE\"" "$BASEFILE" > "$NEWFILE"
  if [ "$(jq -e ".os.udevRules.\"70\"" "$NEWFILE")" != "" ] ; then
    systemctl stop resin-supervisor || true
    mv "$NEWFILE" "$BASEFILE"
    systemctl restart resin-supervisor || finish_up "Supervisor did not restart successfully."
    echo "Restarting os-udevrules service if exists."
    if systemctl is-active --quiet os-udevrules ; then
       # Only run this if there's a relevant service
       systemctl restart os-udevrules || finish_up "udev rules service did not restart successfully."
    fi
  else
    finish_up "udev rule not found in transitory file $BASEFILE"
  fi
}

main
finish_up
