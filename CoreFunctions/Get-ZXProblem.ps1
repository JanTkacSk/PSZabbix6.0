function Get-ZXProblem {
    param(
        [array]$HostID,
        [array]$EventID,
        [switch]$IncludeTags,
        [switch]$Recent,
        [switch]$ShowJsonRequest,
        [switch]$ShowJsonResponse,
        [switch]$WhatIf
    )

    function ConvertFrom-UnixEpochTime ($UnixEpochTime){
        $customDate = (Get-Date -Date "01-01-1970") + ([System.TimeSpan]::FromSeconds($UnixEpochTime))
        $customDate
    }

    #A function that formats and displays the json request that is used in the API call, it removes the API token value and replaces it with *****
    function ShowJsonRequest {
        Write-Host -ForegroundColor Yellow "JSON REQUEST"
        $PSObjShow = $PSObj
        $PSObjShow.auth = "*****"
        $JsonShow = $PSObjShow | ConvertTo-Json -Depth 5
        Write-Host -ForegroundColor Cyan $JsonShow
    }
    

    #Basic PS Object wich will be edited based on the used parameters and finally converted to json
    $PSObj = [PSCustomObject]@{
        "jsonrpc" = "2.0";
        "method" = "problem.get";
        "params" = [PSCustomObject]@{};
        "id" = 1;
        "auth" = $ZXAPIToken | ConvertFrom-SecureString -AsPlainText; 
    }

    if ($HostID){
        $PSObj.params | Add-Member -MemberType NoteProperty -Name "hostids" -Value $HostID
    }
    if ($EventID){
        $PSObj.params | Add-Member -MemberType NoteProperty -Name "eventids" -Value $EventID
    }
    if ($IncludeTags){
        $PSObj.params | Add-Member -MemberType NoteProperty -Name "selectTags" -Value @("tag","value")
    }
    if ($Recent){
        $PSObj.params | Add-Member -MemberType NoteProperty -Name "recent" -Value "true"
    }
    #$PSObj.params.output = "extend"
    $Json =  $PSObj | ConvertTo-Json -Depth 3

    #Show JSON Request if -ShowJsonRequest switch is used
    If ($ShowJsonRequest){
        Write-Host -ForegroundColor Yellow "JSON REQUEST"
        $PSObjShow = $PSObj
        $PSObjShow.auth = "*****"
        $JsonShow = $PSObjShow | ConvertTo-Json -Depth 5
        Write-Host -ForegroundColor Cyan $JsonShow
    }
    
    #Make the API call
    if(!$WhatIf){
        $Request = Invoke-RestMethod -Uri $ZXAPIUrl -Body $Json -ContentType "application/json" -Method Post
    }

    If ($ShowJsonResponse){
        Write-Host -ForegroundColor Yellow "JSON RESPONSE"
        Write-Host -ForegroundColor Cyan $($request.result | ConvertTo-Json -Depth 5)
    }
    
    #Add human readable creation time to the object
    $Request.result | Add-Member -MemberType ScriptProperty -Name CreationTime -Value {ConvertFrom-UnixEpochTime($this.clock)}
    
    #This will be returned by the function
    if($null -ne $Request.error){
        $Request.error
        return
    } 
    else {
        $Request.result
        return
    }
}
