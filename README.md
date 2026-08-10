# Stream Deck Windows Update Macro

Two Stream Deck buttons: one checks for Windows updates, one installs
them. Both run elevated without a UAC prompt (the real work happens in
a scheduled task set to "highest privileges," triggered by the
button), and both run with a hidden window, so the console never
flashes on screen. Each run shows status notifications and writes a
detailed log file.

## What you'll see

- Pressing **Check Updates**: a compact lower-right popup playing
  `gif/space-force-microsoft.gif`, followed a few seconds later by a toast
  reporting how many updates were found (or that you're all caught up).
- Pressing **Install Updates**: a toast saying installation has
  started, then a lower-right popup playing `gif/clapping.gif` when
  it finishes, followed by a toast with the restart status.
- Full details of every run are written to `update-check-log.txt` and
  `update-install-log.txt` alongside the scripts.

## Files

- `scripts/Check-WindowsUpdates.ps1` — checks for updates, logs the result, shows a toast
- `scripts/Install-WindowsUpdates.ps1` — installs all available updates, logs the result, shows a toast
- `scripts/Show-GifPopup.ps1` — displays a compact animated GIF popup in the lower-left corner; it fades in and out after three loops
- `gif/` — GIFs displayed by the update scripts
- `scripts/Setup-ScheduledTasks.ps1` — one-time setup, registers the two scheduled tasks
- `streamdeck/Run-CheckUpdates.bat` / `streamdeck/Run-InstallUpdates.bat` — what the Stream Deck buttons launch
- `streamdeck/Setup-Elevated.bat` — right-click > Run as administrator to run the setup script once

## Setup

1. Clone or copy this repo somewhere on the machine you want to run
   it on, e.g. `C:\StreamDeckScripts`. Keep the `scripts` and `gif`
   folders together.

2. Open `scripts/Setup-ScheduledTasks.ps1` and check the `$scriptFolder`
   path at the top matches the `scripts` folder, e.g.
   `C:\StreamDeckScripts\scripts`. Update it if not.

3. Right-click `streamdeck/Setup-Elevated.bat` and choose **Run as
   administrator**, then approve the UAC prompt if one appears. This
   registers `StreamDeck-CheckUpdates` and `StreamDeck-InstallUpdates`
   in Task Scheduler, both set to run with highest privileges and a
   hidden window. You only need to do this once.

4. Install the toast notification module once, in an elevated
   PowerShell prompt: `Install-Module BurntToast`. (The scripts will
   also try to install it automatically on first run.)

5. In the Stream Deck app, add a **System: Open** action to a button
   and point it at `streamdeck/Run-CheckUpdates.bat`. Add a second
   button pointing at `streamdeck/Run-InstallUpdates.bat`.

6. Press each button once to test. The first run may take longer
   since it installs the PSWindowsUpdate and BurntToast modules.

## Notes

- Install runs use `-AutoReboot:$false`, so a reboot required by the
  updates won't happen automatically — the install toast tells you if
  one is needed.
- Requires Windows PowerShell (not PowerShell 7) and admin rights on
  first module install.
- If toast notifications don't appear, check that BurntToast installed
  correctly (`Get-Module -ListAvailable BurntToast`) — the log files
  still record every run either way.
- If Stream Deck's Open action doesn't accept `.bat` files directly,
  use the System: App action instead, pointing at the same file.

## License

MIT, see [LICENSE](LICENSE).
