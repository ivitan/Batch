@echo off
TITLE Get Local IP address 
ipconfig | find /I "IPv4"
pause