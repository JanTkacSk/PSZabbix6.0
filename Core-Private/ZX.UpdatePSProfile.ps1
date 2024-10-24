$Content = Get-Content $Profile | Where-Object {$_ -notmatch "ZX.ImportPSZabbix6.0.ps1"}
$FirstLine = ". $PSScriptRoot.\ZX.ImportPSZabbix6.0.ps1"
@($FirstLine) + $Content | Set-Content $PROFILE
$AddedLine = Get-Content $Profile | Where-Object {$_ -eq $FirstLine}
if ($AddedLine -ne $null){
    Write-Host -ForegroundColor Green "PowerShell profile was updated"
}
pause