wait_until_port() {
  local port="$1"
  local timeout="$2"

  for i in $(seq 1 "$timeout"); do
    if ss -lnt | awk '{print $4}' | grep -q ":$port$"; then
      return 0
    fi
    sleep 1
  done
  return 1
}


if wait_until_port 6003 180; then
  echo "BPM port is listening. READY."
  exit 0
else
  echo "ERROR: BPM port not up within timeout"
  exit 1
fi
