<#
.SYNOPSIS
    Process all the SQL items in an ItemGroup
.DESCRIPTION
    Process all the SQL items in an ItemGroup.
#>

param( 
    [Parameter(Mandatory=$true)] 
    [string] $Subscription,

    [Parameter(Mandatory=$true)] 
    [string] $ResourceGroupName,

    [Parameter(Mandatory=$true)] 
    [string] $VaultName,

    [Parameter(Mandatory=$true, HelpMessage="Item group number to unprotect")] 
    [System.Int64] $ItemGroupNumber
)

function script:TraceMessage([string] $message, [string] $color="Yellow")
{
    Write-Host "`n$message" -ForegroundColor $color
}

try
{
    Set-AzContext -Subscription $Subscription | Out-Null
}
catch
{
    Add-AzAccount
    Set-AzContext -Subscription $Subscription | Out-Null
}

$path = (Get-Location).Path 
$path = $path + "\itemGroup" + $ItemGroupNumber
$content = Get-Content -Path $path

#fetch recovery services vault  
$vault =  Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName

foreach ($itemId in $content){
    $item = Get-AzRecoveryServicesBackupItem -vaultId $vault.ID -BackupManagementType "AzureWorkload" -WorkloadType "MSSQL" | Where-Object {$_.Id -eq $itemId}
    
    # <your-code-here>
}
