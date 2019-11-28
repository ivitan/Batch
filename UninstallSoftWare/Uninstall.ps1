$list= $list= get-appxpackage -all
$apps =$list| Where-Object { $_.Name -match "Auto" }


foreach ($app in $apps)
{
write-host uninstall... $app.name
$app.Uninstall()
}