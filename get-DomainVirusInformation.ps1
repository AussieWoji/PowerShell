<#
    PowerShell script to retrieve information on a domain from virustotal.com

    API documentation can be found at https://developers.virustotal.com/

#>

param (
    [Parameter(Mandatory = $true)]
    $DomainName
)

# Need to keep this API key private
$virustotalApiKey = "830638d4c4fc756e9a7e17911ef7e949aae222f2aec39a14f4c64c8e6c8cd18a"
$url = 'https://www.virustotal.com/vtapi/v2/domain/report?apikey=' + $virustotalApiKey + '&domain=' + $DomainName

Invoke-RestMethod -Uri $url
