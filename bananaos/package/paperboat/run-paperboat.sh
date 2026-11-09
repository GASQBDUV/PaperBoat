#!/bin/bash
# Starts PaperBoat on bananaOS (no PortMaster needed).
GAMEDIR=${PAPERBOAT_DIR:-/data/roms/ports/paperboat}
LOGDIR=/data/banana/logs/paperboat
mkdir -p "$LOGDIR" "$GAMEDIR/logs"
cd "$GAMEDIR" || exit 1
exec > >(tee "$LOGDIR/paperboat.log") 2>&1
chmod +x ./Paperboat

[ -f assets.zip ] && { unzip -oq assets.zip -d "$GAMEDIR" && rm -f assets.zip; }

CONFIG=paperboat.cfg.json
[ -f "$CONFIG" ] && sed -i -e 's/"Menu":[[:space:]]*1/"Menu": 0/' \
  -e 's/"ControlNav":[[:space:]]*[0-9]*/"ControlNav": 1/' -e 's/"Id":[[:space:]]*1,/"Id": 2,/' "$CONFIG"

if [ ! -f pm64.o2r ]; then
  echo "pm64.o2r is missing. Build it on a PC from your own ROM (see README) and copy it here: $GAMEDIR/pm64.o2r"
  exit 2
fi

if [ "${PAPERBOAT_SCREENS:-dual}" != single ]; then
  # Banana-SDL "stack" mode: one 1024x1536 window, game on one panel, PaperBoat's own UI on the other.
  export PAPERBOAT_SCREENS SDL_BANANA_PANELS=stack SDL_BANANA_TRACE=1 SDL_VIDEODRIVER=offscreen
  # the offscreen driver has no fullscreen size: plain 1024x1536 window
  sed -i -e '/"Fullscreen": {/,/}/ s/"Enabled": true/"Enabled": false/' \
         -e '/^    "Window": {/,$ s/"Height": [0-9]*/"Height": 1536/' \
         -e '/^    "Window": {/,$ s/"Width": [0-9]*/"Width": 1024/' "$CONFIG"
  . /usr/libexec/banana/one-panel && one_panel_dark top && one_panel_restore
else
  [ -f "$CONFIG" ] && sed -i -e '/^    "Window": {/,$ s/"Height": 1536/"Height": 768/' "$CONFIG"
fi
export LD_LIBRARY_PATH="$GAMEDIR/libs:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG_FILE="$GAMEDIR/banana-pad.txt"
./Paperboat
echo "exit: $?"
