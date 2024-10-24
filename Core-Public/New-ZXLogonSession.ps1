function New-ZXLogonSession {
    param(
        [switch]$UserData,
        [switch]$Save,
        [switch]$Load,
        [string]$LoadUrl,
        [string]$LoadID,
        [switch]$ShowJsonRequest,
        [switch]$ShowJsonResponse,
        [switch]$WhatIf,
        [switch]$ShowSessionID

    )

    if(!$RemoveAllSettings -and !$Load -and !$LoadUrl -and !$LoadID){
        $Global:ZXAPIUrl = Read-Host -Prompt "Enter the zabbix API URL"
        $UserName = Read-Host -Prompt "Enter the zabbix API User Name"
        $Password = Read-Host -AsSecureString -Prompt "Enter your password"
    }

    $SaveLocation = "$($env:LOCALAPPDATA)\ZXModule\Login\LogonData.txt"
    if (!( Test-Path $SaveLocation)){
        New-Item -ItemType File $SaveLocation -Force
    }

    if($Save){       
        $NewObj = [pscustomobject]@{
            "Id" = ""
            "URL" = $ZXAPIUrl
            "UserName" = $UserName
            "Password" = $Password | ConvertFrom-SecureString
        }
        #Get the data from the LogonData.txt, filter out the entry with the same URL you have entered in case it exists.
        #This way you can enter the same url again and the password and name will be overwritten in the next steps
        $LogonData = @(Get-Content $SaveLocation | ConvertFrom-Json | Where-Object {$_.URL -ne $NewObj.URL })
        $LogonData += $NewObj
        $LogonData | ForEach-Object -Begin {$i=0} -Process { $_.Id = $i;$i++} -End {Remove-Variable i}
        $LogonData | ConvertTo-Json | Out-File $SaveLocation -Force
    }

    if($Load){
        $LogonData = Get-Content $SaveLocation | ConvertFrom-Json
        $LogonData | ForEach-Object {
            Write-Host -NoNewline "[$($_.Id)]"; 
            Write-Host -NoNewline -ForegroundColor Yellow " $($_.URL)"; 
            Write-Host " - $($_.UserName)"
        }
        $Choice = Read-Host -Prompt "Select the number and press enter"

        $UserName = $LogonData[$Choice].UserName
        $Password = $LogonData[$Choice].Password | ConvertTo-SecureString
        $Global:ZXApiURL = $LogonData[$Choice].URL
    }

    if($LoadUrl){
        $LogonData = (Get-Content $SaveLocation | ConvertFrom-Json) | Where-Object {$_.URL -eq $LoadUrl}
        $UserName = $LogonData.UserName
        $Password = $LogonData.Password | ConvertTo-SecureString
        $Global:ZXApiURL = $LogonData.URL
    }

    #Basic PS Object wich will be edited based on the used parameters and finally converted to json
    $PSObject = [PSCustomObject]@{
        "jsonrpc" = "2.0";
        "method" = "user.login";
        "params" = @{
            "username" = $UserName;
            "password" = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR(($Password)));
            "userData" = "$([bool]$UserData)"
        }
        "id" = "1"
    }

    $JSON = $PSObject | ConvertTo-Json
    
    if($ShowJsonRequest){
        Write-Host -ForegroundColor Yellow "JSON REQUEST"
        $PSObjShow = $PSObject
        $PSObjShow.params.password = "*****"
        $JsonShow = $PSObjShow | ConvertTo-Json
        Write-Host -ForegroundColor Cyan $JsonShow
    }

    #Make the API call
    if(!$WhatIf){
        $request = Invoke-RestMethod -Uri $ZXAPIUrl -Body $Json -ContentType "application/json" -Method Post -SessionVariable global:websession
    }

    If ($ShowJsonResponse){
        #Create a deep copy of the $Request Object. This is necessary because otherwise changing the $PSObjShow is referencing the same object in memory as $Request
        $PSObjShow = $Request.result | ConvertTo-Json -Depth 5 | ConvertFrom-Json 
        if($PSObjShow.sessionid) {
            $PSObjShow.sessionid = "*****"
        }
        Write-Host -ForegroundColor Yellow "JSON RESPONSE"
        Write-Host -ForegroundColor Cyan $($PSObjShow | ConvertTo-Json -Depth 5)
    }

    #This will be returned by the function
    if($null -ne $Request.error){
        $Request.error
        return
    } 
    else {
        $Global:ZXAPIToken = $Request.result.sessionid | ConvertTo-SecureString -AsPlainText -Force
        if($ShowSessionID){
            $Request.result
            return   
        }
        else{
            $request.result.sessionid = "*****"
            $Request.result
            return    
        }
    }   
}