@echo off
COPY \\10.1.1.5\工具软件\实用工具\杂项\上网插件静默安装-别删\Singerss.bat C:\UniAccessAgentDownloadData\

SCHTASKS /CREATE /SC  ONLOGON /TN "上网插件" /TR "C:\UniAccessAgentDownloadData\Singerss.bat"