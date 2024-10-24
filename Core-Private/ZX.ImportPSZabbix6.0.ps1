$Functions = Get-ChildItem $PSScriptRoot\..\CoreFunctions | Select-Object -ExpandProperty FullName

foreach ($Function in $Functions){
    . $Function
}