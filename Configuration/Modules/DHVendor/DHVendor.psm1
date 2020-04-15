<#
    Gets the directory the script was started in.  There are quite a few ways to get the script directory 
    but I like this way so it is what I use (though I normally don't scope the scriptpath variable at the script level).
#>
function Get-ScriptDirectory
{
$Invocation = (Get-Variable MyInvocation -Scope 1).Value
Split-Path $Invocation.MyCommand.Path
}
$script:scriptpath = Get-ScriptDirectory


<#
.Synopsis
   Creates a new vendors.xml file.
.DESCRIPTION
   The New-DHVendorFile will create a default vendors.xml file.  If the file exists you will be prompted to overwrite the existing file. 
.EXAMPLE
   PS C:\> New-DHVendorFile

   This command will create a delfault Vendor.xml file.
.EXAMPLE
   PS C:\> New-DHVendorFile -Force

   This command uses the Force parameter to overwrite an existing Vendors file without prompting the user. 
.INPUTS
   None
.OUTPUTS
   None
.NOTES
    This cmdlet will create a new file named vendors.xml in the current directory (default location is in .\Documents\WindowsPowerShell\Modules\DHVendor.)
.FUNCTIONALITY
   This cmdlet is used to create a default vendors.xml file.  
.LINK
   Add-DHVendor
.LINK
   Get-DHVendorList
.LINK
   New-DHVendorToken
#>
function New-DHVendorFile
{
    param([switch]$Force)            
    $xmlfile  = "vendors.xml"
    $FileCheck = Test-Path "$scriptpath\$xmlfile"
    If (($FileCheck) -and ($force -eq $false)){
        $title = "Confirm new XML file"
        $message = "Are you sure you want to create a new vendor file?" 
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes","Yes"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No","No"
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        $answer = $host.ui.PromptForChoice($title, $message, $options, 1)
        Switch ($answer){
            0 {$new = 'yes'}
            1 {$new = 'no'}
            }
        }
    If(($FileCheck -eq $false) -or ($new -eq 'yes') -or ($force)){
        $XmlTextWriter = New-Object System.Xml.XmlTextWriter("$scriptpath\$xmlfile",$Null)
        $XmlTextWriter.Formatting = 'Indented'
        $XmlTextWriter.Indentation = 1
        $XmlTextWriter.IndentChar = "`t"
        $XmlTextWriter.WriteStartDocument()
        $XmlTextWriter.WriteProcessingInstruction("xml-stylesheet", "type='text/xsl' href='style.xsl'")
        #root element
        $XmlTextWriter.WriteStartElement('Environments')
        # template
        for($x=0; $x -le 4; $x++)
        {
            $Group = @('DEV','TST','QUA','PRD')
            $XmlTextWriter.WriteStartElement('Environment')
            $XmlTextWriter.WriteAttributeString('Name',$Group[$x])
            $XmlTextWriter.WriteStartElement('Vendor')
            $XmlTextWriter.WriteAttributeString('Name',"MTT Maintenance")
            $XmlTextWriter.WriteElementString('GUID',"991f85d7-74a6-466c-ad57-4b6916892709")
            $XmlTextWriter.WriteEndElement()
            $XmlTextWriter.WriteEndElement()
        }
        $XmlTextWriter.WriteEndElement()
        $XmlTextWriter.Flush()
        $XmlTextWriter.Close()
    }
    Else {
    Write-Warning "Creation of new vendor file canceled"
    }
}

<#
.Synopsis
   Adds a new vendor name and GUID to the Vendors file.
.DESCRIPTION
   The Add-DHVendor command will add new vendors to the Vendors file. 
.EXAMPLE
   PS C:\> Add-DHVendor -Environment DEV -VendorName Wojis -GUID bdb7f4df-173f-413a-91da-b3f268a46edf

   This command will add a new VendorId named Wojis for the DEV environment in the vendors file.  All parameters are mandatory for this command. 
.INPUTS
   None
.OUTPUTS
   None
.NOTES
   VendorName parameter can be any descriptive name.
   GUID parameter must be a valid VendorID or GUID in the environment. 
.FUNCTIONALITY
   This cmdlet is used to add new venodors to the vendors XML file.  
.LINK
   New-DHVendorFile
.LINK
   Get-DHVendorList
.LINK
   New-DHVendorToken
#>
function Add-DHVendor
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('DEV','TST','QUA','PRD')]
        [string]$Environment,

        [Parameter(Mandatory=$true)]
        [string]$VendorName,

        [Parameter(Mandatory=$true)]
        [guid]$GUID
    )
    $xmlfile = 'vendors.xml'
    [string]$GUID = $GUID
    $FileCheck = Test-Path "$scriptpath\$xmlfile"
        if ($FileCheck -eq $false){
        Write-Error "Cannot find $xmlfile in directory $scriptpath." -RecommendedAction "Use New-DHVendorFile to create a new vendor XML file."
        return}
    switch ($Environment)
    {
        'DEV' {$EvKey = 1}
        'TST' {$EvKey = 2}
        'QUA' {$EvKey = 3}
        'PRD' {$EvKey = 4}        
    }
    $xml = New-Object -TypeName XML
    $xml.Load("$scriptpath\$xmlfile")
    
    $xmlitem = select-xml -xml $xml -XPath "//Environment[$EvKey]/Vendor[1]"
    $xmlnewnode = $xmlitem.Node.CloneNode($true)
    $xmlnewnode.Name = $VendorName
    $xmlnewnode.GUID = $GUID

    $xmlappendnode = Select-Xml -xml $xml -XPath "//Environment[$EvKey]"
    $xmlappendnode.Node.AppendChild($xmlnewnode)

    $xml.Save("$scriptpath\$xmlfile")
}

<#
.Synopsis
   Gets a list of Vendors from the vendor file for an environment.
.DESCRIPTION
   The Get-DHVendorList command will list vendors from the vendor file. 
.EXAMPLE
   PS C:\> Get-DHVendorList -Environment DEV

   This command will list Vendors and their accociated GUID from the vendor file for the DEV environment.  All parameters are mandatory for this command. 
.INPUTS
   None
.OUTPUTS
   None
.NOTES
   None 
.FUNCTIONALITY
   This cmdlet is used view Vendors and Vendor IDs.  
.LINK
   New-DHVendorFile
.LINK
   Add-DHVendor
.LINK
   New-DHVendorToken
#>
function Get-DHVendorList
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('DEV','TST','QUA','PRD')]
        [string]$Environment
    )
    switch ($Environment)
    {
        'DEV' {$EvKey = 1}
        'TST' {$EvKey = 2}
        'QUA' {$EvKey = 3}
        'PRD' {$EvKey = 4}              
    }
    $xmlfile = 'vendors.xml'
    $xml = New-Object -TypeName XML
    $xml.Load("$scriptpath\$xmlfile")
    $output = (Select-Xml -xml $xml -XPath "//Environment[$EvKey]").Node.vendor
    write-output $output
}

<#
.Synopsis
   Creates a token.
.DESCRIPTION
   The New-DHVendorToken will connect to UAS to generate a token. By default a Session token is generated. 
.EXAMPLE
   PS C:\> New-DHVendorToken -Environment QUA -User 11111111 -VendorName Wojis

    CreateTime  : 6/23/2015 12:52:25 PM
    UserAccount : 11111308
    VendorName  : Wojis
    VendorID    : bdb7f4df-173f-413a-91da-b3f268a46edf
    Token       : 6f41cbf1c5703dcd4d6513b07b0f21c43993589afa0022b65a813c32b...continues.
    TokenType   : Session
    
   This command will generate a new Session token.
.EXAMPLE
   PS C:\> New-DHVendorToken -Environment QUA -User 11111111 -VendorName Wojis -TokenType SingleSignOn


    CreateTime  : 6/23/2015 12:53:58 PM
    UserAccount : 11111308
    VendorName  : Wojis
    VendorID    : bdb7f4df-173f-413a-91da-b3f268a46edf
    Token       : 5e0a319fb6ddf47677832278d4a3cf117b317ab27a999f4b60360f4d...continues.
    TokenType   : SingleSignOn

   This command will generate a new Single Sign On token. 
.INPUTS
   None
.OUTPUTS
   None
.NOTES
    None
.FUNCTIONALITY
   This cmdlet is used to create a default vendors.xml file.  
.LINK
   Add-DHVendor
.LINK
   Get-DHVendorList
.LINK
   New-DHVendorFile
#>
function New-DHVendorToken
{

    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                  SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  ConfirmImpact='Medium')]
    [OutputType([String])]
 
    param(
            [Parameter(Mandatory=$true,
                        Position=0,
                        ParameterSetName='Parameter Set 1')]
            [ValidateSet('DEV','TST','QUA','PRD')]
            [string]$Environment,
            [Parameter(Mandatory=$true,
                        Position=2,
                        ParameterSetName='Parameter Set 1')]
            [int]$User,
            [Parameter(Mandatory=$false,
                        Position=3,
                        ParameterSetName='Parameter Set 1')]
            [ValidateSet('Session','StreamSession','SingleSignOn')]
            [string]$TokenType = 'Session'
    )

    DynamicParam {
            switch ($Environment)
            {               
                'DEV' {$EvKey = 0;$tokenserver = "devapp1f1w001.wojis.dev"}
                'TST' {$EvKey = 1;$tokenserver = "tstapp1f1w001.wojis.tst"}
                'QUA' {$EvKey = 2;$tokenserver = "quaapp1f1w001.wojis.qua"}
                'PRD' {$EvKey = 4;$tokenserver = "prdapp1f1w001.wojis.com"}                        
            }

            #Help on Dynamic Parameters can be found in about_Functions_Advanced_Parameters
            $ParameterName = 'VendorName'
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.ParameterSetName = 'Parameter Set 1'
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1
            $ParameterAttribute.ValueFromPipeline=$false
            $ParameterAttribute.ValueFromPipelineByPropertyName=$false
            $AttributeCollection.Add($ParameterAttribute)
            $arrSet = ([xml](Get-Content "$Scriptpath\vendors.xml")).Environments.Environment[$EvKey].vendor.name
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
            $AttributeCollection.Add($ValidateSetAttribute)
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }

    Begin
    {
        $VendorName = $PsBoundParameters[$ParameterName]
        #[string]$VendorID = "bdb7f4df-173f-413a-91da-b3f268a46edf"
        #[string]$User = "11111111"
        $reg = [regex]"(?is)(?<=\bSecurityToken>\b).*?(?=\b</a:SecurityToken\b)"
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
        }
        $xml = [xml](Get-Content "$Scriptpath\vendors.xml")
        $G = $XML.Environments.Environment[$EvKey].Vendor |
                Where-Object {$_.Name -eq $vendorname} |
                Select-Object -Property GUID
        $GUID = $G.Guid
        $uri = "http://$tokenserver/UserAuthenticationService/UserAuthenticationService.svc/TokenService/V1"
        $body = @"
            <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
                <s:Body>
                    <GenerateToken xmlns="http://service.wojis.com/authentication.user/v1/">
                        <request xmlns:a="http://data.wojis.com/authentication.user/v1/" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                        <a:ClientIdentity xmlns:b="http://schemas.wojis.com/WebServiceComponents/RequestValidation/DataContracts/v1">
                            <b:SecurityToken>Test</b:SecurityToken>
                            <b:UserId>$User</b:UserId>
                            <b:VendorId>$GUID</b:VendorId>
                        </a:ClientIdentity>
                        <a:TokenTypes>
                            <a:TokenType>$TokenType</a:TokenType>
                        </a:TokenTypes>
                        </request>
                    </GenerateToken>
                </s:Body>
            </s:Envelope>
"@
        try
        {
            $r = Invoke-WebRequest -uri $uri -Headers @{"SOAPAction"="`"http://service.wojis.com/authentication.user/v1/ITokenService/GenerateToken`""; `
                                            "Accept-Encoding"="gzip, deflate"} -Body $body -Method Post -ContentType "text/xml; charset=utf-8"              `
                                            -ErrorAction Stop -ErrorVariable URIError
            $w = $reg.Matches($r.Content)
            $time = Get-Date
            [pscustomobject]@{"CreateTime" = $time
                           "UserAccount" = $User
                           "VendorName" = $VendorName
                           "VendorID" = $GUID 
                           "Token" = $w.Value
                           "TokenType" = $TokenType
                        }
        }
        Catch [System.Net.WebException]
        {
            
            Write-Error $URIError.Message
        }

    }
    End
    {
    }
}

Export-ModuleMember -Alias * -Function New-DHVendorToken, Get-DHVendorList, Add-DHVendor, New-DHVendorFile