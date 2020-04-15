if ($PSVersionTable.PSVersion.Major -le 5) {
    #Get-Module -ListAvailable | Import-Module
    #Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\AdmPwd.PS
    #Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\DiskFree
    #Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\GetInfo
    #Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\SIDHistory

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\PackageManagement")) {
        Install-Module -Name PackageManagement -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\PowerShellGet")) {
        Install-Module -Name PowerShellGet -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\Pester")) {
        Install-Module -Name Pester -Scope CurrentUser -AllowClobber -Force -SkipPublisherCheck
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\ImportExcel")) {
        Install-Module -Name ImportExcel -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\PSWindowsUpdate")) {
        Install-Module -Name PSWindowsUpdate -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\NTFSSecurity")) {
        Install-Module -Name NTFSSecurity -Scope CurrentUser -AllowClobber -Force
    }

    <#if (-not (Test-Path -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\PWUtilities")) {
        Write-Host -ForegroundColor Red "Module PWUtilities is missing from $env:USERPROFILE\Documents\PowerShell\Modules\PWUtilities"
    }
    else {
        Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\PWUtilities
    }#>

    #region posh-git (only necessary in Windows Powershell)
    <#if (-not (Test-Path -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\posh-git")) {
        Install-Module -Name posh-git -Scope CurrentUser -AllowClobber -Force -SkipPublisherCheck
    }
    Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\posh-git
    Start-SshAgent -Quiet#>

    Get-InstalledModule | Update-Module
    #endregion
}
elseif ($IsWindows) {
    #region Not PowerShell Core for Mac compatible modules
    <#
    Import-Module $env:USERPROFILE\Documents\PowerShell\Modules\AdmPwd.PS
    Import-Module $env:USERPROFILE\Documents\PowerShell\Modules\DiskFree
    Import-Module $env:USERPROFILE\Documents\PowerShell\Modules\GetInfo
    Import-Module $env:USERPROFILE\Documents\PowerShell\Modules\NTFSSecurity
    Import-Module $env:USERPROFILE\Documents\PowerShell\Modules\SIDHistory
    #>
    #endregion

    #region PowerShell Core for Windows compatible modules
    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\PackageManagement")) {
        Install-Module -Name PackageManagement -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\PowerShellGet")) {
        Install-Module -Name PowerShellGet -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\Pester")) {
        Install-Module -Name Pester -Scope CurrentUser -AllowClobber -Force -SkipPublisherCheck
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\Microsoft.PowerShell.GraphicalTools")) {
        Install-Module -Name Microsoft.PowerShell.GraphicalTools -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\Microsoft.PowerShell.ConsoleGuiTools")) {
        Install-Module -Name Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\PSReleaseTools")) {
        Install-Module -Name PSReleaseTools -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\posh-git")) {
        Install-Module -Name posh-git -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\oh-my-posh")) {
        Install-Module -Name oh-my-posh -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\ImportExcel")) {
        Install-Module -Name ImportExcel -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\PSWindowsUpdate")) {
        Install-Module -Name PSWindowsUpdate -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\NTFSSecurity")) {
        Install-Module -Name NTFSSecurity -Scope CurrentUser -AllowClobber -Force
    }

    <#if (-not (Test-Path -Path "$env:USERPROFILE\Documents\PowerShell\Modules\PWUtilities")) {
        Write-Host -ForegroundColor Red "Module PWUtilities is missing from $env:USERPROFILE\Documents\PowerShell\Modules\PWUtilities"
    }
    else {
        Import-Module $env:USERPROFILE\Documents\PowerShell\Modules\PWUtilities
    }#>

    Get-InstalledModule | Update-Module
    #endregion
}
elseif ($IsMacOS) {
    <#
        ~/.config/powershell

        if (-not (Test-Path -Path $profile.CurrentUserAllHosts)) {
            New-Item $profile.CurrentUserAllHosts -ItemType File -Force
        }
    #>

    #region Not PowerShell Core for Mac compatible modules
    <#
    Import-Module ~/.local/share/powershell/Modules/AdmPwd.PS
    Import-Module ~/.local/share/powershell/Modules/DiskFree
    Import-Module ~/.local/share/powershell/Modules/GetInfo
    Import-Module ~/.local/share/powershell/Modules/ImportExcel
    Import-Module ~/.local/share/powershell/Modules/NTFSSecurity
    Import-Module ~/.local/share/powershell/Modules/PSWindowsUpdate
    Import-Module ~/.local/share/powershell/Modules/PWWhenUserAccountPasswordExpires
    Import-Module ~/.local/share/powershell/Modules/SIDHistory
    #>
    #endregion

    #region PowerShell Core for Mac compatible modules
<#
    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PackageManagement")) {
        Install-Module -Name PackageManagement -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PowerShellGet")) {
        Install-Module -Name PowerShellGet -Scope CurrentUser -AllowClobber -Force
    }
#>
    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/Pester")) {
        Install-Module -Name Pester -Scope CurrentUser -AllowClobber -Force -SkipPublisherCheck
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/Microsoft.PowerShell.GraphicalTools")) {
        Install-Module -Name Microsoft.PowerShell.GraphicalTools -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/Microsoft.PowerShell.ConsoleGuiTools")) {
        Install-Module -Name Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser -Force
    }
    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PSUnixUtilCompleters")) {
        Install-Module -Name PSUnixUtilCompleters -AcceptLicense -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PSReleaseTools")) {
        Install-Module -Name PSReleaseTools -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/posh-git")) {
        Install-Module -Name posh-git -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/oh-my-posh")) {
        Install-Module -Name oh-my-posh -Scope CurrentUser -Force
    }

    <#if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PWUtilities")) {
        Write-Host -ForegroundColor Red "Module PWUtilities is missing from ~/.local/share/powershell/Modules/PWUtilities"
    }
    else {
        Import-Module ~/.local/share/powershell/Modules/PWUtilities
    }#>

    Get-InstalledModule | Update-Module
    #endregion
}
elseif ($IsLinux) {
    <#
        ~/.config/powershell

        if (-not (Test-Path -Path $profile.CurrentUserAllHosts)) {
            New-Item $profile.CurrentUserAllHosts -ItemType File -Force
        }
    #>

    #region Not PowerShell Core for Linux compatible modules
    <#
    Import-Module ~/.local/share/powershell/Modules/AdmPwd.PS
    Import-Module ~/.local/share/powershell/Modules/DiskFree
    Import-Module ~/.local/share/powershell/Modules/GetInfo
    Import-Module ~/.local/share/powershell/Modules/ImportExcel
    Import-Module ~/.local/share/powershell/Modules/NTFSSecurity
    Import-Module ~/.local/share/powershell/Modules/PSWindowsUpdate
    Import-Module ~/.local/share/powershell/Modules/PWWhenUserAccountPasswordExpires
    Import-Module ~/.local/share/powershell/Modules/SIDHistory
    #>
    #endregion

    #region Powershell Core for Linux compatible modules
    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PackageManagement")) {
        Install-Module -Name PackageManagement -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PowerShellGet")) {
        Install-Module -Name PowerShellGet -Scope CurrentUser -AllowClobber -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/Pester")) {
        Install-Module -Name Pester -Scope CurrentUser -AllowClobber -Force -SkipPublisherCheck
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/Microsoft.PowerShell.GraphicalTools")) {
        Install-Module -Name Microsoft.PowerShell.GraphicalTools -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/Microsoft.PowerShell.ConsoleGuiTools")) {
        Install-Module -Name Microsoft.PowerShell.ConsoleGuiTools -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PSUnixUtilCompleters")) {
        Install-Module -Name PSUnixUtilCompleters -AcceptLicense -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PSReleaseTools")) {
        Install-Module -Name PSReleaseTools -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/posh-git")) {
        Install-Module -Name posh-git -Scope CurrentUser -Force
    }

    if (-not (Test-Path -Path "~/.local/share/powershell/Modules/oh-my-posh")) {
        Install-Module -Name oh-my-posh -Scope CurrentUser -Force
    }

    <#if (-not (Test-Path -Path "~/.local/share/powershell/Modules/PWUtilities")) {
        Write-Host -ForegroundColor Red "Module PWUtilities is missing from ~/.local/share/powershell/Modules/PWUtilities"
    }
    else {
        Import-Module ~/.local/share/powershell/Modules/PWUtilities
    }#>

    Get-InstalledModule | Update-Module
    #endregion
}
