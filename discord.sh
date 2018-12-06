#!/bin/bash
socat $SOCAT_ARGS \
    UNIX-LISTEN:$XDG_RUNTIME_DIR/discord/ipc-0,forever,fork \
    UNIX-CONNECT:$XDG_RUNTIME_DIR/discord-ipc-0 \
    &
socat_pid=$!
env TMPDIR=$XDG_CACHE_HOME /app/extra/discord "$@"
kill -SIGTERM $socat_pid
