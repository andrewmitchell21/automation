<#
.SYNOPSIS
    Removes computer DNS record from the Domain Controller
.DESCRIPTION
    This script will remove a DNS from record for a given vm, please note you must pass the fully qualified domain name for the vm, E.g. ew1-st01-250-01.ad.bedegaming.net
.PARAMETER vmName
    Full VM name for the computer object you wish to delete.
.EXAMPLE
    .\DNS-RemoveDNSRecord.ps1 -vmName "ew1-st01-250-01.ad.bedegaming.net"
.NOTES
      Author: Andrew Mitchell
#>

param
(
    [Parameter(Mandatory=$true)]   [string] [ValidateNotNullOrEmpty()]  $vmName
)

$ErrorActionPreference = "Stop";
$separator ="."
$dnsName = $vmName.split($separator,2)[0]
$dnsZoneName = $vmName.split($separator,2)[1]

if (!$dnsZoneName )
{
    Write-Output "A fully qualified domain name must be supplied, aborting script."
    exit(1)
}

try
{
    $dnsRecord = Get-DnsServerResourceRecord -ZoneName $dnsZoneName -Name $dnsName -ErrorAction Stop
    if ($dnsRecord)
    {
      Remove-DnsServerResourceRecord -ZoneName $dnsZoneName -Name $dnsName -RRType $dnsRecord.RecordType -Confirm:$false -Force 
      Write-Output "Removed DNS Record $dnsRecord"
    }
    else
    {
      Write-Output "DNS Record does not exist for $vmName"
      exit(0)
    }
}

catch [Exception]
{
    Write-Output $_.Exception.Message
    exit(1)
}
