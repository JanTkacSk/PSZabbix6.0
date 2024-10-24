$Functions = Get-ChildItem $PSScriptRoot\Core-Public | Select-Object -ExpandProperty FullName

foreach ($Function in $Functions){
    . $Function
}