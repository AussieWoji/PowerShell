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
	 Created on:   	03/22/2020
	 Created by:   	Paul Wojtysiak
	 Organization: 	Wojis
	 Requirements:  GoDaddy API key and secret
	===========================================================================

    A big thank you to Eric at PBX Hacks for his blog post that provided enough direction
        for me to arrive at this solution
        http://pbxhacks.com/automating-lets-encrypt-ssl-certs-via-godaddy-dns-challenge/

.LINK
    <Put link to Confluence article about script here>

#>

<#

Eric from PBX Hacks
http://pbxhacks.com/automating-lets-encrypt-ssl-certs-via-godaddy-dns-challenge/

https://certbot.eff.org/docs/using.html?highlight=hooks#renewing-certificates

https://developer.godaddy.com/getstarted#doc

https://developer.godaddy.com/doc/endpoint/domains#/

#>

#region Create paramters that can be passed in from the command line
param (
    [Parameter(Mandatory = $true)]
    $CertbotDomain,
    [Parameter(Mandatory = $true)]
    $CertbotValidate
)
#endregion

$sw = [Diagnostics.Stopwatch]::StartNew()

#region Import Modules

#endregion

#region Create variables
$dnsRecordType = "TXT"
$dnsRecordName = "_acme_challenge"
$godaddyApiKey = "9Q5aAG1WbkC_XAVmXdPFMw88i9Y4tsv26F"
$godaddyApiSecret = "9Lu6ya8Yka8FbhbuLt6QFB"
$godaddyUri = "https://api.godaddy.com/v1/domains"
#endregion

#region Functions
function get-GoDaddyDnsRecord {
<#
.SYNOPSIS
    Get DNS record

.DESCRIPTION
    Get DNS record based on parameters provided to the function

.PARAMETER Uri
    Base URL for the Rest API to be accessed

.PARAMETER Domain
    Domain name to search for the DNS record

.PARAMETER RecordType
    What type of DNS record is being searched for

.PARAMETER RecordName
    Name of DNS record being searched for

.PARAMETER Key
    Rest API key

.PARAMETER Secret
    Rest API secret

.INPUTS
    None

.OUTPUTS
    DNS record

.EXAMPLE
    $currentDnsRecordData = (get-GoDaddyDnsRecord -Uri $godaddyUri -Domain $CertbotDomain -RecordType $dnsRecordType -RecordName $dnsRecordName -Key $godaddyApiKey -Secret $godaddyApiSecret).data

.NOTES

#>

    param (
        [Parameter(Mandatory = $true)]
        $Uri,
        [Parameter(Mandatory = $true)]
        $Domain,
        [Parameter(Mandatory = $true)]
        $RecordType,
        [Parameter(Mandatory = $true)]
        $RecordName,
        [Parameter(Mandatory = $true)]
        $Key,
        [Parameter(Mandatory = $true)]
        $Secret
    )

    $getParams = @{
        Uri         = "$Uri/$Domain/records/$RecordType/$RecordName"
        Headers     = @{ 'Authorization' = "sso-key $Key`:$Secret" }
        Method      = 'GET'
        ContentType = 'application/json'
    }

    Invoke-RestMethod @getParams
}

function set-GoDaddyDnsRecord {
<#
.SYNOPSIS
    Set DNS record

.DESCRIPTION
    Get DNS record based on parameters provided to the function

.PARAMETER Validate
    Certbot validate data to be inserted into the DNS record

.PARAMETER Uri
    Base URL for the Rest API to be accessed

.PARAMETER Domain
    Domain name to search for the DNS record

.PARAMETER RecordType
    What type of DNS record is being searched for

.PARAMETER RecordName
    Name of DNS record being searched for

.PARAMETER Key
    Rest API key

.PARAMETER Secret
    Rest API secret

.INPUTS
    Certbot validation data for DNS record

.OUTPUTS
    None

.EXAMPLE
    set-GoDaddyDnsRecord -Validate $CertbotValidate -Uri $godaddyUri -Domain $CertbotDomain -RecordType $dnsRecordType -RecordName $dnsRecordName -Key $godaddyApiKey -Secret $godaddyApiSecret

.NOTES

#>

    param (
        [Parameter(Mandatory = $true)]
        $Validate,
        [Parameter(Mandatory = $true)]
        $Uri,
        [Parameter(Mandatory = $true)]
        $Domain,
        [Parameter(Mandatory = $true)]
        $RecordType,
        [Parameter(Mandatory = $true)]
        $RecordName,
        [Parameter(Mandatory = $true)]
        $Key,
        [Parameter(Mandatory = $true)]
        $Secret
    )

    <#
    $Validate = $CertbotValidate
    $Uri = $godaddyUri
    $Domain = $CertbotDomain
    $RecordType = $dnsRecordType
    $RecordName = $dnsRecordName
    $Key = $godaddyApiKey
    $Secret = $godaddyApiSecret

    $Validate
    $Uri
    $Domain
    $RecordType
    $RecordName
    $Key
    $Secret
    #>

    $bodyData = ConvertTo-Json @(@{"data" = $Validate; "ttl" = 600 })

    $putParams = @{
        Uri         = "$Uri/$Domain/records/$RecordType/$RecordName"
        Headers     = @{ 'Authorization' = "sso-key $Key`:$Secret" }
        Method      = 'PUT'
        ContentType = 'application/json'
        Body        = "$bodyData"
    }

    Invoke-RestMethod @putParams

    $digParameters = "$RecordName.$Domain"

    # Wait for the answer to match the new validation value
    do {
        $digData = $null

        # Wait for an answer to return from the dig
        do {
            $digData = (dig $digParameters -t $RecordType +short).replace("`"", "")
        } until($digData)

        Start-Sleep -Seconds 30
    } until($digData -eq $Validate)
}
#endregion

#region Script
$currentDnsRecordData = (get-GoDaddyDnsRecord -Uri $godaddyUri -Domain $CertbotDomain -RecordType $dnsRecordType -RecordName $dnsRecordName -Key $godaddyApiKey -Secret $godaddyApiSecret).data

if ($currentDnsRecordData -ne $CertbotValidate) {
    set-GoDaddyDnsRecord -Validate $CertbotValidate -Uri $godaddyUri -Domain $CertbotDomain -RecordType $dnsRecordType -RecordName $dnsRecordName -Key $godaddyApiKey -Secret $godaddyApiSecret
}

# Display the current certbot validation key
(get-GoDaddyDnsRecord -Uri $godaddyUri -Domain $CertbotDomain -RecordType $dnsRecordType -RecordName $dnsRecordName -Key $godaddyApiKey -Secret $godaddyApiSecret).data
#endregion

$sw.Stop()
Write-Host "Execution Time: $($sw.Elapsed.ToString())"
