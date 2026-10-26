get-appxpackage -all
function Pause(){
[System.Console]::Write('按任意键继续...')
[void][System.Console]::ReadKey(1)
}
pause