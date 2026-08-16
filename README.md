# Stream Deck Windows Updater (with appropriate levels of panic)

An unserious interface for a completely real Windows Update workflow.

This project puts **Check updates** and **Install updates** buttons on an
Elgato Stream Deck, runs the work through elevated scheduled tasks, and adds
animated GIF popups plus Windows toast notifications. It exists because a
routine update deserves the same emotional stakes as the *Space Force*
moment where a Windows update takes 40+ minutes and leaves the staff very,
very annoyed.

The updater works. The presentation is the silly part.

> **Unofficial fan project.** This repository is not affiliated with,
> endorsed by, or associated with Netflix, *Space Force*, Microsoft, or
> Elgato. The included GIFs are used as a humorous reference; replace them
> with assets you have permission to use if you redistribute or deploy this
> outside your own setup.

## What it does

- **Check Updates** opens a small animated *Space Force*-inspired popup,
  checks Windows Update, then shows a toast with the result.
- **Install Updates** starts the installation, shows a completion GIF when
  it is done, and tells you whether Windows needs a restart.
- Both actions run elevated through Task Scheduler after one-time setup, so
  a Stream Deck press does not leave a PowerShell window flashing on screen.
- Every run writes a plain-text log next to the scripts, which is useful when
  the comedy has ended and you need to know what actually happened.

## Screens and sounds, minus the drama

| Stream Deck action | Actual work | Result |
| --- | --- | --- |
| Check Updates | Runs `Get-WindowsUpdate` | GIF popup, then a toast listing the update count/status |
| Install Updates | Runs `Install-WindowsUpdate -AcceptAll` | Start toast, completion GIF, then restart status |

No reboot is forced: installation uses `-AutoReboot:$false`.

## Repository guide

- `scripts/Check-WindowsUpdates.ps1` — checks for updates, logs the result, shows a toast
- `scripts/Install-WindowsUpdates.ps1` — installs all available updates, logs the result, shows a toast
- `scripts/Show-GifPopup.ps1` — displays a compact animated GIF popup in the lower-left corner; it fades in and out after three loops
- `gif/` — GIFs displayed by the update scripts (swap these for your own if needed)
- `scripts/Setup-ScheduledTasks.ps1` — one-time setup, registers the two scheduled tasks
- `streamdeck/Run-CheckUpdates.bat` / `streamdeck/Run-InstallUpdates.bat` — what the Stream Deck buttons launch
- `streamdeck/Setup-Elevated.bat` — right-click > Run as administrator to run the setup script once

## Setup

1. Clone or copy this repo somewhere on the Windows machine that will run it,
   for example `C:\StreamDeckScripts`. Keep `scripts` and `gif` together.

2. Open `scripts/Setup-ScheduledTasks.ps1` and check the `$scriptFolder`
   path at the top matches the `scripts` folder, e.g.
   `C:\StreamDeckScripts\scripts`. Update it if not.

3. Right-click `streamdeck/Setup-Elevated.bat`, choose **Run as
   administrator**, and approve UAC if prompted. This
   registers `StreamDeck-CheckUpdates` and `StreamDeck-InstallUpdates`
   in Task Scheduler, both set to run with highest privileges and a
   hidden window. You only need to do this once.

4. Install the toast notification module once in an elevated PowerShell
   prompt: `Install-Module BurntToast`. The scripts also attempt this on
   their first run.

5. In the Stream Deck app, add a **System: Open** action to a button
   and point it at `streamdeck/Run-CheckUpdates.bat`. Add a second
   button pointing at `streamdeck/Run-InstallUpdates.bat`.

6. Press each button once to test. The first run may take longer
   since it installs the PSWindowsUpdate and BurntToast modules.

## Requirements and notes

- Install runs use `-AutoReboot:$false`, so a reboot required by the
  updates won't happen automatically — the install toast tells you if
  one is needed.
- Requires Windows PowerShell (not PowerShell 7), a Stream Deck, and admin
  rights for the one-time setup/module installation.
- The scripts use the `PSWindowsUpdate` and `BurntToast` PowerShell modules.
- If toast notifications don't appear, check that BurntToast installed
  correctly (`Get-Module -ListAvailable BurntToast`) — the log files
  still record every run either way.
- If Stream Deck's Open action does not accept `.bat` files directly, use the
  System: App action and point it at the same file.
- This is a personal automation script, not a substitute for your
  organisation's update policy, endpoint management, or change controls.

## Customising the level of outrage

Replace the files in `gif/` while keeping the existing filenames:

- `space-force-microsoft.gif` for the update-checking popup
- `clapping.gif` for the installation-complete popup

You can also change the toast copy and GIF timing in the PowerShell scripts.
The actual update behaviour is in `Check-WindowsUpdates.ps1` and
`Install-WindowsUpdates.ps1`; the Stream Deck batch files only trigger the
scheduled tasks.

## License

MIT, see [LICENSE](LICENSE.txt).
