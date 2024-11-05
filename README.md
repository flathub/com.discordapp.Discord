# Discord

Discord is a free all-in-one messaging, voice and video client that's available on your computer and phone.

This repo hosts the flatpak wrapper for [Discord](https://discord.com/), available at [Flathub](https://flathub.org/apps/details/com.discordapp.Discord).

```sh
flatpak install flathub com.discordapp.Discord
flatpak run com.discordapp.Discord
```

## Reporting bugs

If you're experiencing a problem exclusive to the Flatpak version of Discord, i.e. it doesn't happen when running the official deb or tar.gz packages unsandboxed, feel free to open an issue about it here.

Otherwise, please use the [official bug report form](https://support.discord.com/hc/en-us/articles/1500006052822-How-to-Report-a-Bug) instead, as it increases the chances of a bug getting fixed.

## Differences in flatpak version

The flatpak version runs in a sandbox to provide better safety and privacy for users.

However, this sandboxing prevents the following features from working:

- **Game Activity**: This flatpak version of Discord cannot scan running processes to detect running games.  
  There is currently no workaround or solution for this limitation.
- **Unrestricted File Access**: Default sandbox permissions for this package limit Discord to only certain directories, so you can't access your entire Home directory. Currently, this limits which file directories you can attach files from and impacts drag and drop functionality.  
  This limitation will likely be overcomed eventually, when Electron give us a file picker portal which will allow full access to the filesystem while still restricting unauthorized access.  
  To work around this now, you can change sandbox permissions of installed flatpak applications (for example, with [Flatseal](https://flathub.org/apps/details/com.github.tchx84.Flatseal) or with `flatpak override --filesystem=home com.discordapp.Discord`) to give Discord broader file system access, allowing file attachments from more locations.
- **Rich Presence**: See [this page](https://github.com/flathub/com.discordapp.Discord/wiki/Rich-Precense-(discord-rpc)) if you want to expose Discord's rich presence interface for other applications.


### Wayland

This package enables the flags to run on Wayland, however it is opt-in. To opt-in run:

```sh
flatpak override --user --socket=wayland com.discordapp.Discord
```

To opt-out do the same with `--nosocket=wayland`.

### Persistent launch options

To make Discord's launch options persistent, add them to `~/.var/app/com.discordapp.Discord/config/discord-flags.conf` (one option per line):

```conf
# This line will be ignored
--enable-features=WaylandWindowDecorations

# https://chromium.googlesource.com/chromium/src/+/master/docs/linux/password_storage.md
--password-store=basic
```

### Opening Discord automatically at system startup

The Discord app has a built-in option for that, but it doesn't work on Flatpak mostly because of sandbox restrictions.

But we can still do that manually, with these two commands:

```sh
mkdir -p ~/.config/autostart
ln -s "$(flatpak info -l com.discordapp.Discord//stable | sed 's#/app/.*#/exports/share/applications/com.discordapp.Discord.desktop#')" ~/.config/autostart
```

To undo that, run:

```sh
rm ~/.config/autostart/com.discordapp.Discord.desktop
```

## Legal

The Discord app itself is **proprietary** (closed source).
