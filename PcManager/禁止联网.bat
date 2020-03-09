@echo off
title ½ûÖ¹Adobe Reader ÁªÍø
netsh advfirewall firewall add rule name="Adobe" dir=out program="C:\Program Files (x86)\Adobe\Reader 11.0\Reader\AcroRd32.exe" action=block