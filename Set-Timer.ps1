<#
.SYNOPSIS
    Sets a one-shot timer using Task Scheduler. Exits immediately after
    registering; the notification is guaranteed to fire later, even if
    this window is closed.

.USAGE
    powershell -File Set-Timer.ps1 -Seconds 300
    powershell -File Set-Timer.ps1 -Minutes 10
    powershell -File Set-Timer.ps1 -Minutes 5 -Message "Tea is ready"

.NOTES
    Why this design: any "sleep then popup" approach in a single process
    dies if the process/console is closed, and background jobs frequently
    land in a non-interactive session (Session 0) where UI calls silently
    fail. Registering a Scheduled Task with "run only when logged on"
    forces Windows to fire the action in your interactive desktop
    session, so the popup is guaranteed to render. The task deletes
    itself right after running.
#>

param(
    [int]$Seconds = 0,
    [int]$Minutes = 0,
    [string]$Message = ""
)

# ============ EDIT THESE TO CUSTOMIZE ============
$DefaultMinutes = 50
$PopupTitle     = "UmaReminder"
$PopupMessage   = "自主トレが終わりました"
# ==================================================

$logFile = Join-Path $PSScriptRoot "timer-error.log"

try {
    if ($Seconds -le 0 -and $Minutes -le 0) {
        $Minutes = $DefaultMinutes
    }
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = $PopupMessage
    }

    $totalSeconds = $Seconds + ($Minutes * 60)
    if ($totalSeconds -le 0) {
        throw "No duration given. Usage: -Seconds 30 or -Minutes 10"
    }

    $triggerTime = (Get-Date).AddSeconds($totalSeconds)
    $taskName    = "QuickTimer_$([guid]::NewGuid().ToString('N').Substring(0,8))"

    # Escape the message for safe embedding in the inner -Command string
    $safeMessage = $Message.Replace("'", "''")

    # Action run AT TRIGGER TIME: show a popup, then delete this very task.
    # -WindowStyle Hidden means no console flashes up when it fires.
    $innerCommand = @"
Add-Type -AssemblyName System.Windows.Forms;
[System.Windows.Forms.MessageBox]::Show('$safeMessage','$PopupTitle', 'OK', 'Information') | Out-Null;
schtasks /Delete /TN '$taskName' /F | Out-Null
"@

    $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($innerCommand))

    $action  = New-ScheduledTaskAction -Execute "powershell.exe" `
                 -Argument "-NoProfile -WindowStyle Hidden -EncodedCommand $encodedCommand"

    $trigger = New-ScheduledTaskTrigger -Once -At $triggerTime

    $settings = New-ScheduledTaskSettingsSet `
                  -AllowStartIfOnBatteries `
                  -DontStopIfGoingOnBatteries `
                  -StartWhenAvailable `
                  -DontStopOnIdleEnd

    # "Run only when user is logged on" = interactive session = UI actually shows.
    # This is the default for Register-ScheduledTask without -User/-Password creds
    # tied to a service account, using the current user's interactive token.
    Register-ScheduledTask -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Description "One-shot quick timer, self-deletes after firing" `
        | Out-Null

    # Confirmation popup shown immediately on launch (Japanese, per spec).
    # Shows total time as minutes if it's a whole number of minutes, else seconds.
    if ($totalSeconds % 60 -eq 0) {
        $timeLabel = "$($totalSeconds / 60)分"
    } else {
        $timeLabel = "$totalSeconds 秒"
    }

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show("$timeLabel" + "後にリマインダーが来ます", $PopupTitle, 'OK', 'Information') | Out-Null

    # This process exits entirely now. The scheduled task is independent
    # from here on and will fire even if everything else has been closed.
}
catch {
    $errText = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  ERROR: $($_.Exception.Message)`r`n$($_.ScriptStackTrace)`r`n"
    Add-Content -Path $logFile -Value $errText
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "エラーが発生しました:`r`n$($_.Exception.Message)`r`n`r`n詳細: $logFile",
        "$PopupTitle - Error", 'OK', 'Error') | Out-Null
}
