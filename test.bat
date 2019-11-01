@echo off
set work_path=C:\Program Files (x86)\Corel
cd %work_path%
for /D %%s in (Corel*) do (
"C:\Program Files (x86)\Corel\%%s\Setup\Setup.exe" /uninstall /quiet
)

exit