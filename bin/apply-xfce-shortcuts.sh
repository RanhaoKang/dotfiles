#!/usr/bin/env bash

set -euo pipefail

if ! command -v xfconf-query >/dev/null 2>&1; then
  echo "xfconf-query not found; install XFCE xfconf tools first." >&2
  exit 1
fi

set_string() {
  local channel="$1"
  local path="$2"
  local value="$3"
  xfconf-query -c "$channel" -n -t string -p "$path" -s "$value" 2>/dev/null \
    || xfconf-query -c "$channel" -t string -p "$path" -s "$value"
}

set_bool() {
  local channel="$1"
  local path="$2"
  local value="$3"
  xfconf-query -c "$channel" -n -t bool -p "$path" -s "$value" 2>/dev/null \
    || xfconf-query -c "$channel" -t bool -p "$path" -s "$value"
}

set_empty() {
  local channel="$1"
  local path="$2"
  xfconf-query -c "$channel" -n -t empty -p "$path" 2>/dev/null || true
}

# Application shortcuts.
set_bool xfce4-keyboard-shortcuts /commands/custom/override true
set_string xfce4-keyboard-shortcuts /commands/custom/\<Super\>Return ghostty
set_string xfce4-keyboard-shortcuts /commands/custom/\<Super\>d xfce4-appfinder
set_bool xfce4-keyboard-shortcuts /commands/custom/\<Super\>d/startup-notify true

# Disable the default Super_L launcher so Super-based WM bindings still work.
set_empty xfce4-keyboard-shortcuts /commands/custom/Super_L

# Window manager shortcuts.
set_bool xfce4-keyboard-shortcuts /xfwm4/custom/override true
set_string xfce4-keyboard-shortcuts /xfwm4/custom/\<Super\>f maximize_window_key
set_string xfce4-keyboard-shortcuts /xfwm4/custom/\<Super\>q close_window_key

echo "Applied XFCE application and window-manager shortcuts."
