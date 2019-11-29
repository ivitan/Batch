@echo off 　　
if "%1" == "h" goto begin 
mshta vbscript:createobject("wscript.shell").run("%~nx0 h",0)(window.close)&&exit 
:begin 
@echo off 　

"C:\Users\ywting2\OneDrive\彑中\Google Chrome.lnk"
