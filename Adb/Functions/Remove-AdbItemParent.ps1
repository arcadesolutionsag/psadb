﻿<#
    .SYNOPSIS
        Remove the parent item from the adb item.

    .DESCRIPTION
        ...

    .INPUTS
        None

    .OUTPUTS
        None

    .EXAMPLE
        PS C:\> Remove-AdbItemParent -Name 'myname' -Parent 'myparent'
        Remove the parent myparent from the item myname.
#>
function Remove-AdbItemParent
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # The adb session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('Adb.Session')]
        [System.Object]
        $Session,

        # The item name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # The parent to remove from the item.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Parent
    )

    $Session = Test-AdbSession -Session $Session

    $item = Get-AdbItem -Session $Session -Name $Name

    # Prepare the parent list
    $parents = [System.String[]] $item.parentsNames
    $parents = $parents | Where-Object { $_ -ne $Parent } | Sort-Object

    $item = [PSCustomObject] @{
        name         = $Name
        parentsNames = $parents
    }

    $requestSplat = Get-AdbSessionRequestSplat -Session $Session -Method 'Put'
    $requestSplat['Uri'] = '{0}/items/{1}' -f $Session.Uri, $Name
    $requestSplat['Body'] = $item | ConvertTo-Json -Compress -Depth 99

    if ($PSCmdlet.ShouldProcess($requestSplat.Uri, $requestSplat.Method.ToUpper()))
    {
        Write-Verbose ('{0} {1}   {2}' -f $requestSplat.Method.ToUpper(), $requestSplat.Uri, $requestSplat.Body)
        Invoke-RestMethod @requestSplat -Verbose:$false -ErrorAction 'Stop' | Out-Null
    }
}
