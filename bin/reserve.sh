#!/usr/bin/env bash

set -eo pipefail

+() { printf '%q ' "$@" 1>&2; printf '\n' 1>&2; "$@"; }

mkdir -p Reserve

json=$(curl -sS 'https://www.pgevents.ca/events/admin/pgconfdev2026/tokendata/6a28e5f09fa47669593ec44f4723cc244ffa8fa26ea2c70cfaed841c179822e4/sessions.json')

jq -r '
    [.data.[] | select(.status == "Reserve")]
  | map(
      (if (.speakers | length > 0) then
        " (" + (.speakers | map(.name) | join(", ")) + ")"
      else
        ""
      end) as $suffix
    | "\(.title)\($suffix)")
  | join("\n\n")
' <<< "$json" > Reserve/list.txt

jq -r '
    .data.[] | select(.status == "Reserve")
  | "\(.id)\t\(.title)"
' <<< "$json" | while IFS=$'\t' read -r id name; do
  name="${name//[\/.:<>\"\\|?*]/}"
  + npx --yes qrcode-svg \
    --background none \
    --ecl L \
    --join \
    --padding 0 \
    --viewbox \
    "https://www.pgevents.ca/events/pgconfdev2026/feedback/${id}/" \
    > "Reserve/${name}.svg"
  + npx --yes svgo \
    --pretty --indent 2 --final-newline --quiet \
    "Reserve/${name}.svg"
done
