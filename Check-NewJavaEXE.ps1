<#
#>
$CurrentWorkingDirectory = Get-Location

Set-Location "$($SiteCode):"

#Jank ass way of getting the latest version of java online
$info = Invoke-WebRequest -uri "https://www.oracle.com/java/technologies/javase/8u-relnotes.html"
$list = $info.links.href | Where-Object {$info.links.innerText -eq "GA"}
$cleanerList = $list | Where-Object {$_ -like "*8U*"}
$cleanestlist = ForEach($item in $cleanerList){
    $a = $item.replace("/java/technologies/javase/","")
    $b = $a.replace("-relnotes.html","")
    $c = $b.replace("products-doc-","")
    $d = $c.replace("-revision-builds","")
    $d
}
$latestJava8Version = $cleanestlist[0]
[System.Version]$AvailableVersion = "1."+$latestJava8Version.replace("u",".")

$AllAppTimeAndName = Get-CMApplication -Name "Java * Update" -fast 
$lastmodifiedtime = $AllAppTimeAndName.DateLastModified | Sort-Object -Descending | Select-Object -First 1
$Version = ($AllAppTimeAndName | Where-Object {$_.DateLastModified -eq $lastmodifiedtime}).SoftwareVersion
[System.Version]$CurrentAppVersion = $Version

if($AvailableVersion -gt $CurrentAppVersion){

    $url = "https://www.oracle.com/java/technologies/downloads/#java8" 
    $PageInfo = Invoke-WebRequest -Uri $url

    $DownloadItems = @(
        "jre-$latestJava8Version-windows-i586.exe",
        "jdk-$latestJava8Version-windows-i586.exe",
        "jre-$latestJava8Version-windows-x64.exe",
        "jdk-$latestJava8Version-windows-x64.exe"
    )

    $DownLoadPath = @(
        "$PSScriptRoot\Install Files\JavaX86\JRE",
        "$PSScriptRoot\Install Files\JavaX86\JDK",
        "$PSScriptRoot\Install Files\JavaX64\JRE",
        "$PSScriptRoot\Install Files\JavaX64\JDK"
    )

    $list = $PageInfo.Links

    $x=0
    While($x -lt 4){

        foreach($item in $list){
            If ($item.innertext -like $DownloadItems[$x]){
                $DownloadUrl = $item | Select-Object -ExpandProperty "Data-File"
                $EXEname = $item.innerText 
            }
        }

        $Path = $DownloadPath[$x]

        Remove-Item  "$Path\*" -Confirm:$false

        Invoke-WebRequest -Uri $DownloadUrl -OutFile "$path\$EXEname"

        $x++
    }

    #Notify User of update
    New-BurntToastNotification -Text "Java Update $latestJava8Version", "A new version of Java has been downloaded, Please create new application package" -AppLogo "$PSScriptroot\data\icons\Java.ico" 
}

Set-Location $CurrentWorkingDirectory
