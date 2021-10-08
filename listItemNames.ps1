<#
.SYNOPSIS
    Lists all the SQL items in a vault and creates n parallel Item groups    
.DESCRIPTION
    Lists all the SQL items in a vault and creates n parallel Item groups.
#>

param( 
    [Parameter(Mandatory=$true)] 
    [string] $Subscription,

    [Parameter(Mandatory=$true)] 
    [string] $ResourceGroupName,

    [Parameter(Mandatory=$true)] 
    [string] $VaultName,

    [Parameter(Mandatory=$true, HelpMessage="Total items to unprotect")] 
    [System.Int64] $TotalItems,

    [Parameter(Mandatory=$true, HelpMessage="Number of jobs to run in parallel")] 
    [System.Int64] $TotalItemGroups    
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

if ($TotalItems -lt $TotalItemGroups){
    throw "Parameter 'TotalItems' value can't be less than parameter 'TotalItemGroups'"
}

#fetch recovery services vault  
$vault =  Get-AzRecoveryServicesVault -ResourceGroupName $ResourceGroupName -Name $VaultName

$backupItemList = Get-AzRecoveryServicesBackupItem -vaultId $vault.ID -BackupManagementType "AzureWorkload" -WorkloadType "MSSQL"
$itemIds = $backupItemList.Id

if ($backupItemList.Length -lt $TotalItems){
    throw "TotalItems count given is more than the total items present in the vault"
}

$start = 0 
$offset = [int][Math]::Floor($TotalItems / $TotalItemGroups)

for ($i = 1; $i -le $TotalItemGroups; $i = $i + 1){
    
    $end = $start + $offset -1
    if($i -eq $TotalItemGroups){
        $end = $TotalItems - 1 
    }

    $fileName = "itemGroup"+$i   
    $itemIds[$start..$end] > $fileName
    $start = $start + $offset
}
