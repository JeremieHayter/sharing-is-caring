<#

Check most recent version of chrome and compare to msi in install folder. 

If new version is greater, download and notify with toast notification.

If not, do nothing. 

https://chromeenterprise.google/intl/en_ca/browser/download/googlechromestandaloneenterprise64.msi
https://chromeenterprise.google/intl/en_ca/browser/download/thank-you/

For additions coolness, make sure to download the BurntToast Module

Install-Module -Name BurntToast -Repository PSGallery
#>

$CurrentWorkingDirectory = Get-Location

Set-Location "$($SiteCode):"

# Get Verion Info from SCCM
$AllAppTimeAndName = Get-CMApplication -Name "*Chrome*" -fast | Select-Object -Property DateCreated,LocalizedDisplayName
$name = ($AllAppTimeAndName | Sort-Object -Property DateCreated -Descending | Select-Object -First 1).localizedDisplayName
[System.Version]$LatestAppVersion = $Name -replace "[^0-9.]"

<# Get latest chrome version from the web #
Chrome Dev's use omahaproxy.appspot.com for version info.
#>
$j = Invoke-WebRequest 'https://omahaproxy.appspot.com/all.json' | ConvertFrom-Json
[System.Version]$CurrentVersion = $j.versions[4].current_version

#Compare SCCM Application version with Current available version
if($CurrentVersion -gt $LatestAppVersion){

    #Clear download folder 
    Remove-Item  "$PSScriptroot\Install Files\Chrome\*"

    #Download the latest release:
    $ProgressPreference = 'SilentlyContinue'
    $url = "https://dl.google.com/tag/s/dl/chrome/install/googlechromestandaloneenterprise64.msi"
    Invoke-WebRequest -Uri $url -OutFile "$PSScriptroot\Install Files\Chrome\googlechromestandaloneenterprise64.msi"

    #Notify User of update
    if(Get-Module -ListAvailable -Name BurntToast){
        New-BurntToastNotification -Text "Google Chrome Update", "A new version of Google Chrome has been downloaded, Please create new application package" -AppLogo "$PSScriptroot\data\icons\chrome.ico"
    }
    else{
        Write-Host "A new version of Google Chrome has been downloaded, Please create new application package" -ForegroundColor Green
    }
}

Set-Location $CurrentWorkingDirectory