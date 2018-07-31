[cmdletbinding()]
param ($Task = 'Default')
Write-Output "Starting build"

# Grab nuget bits, install modules, set build variables, start build.
Write-Output "  Install Dependent Modules"
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
$moduleList = @('InvokeBuild', 'BuildHelpers', 'PSScriptAnalyzer','Pester')
ForEach ($module in $moduleList)
{
    If ( -Not ( Get-Module $module -ListAvailable -ErrorAction Ignore ) )
    {
        "    Installing module [$module]"
        Install-Module -Name $module -Force -Scope CurrentUser 
    }
}

Write-Output "  Import Dependent Modules"
Import-Module InvokeBuild, BuildHelpers, PSScriptAnalyzer

#clean up build environment
foreach ( $item in (Gci Env: | ? {$_.name -like "BH*"}).name )
{
    Invoke-Expression "Remove-Item `Env:$item" -Verbose
}
Set-BuildEnvironment


Write-Output "  InvokeBuild"
Invoke-Build $Task -Result result
if ($Result.Error)
{
    exit 1
}
exit 0
