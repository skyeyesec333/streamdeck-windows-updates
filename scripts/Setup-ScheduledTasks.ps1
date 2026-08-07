# Setup-ScheduledTasks.ps1
# Run this ONCE, as Administrator, to register the two scheduled
# tasks that the Stream Deck buttons trigger. Both run with the
# highest privileges (so no UAC prompt appears when triggered later)
# and with a hidden window (so no console flashes on screen - the
# scripts report status via toast notification instead).
#
# By default this assumes the scripts live in C:\Users\Bryan\StreamDeckScripts.
# Edit $scriptFolder below if you put them somewhere else, and copy
# Check-WindowsUpdates.ps1 / Install-WindowsUpdates.ps1 there first.

$scriptFolder = "C:\Users\Bryan\StreamDeckScripts"
$checkScript = Join-Path $scriptFolder "Check-WindowsUpdates.ps1"
$installScript = Join-Path $scriptFolder "Install-WindowsUpdates.ps1"

$action1 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$checkScript`""
$action2 = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$installScript`""

$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -TaskName "StreamDeck-CheckUpdates" -Action $action1 -Principal $principal -Force
Register-ScheduledTask -TaskName "StreamDeck-InstallUpdates" -Action $action2 -Principal $principal -Force

Write-Host "Done. The tasks can be triggered with:"
Write-Host "  schtasks /run /tn `"StreamDeck-CheckUpdates`""
Write-Host "  schtasks /run /tn `"StreamDeck-InstallUpdates`""
