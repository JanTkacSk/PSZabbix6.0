$Content = Get-Content $Profile | Where-Object {$_ -notmatch "ZX.ImportPSZabbix6.0.ps1"}
$FirstLine = ". $PSScriptRoot.\ZX.ImportPSZabbix6.0.ps1"
@($FirstLine) + $Content | Set-Content $PROFILE