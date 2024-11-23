function New-Taglist{
    param(
        [string]$TagList
    )

    $InputList = "tag1=value1,tag2=value2".Split(",")
    $OutputList = @()

    foreach($Tag in $InputList){
        $NameValuePair = $Tag.Split("=")
        $OutputList += [PSCustomObject]@{
            "Tag"= $NameValuePair[0]
            "Value"= $NameValuePair[1]
        }
        
    }
    $OutputList

}