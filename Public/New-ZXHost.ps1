function New-ZXHost {
    param(
        [parameter(mandatory="true")]
        [string]$Name,
        [string]$Alias,
        [parameter(mandatory="true")]
        [array]$HostGroup,
        [array]$Template,
        [array]$Tags,
        [array]$Macros,
        [array]$Interfaces,
        [switch]$ShowJsonRequest,
        [switch]$WhatIf
    )

    #Basic PS Object wich will be edited based on the used parameters and finally converted to json
    $PSObj = [PSCustomObject]@{
        "jsonrpc" = "2.0";
        "method" = "host.create";
        "params" = [PSCustomObject]@{
            "groups"=$HostGroup;
            "templates"=$Template;
            "macros"=$Macros;
            "interfaces"=$Interfaces
        }; 
        #This is the same as $Global:ZXAPIToken | ConvertFrom-SecureString -AsPlainText but this worsk also for PS 5.1
        "auth" = "test" #[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR(($Global:ZXAPIToken)));
        "id" = 1;
    }

        #Convert the ps object to json. It is crucial to use a correct value for the -Depth
        $Json = $PSObj | ConvertTo-Json -Depth 5

        #Show JSON Request if -ShowJsonRequest switch is used
        If ($ShowJsonRequest -or $WhatIf){
            Write-Host -ForegroundColor Yellow "JSON REQUEST"
            $PSObjShow = $PSObj
            $PSObjShow.auth = "*****"
            $JsonShow = $PSObjShow | ConvertTo-Json -Depth 5
            Write-Host -ForegroundColor Cyan $JsonShow
        }

}