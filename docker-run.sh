#!/bin/bash
# SIGTERM-handler
term_handler() {
  for PID in "${PIDS[@]}"
  do
    [[ -n "$PID" ]] && kill "$PID"
  done

  exit 0
}

trap 'term_handler' INT QUIT TERM

set -e

# Run all the scripts in the docker-run.d directory. If a script stopping should stop the container then
# the script should export its PID in the PID variable, otherwise it should not export the variable.
PIDS=()
if /usr/bin/find "/docker-run.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
  echo >&3 "$0: /docker-run.d/ is not empty, will attempt to bring up services"

  echo >&3 "$0: Looking for shell scripts in /docker-run.d/"
  for f in $(ls /docker-run.d/* | sort -n)
  do
    case "$f" in
      *.sh)
        if [ -x "$f" ]; then
          echo >&3 "$0: Launching $f";
          unset PID
          source $f
          PIDS+=( "${PID}" )
        else
          # warn on shell scripts without exec bit
          echo >&3 "$0: Ignoring $f, not executable";
        fi
        ;;
      *) echo >&3 "$0: Ignoring $f";;
    esac
  done


  echo >&3 "$0: Start up complete, all services are now running."
else
  echo >&3 "$0: No files found in /docker-run.d/, nothing to do, will run forever!"
  while :
  do
    sleep 1
  done
fi

# Run indefinately until one of the running processes stops
ALL_RUNNING="true"
while [[ "$ALL_RUNNING" == "true" ]]; do
  sleep 1
  for PID in "${PIDS[@]}"
  do
    if [[ ! -e /proc/$PID ]]; then
      ALL_RUNNING="false"
      echo "One of the processes shutdown: ${PID}"
    fi
  done
done

# Stop container properly
term_handler
