function Get-ZXTemplate {
    param(
        [array]$Name,
        [array]$Id,
        [array]$VisibleName,
        [string]$NameSearch,
        [string]$VisibleNameSearch,
        [switch]$IncludeHosts,
        [switch]$IncludeMacros,
        [switch]$IncludeParentTemplates,
        [switch]$ShowJsonRequest,
        [switch]$ShowJsonResponse,
        [switch]$WhatIf
    )

    function AddFilter($PropertyName,$PropertyValue){
        #Check if filter is already in the object or not and if not, add it.
        if ($null -eq $PSObj.params.filter){
            $PSObj.params | Add-Member -MemberType NoteProperty -Name "filter" -Value ([PSCustomObject]@{})
        }
        #Add a specific property to the filter
        $PSObj.params.filter | Add-Member -MemberType NoteProperty -Name $PropertyName -Value $PropertyValue
    }

    #Function to add a Search parameter to the PS object
    function AddSearch($PropertyName,$PropertyValue){
        #Check if search is already in the object or not and if not, add it.
        if ($null -eq $PSObj.params.search){
            $PSObj.params | Add-Member -MemberType NoteProperty -Name "search" -Value ([PSCustomObject]@{})
        }
        #Add a specific property to the filter
        $PSObj.params.search | Add-Member -MemberType NoteProperty -Name $PropertyName -Value $PropertyValue
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
        "method" = "template.get";
        "params" = [PSCustomObject]@{};
        "auth" = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR(($Global:ZXAPIToken))); #This is the same as $Global:ZXAPIToken | ConvertFrom-SecureString -AsPlainText but this worsk also for PS 5.1
        "id" = 1
    }

    #Template name in the zabbix api is host, not name, therefore property name is "host"...
    if ($NameSearch){
        AddSearch -PropertyName "host" -PropertyValue $NameSearch
    }

    if ($VisibleNameSearch){
        AddSearch -PropertyName "name" -PropertyValue $VisibleNameSearch
    }
    if ($Name){
        AddFilter -PropertyName "host" -PropertyValue $Name
    }
    if ($VisibleName){
        AddFilter -PropertyName "name" -PropertyValue $VisibleName
    }
    if ($Id){
        $PSObj.params | Add-Member -MemberType NoteProperty -Name "templateids" -Value $Id
    }

    # Add "selectHosts" parameter to return all hosts linked tho the templates.
    if ($IncludeHosts){
        $PSObj.params | Add-Member -MemberType NoteProperty -Name "selectHosts" -Value @("host","name","description","status")
    }
    #Add "selectMacros" paremeter to return all macros of the template
    if ($IncludeMacros) {
        $PSObj.params | Add-Member -MemberType NoteProperty -Name "selectMacros" -Value "extend"
    }
    #Add "selectPatentTemplates" to return all templates that are are a child of this template, sounds counterintuitive
    if ($IncludeParentTemplates) {
        $PSObj.params | Add-Member -MemberType NoteProperty -Name "selectParentTemplates" -Value $IncludeParentTemplates
    }


    $Json =  $PSObj | ConvertTo-Json -Depth 5

    #Show JSON Request if -ShowJsonRequest switch is used
    If ($ShowJsonRequest -or $WhatIf){
        Write-Host -ForegroundColor Yellow "JSON REQUEST"
        $PSObjShow = $PSObj
        $PSObjShow.auth = "*****"
        $JsonShow = $PSObjShow | ConvertTo-Json -Depth 5
        Write-Host -ForegroundColor Cyan $JsonShow
    }
    
    #Make the API call
    if (!$WhatIf){
        $Request = Invoke-RestMethod -Uri $ZXAPIUrl -Body $Json -ContentType "application/json" -Method Post
    }
    
    If ($ShowJsonResponse){
        Write-Host -ForegroundColor Yellow "JSON RESPONSE"
        Write-Host -ForegroundColor Cyan $($request.result | ConvertTo-Json -Depth 5)
    }

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