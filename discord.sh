#!/bin/bash

read -ra SOCAT_ARGS <<<"${SOCAT_ARGS}"

FLATPAK_ID=${FLATPAK_ID:-"com.discordapp.Discord"}
OUR_SOCKET="${XDG_RUNTIME_DIR}/app/${FLATPAK_ID}/discord-ipc-0"
DISCORD_SOCKET="${XDG_RUNTIME_DIR}/discord-ipc-0"

invoke_socat=true
# Check if our socket already exists.
if [ -S "${OUR_SOCKET}" ]
then
    # Check if socat is listening on it.
    if socat "${SOCAT_ARGS[@]}" -u OPEN:/dev/null "UNIX-CONNECT:${OUR_SOCKET}"
    then
        # socat is still listening on it, make sure not to invoke it again.
        invoke_socat=false
    else
        # Socket exists but socat is not listening on it (for whatever reason), delete it so we can invoke socat again.
        rm -f "${OUR_SOCKET}"
    fi
fi

if [ "${invoke_socat}" = true ]
then
    socat "${SOCAT_ARGS[@]}" "UNIX-LISTEN:${OUR_SOCKET},forever,fork" "UNIX-CONNECT:${DISCORD_SOCKET}" &
    socat_pid=$!
fi

if [ -f "${XDG_CONFIG_HOME}/discord-flags.conf" ]
then
    mapfile -t FLAGS <<< "$(grep -Ev '^\s*$|^#' "${XDG_CONFIG_HOME}/discord-flags.conf")"
fi

# Run the updater if we're missing a symlink to Discord's main binary in $XDG_CONFIG_HOME/discord
if [ ! -x "${XDG_CONFIG_HOME}/discord/Discord" ]
then
    echo 'Missing symlink created by Discord after installation, running updater_bootstrap first...' >&2
    app_dir=$(updater_bootstrap --zenity "${XDG_CONFIG_HOME}/discord" stable https://updates.discord.com/)
    if [ $? -eq 0 ]
    then
        echo "Patching desktop file in Discord's asar file..." >&2
        patch-electron-desktop-filename "${XDG_CONFIG_HOME}/discord/${app_dir}/resources/app.asar"
    fi
fi

env TMPDIR="${XDG_CACHE_HOME}" ZYPAK_DISABLE_SANDBOX=1 zypak-wrapper "${XDG_CONFIG_HOME}/discord/${app_dir:-}/Discord" "${FLAGS[@]}" "$@"

if [ "${invoke_socat}" = true ]
then
    kill -SIGTERM "${socat_pid}"
fi
