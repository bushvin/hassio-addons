#!/usr/bin/with-contenv bashio

echo "Running restic backup"
date
set -e

mkdir -p /data/restic-cache
OPTIONS=/data/options.json
$(jq -r ".restic_envvar|to_entries[]|\"export \" + .key + \"=\" + (.value|tostring) + \"\"" $OPTIONS)

# These should never be overridden by environment vars
export RESTIC_REPOSITORY=$(bashio::config restic_repository)
export RESTIC_PASSWORD=$(bashio::config restic_password)
export RESTIC_CACHE_DIR=/data/restic-cache
export TMPDIR=/tmp
restic_hostname=$(bashio::config restic_hostname hassio)

for b in addons backup config media share ssl; do
    enable_backup=$(bashio::config ${b}.enable_backup)
    enable_forget=$(bashio::config ${b}.enable_forget)
    if test ${enable_backup,,} == "true"; then
      restic_tags=$(jq -r ".${b}.tags|to_entries[]|\"--tag \" + (.value|tostring) + \"\"" $OPTIONS)
      cat <<EOF>/tmp/exclude.$b
$(jq -r ".${b}.exclude|to_entries[]|(.value|tostring)" $OPTIONS)
EOF
      echo restic backup --verbose \
          --host=$restic_hostname \
          $tags \
          --cleanup-cache \
          --exclude-file=/tmp/exclude.$b \
          /${b}

      if test ${enable_forget,,} == "true"; then
          keep_daily=$(bashio::config ${b}.keep_daily 0)
          keep_weekly=$(bashio::config ${b}.keep_weekly 0)
          keep_monthly=$(bashio::config ${b}.keep_monthly 0)
          keep_yearly=$(bashio::config ${b}.keep_yearly 0)
          echo restic forget --verbose \
              --host=$restic_hostname \
              $tags \
              --keep-daily $keep_daily \
              --keep-weekly $keep_weekly \
              --keep-monthly $keep_monthly \
              --keep-yearly $keep_yearly \
              --prune
      fi
    fi
done

echo "Restic Backup finished"
date

