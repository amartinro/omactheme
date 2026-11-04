#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

jq empty "$root/dock/manifest.json"
bash -n "$root/bin/tahoe-window" "$root/hooks/theme-set" "$root/install.sh" \
  "$root/finish-install.sh" "$root/enable-mission-control.sh" "$root/uninstall.sh"
python3 - "$root/theme/tahoe-dark/colors.toml" "$root/theme/tahoe-dark/shell.toml" <<'PY'
import sys, tomllib
for path in sys.argv[1:]:
    with open(path, "rb") as handle:
        tomllib.load(handle)
PY
python3 -m py_compile "$root/notifications/close-button.py"
# The patcher must turn a pristine upstream card into the shipped result and be
# idempotent, without touching the live clone.
if [[ -f /usr/share/omarchy/shell/plugins/notifications/components/NotificationCard.qml ]]; then
  scratch="$(mktemp -d)"
  trap 'rm -rf "$scratch"' EXIT
  mkdir -p "$scratch/components"
  cp /usr/share/omarchy/shell/plugins/notifications/components/NotificationCard.qml \
    "$scratch/components/NotificationCard.qml"
  python3 "$root/notifications/close-button.py" "$scratch/components/NotificationCard.qml"
  python3 "$root/notifications/close-button.py" "$scratch/components/NotificationCard.qml"
  patched="$(cat "$scratch/components/NotificationCard.qml")"
  grep -q "macOS-style close affordance" <<<"$patched"
  grep -q "import QtQuick.Shapes" <<<"$patched"
  grep -q "Layout.leftMargin: Style.space(32)" <<<"$patched"
  [[ $(grep -c "Layout.leftMargin: Style.space(12)" <<<"$patched") -eq 0 ]]
fi
test -s "$root/theme/tahoe-dark/backgrounds/tahoe-night-glass.png"
file "$root/theme/tahoe-dark/backgrounds/tahoe-night-glass.png" | grep -q 'PNG image data'
echo "Tahoe Dark static validation passed"
