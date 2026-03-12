<#
    .SYNOPSIS
        Unit test for the ScomComponent DSC resource class.

    .NOTES
        Class-based DSC resources call functions internally. Pester can mock
        functions that the class calls, provided those functions are resolved
        dynamically (i.e. public module functions, not .NET methods).

        ScomComponent.Get() calls Test-cScomInstallationStatus (a public function)
        and ScomComponent.Set() calls Get-cScomParameter (a public function)
        plus Get-ChildItem and Process.Start. We can test the logic by mocking
        these functions.

        ScomComponent.Test() delegates entirely to Get(), so it is tested
        indirectly through the Get() tests and directly via simple scenarios.
#>

using module ScomDsc

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    $allRoles = @(
        @{ Role = 'FirstManagementServer' }
        @{ Role = 'AdditionalManagementServer' }
        @{ Role = 'ReportServer' }
        @{ Role = 'WebConsole' }
        @{ Role = 'NativeConsole' }
    )
}

BeforeAll {
    $script:dscModuleName = 'ScomDsc'

    # using module ScomDsc (at file top) already loaded the module and its types.
    # Calling Import-Module -Force again would create a second module session
    # state, causing Pester mocks to target the wrong scope.

    $PSDefaultParameterValues['Mock:ModuleName'] = $script:dscModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:dscModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Get-Module -Name $script:dscModuleName | Remove-Module -Force
}

Describe 'ScomComponent' {
    Context 'When constructing a new instance with defaults' {
        BeforeAll {
            $script:instance = [ScomComponent]::new()
        }

        It 'Should set IsSingleInstance to yes' {
            $script:instance.IsSingleInstance | Should -Be 'yes'
        }

        It 'Should set default InstallLocation' {
            $script:instance.InstallLocation | Should -Be 'C:\Program Files\Microsoft System Center\Operations Manager'
        }

        It 'Should set Ensure to Present' {
            $script:instance.Ensure | Should -Be 'Present'
        }

        It 'Should set DatabaseName to OperationsManager' {
            $script:instance.DatabaseName | Should -Be 'OperationsManager'
        }

        It 'Should set DwDatabaseName to OperationsManagerDW' {
            $script:instance.DwDatabaseName | Should -Be 'OperationsManagerDW'
        }

        It 'Should set WebSiteName to Default Web Site' {
            $script:instance.WebSiteName | Should -Be 'Default Web Site'
        }

        It 'Should set WebConsoleAuthorizationMode to Mixed' {
            $script:instance.WebConsoleAuthorizationMode | Should -Be 'Mixed'
        }

        It 'Should set WebConsoleUseSSL to false' {
            $script:instance.WebConsoleUseSSL | Should -BeFalse
        }

        It 'Should set UseMicrosoftUpdate to true' {
            $script:instance.UseMicrosoftUpdate | Should -BeTrue
        }

        It 'Should set SqlInstancePort to 1433' {
            $script:instance.SqlInstancePort | Should -Be 1433
        }

        It 'Should set DwSqlInstancePort to 1433' {
            $script:instance.DwSqlInstancePort | Should -Be 1433
        }

        It 'Should set ManagementServicePort to 5723' {
            $script:instance.ManagementServicePort | Should -Be 5723
        }
    }

    Context 'When calling GetConfigurableDscProperties' {
        BeforeAll {
            $script:instance = [ScomComponent]::new()
            $script:instance.Role = 'NativeConsole'
            $script:instance.SourcePath = 'C:\Sources'
            $script:props = $script:instance.GetConfigurableDscProperties()
        }

        It 'Should return a hashtable' {
            $script:props | Should -BeOfType [hashtable]
        }

        It 'Should include the Role property' {
            $script:props.ContainsKey('Role') | Should -BeTrue
        }

        It 'Should include the SourcePath property' {
            $script:props.ContainsKey('SourcePath') | Should -BeTrue
        }

        It 'Should not include the Reasons property (NotConfigurable)' {
            $script:props.ContainsKey('Reasons') | Should -BeFalse
        }
    }

    Context 'When component is installed and Ensure is Present' {
        BeforeAll {
            Mock -CommandName Test-cScomInstallationStatus -MockWith { $true }

            $script:instance = [ScomComponent]::new()
            $script:instance.Role = 'NativeConsole'
            $script:instance.SourcePath = 'C:\Sources'
            $script:getResult = $script:instance.Get()
        }

        It 'Should return no Reasons' {
            $script:getResult.Reasons | Should -BeNullOrEmpty
        }

        It 'Should return the correct Role' {
            $script:getResult.Role | Should -Be 'NativeConsole'
        }
    }

    Context 'When component is NOT installed and Ensure is Present' {
        BeforeAll {
            Mock -CommandName Test-cScomInstallationStatus -MockWith { $false }

            $script:instance = [ScomComponent]::new()
            $script:instance.Role = 'FirstManagementServer'
            $script:instance.SourcePath = 'C:\Sources'
            $script:getResult = $script:instance.Get()
        }

        It 'Should return Reasons indicating component is not installed' {
            $script:getResult.Reasons | Should -Not -BeNullOrEmpty
        }

        It 'Should have a reason code containing ProductNotInstalled' {
            $script:getResult.Reasons[0].Code | Should -Match 'ProductNotInstalled'
        }

        It 'Should have a reason phrase indicating the component should be installed' {
            $script:getResult.Reasons[0].Phrase | Should -Match 'not installed'
        }
    }

    Context 'When component is installed and Ensure is Absent' {
        BeforeAll {
            Mock -CommandName Test-cScomInstallationStatus -MockWith { $true }

            $script:instance = [ScomComponent]::new()
            $script:instance.Role = 'NativeConsole'
            $script:instance.SourcePath = 'C:\Sources'
            $script:instance.Ensure = 'Absent'
            $script:getResult = $script:instance.Get()
        }

        It 'Should return Reasons indicating component is installed but should not be' {
            $script:getResult.Reasons | Should -Not -BeNullOrEmpty
        }

        It 'Should have a reason code containing ProductInstalled' {
            $script:getResult.Reasons[0].Code | Should -Match 'ProductInstalled'
        }
    }

    Context 'When component is NOT installed and Ensure is Absent' {
        BeforeAll {
            Mock -CommandName Test-cScomInstallationStatus -MockWith { $false }

            $script:instance = [ScomComponent]::new()
            $script:instance.Role = 'NativeConsole'
            $script:instance.SourcePath = 'C:\Sources'
            $script:instance.Ensure = 'Absent'
            $script:getResult = $script:instance.Get()
        }

        It 'Should return no Reasons (desired state: absent and not installed)' {
            $script:getResult.Reasons | Should -BeNullOrEmpty
        }
    }

    Context 'When Test() is called and component is in desired state' {
        BeforeAll {
            Mock -CommandName Test-cScomInstallationStatus -MockWith { $true }

            $script:instance = [ScomComponent]::new()
            $script:instance.Role = 'NativeConsole'
            $script:instance.SourcePath = 'C:\Sources'
        }

        It 'Should return $true' {
            $script:instance.Test() | Should -BeTrue
        }
    }

    Context 'When Test() is called and component is NOT in desired state' {
        BeforeAll {
            Mock -CommandName Test-cScomInstallationStatus -MockWith { $false }

            $script:instance = [ScomComponent]::new()
            $script:instance.Role = 'NativeConsole'
            $script:instance.SourcePath = 'C:\Sources'
        }

        It 'Should return $false' {
            $script:instance.Test() | Should -BeFalse
        }
    }

    Context 'When Set() is called and setup.exe is missing' {
        BeforeAll {
            Mock -CommandName Get-cScomParameter -MockWith { '/install /silent /components:OMConsole' }
            Mock -CommandName Get-ChildItem -MockWith { $null }
            Mock -CommandName Write-Error
        }

        It 'Should write an error about missing setup.exe' {
            $instance = [ScomComponent]::new()
            $instance.Role = 'NativeConsole'
            $instance.SourcePath = 'C:\Sources'
            $instance.Set()
            Should -Invoke -CommandName Write-Error -Times 1 -ParameterFilter {
                $Message -like '*setup.exe*'
            }
        }
    }

    Context 'When Get() returns correct property values' {
        BeforeAll {
            Mock -CommandName Test-cScomInstallationStatus -MockWith { $true }

            $script:instance = [ScomComponent]::new()
            $script:instance.Role = 'WebConsole'
            $script:instance.SourcePath = 'C:\Sources'
            $script:instance.ManagementServer = 'MG01'
            $script:instance.WebSiteName = 'SCOM Site'
            $script:instance.WebConsoleAuthorizationMode = 'Mixed'
            $script:instance.WebConsoleUseSSL = $true
            $script:getResult = $script:instance.Get()
        }

        It 'Should return the configured ManagementServer' {
            $script:getResult.ManagementServer | Should -Be 'MG01'
        }

        It 'Should return the configured WebSiteName' {
            $script:getResult.WebSiteName | Should -Be 'SCOM Site'
        }

        It 'Should return the configured WebConsoleAuthorizationMode' {
            $script:getResult.WebConsoleAuthorizationMode | Should -Be 'Mixed'
        }

        It 'Should return the configured WebConsoleUseSSL' {
            $script:getResult.WebConsoleUseSSL | Should -BeTrue
        }
    }

    Context 'When Get() is called for each role' {
        BeforeEach {
            Mock -CommandName Test-cScomInstallationStatus -MockWith { $true }
        }

        It 'Should not throw for role <Role>' -TestCases $allRoles {
            $instance = [ScomComponent]::new()
            $instance.Role = $Role
            $instance.SourcePath = 'C:\Sources'
            { $instance.Get() } | Should -Not -Throw
        }
    }
}
