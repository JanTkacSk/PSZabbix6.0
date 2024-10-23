function Set-ZXHostTag{
    param(
        [string]$HostName,
        [string]$HostId,
        [string]$AddTag, 
        [string]$AddValue,
        [string]$RemoveTag,
        [string]$RemoveValue,
        [switch]$RemoveAllTags,
        [switch]$WhatIf,
        [switch]$ShowJsonRequest,
        [switch]$ShowJsonResponse,
        [bool]$Continue

    )
    #Validate Parameters
    if ($AddTag -eq $RemoveTag -and $AddValue -eq $RemoveValue){
        Write-Host -ForegroundColor Red "You are trying to add and remove an identical tag/value pair. Choose only one operation."
        continue
    }
    if($RemoveTag -and -not $RemoveValue ) {
        Write-Host -ForegroundColor Yellow "-RemoveValue parameter was not specified. This will remove all $RemoveTag tags regardless of the value. Continue ?"
        Pause    
    }

    #Funcions
    function DateToString{
        (Get-Date).ToString("2024-MM-dd_HH.mm.ss.ffff")
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
    $PSObj  = [PSCustomObject]@{
        "jsonrpc" = "2.0"; 
        "method" = "host.update"; 
        "params" = [PSCustomObject]@{
            "hostid" = $HostId
        }; 
        "auth" = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR(($Global:ZXAPIToken))); #This is the same as $Global:ZXAPIToken | ConvertFrom-SecureString -AsPlainText but this worsk also for PS 5.1
        "id" = "1"
    }

    if($AddTag -or $RemoveTag -or $RemoveAllTags){

        if($HostId){
            $ZXHost = Get-ZXHost -HostID $HostId -IncludeTags
        }
        elseif ($HostName){
            $ZXHost = Get-ZXHost -Name $HostName -IncludeTags
        }
        $PSObj.params.hostid = $ZXHost.hostid
        $PSObj.params |  Add-Member -MemberType NoteProperty -Name "host" -Value $ZXHost.host
        $PSObj.params |  Add-Member -MemberType NoteProperty -Name "name" -Value $ZXHost.name
        [System.Collections.ArrayList]$TagList = $ZXHost.tags

        if($AddTag){
            $TagList =  $Taglist += [PSCustomObject]@{"tag"= $AddTag; "value"=$AddValue}
        }

        if($RemoveTag){
            if (!$RemoveValue){                
                $TagList = $TagList | Where-Object {$_.tag -cne $RemoveTag}
            }
            if($RemoveValue){
                $TagList.Remove(($TagList|Where-Object {$_.tag -ceq $RemoveTag -and $_.value -ceq $RemoveValue}))
            }
        }
        
        if($RemoveAllTags){
            $TagList = @()
        } 

        $PSObj.params |  Add-Member -MemberType NoteProperty -Name "tags" -Value @($TagList)

    }
    
    $Json = $PSObj | ConvertTo-Json -Depth 5

    #Show JSON Request if -ShowJsonRequest switch is used
    If ($ShowJsonRequest -or $WhatIf){
        Write-Host -ForegroundColor Yellow "JSON REQUEST"
        $PSObjShow = $PSObj
        $PSObjShow.auth = "*****"
        $JsonShow = $PSObjShow | ConvertTo-Json -Depth 5
        Write-Host -ForegroundColor Cyan $JsonShow
    }
    
    #Make the API call
    if(!$Whatif){
        $Request = Invoke-RestMethod -Uri $ZXAPIUrl -Body $Json -ContentType "application/json" -Method Post
    }

    If ($ShowJsonResponse){
        Write-Host -ForegroundColor Yellow "JSON RESPONSE"
        Write-Host -ForegroundColor Cyan $($request | ConvertTo-Json -Depth 5)
    }

    #This will be returned by the function
    if($null -ne $Request.error){
        $Request.error
        return
    }
    elseif($null -ne $Request.result){
        $Request.result
        return
    }
    elseif(!$WhatIf) {
        Write-Host -ForegroundColor Yellow "No result"
        return
    }
    
}


