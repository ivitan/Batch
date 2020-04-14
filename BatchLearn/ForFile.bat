@echo off
:: Coreldraw 2017默认路径为到C:\Program Files\Corel\CorelDRAW Graphics Suite 2017\
set work_path=C:\Program Files (x86)\Corel
cd %work_path%
for /R %%s in (.,*) do (
echo %%s
)
pause