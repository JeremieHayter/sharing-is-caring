<#
For additions coolness, make sure to download the BurntToast Module

Install-Module -Name BurntToast -Repository PSGallery
#>
$Location = Get-Location
Set-Location "$($SiteCode):"

$ApplicationName = "Notepad++"
$AllAppTimeAndName = Get-CMApplication -Name "*$ApplicationName*" -fast | Select-Object -Property DateCreated,LocalizedDisplayName,SoftwareVersion
[System.version]$MECMVersion = $AllAppTimeAndName.SoftwareVersion
 
# Let's go directly to the website and see what it lists as the current version
$BaseUri = "https://notepad-plus-plus.org"
$BasePage = Invoke-WebRequest -Uri $BaseUri -UseBasicParsing
$ChildPath = $BasePage.Links | Where-Object { $_.outerHTML -like '*Current Version*' } | Select-Object -ExpandProperty href
$CurrentVersion = $ChildPath -replace "[^0-9.]"
[System.version]$CurrentVersion1 = $CurrentVersion

if($CurrentVersion1 -gt $MECMVersion){

    #Clear download folder 
    Remove-Item  "$PSScriptroot\Install Files\$ApplicationName\*" -Confirm:$false

    # Now let's go to the latest version's page and find the installer
    $DownloadPageUri = $BaseUri + $ChildPath
    $DownloadPage = Invoke-WebRequest -Uri $DownloadPageUri -UseBasicParsing
    $DownloadUrl = $DownloadPage.Links | Where-Object { $_.outerHTML -like '*npp.*.Installer.x64.exe"*' } | Select-Object -ExpandProperty href | Select-Object -First 1

    Invoke-WebRequest -Uri $DownloadUrl -OutFile "$PSScriptRoot\Install Files\$ApplicationName\npp.$CurrentVersion.Installer.x64.exe" | Out-Null

    #Notify User of update
    if(Get-Module -ListAvailable -Name BurntToast){
        New-BurntToastNotification -Text "$ApplicationName Update", "Version: $CurrentVersion of $ApplicationName has been downloaded, Please create new application package" -AppLogo "$PSScriptroot\data\icons\Notepad++.ico" 
    }
    else{
        Write-Host "Version: $CurrentVersion of $ApplicationName has been downloaded, Please create new application package" -ForegroundColor Green
    }
}
Set-Location $Location