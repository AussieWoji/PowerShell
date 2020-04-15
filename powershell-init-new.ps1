$personalModules = Read-Host "Path to personal modules? (Different on Mac/Linux/Windows)"

Update-Help -Force

# Trust the PSGallery repository
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

if ($(Get-PackageProvider | Where-Object {$_.Name -contains "NuGet"})) {
    Write-Host "NuGet is installed:"
    Get-PackageProvider | Where-Object {$_.Name -contains "NuGet"}
}
else {
    # If NuGet not installed then run the following:
    Install-PackageProvider -Name NuGet -Force
}

Install-Module -Name PackageManagement -Scope CurrentUser -AllowClobber -Force
Install-Module -Name PowerShellGet -Scope CurrentUser -AllowClobber -Force
Install-Module -Name Pester -Scope CurrentUser -AllowClobber -Force -SkipPublisherCheck
Install-Module -Name PSReleaseTools -Scope CurrentUser -Force
Install-Module -Name Microsoft.PowerShell.GraphicalTools -Scope CurrentUser -Force # Allows Out-GridView on all platforms

if ($PSVersionTable.PSVersion.Major -le 5) {
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

    #region Windows PowerShell compatible modules
    #Get-Module -ListAvailable | Import-Module
    Copy-Item -Path -Recurse $personalModules\PWUtilities\* -Destination $env:USERPROFILE\Documents\PowerShell\Modules -Force
    Copy-Item -Path -Recurse $personalModules\AdmPwd.PS\* -Destination $env:USERPROFILE\Documents\WindowsPowerShell\Modules -Force
    Copy-Item -Path -Recurse $personalModules\DiskFree\* -Destination $env:USERPROFILE\Documents\PowerShell\Modules -Force
    Copy-Item -Path -Recurse $personalModules\GetInfo\* -Destination $env:USERPROFILE\Documents\WindowsPowerShell\Modules -Force
    Copy-Item -Path -Recurse $personalModules\SIDHistory\* -Destination $env:USERPROFILE\Documents\WindowsPowerShell\Modules -Force

    Install-Module -Name AzureAD -Scope CurrentUser -Force
    Install-Module -Name DellBIOSProvider -Scope CurrentUser -Force
    Install-Module -Name DellWarranty -Scope CurrentUser -Force
    Install-Module -Name Carbon -Scope CurrentUser -Force
    Install-Module -Name ImportExcel -Scope CurrentUser -Force
    Install-Module -Name MSOnline -Scope CurrentUser -Force
    Install-Module -Name NTFSSecurity -Scope CurrentUser -Force
    Install-Module -Name OpenSSHUtils -Scope CurrentUser -Force
    Install-Module -Name posh-git -Scope CurrentUser -Force
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
    Install-Module -Name PSWindowsUpdate -Scope CurrentUser -Force
    #endregion

    #region Windows OpenSSH install
    # Get the OpenSSH Windows capabilities MUST BE RUN AS ADMIN (Windows PowerShell and/or PowerShell Core) (Windows only)
    Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

    # Install the OpenSSH Client (Windows only)
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

    # Install the OpenSSH Server (Windows only)
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

    # Install OpenSSH Utilities (Windows only) (Install on all remote Windows machines before configuring the rest of OpenSSH)
    Install-Module -Force OpenSSHUtils

    # Configure the OpenSSH Server service (Windows only)
    Set-Service -Name sshd -StartupType Automatic

    # Confirm the Firewall rule is configured. It should be created automatically by setup. (Windows only)
    Get-NetFirewallRule -Name *ssh*
    # There should be a firewall rule named "OpenSSH-Server-In-TCP", which should be enabled 

    # Change OpenSSH shell from CMD to PowerShell (Windows only)
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\6\pwsh.exe" -PropertyType String -Force

    # Start the OpenSSH Server service (Windows only)
    Start-Service sshd
    #endregion

    #region Windows PowerShell ISE compatible modules
    <#
    Install-Module -Name ISEModuleBrowserAddon -Scope CurrentUser
    Install-Module -Name ISEScriptAnalyzerAddon -Scope CurrentUser
    Install-Module -Name PsISEProjectExplorer -Scope CurrentUser
    Install-Module -Name ScriptBrowser -Scope CurrentUser
    Install-Module -Name ShowDscResourceModule -Scope CurrentUser
    #>
    #endregion
}
elseif ($IsWindows) {
    #region PowerShell Core for Windows compatible modules
    Copy-Item -Path -Recurse $personalModules\PWUtilities\* -Destination $env:USERPROFILE\Documents\PowerShell\Modules -Force

    Install-Module -Name Carbon -Scope CurrentUser -Force
    Install-Module -Name OpenSSHUtils -Scope CurrentUser -Force
    #endregion
}
elseif ($IsMacOS -or $IsLinux) {
    #region PowerShell Core for Mac compatible modules
    Copy-Item -Path -Recurse $personalModules/PWUtilities/* -Destination ~/.local/share/powershell/Modules -Force
    #endregion
}


<#
#region Notification Bubbles (Windows PowerShell only) (Windows only)
Add-Type -AssemblyName System.Drawing
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 

$objNotifyIcon.Icon = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell).Path)
#$objNotifyIcon.Icon = "C:\Users\paul.wojtysiak\OneDrive\Scripts\powershell\WUSTL\powershell-icon.ico"
$objNotifyIcon.BalloonTipIcon = "Info" 
$objNotifyIcon.BalloonTipText = "The PowerShell Initialization script has completed" 
$objNotifyIcon.BalloonTipTitle = "PowerShell Initialization Complete"
 
$objNotifyIcon.Visible = $True 
$objNotifyIcon.ShowBalloonTip(10000)
#endregion
#>


<#
# Configure the OpenSSH Authentication Agent service (Windows only)
Set-Service -Name ssh-agent -StartupType Automatic

# Start the OpenSSH Authentication Agent service (Windows only)
Start-Service ssh-agent

# Generate SSH Keys (works on all operating systems)
ssh-keygen

# This should return a status of Running (Windows only)
Get-Service ssh-agent

# Now load your key files into ssh-agent (works on all opeating systems)
ssh-add ~\.ssh\id_rsa

# Now that it's loaded into ssh-agent,
# we don't have to keep the key file anymore (works on all opeating systems)
Remove-Item ~\.ssh\id_rsa

# Securely copy public key to remote host authorized keys (works on all opeating systems)
scp C:\Users\admin\.ssh\id_rsa.pub admin@mca01:C:\Users\admin\.ssh\authorized_keys

# Configure the ACLs on the authorized keys (works on all opeating systems)
ssh --% admin@mca01 powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\admin\.ssh\authorized_keys

# (works on all opeating systems)
ssh --% admin@mca-laptop1 powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\admin\.ssh\authorized_keys
ssh --% admin@mca01 powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\admin\.ssh\authorized_keys
ssh --% admin@mca03 powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\admin\.ssh\authorized_keys
ssh --% admin@mca04 powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\admin\.ssh\authorized_keys
ssh --% admin@overhead powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\admin\.ssh\authorized_keys
ssh --% admin@pastor powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\paulw\.ssh\authorized_keys
#endregion


Enter-PSSession -HostName mca01 -UserName admin -SSHTransport
#>
