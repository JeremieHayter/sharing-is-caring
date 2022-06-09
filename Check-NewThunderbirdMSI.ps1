<#
For additions coolness, make sure to download the BurntToast Module

Install-Module -Name BurntToast -Repository PSGallery
#>
$CurrentWorkingDirectory = Get-Location

Set-Location "$($SiteCode):"

$AllAppTimeAndName = Get-CMApplication -Name "*Thunderbird*" -fast | Select-Object -Property DateCreated,LocalizedDisplayName
$name = ($AllAppTimeAndName | Sort-Object -Property DateCreated -Descending | Select-Object -First 1).localizedDisplayName
[System.Version]$LatestSCCMAppVersion = $Name -replace "[^0-9.]"

$ff = Invoke-WebRequest  "https://product-details.mozilla.org/1.0/thunderbird_versions.json" | ConvertFrom-Json

[System.Version]$CurrentVersion = $ff.LATEST_THUNDERBIRD_VERSION
$VersoinNumber = $ff.LATEST_THUNDERBIRD_VERSION

if($CurrentVersion -gt $LatestSCCMAppVersion){

    #Clear download folder 
    Remove-Item  "$PSScriptroot\Install Files\ThunderBird\*"

    #Download the latest release:
    $ProgressPreference = 'SilentlyContinue'
    $url = "https://download.mozilla.org/?product=thunderbird-$VersoinNumber-msi-SSL&os=win64&lang=en-US"
    Invoke-WebRequest -Uri $url -OutFile "$PSScriptroot\Install Files\Thunderbird\Thunderbird Setup $VersoinNumber.msi"

    #Notify User of update
    if(Get-Module -ListAvailable -Name BurntToast){
        New-BurntToastNotification -Text "Thunderbird Update $versionnumber", "A new version of Thunderbird has been downloaded, Please create new application package" -AppLogo "$PSScriptroot\data\icons\Thunderbird.ico"
    }
    else{
        Write-Host "A new version of Thunderbird has been downloaded, Please create new application package" -ForegroundColor Green
    }
}
Set-Location $CurrentWorkingDirectory