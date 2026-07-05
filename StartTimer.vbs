' StartTimer.vbs
' Double-click this file: instantly starts the default 50-minute timer,
' no typing, no confirmation dialog to click through.
' All settings (time, messages) are edited inside Set-Timer.ps1.

Dim scriptDir, psScript, cmd, shell

scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
psScript  = scriptDir & "\Set-Timer.ps1"

cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & psScript & """"

Set shell = CreateObject("WScript.Shell")
shell.Run cmd, 0, False   ' 0 = hidden window, False = don't wait for it to finish

' No further UI here -- Set-Timer.ps1 itself shows the "UmaReminder" popup.
' If you STILL see no popup after this fix, check for a "timer-error.log"
' file next to this script -- Set-Timer.ps1 now logs any failure there.
