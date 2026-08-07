# Check-WindowsUpdates.ps1
# Checks for available Windows updates, logs the result to
# update-check-log.txt, and shows a Windows toast notification with
# a summary so you don't have to watch a console window to know what
# happened.

$logPath = Join-Path $PSScriptRoot "update-check-log.txt"

function Ensure-Module {
    param([string]$Name)
    if (-not (Get-Module -ListAvailable -Name $Name)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue | Out-Null
        Install-Module -Name $Name -Force -Confirm:$false -Scope CurrentUser -ErrorAction SilentlyContinue
    }
    Import-Module $Name -ErrorAction SilentlyContinue
}

function Show-Toast {
    param([string]$Title, [string]$Body)
    try {
        New-BurntToastNotification -Text $Title, $Body -ErrorAction Stop
    } catch {
        # Toast notifications unavailable in this session (e.g. no BurntToast,
        # or no interactive desktop). The log file still has the result.
    }
}

Ensure-Module "PSWindowsUpdate"
Ensure-Module "BurntToast"

Show-Toast "Windows Update" "Checking for updates..."

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$updates = Get-WindowsUpdate -ErrorAction SilentlyContinue

if ($updates) {
    $count = $updates.Count
    $titles = ($updates | ForEach-Object { " - $($_.Title)" }) -join "`n"
    $summary = "$timestamp - $count update(s) available:`n$titles"
    $firstTitle = $updates[0].Title
    $body = if ($count -gt 1) { "$firstTitle (+$($count - 1) more)" } else { $firstTitle }
    Show-Toast "$count Windows update(s) found" $body
} else {
    $summary = "$timestamp - No updates available."
    Show-Toast "Windows Update" "You're all caught up - no updates available."
}

$summary | Out-File -FilePath $logPath -Encoding utf8
