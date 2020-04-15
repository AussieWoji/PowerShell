$userProfile = $env:USERPROFILE
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Copy-Item -Recurse "$env:USERPROFILE\OneDrive\Scripts\powershell\WindowsPowerShell\" -Destination "$env:USERPROFILE\Documents\" -Force
#$env:USERPROFILE\OneDrive\Scripts\powershell\Add-Ons\PowerShell-Module_Browser-setup.exe /s /v`”/qn
Start-Process -FilePath "$env:USERPROFILE\OneDrive\Scripts\powershell\Add-Ons\CimExplorerSetup.msi" -ArgumentList "/quiet"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name ISEModuleBrowserAddon -Scope CurrentUser -Force
Install-Module -Name ScriptBrowser -Scope CurrentUser -Force
Install-Module -Name ISEScriptAnalyzerAddOn -Scope CurrentUser -Force
Install-DscResourceAddOn
Update-Help -Force

#region Notification Bubble
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