
<#
.SYNOPSIS
    Removes computer object from AD
.DESCRIPTION
    This script will remove the computer object from AD based on the value passed in via the user
.PARAMETER vmName
    Full VM name for the computer object you wish to delete.
.EXAMPLE
    .\Ad-RemoveObject.ps1 -vmName "fqdn"
#>

param
(
    [Parameter(Mandatory=$true)]   [string] [ValidateNotNullOrEmpty()]  $vmName
)

$ErrorActionPreference = "Stop";
$separator ="."
$adMachine = $vmName.split($separator,2)[0]

try
{
    if ($adComputer = Get-ADComputer $adMachine)
    {
        $domainCheck = $adComputer.DistinguishedName
        if($domainCheck.Split(',') -match '^ou=.*Domain Controllers')
        {
            Write-Output "Cannot remove computer $vmName as it belongs to the domain controller computer group"
            exit(1)
        }
        else
        {
            Remove-ADObject -Identity $adComputer -Recursive -Confirm:$false
            Write-Output "Removed AD object $adComputer"
            exit(0)
        }
    }
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
{
    Write-Output "$vmName computer does not exist"
    exit(1)
}
catch [Exception]
{
    Write-Output $_.Exception.Message
    exit(1)
}
