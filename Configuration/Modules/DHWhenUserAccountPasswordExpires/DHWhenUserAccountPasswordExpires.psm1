<#
.Synopsis
   Gets date password was last set and when password will expire for a user account.
.DESCRIPTION
   The Get-DHWhenUserAccountPasswordExpires gets the expiration date of a user account.
.Notes
   You must have Remote Server Administration Tools (RSAT) install prior to using this function. 
.EXAMPLE
   PS C:\> Get-DHWhenUserAccountPasswordExpires -UserName app2svcacct1 -Domain WOJISWEB.com

  
    UserPrincipalName      PasswordNeverExpires Password Set        Password Expires Date
    -----------------      -------------------- ------------        ---------------------
    app2svcacct1@WOJISWEB.COM                False 2/3/2015 2:56:35 PM 4/4/2015 3:56:35 PM  

     This command will get the password expiration date for user app2svcacct expires
.EXAMPLE
  PS C:\> Get-DHWhenUserAccountPasswordExpires -UserName app2svcacct* -Domain WOJISWEB.com

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
function Get-DHWhenUserAccountPasswordExpires
{
    Param
    (
        [Parameter(Mandatory=$true)][String]$UserName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("wojisweb.com","wojisapp.com","wojis.com","wojis.qua","wojis.tst","wojis.dev")]
        [String]$Domain
    )

    Begin
    {
        Switch ($Domain)
              {
                  'wojisweb.com' {$DC = "prddc001.wojisweb.com";$Search = "DC=wojisweb,DC=com"}
                  'wojisapp.com' {$DC = "prddc001.wojis.com";$Search = "DC=wojisapp,DC=com"}
                  'wojis.com' {$DC = "prddc001.wojis.com";$Search = "DC=wojis,DC=com"}
                  'wojis.qua' {$DC = "quadc001.wojis.qua";$Search = "DC=wojis,DC=qua"}
                  'wojis.tst' {$DC = "tstdc001.wojis.tst";$Search = "DC=wojis,DC=tst"}
                  'wojis.dev' {$DC = "devdc001.wojis.dev";$Search = "DC=wojis,DC=dev"}
                  Default {Exit}
              }
    }
    Process
    {
        Get-ADUser -Filter {Name -like $UserName} -Properties msDS-UserPasswordExpiryTimeComputed,PasswordLastSet,PasswordNeverExpires -Server $DC | 
        Format-Table -AutoSize -property UserPrincipalName,PasswordNeverExpires,@{L="Password Set";E={$_."PasswordLastSet"}},@{L="Password Expires Date";E={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
    }
    End
    {
    }
}