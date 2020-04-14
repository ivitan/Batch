::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCyDJGyX8VAjFAJDWA2MOzmGIroL5uT07u6Unm4SRue3pUBfAWILzTibN5hioH2lGY9mvM4ACQ9dQUP5Nh8slj8T7jXRY5Wjtg7yU0GK6UV+FWBgyWrTg0s=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
set work_path="C:\Program Files\Corel"
set work_path2="C:\Program Files (x86)\Corel"
if exist %work_path% (
cd %work_path% 
for /D %%s in (Corel*) do (
echo %%s
"C:\Program Files\Corel\%%s\Setup\Setup.exe" /uninstall /quiet
))else (
cd %work_path2% 
for /D %%s in (Corel*) do (
echo %%s
"C:\Program Files (x86)\Corel\%%s\Setup\Setup.exe" /uninstall /quiet
))
exit