#!/bin/bash
FLATPAK_ID=${FLATPAK_ID:-"com.discordapp.Discord"}
socat $SOCAT_ARGS \
    UNIX-LISTEN:$XDG_RUNTIME_DIR/app/${FLATPAK_ID}/discord-ipc-0,forever,fork \
    UNIX-CONNECT:$XDG_RUNTIME_DIR/discord-ipc-0 \
    &
socat_pid=$!

FEATURES="UseSkiaRenderer"

if [[ $XDG_SESSION_TYPE == "wayland" ]]
then
    FEATURES="$FEATURES,WaylandWindowDecorations"
fi

FLAGS="--ozone-platform-hint=auto \
--enable-gpu-rasterization \
--enable-zero-copy \
--enable-gpu-compositing \
--enable-native-gpu-memory-buffers \
--enable-oop-rasterization \
--enable-features=$FEATURES"

if [[ $XDG_SESSION_TYPE == "wayland" ]] && [ -c /dev/nvidia0 ]
then
    FLAGS="$FLAGS --disable-gpu-sandbox"
fi

disable-breaking-updates.py
set-gtk-dark-theme.py &
env TMPDIR=$XDG_CACHE_HOME zypak-wrapper /app/discord/Discord $FLAGS "$@"
kill -SIGTERM $socat_pid
