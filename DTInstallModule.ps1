
<#PSScriptInfo

.VERSION 1.1.1

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
$ModuleDir = Resolve-Path $ModuleDir

# Find this script's actual name
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
    # Modules should be installed in ModulePath. This should be an array of paths.
    $ModulePaths = $env:PSModulePath.Split(";")
    if ($ModulePaths.Length -gt 1)
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
        $PSModuleDir = $ModulesPaths[0]
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
    Remove-Module $ModuleName -ErrorAction Ignore

    Write-Host ""
    Write-Host "Copying module files..."

    $DirExclude = "git|vscode|$InstallScriptName"
    $FileInclude = "\.psd1|\.psm1|README|LICENSE"

    # get files, recursively, excluding directories that match $DirExclude and including only files that match $FileInclude
    $Files = Get-ChildItem -Path $ModuleDir -Recurse -File |
        Where-Object { ($_.DirectoryName -notmatch $DirExclude) -and ($_.FullName -match $FileInclude) }

    for ($i = 0; $i -lt $Files.Length; $i++)
    {
        $File = $Files[$i]
        $Source = $File.FullName

        $DestinationDir = $ModuleInstallDir

        # if file is in subdirectory, add that subdirectory to destination
        if ($File.DirectoryName -ne $ModuleDir)
        {
            $RelativeDir = $File.DirectoryName.Replace($ModuleDir, "")
            $DestinationDir = Join-Path $ModuleInstallDir $RelativeDir
        }

        if (-not (Test-Path $DestinationDir))
        {
            Write-Host ""
            Write-Host "Creating $DestinationDir..."
            $null = New-Item -Path $DestinationDir -ItemType Directory -ErrorAction Stop
        }

        $Destination = Join-Path $DestinationDir $File.Name

        write-host "Copying  $Destination..."
        Copy-Item -Path $Source -Destination $Destination -ErrorAction Stop -Force
    }

    Write-Host ""
    Write-Host "Installation completed!"
    Write-Host ""
    Write-Host "Press return."
    $null = Read-Host
    exit 0
}
catch
{
    Write-Host ""
    Write-Host $_
    Write-Host "Installation failed."
    Write-Host "Press return."
    $null = Read-Host
    exit 1
}


<#
.SYNOPSIS
    Installs module.

.DESCRIPTION
    This script installs module(s) found in containing directory, or parent directory, by copying necessary files into modules directory.
    The script is intended to be run inside the directory of the module to install, but can also be run from anywhere passing necessary parameters.

.PARAMETER ModuleDir
    Directory of the module to install.

.PARAMETER PSModuleDir
    One of directories in $env:PSModulePath.

.EXAMPLE
    .\DTInstallModule.ps1
    Installs module contained in local or parent directory

.EXAMPLE
    .\DTInstallModule.ps1 -ModuleDir C:\my_module
    Installs module contained in C:\my_module
#>