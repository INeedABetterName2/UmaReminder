UmaReminder

What it does
Double-click UmaReminder.bat.
The batch file immediately schedules a reminder for 50 minutes later.
The batch file then exits.

At the scheduled time, a Windows popup appears with:

Title:
ウマ娘

Message:
自主トレが完了しました

Requirements
Windows 10 or Windows 11
PowerShell (included with Windows)
Task Scheduler service enabled (enabled by default)
Known limitation

If you run the batch file within the last 50 minutes before midnight (approximately 23:10–23:59), the reminder may fail to be scheduled because the script does not handle reminders that roll over to the next day.

To avoid this issue, simply don't start the batch during that time period.