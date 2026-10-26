
Set Shell = CreateObject("WScript.Shell") Shell.Run "cmd /c @runas /user:administrator CMD" WScript.Sleep 2000 Shell.SendKeys "password{ENTER}exit{ENTER}" WScript.Sleep 1000 Shell.SendKeys "@echo off&cls&net stop messenger&net start messenger&exit{ENTER}"
