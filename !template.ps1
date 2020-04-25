<#

.SYNOPSIS
    <Overview of script>

.DESCRIPTION
    <Brief description of script>

.PARAMETER <Parameter_Name> #Remove if not used or help will not appear.
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
    <Inputs if any, otherwise state None>

.OUTPUTS
    <Outputs if any, otherwise state None>

.EXAMPLE
    <Example goes here. Repeat this attribute for more than one example>

.NOTES
	===========================================================================
	 Created on:   	02/01/2020
	 Created by:   	Paul Wojtysiak
	 Organization: 	Washington University in St. Louis - Information Technology
	 Requirements:
	===========================================================================

.LINK
    <Put link to Confluence article about script here>

#>

#region Create paramters that can be passed in from the command line
param (
    #Script parameters go here
)
#endregion

$sw = [Diagnostics.Stopwatch]::StartNew()

#region Import Modules

#endregion

#region Create variables

#endregion

#region Functions
function Start-Log {
<#
.SYNOPSIS
    Start-Log creates the logfile.

.DESCRIPTION
    Creates log file in the logs directory within the directory the script/executable was run.

.PARAMETER Filepath
    Path to the log file

.INPUTS
    None

.OUTPUTS
    Log file is created

.EXAMPLE
    Start-Log -FilePath "$logdir\$filename"

.NOTES

#>

    [CmdletBinding()]
        param (
            [ValidateScript({ Split-Path $_ -Parent | Test-Path })]
        [string]$FilePath
        )

        try
        {
            if (!(Test-Path $FilePath))
            {
                ## Create the log file
                New-Item $FilePath -Type File | Out-Null
            }
            else {
                # Replace the log file.
                New-Item $FilePath -Type File -Force -Confirm:$false| Out-Null
            }

        ## Set the global variable to be used as the FilePath for all subsequent Write-Log
        ## calls in this session
        $global:ScriptLogFilePath = $FilePath
        }
        catch
        {
            Write-Error $_.Exception.Message
        }
}

function Write-Log {
<#
.SYNOPSIS
    Write-Log writes data to the logfile.

.DESCRIPTION
    Writes to the log file in CMTrace format for easier review of errors and warnings.

.PARAMETER Message
    Status text to be written to the log or log & host

.PARAMETER Silent
    Writes status  text only to the log

.PARAMETER LogLevel
    1 for informational messages; 2 for warning messages; 3 for error messages

.INPUTS
    None

.OUTPUTS
    Messages to the log file

.EXAMPLE
    Write-Log "Informational message"

    Write-Log "Informational message" -Silent

    Write-Log "Informational message" -LogLevel 1

    Write-Log "Informational message" -LogLevel 1 -Silent

    Write-Log "Warning message" -LogLevel 2

    Write-Log "Warning message" -LogLevel 2 -Silent

    Write-Log "Error message" -LogLevel 3

    Write-Log "Error message" -LogLevel 3 -Silent

.NOTES

#>

    param (
    [Parameter(Mandatory = $true)]
    [string]$Message,
    [switch]$Silent,
    [Parameter()]
    [ValidateSet(1, 2, 3)]
    [int]$LogLevel = 1
    )

    if(!$silent){
        if($LogLevel -eq 1){
            $color = "Green" #(get-host).ui.rawui.ForegroundColor
        }
        if($LogLevel -eq 2){
            $color = "Yellow"
        }
        if($LogLevel -eq 3){
            $color = "Red"
        }
        write-host $Message -ForegroundColor $color
    }
    $TimeGenerated = "$(Get-Date -Format HH:mm:ss).$((Get-Date).Millisecond)+000"
    $Line = '<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="" type="{4}" thread="" file="">'

    $LineFormat = $Message, $TimeGenerated, (Get-Date -Format MM-dd-yyyy), "$($script:scriptname):$($MyInvocation.ScriptLineNumber)", $LogLevel
    $Line = $Line -f $LineFormat
    try{Add-Content -Value $Line -Path $ScriptLogFilePath -ErrorAction "Stop"}
    catch{
        $retrycount = 1
        $logretry = $true
        while(($logretry) -and ($retrycount -le 5)){
            try{
                Add-Content -Value $Line -Path $ScriptLogFilePath -ErrorAction "Stop"
                $logretry = $false
            }
            catch{
                start-sleep -seconds 1
                $retrycount++
            }
        }
    }
}

function Get-ScriptDirectory{
<#
.SYNOPSIS
    Get-ScriptDirectory returns the proper location of the script.

.OUTPUTS
    System.String

.NOTES
    Returns the correct path within a packaged executable.
#>

    [OutputType([string])]
    param ()

    if ($null -ne $hostinvocation)
    {
        $frootval = Split-Path $hostinvocation.MyCommand.path
        $script:logdir = "$frootval\logs"
        $fnameval = $hostinvocation.MyCommand.ToString()
        $fnameval = $fnameval.split('\')[-1]
		$fnameval = $fnameval.split('.')[0]
		$name = $fnameval
    }
    else
    {
        $frootval = Split-Path $script:MyInvocation.MyCommand.Path
        $script:logdir = "$frootval\logs"
        $fnameval = $script:myinvocation.MyCommand.ToString()
		$fnameval = $fnameval.split('.')[0]
		$name = $fnameval
    }

    $script:now = Get-Date -Format "yyyyMMdd_HHmm"
    $script:filename = "$name-$script:now.log"

    if (-not (Test-Path $logdir)) {
        New-Item -ItemType Directory $logdir -Force | Out-Null
    }
}

<#

function <FunctionName> {
<#
.SYNOPSIS
    <Overview of function>

.DESCRIPTION
    <Brief description of function>

.PARAMETER <Parameter_Name> #Remove if not used or help will not appear.
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
    <Inputs if any, otherwise state None>

.OUTPUTS
    <Outputs if any, otherwise state None>

.EXAMPLE
    <Example goes here. Repeat this attribute for more than one example>

.NOTES

#>
<#
    [CmdletBinding()]
    Param (

	)

	Begin {
		Write-Log 'Beginning <function name>...' -Silent
	}

	Process {
		Try {
			<code goes here>
		}

		Catch {
			Write-Log "Error: $($_.Exception)" -LogLevel 3
			Break
		}
	}

	End {
		If ($?) {
			Write-Log 'Ending <function name>' -Silent
		}
	}
}
#>
#endregion

#region Script
#region Logging Setup
	Get-ScriptDirectory
	Start-Log -FilePath "$logdir\$filename"
#endregion

#endregion

$sw.Stop()
Write-Log "Execution Time: $($sw.Elapsed.ToString())"

Write-Host "Script completed...";
if ((Test-Path variable:psISE) -and $psISE) {
} Else {
    Write-Host -NoNewLine 'Press any key to continue...'
    [void][System.Console]::ReadKey($true)
}
