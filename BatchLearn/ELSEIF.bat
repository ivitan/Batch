@echo off
setlocal EnableDelayedExpansion
set option=2
set sum=-1
if %option% == 3 ( 
  echo three 
  set /a sum=%option%*%option%*%option% 
) else if %option% == 2 ( 
  echo two 
  set /a sum=2*%option% 
) else if %option% == 1 ( 
  echo one 
  set /a sum=%option% 
) else ( 
  echo zero 
  set /a sum=0 
)
echo sum = !sum!