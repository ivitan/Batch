msg %username% /time:10 "要显示的内容"

mshta vbscript:msgbox("要显示的内容",64,"要显示的标题")(window.close)

mshta vbscript:CreateObject("Wscript.Shell").popup("要显示的内容",7,"要显示的标题",64)(window.close)

mshta "javascript:new ActiveXObject('WScript.Shell').popup('要显示的内容',7,'要显示的标题',64);window.close();"