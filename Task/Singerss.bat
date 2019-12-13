@echo off
COPY \\10.1.1.5\工具软件\02-上网插件\singress.exe "C:\UniAccessAgentDownloadData\singress.exe"
CD C:\UniAccessAgentDownloadData\
.\singress.exe /sp- /silent 
EXIT