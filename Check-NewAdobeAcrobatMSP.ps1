<#
Stricktly dirty automation that compares existing AdobeReader package version with Version on Adobe's website.
If web version is greater then MECM version, Download it.
#>

$CurrentWorkingDirectory = Get-Location

Set-Location "$($SiteCode):"

$AllAppTimeAndName = Get-CMApplication -Name "Adobe Acrobat" -fast 
[System.Version]$CurrentAppVersion = $AllAppTimeAndName.softwareVersion

$year = (get-date).year
$findurl = 'https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/'
$StartingContent = Invoke-Webrequest $findurl
$URLList = $StartingContent.Links

$versionlist = foreach($item in $URLList){

    If ($item.innertext -like "17*Planned update*$year"){
        $a = $item.innertext -replace "[^0-9.]"
        $a.substring(0,12)
    }
}

$latestversion = $versionlist | Sort-Object -Descending | Select-Object -first 1
$MSPVersion = $latestversion.replace(".","")
[System.Version]$LatestAppVersion = $latestversion

if($LatestAppVersion -gt $CurrentAppVersion){

    foreach($item in $URLList){
        If ($item.innertext -like "$latestversion*$year"){
            $a = $item.href -replace "\#(.*)",""
        }
    }
    
    $url = $findurl+$a
    $content = Invoke-WebRequest -Uri $url 
    $list = $content.Links
    
    foreach($item in $list){
        If ($item.innertext -like "*Acrobat2017Upd$MSPVersion.msp"){
            $downloadurl = $item.href
            $MSPname = $item.innerText
        }
    }
    
    Remove-Item  "$PSScriptroot\Install Files\AdobeAcrobat2017\*" -Confirm:$false
    
    Invoke-WebRequest -Uri $downloadurl -OutFile "$PSScriptroot\Install Files\AdobeAcrobat2017\$MSPname"

    #Notify User of update
    New-BurntToastNotification -Text "Adobe Acrobat Update", "A new version of Adobe Acrobat has been downloaded, Please create new application package" -AppLogo "$PSScriptroot\data\icons\adobe.ico"
}

Set-Location $CurrentWorkingDirectory
