# This oneiner does the following:
# * takes UUIDs from the 'batch' file
# * in parallel runs the update logic on them, with parallelism defined by the '-P' setting
#   Connect to the device with balena ssh in non-interctive mode (so that connection fails if the UUID is not accessible),
#   pipe in the task script, and save the log with the UUID prepended
cat batch | stdbuf -oL xargs -I{} -P 30 /bin/sh -c "grep -a -q '{} : DONE' udev-rules.log || (cat add-udev-rule.sh | balena ssh {} | sed 's/^/{} : /' | tee --append udev-rules.log)"
