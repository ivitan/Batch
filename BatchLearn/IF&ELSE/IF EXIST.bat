@ECHO OFF
TITLE IF EXIST
ECHO if exist
ECHO 语法: if [not] exist [路径\]文件名 待执行的命令
ECHO 如果有指定的文件，则条件成立，运行命令，否则运行下一句。
ECHO Sample: if exist config.sys edit config.sys (表示如果存在这文件，则编辑它，用很难看的系统编辑器)
ECHO Sample: if exist config.sys type config.sys (表示如果存在这文件，则显示它的内容)
PAUSE