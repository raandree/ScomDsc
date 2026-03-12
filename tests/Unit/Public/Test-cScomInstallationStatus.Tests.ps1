<#
    .SYNOPSIS
        Unit test for Test-cScomInstallationStatus.

    .NOTES
        The function Test-cScomInstallationStatus does not check the Ensure
        property. It only reports whether a SCOM component is installed.

        Known source bug: AdditionalManagementServer is not handled (falls
        through all branches and returns $null) because the source has a
        duplicate check for FirstManagementServer.
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    $casesGetPackage = @(
        @{
            ScomComponent = @{
                Role            = 'NativeConsole'
                InstallLocation = 'C:\Program Files\Microsoft System Center\Operations Manager'
            }
        }
        @{
            ScomComponent = @{
                Role            = 'FirstManagementServer'
                InstallLocation = 'C:\Program Files\Microsoft System Center\Operations Manager'
            }
        }
        @{
            ScomComponent = @{
                Role            = 'ReportServer'
                InstallLocation = 'C:\Program Files\Microsoft System Center\Operations Manager'
            }
        }
    )

    $casesWebConsole = @(
        @{
            ScomComponent = @{
                Role             = 'WebConsole'
                WebSiteName      = 'Default Web Site'
                ManagementServer = 'MG1'
                InstallLocation  = 'C:\Program Files\Microsoft System Center\Operations Manager'
            }
        }
    )

    # AdditionalManagementServer is not handled by the source function (known bug).
    $casesUnhandled = @(
        @{
            ScomComponent = @{
                Role            = 'AdditionalManagementServer'
                InstallLocation = 'C:\Program Files\Microsoft System Center\Operations Manager'
            }
        }
    )
}

BeforeAll {
    $script:dscModuleName = 'ScomDsc'

    Import-Module -Name $script:dscModuleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName

    # Override Get-Package with a function stub so Pester can mock it.
    # The real Get-Package is a compiled cmdlet (PackageManagement) whose
    # ValidateSet on ProviderName rejects 'msi' and cannot be bypassed
    # by Pester's -RemoveParameterValidation on compiled cmdlets.
    function global:Get-Package
    {
        [CmdletBinding()]
        param
        (
            [Parameter()]
            [string]
            $Name,

            [Parameter()]
            [string]
            $ProviderName
        )
    }

    if (-not (Get-Command -Name Get-WebSite -ErrorAction SilentlyContinue))
    {
        function global:Get-WebSite
        {
            [CmdletBinding()]
            param
            (
                [string]
                $Name
            )
        }
    }
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Item -Path 'Function:\Get-Package' -ErrorAction SilentlyContinue
    Remove-Module -Name $script:dscModuleName -Force
}

Describe 'Test-cScomInstallationStatus' {
    Context 'When Get-Package is available and component is installed' {
        BeforeEach {
            Mock -CommandName Get-Command -MockWith { return 'A command' }
            Mock -CommandName Get-Package -MockWith { return 'A Package' } -ParameterFilter { $Name -like 'System Center Operations Manager*' }
        }

        It 'Should return $true for role <ScomComponent.Role>' -TestCases $casesGetPackage {
            Test-cScomInstallationStatus -ScomComponent $ScomComponent | Should -BeTrue
        }
    }

    Context 'When Get-Package is available and component is NOT installed' {
        BeforeEach {
            Mock -CommandName Get-Command -MockWith { return 'A command' }
            Mock -CommandName Get-Package -MockWith { return $null } -ParameterFilter { $Name -like 'System Center Operations Manager*' }
        }

        It 'Should return $false for role <ScomComponent.Role>' -TestCases $casesGetPackage {
            Test-cScomInstallationStatus -ScomComponent $ScomComponent | Should -BeFalse
        }
    }

    Context 'When WebConsole role and website exists' {
        BeforeEach {
            Mock -CommandName Get-WebSite -MockWith { return 'A Website' }
        }

        It 'Should return $true for WebConsole' -TestCases $casesWebConsole {
            Test-cScomInstallationStatus -ScomComponent $ScomComponent | Should -BeTrue
        }
    }

    Context 'When WebConsole role and website does not exist' {
        BeforeEach {
            Mock -CommandName Get-WebSite -MockWith { return $null }
        }

        It 'Should return $false for WebConsole' -TestCases $casesWebConsole {
            Test-cScomInstallationStatus -ScomComponent $ScomComponent | Should -BeFalse
        }
    }

    Context 'When Get-Package is NOT available and path exists' {
        BeforeEach {
            Mock -CommandName Get-Command -MockWith { return $null } -ParameterFilter { $Name -eq 'Get-Package' }
            Mock -CommandName Test-Path -MockWith { return $true }
        }

        It 'Should return $true for role <ScomComponent.Role>' -TestCases $casesGetPackage {
            Test-cScomInstallationStatus -ScomComponent $ScomComponent | Should -BeTrue
        }
    }

    Context 'When Get-Package is NOT available and path does not exist' {
        BeforeEach {
            Mock -CommandName Get-Command -MockWith { return $null } -ParameterFilter { $Name -eq 'Get-Package' }
            Mock -CommandName Test-Path -MockWith { return $false }
        }

        It 'Should return $false for role <ScomComponent.Role>' -TestCases $casesGetPackage {
            Test-cScomInstallationStatus -ScomComponent $ScomComponent | Should -BeFalse
        }
    }

    Context 'When AdditionalManagementServer role is used (known unhandled role)' {
        BeforeEach {
            Mock -CommandName Get-Command -MockWith { return 'A command' }
            Mock -CommandName Get-Package -MockWith { return 'A Package' }
        }

        It 'Should return $null for AdditionalManagementServer (known bug)' -TestCases $casesUnhandled {
            Test-cScomInstallationStatus -ScomComponent $ScomComponent | Should -BeNullOrEmpty
        }
    }
}
