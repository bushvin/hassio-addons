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
restic_cacert=$(bashio::config restic_cacert)
if test "${restic_cacert}" != "" -a -f "${restic_cacert}"; then
    restic_cacert="--cacert=${restic_cacert}"
else
    restic_cacert=""
fi

if test "$(bashio::config restic_insecure_tls)" == "true"; then
    restic_insecure_tls="--insecure-tls"
else
    restic_insecure_tls=""
fi

set +e
cat <<EOF> /tmp/pre
$(bashio::config pre_commands)
EOF
bash -x /tmp/pre
RC=$?
set -e
if test $RC -ne 0; then
    echo "pre commands execution failed"
    exit $RC
fi

for b in addons backup config media share ssl; do
    enable_backup=$(bashio::config ${b}.enable_backup)
    enable_forget=$(bashio::config ${b}.enable_forget)
    if test ${enable_backup,,} == "true"; then
      restic_tags=$(jq -r ".${b}.tags|to_entries[]|\"--tag \" + (.value|tostring) + \"\"" $OPTIONS)
      cat <<EOF>/tmp/exclude.$b
$(jq -r ".${b}.exclude|to_entries[]|(.value|tostring)" $OPTIONS)
EOF
      set -x
      restic version
      restic cache --cleanup
      restic backup --verbose \
          $restic_cacert \
          $restic_insecure_tls \
          --host=$restic_hostname \
          $restic_tags \
          --cleanup-cache \
          --exclude-file=/tmp/exclude.$b \
          /${b}
      set +x

      if test ${enable_forget,,} == "true"; then
          keep_daily=$(bashio::config ${b}.keep_daily 0)
          keep_weekly=$(bashio::config ${b}.keep_weekly 0)
          keep_monthly=$(bashio::config ${b}.keep_monthly 0)
          keep_yearly=$(bashio::config ${b}.keep_yearly 0)
          set -x
          restic forget --verbose \
              $restic_cacert \
              $restic_insecure_tls \
              --host=$restic_hostname \
              $restic_tags \
              --keep-daily $keep_daily \
              --keep-weekly $keep_weekly \
              --keep-monthly $keep_monthly \
              --keep-yearly $keep_yearly
          set +x
          if test "$(bashio::config restic_repack_uncompressed)" == "true" && test $(restic $restic_cacert $restic_insecure_tls cat config | jq -r .version) -ge 2; then
              restic_repack_uncompressed="--repack-uncompressed"
          fi
          set -x
          restic prune --verbose \
              $restic_cacert \
              $restic_insecure_tls \
              ${restic_repack_uncompressed:-}
          set +x
      fi
    else
        echo "Skipping backup of /$b"
    fi
done

set +e
cat <<EOF> /tmp/post
$(bashio::config post_commands)
EOF
bash -x /tmp/post
RC=$?
set -e
if test $RC -ne 0; then
    echo "post commands execution failed"
    exit $RC
fi

echo "Restic Backup finished"
date

