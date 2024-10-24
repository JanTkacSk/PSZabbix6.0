$Content = Get-Content $Profile | Where-Object {$_ -notmatch "PSZabbix6.0"}
$ModulePath = (get-item -Path $PSScriptRoot\PSZabbix6.0.psm1).FullName
$FirstLine = "Import-Module $ModulePath"
@($FirstLine) + $Content | Set-Content $PROFILE
$AddedLine = Get-Content $Profile | Where-Object {$_ -eq $FirstLine}
if ($AddedLine -ne $null){
    Write-Host -ForegroundColor Green "PowerShell profile was updated"
}
pause
