$script:ModuleName = 'MarkdownEx'

$script:Source = Join-Path $BuildRoot $ModuleName
$script:Output = Join-Path $BuildRoot "BuildOutput"
$script:Destination = Join-Path $Output $ModuleName
$script:ManifestPath = "$Destination\$ModuleName.psd1"
$script:Imports = ( 'classes', 'public', 'private' )
$script:TestFile = "$PSScriptRoot\BuildOutput\TestResults_PS$PSVersion`_$TimeStamp.xml"

Task Default Clean, Build, Pester, UpdateSource
Task Build Compile, CopyToOutput
Task BuildTest Build, ImportModule, UnitTests
Task Pester ImportModule, UnitTests
Task Publish

Task Clean {
    "Cleaning output folder"
    $null = Get-ChildItem $Output -Recurse -File | Remove-Item -ErrorAction Ignore
    $null = New-Item  -Type Directory -Path $Destination -ErrorAction Ignore
}

Task Compile {
    # This build command requires .Net Core
    "Compiling solution..."
    dotnet build $BuildRoot -c Release
}

Task CopyToOutput {

    $null = New-Item -Type Directory -Path $Destination -ErrorAction Ignore

    "  Copying binaries from [{0}] to [{1}]" -f "$buildRoot\$ModuleName\bin\Release", "$Destination\"
    "    This will fail if this module was ever loaded in any active PowerShell sessions."
    $copySplat = @{
        Path = "$Source\bin\Release\*.dll"
        Destination = "$Destination\"
        ErrorAction = 'Stop'
        Exclude = "System.Management.Automation.dll"
        Verbose = $true
    }
    Copy-Item @copySplat

    $copySplat = @{
        Path = "$BuildRoot\$ModuleName\$ModuleName.psd1"
        Destination = $ManifestPath
        ErrorAction = 'Stop'
        Verbose = $true
    }
    Copy-Item @copySplat

    Step-ModuleVersion -Path $ManifestPath -By Build
}

Task UnitTests {
    $TestResults = Invoke-Pester -Path Tests\ -PassThru -Tag Build -ExcludeTag Slow
    if ($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed [$($TestResults.FailedCount)] Pester tests"
    }
}

Task ImportModule {
    if ( -Not ( Test-Path $ManifestPath ) )
    {
        Write-Output "  Modue [$ModuleName] is not built, cannot find [$ManifestPath]"
        Write-Error "Could not find module manifest [$ManifestPath]. You may need to build the module first"
    }
    else
    {
        if (Get-Module $ModuleName)
        {
            Write-Output "  Unloading Module [$ModuleName] from previous import"
            Remove-Module $ModuleName -Force
        }
        Write-Output "  Importing Module [$ModuleName] from [$ManifestPath]"
        Import-Module $ManifestPath -Force
    }
}

Task UpdateSource {
   Copy-Item -Path $ManifestPath -Destination "$Source\$ModuleName.psd1" -Force -Verbose
}

Task Publish {
    $TMModule = @{
        ManifestPath = $ManfestPath
        NugetApiKey = (Get-TMConfigSetting -Environment Production -Project Global)['ProgetAPIKey']
        Repository = 'TMDevOps'
    }
    Publish-TMModule @TMModule
}