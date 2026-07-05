@echo off
setlocal

for /f %%i in ('powershell -NoProfile -Command "(Get-Date).AddMinutes(50).ToString('HH:mm')"') do set NotifyTime=%%i

schtasks /Create ^
 /TN "UmaReminder" ^
 /SC ONCE ^
 /ST %NotifyTime% ^
 /F ^
 /RL HIGHEST ^
 /TR "powershell -NoProfile -WindowStyle Hidden -Command \"Start-Process powershell -ArgumentList '-NoProfile -WindowStyle Hidden -Command \"\"$ErrorActionPreference=Stop; [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] ^| Out-Null; [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType=WindowsRuntime] ^| Out-Null; $xml = New-Object Windows.Data.Xml.Dom.XmlDocument; $xml.LoadXml('<toast><visual><binding template=''ToastGeneric''><text>ウマ娘</text><text>自主トレが完了しました</text></binding></visual></toast>'); $toast = [Windows.UI.Notifications.ToastNotification]::new($xml); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('UmaReminder').Show($toast)\"\"' -WindowStyle Hidden\""

echo Scheduled for %NotifyTime%
pause
