---
title: Modding Mass Effect Legendary Edition on Linux
date: '2026-09-17 11:15:00'
layout: post
categories:
- Computers
- Gaming
- Linux
tags: [Linux, Proton, Lutris, Wine, Mass Effect, modding]
author: mlilback
---

I spent an evening getting the EA App version of Mass Effect Legendary Edition modded on [my new Linux box]({% post_url 2026-09-16-trask-a-quiet-linux-gaming-pc %}), and most of that evening was dead ends. All three games now load with DLC mods, merge mods and ASI plugins, so I'm writing down what worked and every trap I hit along the way. If you're googling one of these error messages at 1am, this is for you.

The stack is Lutris plus umu-launcher plus GE-Proton, with mods installed by ME3Tweaks Mod Manager. M3 is officially unsupported on Linux -- its developers say so, and recent builds include Wine fixes contributed by users. If something here breaks with a newer M3, ask in the `#linux` channel on the ME3Tweaks Discord. Don't file Linux bugs as regular M3 issues.

What I tested, September 2026: Bazzite 44 with GNOME 50 on Wayland at 4K and 125% scaling, a Radeon RX 9070 XT on Mesa RADV, Lutris 0.5.22, umu-launcher 1.4.4, GE-Proton11-7, EA App 13.791, and ME3Tweaks Mod Manager 9.2.1 Build 137. DLC mods, merge mods and ASIs, no texture mods. Nothing below is Bazzite-specific except the paths, and I did not test MEM/ALOT.

## The EA App and the game in Lutris

Set Lutris's default install folder before you install anything (Preferences → Storage), or everything lands in `~/Games`.

Install the EA App from Lutris's installer. It gets its own Wine prefix, separate from Epic's and Ubisoft's. Log in, then install Mass Effect LE from inside the EA App. If you install to a second drive, check `dosdevices/` in the prefix to see which letter maps to it. Mine was `S:`.

Enable the EA App source in Lutris (Sources → EA App) and log in there too. That is a second, separate login from the EA App's own. When a library refresh fails with `User not authenticated to EA`, that's the one that expired.

Lutris only detects EA games under `<prefix>/drive_c/Program Files/EA Games`. Anywhere else and the game is invisible to it. Symlink that path to the real install folder and refresh -- Lutris reads `__Installer/installerdata.xml` and builds the game entry itself.

Launch the game with `EALauncher.exe`, not `EADesktop.exe`. Lutris's generated entry copies the EA App's exe, so fix it to:

- exe: `drive_c/Program Files/Electronic Arts/EA Desktop/EA Desktop/EALauncher.exe`
- arguments: `origin2://game/launch?offerIds=198196&autoDownload=1`

198196 is ME LE's content ID.

If the EA App window is microscopic on a HiDPI screen, that's because EA Desktop is Chromium-based and ignores Wine's DPI entirely. Give the EA App entry `--force-device-scale-factor=2` and point that entry at `EADesktop.exe`, since `EALauncher.exe` won't pass arguments through.

Here's the one that cost me the most time. In LE1 and LE2, mouse clicks did nothing while the keyboard worked fine. The fix is to turn off Wine DPI scaling for the game entry (Configure → Runner options → Show advanced options → uncheck "Enable DPI Scaling"), which is `wine: {Dpi: false}` in its yml. At a Wine DPI of 192 the game gets its window coordinates at half scale but the click positions raw, so every click lands somewhere else. Set it on every Lutris entry that touches the prefix, because each launch writes its own DPI value into it.

The EA App also keeps running after you quit the game. Its window hides, Wine tray icons don't show up on GNOME, and it looks gone. Use Lutris's Stop button on the game entry.

A cosmetic Lutris quirk: every EA game gets the slug `ea-app`, colliding with the launcher entry, so your game shows the EA App's icon.

Two things I tried that don't work for Mass Effect: Proton's native Wayland driver (`PROTON_ENABLE_WAYLAND=1` gave me a black screen in ME1 and a stuck pointer grab), and gamescope (swapchain loop). It runs fine through XWayland.

## Installing ME3Tweaks Mod Manager

Grab `ME3TweaksModManagerExtractor_<version>.exe` from the [releases page](https://github.com/ME3Tweaks/ME3TweaksModManager/releases) and check it against the sha256 digest GitHub shows for the asset. It's a 7z self-extractor, so there's no need to run it under Wine at all:

```bash
7z e ME3TweaksModManagerExtractor_*.exe ME3TweaksModManager/ME3TweaksModManager.exe
```

Put the exe somewhere the game's prefix can reach through a drive letter. M3's default mod library is `mods\` next to it. Version 9.2 and later bundles its own .NET, so no winetricks, and it fetches a Linux-specific Visual C++ runtime itself when it installs ASIs.

M3 has to run in the same prefix with the same Proton as the EA App and the game. That's how it finds the install: the prefix holds the `HKLM\SOFTWARE\BioWare\Mass Effect Legendary Edition` `Install Dir` key, and M3 picked up LE1, LE2, LE3 and the launcher with no manual setup at all.

I used a script instead of a Lutris entry:

```bash
#!/usr/bin/env bash
# Run ME3Tweaks Mod Manager in the EA App prefix that holds Mass Effect LE.
set -euo pipefail

export WINEPREFIX=/path/to/lutris/ea-app               # the EA App prefix
PROTON=GE-Proton11-7                                   # must match $WINEPREFIX/version
export PROTONPATH=$HOME/.local/share/Steam/compatibilitytools.d/$PROTON-x86_64
export GAMEID=umu-default STORE=none
export PROTON_USE_WINED3D=1                            # DXVK reportedly blacks out M3's window
M3_DIR=/path/to/games/ME3TweaksModManager

# Refuse to run alongside the EA App, a running game, or a second M3.
# LE games show no exe name in ps, only their arguments, hence -SeekFreeLoadingPCConsole.
if pgrep -f -i 'EADesktop\.exe|EALauncher\.exe|MassEffect(1|2|3|Launcher)\.exe|ME3TweaksModManager\.exe|-SeekFreeLoadingPCConsole' >/dev/null; then
  echo "M3, EA App or Mass Effect is already running; stop it first" >&2; exit 1
fi
[ "$(cat "$WINEPREFIX/version")" = "$PROTON" ] || { echo "prefix Proton mismatch" >&2; exit 1; }

# Optional on HiDPI: make M3 (a DPI-aware WPF app) readable. The game entry's
# "Dpi: false" puts it back to 96 at the next game launch.
for key in 'HKCU\Control Panel\Desktop' 'HKCU\Software\Wine\Fonts'; do
  umu-run reg add "$key" /v LogPixels /t REG_DWORD /d 192 /f
done

cd "$M3_DIR"
exec umu-run "$M3_DIR/ME3TweaksModManager.exe"
```

Three things went wrong writing that. `PROTONPATH` wants the full directory path or a name umu can resolve, and GE-Proton's folder is `GE-Proton11-7-x86_64` while the prefix's `version` file says `GE-Proton11-7`, so the bare name fails with `toolmanifest.vdf not found`. `pgrep` takes extended regex by default and has no `-E` option, so adding one makes it error out and the guard silently never fires. And I used WineD3D on the strength of reports that DXVK blacks out M3's window, which means I never actually tested DXVK myself.

On first start M3 warns you it's running under Wine. Don't turn on dark mode -- M3's own changelog calls it very broken there. Settings and logs live inside the prefix at `drive_c/ProgramData/ME3TweaksModManager/`, and those logs are the first place to look when something goes sideways.

## Back up first

Some mods rewrite base-game packages rather than adding a `DLC_MOD_*` folder. The LE1 Community Patch and the Unofficial LE2 Patch both do. So deleting a DLC folder is not a full undo, and you want M3's vanilla backup of each game before you install anything.

Create one empty folder per game first (`backups/LE1`, `LE2`, `LE3`). M3 copies the game's contents directly into the folder you pick, not into a subfolder under it. If you get that wrong, M3 can unlink a backup and link an existing one, so you can move the files on the Linux side and relink. Mine skipped about 5,400 non-English localization files per game, which is fine for an English install.

## Getting mods in

Nexus's "Mod Manager Download" buttons don't work. They open an `nxm://` link and nothing on the Linux host handles it, so the browser offers to "open xdg-open" and then nothing happens. Use Manual Download. M3's own in-app downloads are reported broken under Wine too.

Don't drag large archives onto M3. Small ones dragged fine, but dropping the 1.9 GB LE1 Community Patch archive pinned M3's UI thread at full CPU and never opened it. Force-quit was the only way out, and it was safe, since nothing had been written yet. Use the import menu.

The import file dialog only lists `C:`. Type the drive-letter path into the filename box instead, like `X:\Downloads\` if that's where your home folder is mapped in `dosdevices/`.

Installing straight from an archive doesn't add that version to M3's library, so import anything you want to keep around.

Free Nexus accounts are throttled to about 3 MB/s. The LE2 patch is 4.7 GB and the LE3 Community Framework is 4.5 GB, so budget 25 minutes each.

## Install order matters, and I learned that the hard way

A lot of LE mods are merge mods. Instead of adding a folder they patch base-game packages like `SFXGame.pcc` and `Startup_*.pcc` in place. Community patches and frameworks go in first, then everything else.

I installed four LE2 merge mods before the Unofficial LE2 Patch. The patch rewrote the `Startup_*.pcc` files and wiped the Mission Results Screen Fix merge, though its `SFXGame.pcc` merges survived. Loading an old save then hung on the Normandy with the camera under the CIC floor, no HUD and no input at all. Reinstalling the merge mods after the patch put the lost merge back and the save loaded fine. If a patch goes in late, reinstall your merge mods.

## ASI plugins, which needed nothing

On the first mod install M3 put in the LEBinkProxy loader -- it renames `bink2w64.dll` to `bink2w64_original.dll` and drops in its own -- along with AutoTOC for all three games and Autoload Enabler v13 for LE1. They loaded under Proton with no `WINEDLLOVERRIDES`, because Wine has no built-in bink DLL and loads the one in the game folder.

To confirm mods are live without starting a playthrough, read `Game/ME1/Binaries/Win64/Logs/bink2w64_proxy.log` for the ASIs and `AutoloadEnabler.log` for every DLC mod it mounted, in order. LE1 mods don't announce themselves on the main menu, so this is the only way to know.

## What I ended up with

LE1: Community Patch 2.0, Black Market License, Charted Worlds, Galaxy Map Trackers, Keepers Finders, Normandy Rapid Transit, XP Rescale, Longer Sprint Slow Motion and Speed Up.

LE2: Unofficial LE2 Patch 0.9.6 with Persistent Mod Settings, Children of Rannoch, All VIP Club Encounters, Faster Normandy, Mission Results Screen Fix, One Probe All Resources, Proper Convo-Cutscene Skipper, Infinite Normandy Fuel, Hide Helmets and Headgear, Customizable Asari Commando Armor, Aria Outfit, Cat Suits, Paragade Persuasion, and a few small ones.

LE3: Community Framework, Patch and Persistent Settings 1.7.9, Storm Improvements, FISH (Plus Kelly), Journal Enhanced, WiredTexan's Improved Scanning, Hide Helmets and Headgear, Apartment Additions, Liara Casual, and a couple more.

Still untested here: texture mods through MEM, M3 with DXVK, and the Steam version, which should be easier since M3's detection also checks Steam's uninstall key. HDR mods like Luma need either the Wayland driver or gamescope, and neither one works for Mass Effect, so that's a dead end for now.
