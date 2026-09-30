#!/bin/zsh
# Host-side driver. Usage: ./detonate.sh            (build + analyse everything in ./inbox)
#                          ./detonate.sh --cleanup  (remove image and network)
set -euo pipefail
cd "${0:A:h}"
IMAGE=pdf-triage:latest
NET=detonate-net   # host-only network: no route to the internet

if [[ "${1:-}" == "--cleanup" ]]; then
  container image rm "$IMAGE" || true
  container network rm "$NET" || true
  exit 0
fi

ls inbox/*.eml >/dev/null 2>&1 || { echo "Put the raw .eml file(s) in $PWD/inbox first."; exit 1; }
mkdir -p out

# Deliberately NOT app-net: the sample must not be able to reach anything.
container network ls | grep -q "^$NET " || container network create --internal "$NET"

container build -t "$IMAGE" -f Containerfile .

container run --rm \
  --network "$NET" --no-dns \
  --read-only --tmpfs /work --tmpfs /tmp \
  --cap-drop ALL --user 1000:1000 \
  --cpus 1 --memory 1G \
  --mount type=bind,source="$PWD/inbox",target=/in,readonly \
  -v "$PWD/out:/out" \
  "$IMAGE"

echo; echo "Report saved to $PWD/out/report.txt (text only; the PDFs never left the tmpfs)."
