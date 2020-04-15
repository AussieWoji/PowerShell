<#

.SYNOPSIS
    Set of tools for commonly performed tasks.

.DESCRIPTION
    Set of tools for commonly performed tasks.

.EXAMPLE
    Get-Help PWUtilities -Full

.PARAMETER Get-PWPing
    Tests the connections to the servername provided. Use Get-Help Get-PWPing -Full for more information

.PARAMETER Get-PWNSLookup
    Tests the connections to the servername provided. Use Get-Help Get-PWNSLookup -Full for more information

.PARAMETER Remove-PWOldLogs
    Removes files that were last accessed greater than 7 days ago in specified folder path. Use Get-Help Get-PWOldLogs -Full for more information

.PARAMETER Get-DHIISAPPPool
    Lists app pools, usernames, and passwords from a given server. Use Get-Help Get-DHIISAPPPool -Full for more information

.PARAMETER Get-PWIISStatus
    Displays status of the IIS Windows service. Use Get-Help Get-PWIISStatus -Full for more information

.PARAMETER Get-PWAppPoolStatus
    Displays status of provided IIS app pool. Use Get-Help Get-PWAppPoolStatus -Full for more information

.PARAMETER Start-PWAppPool
    Start the provided IIS app pool. Use Get-Help Start-PWAppPool -Full for more information

.PARAMETER Stop-PWAppPool
    Stop the provided IIS app pool. Use Get-Help Stop-PWAppPool -Full for more information

.PARAMETER Restart-PWAppPool
    Restart the provided IIS app pool. Use Get-Help Restart-PWAppPool -Full for more information

.PARAMETER Get-PWServiceStatus
    Displays status of provided Windows service. Use Get-Help Get-PWServiceStatus -Full for more information

.PARAMETER Start-PWService
    Starts the provided Windows service. Use Get-Help Start-PWService -Full for more information

.PARAMETER Stop-PWService
    Stops the provided Windows service. Use Get-Help Stop-PWService -Full for more information

.PARAMETER Restart-PWService
    Restarts the provided Windows service. Use Get-Help Restart-PWService -Full for more information

.PARAMETER Get-PWInstalledApps
    Displays installed application/s. Use Get-Help Get-PWInstalledApps -Full for more information

.PARAMETER Get-PWDriveFreeSpace
    Displays the drive free space for the drive provided. Use Get-Help Get-PWDriveFreeSpace -Full for more information

.PARAMETER Get-PWFolderSpace
    Displays the folder sizes of the provided drive. Use Get-Help Get-PWFolderSpace -Full for more information

.PARAMETER New-PWDrive
    Maps a drive. Use Get-Help Get-PWDrive -Full for more information

.PARAMETER Remove-PWDrive
    Removes drive mappings. Use Get-Help Get-PWDrive -Full for more information

.PARAMETER Get-PWWhenUserAccountPasswordExpires
    Gets date password was last set and when password will expire for a user account

.NOTES
    Created by: Paul Wojtysiak
    Created: 02/01/2017
    Requirement: None

#>

#region Remove-PWOldLogs
Function Remove-PWOldLogs ($pwServer, $drive, $folderPath)
{

    <#

    .SYNOPSIS
        Removes files that were last accessed greater than 7 days ago in specified folder path.

    .DESCRIPTION
        Removes files that were last accessed greater than 7 days ago in specified folder path.

    .EXAMPLE
        Get-PWOldLogs  <short server name> <drive letter> <path to files to remove>

    .EXAMPLE
        Get-Help Get-PWOldLogs -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $drive
        Drive to remove the files from.

    .PARAMETER $folderPath
        Folder path to the files to be removed.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    New-PSDrive -Name $pwServer-$drive -PSProvider FileSystem -Credential $userCredentials -Root \\$pwFQServer\$drive$ -Scope global
    Set-Location $pwServer-$drive`:

    If (Test-Path -Path $folderPath)
    {
        $colItems = (Get-ChildItem $folderPath | Measure-Object -property length -sum)
        "$folderPath -- " + "{0:N2}" -f ($colItems.sum / 1MB) + " MB"

        $a = Get-ChildItem $folderPath
        foreach($x in $a)
        {
            $y = ((Get-Date) – $x.LastAccessTime).Days
            if ($y -gt 7 -and $x.PsISContainer -ne $True)
            {
                $x.Delete()
            }
        }

        $colItems = (Get-ChildItem $folderPath | Measure-Object -property length -sum)
        "$folderPath -- " + "{0:N2}" -f ($colItems.sum / 1MB) + " MB"
    }
    Remove-PSDrive -Name $pwServer-$drive -Force
}
#endregion

#region Get-DHIISAPPPool
#Dustin - https://rosedaleroad.wordpress.com/
#Pipe to Format-Table -Autosize
#needs fully qualified server name
Function Get-DHIISAPPPool ([String[]]$pwServer,[switch]$ShowPassword)
{

    <#

    .SYNOPSIS
        Lists app pools, usernames, and passwords from a given server.

    .DESCRIPTION
        Based on the provided server it will return the app pool names, there usernames, and optionally their passwords.

    .EXAMPLE
        Get-DHIISAPPPool <short server name> -ShowPassword:<$true/$false>

    .EXAMPLE
        Get-Help Get-DHIISAPPPool -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $ShowPassword
        Switch to determine whether to return the app pool password or not.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {
        if(Get-Module -ListAvailable webadministration){
            Import-Module webadministration
            $PoolCollection = (Get-ItemProperty "IIS:\apppools").children.keys 
            $Computer = $env:COMPUTERNAME
            $AppCollection = @()
            foreach ($PoolName in $PoolCollection) {
                If($PoolName.Equals("DefaultAppPool") -ne $true -and $PoolName.Equals("Classic .NET AppPool") -ne $true `
                -and $PoolName.Equals(".NET v2.0") -ne $true -and $PoolName.Equals(".NET v2.0 Classic") -ne $true `
                -and $PoolName.Equals("ASP.NET v3.0") -ne $true -and $PoolName.Equals("ASP.NET v3.0 Classic") -ne $true `
                -and $PoolName.Equals("ASP.NET v4.0") -ne $true -and $PoolName.Equals("ASP.NET v4.0 Classic") -ne $true `
                -and $PoolName.Equals(".NET v4.5") -ne $true -and $PoolName.Equals(".NET v4.5 Classic") -ne $true){
                    $t = New-Object System.Object
                    $t | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value "$Computer" 
                    $t | Add-Member -MemberType NoteProperty -Name "AppPool" -Value "$PoolName"
                    $u = (Get-Item IIS:\AppPools\$PoolName).processmodel.username
                    $t | Add-Member -MemberType NoteProperty -Name "UserName" -Value "$u" 
                    If ($Using:ShowPassword){
                        $p = (Get-Item IIS:\AppPools\$PoolName).processmodel.password
                        $t | Add-Member -MemberType NoteProperty -Name "Password" -Value "$p"
                    } #If
                    $AppCollection += $t
                }#if
            }#foreach
            Remove-Module webadministration
            <#write-output#> $AppCollection
        }#if
        #else{Write-Output "$using:ComputerName IIS not installed"}
    } | Sort-Object ComputerName | Select-Object -Property ComputerName, AppPool, UserName, Password #| Export-Csv -NoTypeInformation -Path $ScriptPath\iis-information.csv -Append #Invoke-Command
}#function
#endregion

#region Get-PWAppPoolStatus
Function Get-PWAppPoolStatus ($pwServer, $appPoolName)
{

    <#

    .SYNOPSIS
        Displays status of provided IIS app pool.

    .DESCRIPTION
        Displays status of provided IIS app pool.

    .EXAMPLE
        Get-PWAppPoolStatus <short server name> <app pool name>

    .EXAMPLE
        Get-Help Get-PWAppPoolStatus -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $appPoolName
        IIS app pool name.  This should be unique so only one pool is returned.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {
        param($apn)
        Import-Module WebAdministration
        $appPoolStatus = Get-WebAppPoolState $apn
        If ($appPoolStatus.Value -eq "Started") {
            Write-Host -ForegroundColor Green $appPoolStatus.Value
        }
        Else {
            Write-Host -ForegroundColor Red $appPoolStatus.Value
        }
    } -ArgumentList $appPoolName
}
#endregion

#region Start-PWAppPool
Function Start-PWAppPool ($pwServer, $appPoolName)
{

    <#

    .SYNOPSIS
        Start the provided IIS app pool.

    .DESCRIPTION
        Start the provided IIS app pool.

    .EXAMPLE
        Start-PWAppPool <short server name> <app pool name>

    .EXAMPLE
        Get-Help Start-PWAppPool -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $appPoolName
        IIS app pool name.  This should be unique so only one pool is returned.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {
        param($apn)
        Import-Module WebAdministration
        Start-WebAppPool $apn
        $appPoolStatus = Get-WebAppPoolState $apn
        If ($appPoolStatus.Value -eq "Started") {
            Write-Host -ForegroundColor Green $appPoolStatus.Value
        }
        Else {
            Write-Host -ForegroundColor Red $appPoolStatus.Value
        }
    } -ArgumentList $appPoolName
}
#endregion

#region Stop-PWAppPool
Function Stop-PWAppPool ($pwServer, $appPoolName)
{

    <#

    .SYNOPSIS
        Stop the provided IIS app pool.

    .DESCRIPTION
        Stop the provided IIS app pool.

    .EXAMPLE
        Stop-PWAppPool <short server name> <app pool name>

    .EXAMPLE
        Get-Help Stop-PWAppPool -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $appPoolName
        IIS app pool name.  This should be unique so only one pool is returned.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {
        param($apn)
        Import-Module WebAdministration
        Stop-WebAppPool $apn
        $appPoolStatus = Get-WebAppPoolState $apn
        If ($appPoolStatus.Value -eq "Stopped") {
            Write-Host -ForegroundColor Green $appPoolStatus.Value
        }
        Else {
            Write-Host -ForegroundColor Red $appPoolStatus.Value
        }
    } -ArgumentList $appPoolName
}
#endregion

#region Restart-PWAppPool
Function Restart-PWAppPool ($pwServer, $appPoolName)
{

    <#

    .SYNOPSIS
        Restart the provided IIS app pool.

    .DESCRIPTION
        Restart the provided IIS app pool.

    .EXAMPLE
        Restart-PWAppPool <short server name> <app pool name>

    .EXAMPLE
        Get-Help Restart-PWAppPool -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $appPoolName
        IIS app pool name.  This should be unique so only one pool is returned.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {
        param($apn)
        Import-Module WebAdministration
        Restart-WebAppPool $apn
        $appPoolStatus = Get-WebAppPoolState $apn
        If ($appPoolStatus.Value -eq "Started") {
            Write-Host -ForegroundColor Green $appPoolStatus.Value
        }
        Else {
            Write-Host -ForegroundColor Red $appPoolStatus.Value
        }
    } -ArgumentList $appPoolName
}
#endregion

#region Get-PWServiceStatus
#needs fully qualified server name
Function Get-PWServiceStatus ($pwServer, $serviceDisplayName)
{

    <#

    .SYNOPSIS
        Displays status of provided Windows service.

    .DESCRIPTION
        Displays status of provided Windows service.

    .EXAMPLE
        Get-PWServiceStatus <short server name> <service display name>

    .EXAMPLE
        Get-Help Get-PWServiceStatus -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $serviceDisplayName
        Windows Service name.  This should be unique so only one service is returned.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Write-Host -ForegroundColor Yellow $pwFQServer
    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {
        param($sdn)
        $serverStatus = Get-Service -DisplayName $sdn
        If ($serverStatus.Status -eq "Running") {
            Write-Host -ForegroundColor Green $serverStatus.Status
        }
        Else {
            Write-Host -ForegroundColor Red $serverStatus.Status
        }
    } -ArgumentList $serviceDisplayName
}
#endregion

#region Start-PWService
Function Start-PWService ($pwServers, $serviceDisplayName)
{

    <#

    .SYNOPSIS
        Starts the provided Windows service.

    .DESCRIPTION
        Starts the provided Windows service.

    .EXAMPLE
        Get-PWServiceStart <short server name> <service display name>

    .EXAMPLE
        Get-Help Get-PWServiceStart -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $serviceDisplayName
        Windows Service name.  This should be unique so only one service is returned.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Write-Host -ForegroundColor Yellow $pwFQServer
    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {
        Start-Service -DisplayName $serviceDisplayName
        $serverStatus = Get-Service -DisplayName $serviceDisplayName
        If ($serverStatus.Status -eq "Running") {
            Write-Host -ForegroundColor Green $serverStatus.Status
        }
        Else {
            Write-Host -ForegroundColor Red $serverStatus.Status
        }
    
    }
}
#endregion

#region Stop-PWService
Function Stop-PWService ($pwServers, $serviceDisplayName)
{

    <#

    .SYNOPSIS
        Stops the provided Windows service.

    .DESCRIPTION
        Stops the provided Windows service.

    .EXAMPLE
        Get-PWServiceStop <short server name> <service display name>

    .EXAMPLE
        Get-Help Get-PWServiceStop -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $serviceDisplayName
        Windows Service name.  This should be unique so only one service is returned.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Write-Host -ForegroundColor Yellow $pwFQServer
    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {
        Stop-Service -DisplayName $serviceDisplayName
        $serverStatus = Get-Service -DisplayName $serviceDisplayName
        If ($serverStatus.Status -eq "Running") {
            Write-Host -ForegroundColor Green $serverStatus.Status
        }
        Else {
            Write-Host -ForegroundColor Red $serverStatus.Status
        }
    
    }
}
#endregion

#region Restart-PWService
Function Restart-PWService ($pwServer, $serviceDisplayName)
{

    <#

    .SYNOPSIS
        Restarts the provided Windows service.

    .DESCRIPTION
        Restarts the provided Windows service.

    .EXAMPLE
        Get-PWServiceRestart <short server name> <service display name>

    .EXAMPLE
        Get-Help Get-PWServiceRestart -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $serviceDisplayName
        Windows Service name.  This should be unique so only one service is returned.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Write-Host -ForegroundColor Yellow $pwFQServer
    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {
        Restart-Service -DisplayName $serviceDisplayName
        $serverStatus = Get-Service -DisplayName $serviceDisplayName
        If ($serverStatus.Status -eq "Running") {
            Write-Host -ForegroundColor Green $serverStatus.Status
        }
        Else {
            Write-Host -ForegroundColor Red $serverStatus.Status
        }
    }
}
#endregion

#region Get-PWInstalledApps
#needs fully qualified server name
function Get-PWInstalledApps ($pwServer, $type, $appFilter)
{

    <#

    .SYNOPSIS
        Displays installed application/s.

    .DESCRIPTION
        Displays either all installed Scottrade applications or the application provided from the server provided.  It also returns the version.

    .EXAMPLE
        Get-PWInstalledApps <short server name> <scottrade/app> <app name>

    .EXAMPLE
        Get-Help Get-PWInstalledApps -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $type
        Is either scottrade or app to filter to either all Scottrade applications or a specific application.

    .PARAMETER $appFilter
        Application name.  This should be unique so only one application is returned.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    $funcReturn = Get-PWFullyQualifiedServerName $pwServer

    $pwFQServer = $funcReturn[0]
    $userCredentials = $funcReturn[1]

    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like $appFilter}} | Sort-Object PScomputername, Name | Format-Table -AutoSize -Property PSComputerName, DisplayName, DisplayVersion, Publisher, Comments
    Invoke-Command -ComputerName $pwFQServer -Credential $userCredentials -ScriptBlock {Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like $appFilter}} | Sort-Object PScomputername, Name | Format-Table -AutoSize -Property PSComputerName, DisplayName, DisplayVersion, Publisher, Comments
}
#endregion

#region Get-PWDriveFreeSpace
#needs fully qualified server name
<#

    NEEDS TO BE COMPLETED

#>
function Get-PWDriveFreeSpace
{
    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory = $true,position=1,HelpMessage = "Enter the short server name")]
        [ValidateNotNullOrEmpty()]
        [string] $server,


        [Parameter(Mandatory = $true,position=2,HelpMessage = "Enter drive to connect to")]
        [ValidateNotNullOrEmpty()]
        [string] $file
    )

   $servers = "qfcbusvc201.scottapp.qf","qfcbusvc202.scottapp.qf","qfcbusvc203.scottapp.qf","qfcbusvc204.scottapp.qf","qfcbusvc205.scottapp.qf","qfdlysvcaint101.scottrade.qf","qfdlysvcaint102.scottrade.qf","qfdlysvcfe101.scottweb.qf","qfdlysvcfe102.scottweb.qf","qfdlysvcmob101.scottweb.qf","qfdlysvcmob102.scottweb.qf","qfdlysvcscot101.scottweb.qf","qfdlysvcscot102.scottweb.qf","qfdlysvcweb101.scottweb.qf","qfdlysvcweb102.scottweb.qf","qfexecution201.scottapp.qf","qfexecution202.scottapp.qf","qfexecution203.scottapp.qf","qfexecution204.scottapp.qf","qfexecution205.scottapp.qf","qfmaordoms001.scottapp.qf","qfmaordoms002.scottapp.qf","qfmtsvcapp201.scottapp.qf","qfmtsvcapp202.scottapp.qf","qfmtsvcint001.scottrade.qf","qfmtsvcint002.scottrade.qf","qfmtsvcmob101.scottweb.qf","qfordersvc001.scottapp.qf","qfordersvc002.scottapp.qf","qfordersvc003.scottapp.qf","qfordersvc004.scottapp.qf","qfordersvc005.scottapp.qf","qfordersvc006.scottapp.qf","qfordersvc007.scottapp.qf","qfordersvc008.scottapp.qf","qfordersvcts101.scottapp.qf","qfordersvcts102.scottapp.qf","qfqdatascot001.scottweb.qf","qfqdatascot002.scottweb.qf","qfriaordoms001.scottapp.qf","qfriaordoms002.scottapp.qf","qfriatrdext001.scottweb.qf","qfriatrdint001.scottrade.qf","qfriatrdweb001.scottweb.qf","qfriatrdweb002.scottweb.qf","qfrtersvc201.scottapp.qf","qfrtersvc202.scottapp.qf","qfrtersvc203.scottapp.qf","qfrtersvc204.scottapp.qf","qfrtersvc205.scottapp.qf","qfrtersvc206.scottapp.qf","qfrtersvc207.scottapp.qf","qfrtersvc208.scottapp.qf","qfrtersvc209.scottapp.qf","qfrtersvc210.scottapp.qf","qfsoommon201.scottapp.qf","qfsoommon202.scottapp.qf","qfsoomsvc201.scottapp.qf","qftrdelidly101.scottweb.qf","qftrdelidly102.scottweb.qf","qftrdoldfe101.scottweb.qf","qftrdoldfe102.scottweb.qf","qftrdoldint101.scottrade.qf","qftrdoldint102.scottrade.qf","qftrdoldoms101.scottapp.qf","qftrdoldoms102.scottapp.qf","qftrdoldweb101.scottweb.qf","qftrdoldweb102.scottweb.qf","qftrdsvceli101.scottweb.qf","qftrdsvceli102.scottweb.qf","qftrdsvcext101.scottweb.qf","qftrdsvcext102.scottweb.qf","qftrdsvcfe101.scottweb.qf","qftrdsvcfe102.scottweb.qf","qftrdsvcinno001.scottweb.qf","qftrdsvcinno002.scottweb.qf","qftrdsvcint101.scottrade.qf","qftrdsvcint102.scottrade.qf","qftrdsvcmait101.scottrade.qf","qftrdsvcmawb101.scottweb.qf","qftrdsvcmawb102.scottweb.qf","qftrdsvcmob101.scottweb.qf","qftrdsvcmob102.scottweb.qf","qftrdsvcoms101.scottapp.qf","qftrdsvcoms102.scottapp.qf","qftrdsvcweb101.scottweb.qf","qftrdsvcweb102.scottweb.qf","qftrdsvcweb103.scottweb.qf","qftrdsvcweb104.scottweb.qf","qftscont201.scottapp.qf","qftscontria201.scottapp.qf","qftswork201.scottapp.qf","qftswork202.scottapp.qf","qftsworkria201.scottapp.qf","qftsworkria202.scottapp.qf","qfwboapp201.scottapp.qf","qfwboapp202.scottapp.qf","qfwboeli201.scottweb.qf","qfwboeli202.scottweb.qf","qfwboint201.scottrade.qf","qfwboint202.scottrade.qf","qfwboma201.scottweb.qf","qfwbomaoms201.scottapp.qf","qfwbomaoms202.scottapp.qf","qfwbooms201.scottapp.qf","qfwbooms202.scottapp.qf","qfwbooms203.scottapp.qf","qfwbooms204.scottapp.qf","qfwboomsts201.scottapp.qf","qfwboomsts202.scottapp.qf","qfwboria201.scottweb.qf","qfwboria202.scottweb.qf","qfwboriaoms201.scottapp.qf","qfwboriaoms202.scottapp.qf","qfwboscot201.scottweb.qf","qfwboscot202.scottweb.qf","qfwboweb201.scottweb.qf","qfwboweb202.scottweb.qf","qfwboweb203.scottweb.qf"

    If (!$PSScriptRoot) {
        $ScriptPath = "$env:USERPROFILE\Desktop"
    }
    Else {
        $ScriptPath = $PSScriptRoot
    }

    New-Item $ScriptPath\qf-d-freespace.csv -Type file -Force | Out-Null

    foreach ($server in $servers) {
        #Get-WmiObject Win32_LogicalDisk -Computername $server -Credential $qf | Where-Object {$_.DeviceID -like "D:"} | Select-Object PSComputerName, DeviceID, FreeSpace, Size
        Invoke-Command -ComputerName $server -Credential $qf -ScriptBlock {Get-PSDrive C,D} | Sort-Object PSComputerName | Select-Object PSComputerName, Name, Used, Free | Export-Csv -NoTypeInformation -Path $ScriptPath\qf-d-freespace.csv -Append
    }
}
#endregion

#region Get-PWFolderSpace
Function Get-PWFolderSpace
{

    <#

    .SYNOPSIS
        Displays the folder sizes of the provided folder.

    .DESCRIPTION
        Displays the folder sizes of the provided folder.

    .EXAMPLE
        Get-ChildItem -Path . -Directory -ErrorAction SilentlyContinue | Get-PWFolderSpace | Sort-Object Size

    .NOTES
        Edited by: Paul Wojtysiak
        Created: 11/23/2016
        Requirement: None

    #>

     BEGIN{$fso = New-Object -comobject Scripting.FileSystemObject}

     PROCESS{

        $path = $input.fullname

        $folder = $fso.GetFolder($path)

        $size = $folder.size

        [PSCustomObject]@{‘Name’ = $path;’Size’ = ($size / 1gb)}
     }
}
#endregion

#region New-PWDrive
function New-PWDrive
{

    <#

    .SYNOPSIS
        Maps a drive.

    .DESCRIPTION
        Maps a drive to the specified server and administrative share of the specified drive using the necessary credentials.
        Logs teh drives mapped so Remove-PWDrive can remove the mappings.

    .EXAMPLE
        New-PWDrive  <short server name> <drive letter>

    .EXAMPLE
        Get-Help New-PWDrive -Full

    .PARAMETER $pwServer
        Short server name.

    .PARAMETER $drive
        Drive to map to.

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    [CmdletBinding()]
    
    param (
        [Parameter(Mandatory = $true,position=1,HelpMessage = "Enter the short server name")]
        [ValidateNotNullOrEmpty()]
        [string] $server,


        [Parameter(Mandatory = $true,position=2,HelpMessage = "Enter drive to connect to")]
        [ValidateNotNullOrEmpty()]
        [string] $drive
    )
    $server=$server.ToLower()
    $drive=$drive.ToLower()
    $environment = $server.Substring(0,2).ToLower()
    $outArray = @()
    
    $myObj = "" | Select "Server","Drive"
    $myObj.Server = $server
    $myObj.Drive = $drive

    $outArray += $myObj

    If (Test-Path $server-$drive`:) {
        Write-Host "The drive $server-$drive`: already exists"
    }
    Else {
        If (Test-Connection -ComputerName $server`.wustl.edu -Count 1 -Quiet) {
            New-PSDrive -Name $server-$drive -PSProvider FileSystem -Credential $dev -Root \\$server.wustl.edu\$drive$ -Scope global
            Write-Host -ForegroundColor Yellow "Use Set-Location $server-$drive`: to change drives"
        }
        Else {
            Write-Host "Cannot find server" $server
        }

        $outArray | Export-Csv -Path $env:USERPROFILE\Documents\WindowsPowerShell\Modules\PWUtilities\drives.csv -Append -NoTypeInformation
    }
}
#endregion

#region Remove-PWDrive
function Remove-PWDrive
{

    <#

    .SYNOPSIS
        Removes drive mappings.

    .DESCRIPTION
        Removes drive mappings created by New-PWDrive.

    .EXAMPLE
        Remove-PWDrive

    .EXAMPLE
        Get-Help Remove-PWDrive -Full

    .NOTES
        Edited by: Paul Wojtysiak
        Last update: 11/23/2016
        Requirement: None

    #>

    Set-Location c:

    $driveImport = Import-Csv $env:USERPROFILE\Documents\WindowsPowerShell\Modules\PWUtilities\drives.csv

    foreach ($item in $driveImport)
    {
        $server = $item.Server
        $drive = $item.Drive
        Remove-PSDrive -Name $server-$drive
    }

    Clear-Content -Path $env:USERPROFILE\Documents\WindowsPowerShell\Modules\PWUtilities\drives.csv
}
#endregion

#region Get-PWWhenUserAccountPasswordExpires
function Get-PWWhenUserAccountPasswordExpires
{
    <#
    .Synopsis
    Gets date password was last set and when password will expire for a user account.
    .DESCRIPTION
    The Get-PWWhenUserAccountPasswordExpires gets the expiration date of a user account.
    .Notes
    You must have Remote Server Administration Tools (RSAT) install prior to using this function. 
    .EXAMPLE
    PS C:\> Get-PWWhenUserAccountPasswordExpires -UserName app2svcacct1 -Domain WOJISWEB.com

    
        UserPrincipalName      PasswordNeverExpires Password Set        Password Expires Date
        -----------------      -------------------- ------------        ---------------------
        app2svcacct1@WOJISWEB.COM                False 2/3/2015 2:56:35 PM 4/4/2015 3:56:35 PM  

        This command will get the password expiration date for user app2svcacct expires
    .EXAMPLE
    PS C:\> Get-PWWhenUserAccountPasswordExpires -UserName app2svcacct* -Domain WOJISWEB.com

        UserPrincipalName      PasswordNeverExpires Password Set        Password Expires Date
        -----------------      -------------------- ------------        ---------------------
        app2svcacct1@WOJISWEB.COM                False 2/3/2015 2:56:35 PM 4/4/2015 3:56:35 PM  
        app2svcacct2@WOJISWEB.COM                False 2/3/2015 2:56:35 PM 4/4/2015 3:56:35 PM  
        app2svcacct3@WOJISWEB.COM                False 2/3/2015 2:56:36 PM 4/4/2015 3:56:36 PM  
        app2svcacct4@WOJISWEB.COM                False 2/3/2015 2:56:36 PM 4/4/2015 3:56:36 PM  
        app2svcacct5@WOJISWEB.COM                False 2/3/2015 2:56:36 PM 4/4/2015 3:56:36 PM  
        app2svcacct6@WOJISWEB.COM                False 2/3/2015 2:56:36 PM 4/4/2015 3:56:36 PM  
        app2svcacct7@WOJISWEB.COM                False 2/9/2015 1:53:02 PM 4/10/2015 2:53:02 PM 

        This command uses a wildcard "*" to get the expiration date for all user accounts that start with app2svcacct

    #>

    Param
    (
        [Parameter(Mandatory=$true)][String]$UserName,
        [String]$Domain
    )

    Begin
    {
        if ($Domain) {
			$DC = (Get-ADDomain -Server $Domain).PDCEmulator
			$Search = (Get-ADDomain -Server $Domain).DistinguishedName
		}
		else {
			$DC = (Get-ADDomain).PDCEmulator
			$Search = (Get-ADDomain).DistinguishedName
		}
    }
    Process
    {
        Get-ADUser -Filter {SamAccountName -like $UserName} -Properties msDS-UserPasswordExpiryTimeComputed,PasswordLastSet,PasswordNeverExpires -Server $DC | 
        Format-Table -AutoSize -property UserPrincipalName,PasswordNeverExpires,@{L="Password Set";E={$_."PasswordLastSet"}},@{L="Password Expires Date";E={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
    }
    End
    {
    }
}#endregion

#region Export Modules
Export-ModuleMember -Alias * -Function Remove-PWOldLogs, Get-DHIISAPPPool, Get-PWAppPoolStatus, Start-PWAppPool, Stop-PWAppPool, Restart-PWAppPool, Get-PWServiceStatus, Start-PWService, Stop-PWService, Restart-PWService, Get-PWInstalledApps, Get-PWDriveFreeSpace, Get-PWFolderSpace, New-PWDrive, Remove-PWDrive, Get-PWWhenUserAccountPasswordExpires
#endregion
