<#
Stricktly dirty automation that compares existing AdobeReader package version with Version on Adobe's website.
If web version is greater then MECM version, Download it.
#>

$CurrentWorkingDirectory = Get-Location

Set-Location "$($SiteCode):"

$AllAppTimeAndName = Get-CMApplication -Name "*Adobe" -fast 
[System.Version]$CurrentAppVersion = $AllAppTimeAndName.softwareVersion

$year = (get-date).year
$findurl = 'https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/'
$StartingContent = Invoke-Webrequest $findurl
$URLList = $StartingContent.Links

$versionlist = foreach($item in $URLList){

    If ($item.innertext -like "*Planned update*$year"){
        $a = $item.innertext -replace "[^0-9.]"
        $a.substring(0,12)
    }
}

$latestversion = $versionlist | Sort-Object -Descending | Select-Object -first 1
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
        If ($item.innertext -like "*AcroRdrDCUpd$latestversion.msp"){
            $downloadurl = $item.href
            $MSPname = $item.innerText
        }
    }
    
    Remove-Item  "$PSScriptroot\Install Files\AdobeReaderDC\*" -Confirm:$true
    
    Invoke-WebRequest -Uri $downloadurl -OutFile "$PSScriptroot\Install Files\AdobeReaderDC\$MSPname"

    #Notify User of update
    New-BurntToastNotification -Text "Adobe Reader Update", "A new version of Adobe Reader has been downloaded, Please create new application package" -AppLogo "$PSScriptroot\data\icons\adobe.ico" 
}

Set-Location $CurrentWorkingDirectory
