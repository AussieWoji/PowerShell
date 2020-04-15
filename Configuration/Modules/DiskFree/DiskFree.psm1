<#
    .SYNOPSIS
        Gets free disk space

    .DESCRIPTION
        This function queries the removable disk, local disk, network, CD/DVD, and ram disk drive types and creates a custom PowerShell object for output. 
        In addition to the default output of the "raw" PS object, I also implemented a -Format option for "human friendly" output.

    .LINK
        http://binarynature.blogspot.com/2010/04/powershell-version-of-df-command.html#!/2010/04/powershell-version-of-df-command.html

    .EXAMPLE
        PS C:\> Get-DiskFree
        

        FileSystem : NTFS
        Type       : Local Fixed Disk
        Volume     : C:
        Available  : 151563018240
        Computer   : 0210-WL-00065
        Used       : 103510429696
        Size       : 255073447936
        
        * Default Output

    .EXAMPLE
        PS C:\> $cred = Get-Credential -Credential 'example\administrator'
        PS C:\> 'db01','sp01' | Get-DiskFree -Credential $cred -Format | Format-Table -GroupBy Name -AutoSize
        
           Name: DB01

        Name Vol Size  Used  Avail Use% FS   Type
        ---- --- ----  ----  ----- ---- --   ----
        DB01 C:  39.9G 15.6G 24.3G   39 NTFS Local Fixed Disk
        DB01 D:  4.1G  4.1G  0B     100 CDFS CD-ROM Disc

           Name: SP01

        Name Vol Size   Used   Avail Use% FS   Type
        ---- --- ----   ----   ----- ---- --   ----
        SP01 C:  39.9G  20G    19.9G   50 NTFS Local Fixed Disk
        SP01 D:  722.8M 722.8M 0B     100 UDF  CD-ROM Disc

        * Output with the Format Option

    .EXAMPLE
        PS C:\> $servers = Get-ADComputer -Filter { OperatingSystem -like '*win*server*' } | Select-Object -ExpandProperty Name
        PS C:\> Get-DiskFree -cn $servers | Where-Object { ($_.Volume -eq 'C:') -and ($_.Available / $_.Size) -lt .20 } | Select-Object Computer
        
        Computer
        --------
        FS01
        FS03

        * Low Disk Space

    .EXAMPLE
        PS C:\> $cred = Get-Credential 'example\administrator'
        PS C:\> $servers = 'dc01','db01','exch01','sp01'
        PS C:\> Get-DiskFree -Credential $cred -cn $servers -Format | ? { $_.Type -like '*fixed*' } | select * -ExcludeProperty Type | Out-GridView -Title 'Windows Servers Storage Statistics'
        
        * Out-GridView

    .EXAMPLE
        PS C:\> $cred = Get-Credential 'example\administrator'
        PS C:\> $servers = 'dc01','db01','exch01','sp01'
        PS C:\> Get-DiskFree -Credential $cred -cn $servers -Format | ? { $_.Type -like '*fixed*' } | sort 'Use%' -Descending | select -Property Name,Vol,Size,'Use%' | Export-Csv -Path $HOME\Documents\windows_servers_storage_stats.csv -NoTypeInformation
        
        * Output to CSV

    .NOTES
        Created by: Marc Weisel
        Last update: 04/08/2010
        Requirement: None
#>

function Get-DiskFree
{

    [CmdletBinding()]
    param 
    (
        [Parameter(Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias('hostname')]
        [Alias('cn')]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter(Position=1,
                   Mandatory=$false)]
        [Alias('runas')]
        [System.Management.Automation.Credential()]$Credential =
        [System.Management.Automation.PSCredential]::Empty,
        
        [Parameter(Position=2)]
        [switch]$Format
    )
    
    BEGIN
    {
        function Format-HumanReadable 
        {
            param ($size)
            switch ($size) 
            {
                {$_ -ge 1PB}{"{0:#.#'P'}" -f ($size / 1PB); break}
                {$_ -ge 1TB}{"{0:#.#'T'}" -f ($size / 1TB); break}
                {$_ -ge 1GB}{"{0:#.#'G'}" -f ($size / 1GB); break}
                {$_ -ge 1MB}{"{0:#.#'M'}" -f ($size / 1MB); break}
                {$_ -ge 1KB}{"{0:#'K'}" -f ($size / 1KB); break}
                default {"{0}" -f ($size) + "B"}
            }
        }
        
        $wmiq = 'SELECT * FROM Win32_LogicalDisk WHERE Size != Null AND DriveType >= 2'
    }
    
    PROCESS
    {
        foreach ($computer in $ComputerName)
        {
            try
            {
                if ($computer -eq $env:COMPUTERNAME)
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -ErrorAction Stop
                }
                else
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -Credential $Credential `
                             -ErrorAction Stop
                }
                
                if ($Format)
                {
                    # Create array for $disk objects and then populate
                    $diskarray = @()
                    $disks | ForEach-Object { $diskarray += $_ }
                    
                    $diskarray | Select-Object @{n='Name';e={$_.SystemName}}, 
                        @{n='Vol';e={$_.DeviceID}},
                        @{n='Size';e={Format-HumanReadable $_.Size}},
                        @{n='Used';e={Format-HumanReadable `
                        (($_.Size)-($_.FreeSpace))}},
                        @{n='Avail';e={Format-HumanReadable $_.FreeSpace}},
                        @{n='Use%';e={[int](((($_.Size)-($_.FreeSpace))`
                        /($_.Size) * 100))}},
                        @{n='FS';e={$_.FileSystem}},
                        @{n='Type';e={$_.Description}}
                }
                else 
                {
                    foreach ($disk in $disks)
                    {
                        $diskprops = @{'Volume'=$disk.DeviceID;
                                   'Size'=$disk.Size;
                                   'Used'=($disk.Size - $disk.FreeSpace);
                                   'Available'=$disk.FreeSpace;
                                   'FileSystem'=$disk.FileSystem;
                                   'Type'=$disk.Description
                                   'Computer'=$disk.SystemName;}
                    
                        # Create custom PS object and apply type
                        $diskobj = New-Object -TypeName PSObject `
                                   -Property $diskprops
                        $diskobj.PSObject.TypeNames.Insert(0,'BinaryNature.DiskFree')
                    
                        Write-Output $diskobj
                    }
                }
            }
            catch 
            {
                # Check for common DCOM errors and display "friendly" output
                switch ($_)
                {
                    { $_.Exception.ErrorCode -eq 0x800706ba } `
                        { $err = 'Unavailable (Host Offline or Firewall)'; 
                            break; }
                    { $_.CategoryInfo.Reason -eq 'UnauthorizedAccessException' } `
                        { $err = 'Access denied (Check User Permissions)'; 
                            break; }
                    default { $err = $_.Exception.Message }
                }
                Write-Warning "$computer - $err"
            } 
        }
    }
    
    END {}
}

Export-ModuleMember Get-DiskFree