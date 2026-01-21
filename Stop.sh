#!/bin/bash
set -euo pipefail

POD="IS_BPM"
STOP_TIMEOUT=300     # grace period for podman stop
VERIFY_TIMEOUT=320   # wait slightly longer than stop timeout

log() {
  echo "[$(date '+%F %T')] [$(hostname)] $*"
}

is_running() {
  # Check exact container name (no substring issues)
  podman ps --format "{{.Names}}" | grep -wq "$POD"
}

wait_until_stopped() {
  for i in $(seq 1 "$VERIFY_TIMEOUT"); do
    if ! is_running; then
      return 0
    fi
    sleep 1
  done
  return 1
}

STOP() {
  log "Requested STOP for $POD"

  if is_running; then
    log "$POD is running. Issuing podman stop (timeout=${STOP_TIMEOUT}s)..."
    podman stop --time="$STOP_TIMEOUT" "$POD" || true

    log "Waiting for $POD to stop..."
    if wait_until_stopped; then
      log "SUCCESS: $POD is fully stopped"
      exit 0
    else
      log "ERROR: $POD still running after ${VERIFY_TIMEOUT}s"
      exit 1
    fi
  else
    log "$POD is not running (already stopped)"
    exit 0
  fi
}

STOP
