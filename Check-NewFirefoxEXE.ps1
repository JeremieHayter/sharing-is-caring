<#
For additions coolness, make sure to download the BurntToast Module

Install-Module -Name BurntToast -Repository PSGallery
#>

$CurrentWorkingDirectory = Get-Location

Set-Location "$($SiteCode):"

$AllAppTimeAndName = Get-CMApplication -Name "*Firefox*" -fast | Select-Object -Property DateCreated,LocalizedDisplayName
$name = ($AllAppTimeAndName | Sort-Object -Property DateCreated -Descending | Select-Object -First 1).localizedDisplayName
[System.Version]$LatestSCCMAppVersion =  ($Name -replace "x64") -replace "[^0-9.]"

$ff = Invoke-WebRequest  "https://product-details.mozilla.org/1.0/firefox_versions.json" | ConvertFrom-Json
[System.Version]$CurrentVersion = $ff.LATEST_FIREFOX_VERSION

if($CurrentVersion -gt $LatestSCCMAppVersion){

    #Clear download folder 
    Remove-Item  "$PSScriptroot\Install Files\Firefox\*"

    #Download the latest release:
    $ProgressPreference = 'SilentlyContinue'
    $url = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-CA"
    Invoke-WebRequest -Uri $url -OutFile "$PSScriptroot\Install Files\firefox\firefox.exe"
    Rename-Item -Path "$PSScriptroot\Install Files\firefox\firefox.exe" -NewName "Firefox Setup $currentversion.exe"

    #Notify User of update
    if(Get-Module -ListAvailable -Name BurntToast){
        New-BurntToastNotification -Text "FireFox Update", "A new version of Firefox has been downloaded, Please create new application package" -AppLogo "$PSScriptroot\data\icons\Firefox.ico" 
    }
    else{
        Write-Host "A new version of Firefox has been downloaded, Please create new application package" -ForegroundColor Green
    }
}

Set-Location $CurrentWorkingDirectory