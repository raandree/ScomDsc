<#
    .SYNOPSIS
        Unit test for Resolve-cScomModule.

    .NOTES
        Resolve-cScomModule locates and imports the OperationsManager module.
        All external dependencies are mockable since the function uses standard
        PowerShell commands (Get-Module, Import-Module, Get-ChildItem).
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeAll {
    $script:dscModuleName = 'ScomDsc'

    # Add RequiredModules to the module path so DscResource.Base and friends resolve.
    $requiredModulesPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\output\RequiredModules'
    $builtModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\output\builtModule'

    foreach ($pathToAdd in @($requiredModulesPath, $builtModulePath))
    {
        if (Test-Path -Path $pathToAdd)
        {
            $resolvedPath = Resolve-Path -Path $pathToAdd

            if ($env:PSModulePath -notlike "*$resolvedPath*")
            {
                $env:PSModulePath = '{0}{1}{2}' -f $resolvedPath, [System.IO.Path]::PathSeparator, $env:PSModulePath
            }
        }
    }

    Import-Module -Name $script:dscModuleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:dscModuleName -Force
}

Describe 'Resolve-cScomModule' {
    Context 'When OperationsManager module is already loaded' {
        BeforeAll {
            Mock -CommandName Get-Module -ParameterFilter { $Name -eq 'OperationsManager' -and -not $ListAvailable } -MockWith {
                [PSCustomObject]@{ Name = 'OperationsManager' }
            }
            Mock -CommandName Import-Module
        }

        It 'Should not attempt to import the module' {
            Resolve-cScomModule
            Should -Invoke -CommandName Import-Module -Times 0
        }

        It 'Should return early without error' {
            { Resolve-cScomModule } | Should -Not -Throw
        }
    }

    Context 'When OperationsManager module is available via ListAvailable' {
        BeforeAll {
            $script:mockModuleInfo = [PSCustomObject]@{ Name = 'OperationsManager'; ModuleType = 'Script' }

            Mock -CommandName Get-Module -ParameterFilter { $Name -eq 'OperationsManager' -and -not $ListAvailable } -MockWith { $null }
            Mock -CommandName Get-Module -ParameterFilter { $Name -eq 'OperationsManager' -and $ListAvailable } -MockWith { $script:mockModuleInfo }
            Mock -CommandName Import-Module
        }

        It 'Should import the module' {
            Resolve-cScomModule
            Should -Invoke -CommandName Import-Module -Times 1
        }
    }

    Context 'When OperationsManager module is not available via ListAvailable but found on disk' {
        BeforeAll {
            $script:mockModuleInfo = [PSCustomObject]@{ Name = 'OperationsManager'; ModuleType = 'Script' }

            Mock -CommandName Get-Module -ParameterFilter { $Name -eq 'OperationsManager' -and -not $ListAvailable } -MockWith { $null }
            Mock -CommandName Get-Module -ParameterFilter { $Name -eq 'OperationsManager' -and $ListAvailable } -MockWith { $null }
            Mock -CommandName Get-ChildItem -MockWith {
                [PSCustomObject]@{ FullName = 'C:\Program Files\SCOM\OperationsManager.psd1' }
            }
            Mock -CommandName Get-Module -ParameterFilter { $Name -ne 'OperationsManager' } -MockWith { $script:mockModuleInfo }
            Mock -CommandName Import-Module
        }

        It 'Should search for the module on disk' {
            Resolve-cScomModule
            Should -Invoke -CommandName Get-ChildItem -Times 1
        }
    }

    Context 'When OperationsManager module is not found anywhere' {
        BeforeAll {
            Mock -CommandName Get-Module -MockWith { $null }
            Mock -CommandName Get-ChildItem -MockWith { $null }
            Mock -CommandName Import-Module
            Mock -CommandName Write-Error
        }

        It 'Should write an error' {
            Resolve-cScomModule
            Should -Invoke -CommandName Write-Error -Times 1
        }

        It 'Should not attempt to import' {
            Resolve-cScomModule
            Should -Invoke -CommandName Import-Module -Times 0
        }
    }
}
