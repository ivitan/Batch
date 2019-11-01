@echo off

::"C:\Program Files (x86)\Corel\CorelDRAW Graphics Suite 2018\Setup\Setup.exe" /?


"C:\Program Files (x86)\Foxmail\uninst.exe" /
Set objShell = CreateObject("Wscript.Shell")

do
objShell.SendKeys "u"
loop
exit