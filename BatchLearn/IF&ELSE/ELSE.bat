@ECHO OFF
TITLE ELSE
ECHO 语法： if 条件 (成立时执行的命令) else (不成立时执行的命令)
ECHO 如果是多个条件，建议适当使用括号把各条件包起来，以免出错。

ECHO 实例: if 1 == 0 ( echo comment1 ) else if 1==0 ( echo comment2 ) else (echo comment3 )

ECHO 注：如果 else 的语句需要换行，if 执行的行尾需用“^”连接，并且 if 执行的动作需用(括起来)，否则报错

ECHO 实例: 

if 1 == 0 ( echo comment1 ) else if 1==0 ( echo comment2 ) ^
else (echo comment3 )

PAUSE