#Get-Module -ListAvailable | Import-Module
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\AdmPwd.PS
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\DiskFree
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\GetInfo
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\NTFSSecurity
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\PSScriptAnalyzer
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\PSWindowsUpdate
Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\PWUtilities
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\SIDHistory

#region posh-git
Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\posh-git
Start-SshAgent -Quiet
#endregion




############   ISE Only   ############
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\ISERegex
#Start-ISERegex
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\PsISEProjectExplorer
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\ShowDscResourceModule
#Install-DscResourceAddOn
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\ISEScriptAnalyzerAddOn
#Import-Module $env:USERPROFILE\Documents\WindowsPowerShell\Modules\VariableExplorer

#region Validate XML
<#
$validateBlock = {
    if ($psISE.CurrentFile.Editor.SelectedText) {
        $filePath = "${Env:Temp}\temp.xml"
        Set-Content -PassThru $filePath -Value $psISE.CurrentFile.Editor.SelectedText
        $cleanUp = $true
    } else {
        if ($psISE.CurrentFile.IsSaved) {
            $filePath = $psISE.CurrentFile.FullPath
        } else {
            $filePath = "${Env:Temp}\temp.xml"
            Set-Content -PassThru $filePath -Value $psISE.CurrentFile.Editor.Text
            $cleanUp = $true
        }
    }

    if (Test-XML $filePath) {
        [System.Windows.Forms.MessageBox]::Show("XML document is valid.")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Invalid XML document. Refer to console output!")
    }

    if ($cleanUp) {
        Remove-Item -Path "${Env:Temp}\temp.xml" -Force
        $cleanUp = $false
    }
}
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Validate _XML",$validateBlock,"Ctrl+Alt+X")
#>
#endregion

#region Format XML
<#
$formatBlock = {
    if ($psISE.CurrentFile.Editor.SelectedText) {
        $filePath = "${Env:Temp}\temp.xml"
        Set-Content -PassThru $filePath -Value $psISE.CurrentFile.Editor.SelectedText
        $cleanUp = $true
    } else {
        if ($psISE.CurrentFile.IsSaved) {
            $filePath = $psISE.CurrentFile.FullPath
        } else {
            $filePath = "${Env:Temp}\temp.xml"
            Set-Content -PassThru $filePath -Value $psISE.CurrentFile.Editor.Text
            $cleanUp = $true
        }
    }

    if (Test-XML $filePath) {
        $psISE.CurrentFile.Editor.Text = Format-XML (Get-Content $filePath)
    } else {
        [System.Windows.Forms.MessageBox]::Show("Invalid XML document. Refer to console output!")
    }

    if ($cleanUp) {
        Remove-Item -Path "${Env:Temp}\temp.xml" -Force
        $cleanUp = $false
    }
}
$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Format _XML",$formatBlock,"Alt+X")
#>
#endregion

#region Module Browser
<#
#Module Browser Begin
#Version: 1.0.0
#Add-Type -Path 'C:\Program Files (x86)\Microsoft Module Browser\ModuleBrowser.dll'
Add-Type -Path $env:USERPROFILE\Documents\WindowsPowerShell\Modules\ISEModuleBrowserAddon\1.0.1.0\ISEModuleBrowserAddon.dll
$moduleBrowser = $psISE.CurrentPowerShellTab.VerticalAddOnTools.Add('Module Browser', [ModuleBrowser.Views.MainView], $true)
$psISE.CurrentPowerShellTab.VisibleVerticalAddOnTools.SelectedAddOnTool = $moduleBrowser
#Module Browser End
#>
#endregion

