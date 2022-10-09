
<#PSScriptInfo

.VERSION 1.0.0

.GUID d4e95bd6-ba9c-4024-8de2-0f6d1b8439b4

.AUTHOR daniznf

.COMPANYNAME znflabs

.COPYRIGHT (c) 2022 daniznf. All rights reserved.

.TAGS Install module

.LICENSEURI https://www.gnu.org/licenses/gpl-3.0.txt

.PROJECTURI https://github.com/daniznf/DTInstallModule

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

#>

param (
    [string]
    $ModuleDir,
    [string]
    $PSModuleDir
)


if ($ModuleDir -and (-not (Test-Path $ModuleDir)))
{
    Write-Host "Directory $ModuleDir does not exist!"
    $ModuleDir = $null
}

$InvocationPath = $MyInvocation.MyCommand.Path

if (-not $ModuleDir) { $ModuleDir = Split-Path $InvocationPath -Parent }

# Find this script actual name
$InstallScriptName = $MyInvocation.MyCommand.Name
$InstallScriptName = $InstallScriptName.Remove($InstallScriptName.LastIndexOf("."))

# If this is in subdirectory of the module to install, go up of one directory. The module to install should be there.
$ModuleName = Split-Path $ModuleDir -Leaf
if ($ModuleName -eq $InstallScriptName)
{
    $ModuleDir = Split-Path $ModuleDir -Parent
    $ModuleName = Split-Path $ModuleDir -Leaf
}

Write-Host "This installation script is going to install $ModuleName from $ModuleDir."

if (-not ($PSModuleDir))
{
    $ModulePaths = $env:PSModulePath.Split(";")
    if ($ModulePaths -is [System.Array])
    {
        Write-Host ""
        Write-host "Recognized module paths are:"
        for ($i = 0; $i -lt $ModulePaths.Length; $i++)
        {
            Write-Host ("{0}: {1}" -f $i, $ModulePaths[$i])
        }

        [int] $Choice = -1
        while ($Choice -notin (0..($ModulePaths.Length-1)))
        {
            Write-Host ""
            $Choice = Read-Host -Prompt ("Please choose where you want to install module [{0}-{1}]" -f 0, ($ModulePaths.Length-1) )
            Write-Host ""
        }

        $PSModuleDir = $ModulePaths[$Choice]
    }
    else # $ModulesPaths is string
    {
        $PSModuleDir = $ModulesPaths
    }
}

$ModuleInstallDir = Join-Path $PSModuleDir $ModuleName

Write-Host "Module $ModuleName will be installed in $ModuleInstallDir."

[string] $Choice = Read-Host -Prompt ("Continue? [y-n]")
if (($Choice -ne "y") -and ($Choice -ne "yes"))
{
    Write-Host ""
    Write-Host "Installation aborted."
    Write-Host ""
    Write-Host "Press return."
    $null = Read-Host
    exit 1
}

try
{
    if (-not (Test-Path $ModuleInstallDir))
    {
        Write-Host ""
        Write-Host "Creating $ModuleInstallDir ..."
        New-Item -Path $ModuleInstallDir -ItemType Directory -ErrorAction Stop
    }

    Remove-Module $ModuleName -ErrorAction Ignore

    Write-Host ""
    Write-Host "Copying module files..."
    Copy-Item -Path (Join-Path $ModuleDir "*") -Destination $ModuleInstallDir -Include "*.psd1","*.psm1", "README.md", "LICENSE" -ErrorAction Stop

    Write-Host ""
    Write-Host "Installation finished!"
    Write-Host ""
    Write-Host "Press return."
    $null = Read-Host
    exit 0
}
catch
{
    Write-Host $_
    Write-Host ""
    Write-Host "Press return."
    $null = Read-Host
    exit 1
}


<#
.SYNOPSIS
    Installs module.

.DESCRIPTION
    This script installs module found in containing directory, or parent directory, into modules directory.
    The script is intended to be run inside the directory of the module to install, but can also be run from anywhere passing necessary parameters.

.PARAMETER ModuleDir
    Directory of the module to install.

.PARAMETER PSModuleDir
    One of directories in $env:PSModulePath.
#>