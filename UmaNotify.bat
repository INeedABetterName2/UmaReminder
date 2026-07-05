@echo off
setlocal

:: Calculate the time 50 minutes from now
for /f %%i in ('powershell -NoProfile -Command "(Get-Date).AddMinutes(50).ToString('HH:mm')"') do set NotifyTime=%%i

:: Create a one-time scheduled task
schtasks /Create ^
 /TN "UmaReminder" ^
 /SC ONCE ^
 /ST %NotifyTime% ^
 /TR "powershell -WindowStyle Hidden -Command Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('自主トレが完了しました','ウマ娘')" ^
 /F >nul

echo Reminder scheduled for %NotifyTime%.
timeout /t 2 >nul