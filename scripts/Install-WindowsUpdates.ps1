# Install-WindowsUpdates.ps1
# Installs all available Windows updates, logs the result to
# update-install-log.txt, and shows toast notifications at the start
# and end (including whether a restart is needed) so you know what
# happened without watching a console window.

$logPath = Join-Path $PSScriptRoot "update-install-log.txt"
$gifPopupScript = Join-Path $PSScriptRoot "Show-GifPopup.ps1"

function Get-GifPath {
    param([string]$Name)
    $deployedPath = Join-Path $PSScriptRoot "gif\$Name"
    if (Test-Path -LiteralPath $deployedPath) { return $deployedPath }
    return Join-Path (Split-Path $PSScriptRoot -Parent) "gif\$Name"
}

$completeGif = Get-GifPath "clapping.gif"

function Show-GifPopup {
    param([string]$GifPath)
    if ((Test-Path -LiteralPath $gifPopupScript) -and (Test-Path -LiteralPath $GifPath)) {
        Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
            "-NoProfile", "-STA", "-ExecutionPolicy", "Bypass", "-File", "`"$gifPopupScript`"", "-GifPath", "`"$GifPath`""
        )
    }
}

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
        # Toast notifications unavailable in this session. The log file
        # still has the result.
    }
}

Ensure-Module "PSWindowsUpdate"
Ensure-Module "BurntToast"

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Show-Toast "Windows Update" "Installing updates - this may take a few minutes..."

try {
    $result = Install-WindowsUpdate -AcceptAll -AutoReboot:$false -Confirm:$false -Verbose *>&1
    $summary = "$timestamp - Install run complete.`n$($result | Out-String)"

    $rebootNeeded = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    Show-GifPopup $completeGif
    if ($rebootNeeded) {
        Show-Toast "Windows Update installed" "Done. A restart is needed to finish installing."
    } else {
        Show-Toast "Windows Update installed" "Done. No restart needed."
    }
} catch {
    $summary = "$timestamp - Install run failed: $($_.Exception.Message)"
    Show-Toast "Windows Update failed" $_.Exception.Message
}

$summary | Out-File -FilePath $logPath -Encoding utf8
