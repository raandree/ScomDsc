<#
    .SYNOPSIS
        Unit test for Get-cScomParameter.

    .NOTES
        Get-cScomParameter builds a setup.exe command line string from role
        and parameter inputs. It contains pure logic with no external SCOM
        dependencies, making it fully unit-testable.
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    $casesInstallRoles = @(
        @{
            Role              = 'FirstManagementServer'
            ExpectedComponent = 'OMServer'
        }
        @{
            Role              = 'AdditionalManagementServer'
            ExpectedComponent = 'OMServer'
        }
        @{
            Role              = 'NativeConsole'
            ExpectedComponent = 'OMConsole'
        }
        @{
            Role              = 'WebConsole'
            ExpectedComponent = 'OMWebConsole'
        }
        @{
            Role              = 'ReportServer'
            ExpectedComponent = 'OMReporting'
        }
    )
}

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

Describe 'Get-cScomParameter' {
    Context 'When installing a role (no -Uninstall)' {
        It 'Should return a command line containing /install for <Role>' -TestCases $casesInstallRoles {
            $result = Get-cScomParameter -Role $Role
            $result | Should -Match '/install'
        }

        It 'Should return a command line with /components:<ExpectedComponent> for <Role>' -TestCases $casesInstallRoles {
            $result = Get-cScomParameter -Role $Role
            $result | Should -Match "/components:$ExpectedComponent"
        }

        It 'Should include /silent for <Role>' -TestCases $casesInstallRoles {
            $result = Get-cScomParameter -Role $Role
            $result | Should -Match '/silent'
        }

        It 'Should include AcceptEndUserLicenseAgreement for <Role>' -TestCases $casesInstallRoles {
            $result = Get-cScomParameter -Role $Role
            $result | Should -Match 'AcceptEndUserLicenseAgreement'
        }
    }

    Context 'When uninstalling a role (-Uninstall)' {
        It 'Should return /uninstall for <Role>' -TestCases $casesInstallRoles {
            $result = Get-cScomParameter -Role $Role -Uninstall
            $result | Should -Match '/uninstall'
        }

        It 'Should return /silent for <Role>' -TestCases $casesInstallRoles {
            $result = Get-cScomParameter -Role $Role -Uninstall
            $result | Should -Match '/silent'
        }

        It 'Should return /components:<ExpectedComponent> for <Role>' -TestCases $casesInstallRoles {
            $result = Get-cScomParameter -Role $Role -Uninstall
            $result | Should -Match "/components:$ExpectedComponent"
        }

        It 'Should not include parameter arguments for <Role>' -TestCases $casesInstallRoles {
            $result = Get-cScomParameter -Role $Role -Uninstall
            $result | Should -Not -Match 'AcceptEndUserLicenseAgreement'
        }
    }

    Context 'When providing custom parameter values for FirstManagementServer' {
        BeforeAll {
            $script:result = Get-cScomParameter -Role FirstManagementServer `
                -ManagementGroupName 'TestMG' `
                -SqlServerInstance 'SQL01' `
                -SqlInstancePort '1433' `
                -DatabaseName 'OM_DB' `
                -DwSqlServerInstance 'DWSQL01' `
                -DwSqlInstancePort '1434' `
                -DwDatabaseName 'OM_DW' `
                -InstallLocation 'D:\SCOM' `
                -ManagementServicePort '5723' `
                -ActionAccountUser 'DOMAIN\Action' `
                -ActionAccountPassword 'P@ssw0rd1' `
                -DASAccountUser 'DOMAIN\DAS' `
                -DASAccountPassword 'P@ssw0rd2' `
                -DataReaderUser 'DOMAIN\Reader' `
                -DataReaderPassword 'P@ssw0rd3' `
                -DataWriterUser 'DOMAIN\Writer' `
                -DataWriterPassword 'P@ssw0rd4'
        }

        It 'Should include the custom ManagementGroupName' {
            $script:result | Should -Match 'ManagementGroupName:"TestMG"'
        }

        It 'Should include the custom SqlServerInstance' {
            $script:result | Should -Match 'SqlServerInstance:"SQL01"'
        }

        It 'Should include the custom DwSqlServerInstance' {
            $script:result | Should -Match 'DwSqlServerInstance:"DWSQL01"'
        }

        It 'Should include the custom DatabaseName' {
            $script:result | Should -Match 'DatabaseName:"OM_DB"'
        }

        It 'Should include the custom DwDatabaseName' {
            $script:result | Should -Match 'DwDatabaseName:"OM_DW"'
        }

        It 'Should include the custom InstallLocation' {
            $script:result | Should -Match 'InstallLocation:"D:\\SCOM"'
        }

        It 'Should include the ActionAccountUser' {
            $script:result | Should -Match 'ActionAccountUser:"DOMAIN\\Action"'
        }

        It 'Should include the ActionAccountPassword' {
            $script:result | Should -Match 'ActionAccountPassword:"P@ssw0rd1"'
        }

        It 'Should include the DataReaderUser' {
            $script:result | Should -Match 'DataReaderUser:"DOMAIN\\Reader"'
        }

        It 'Should include the DataWriterUser' {
            $script:result | Should -Match 'DataWriterUser:"DOMAIN\\Writer"'
        }
    }

    Context 'When providing custom parameter values for WebConsole' {
        BeforeAll {
            $script:result = Get-cScomParameter -Role WebConsole `
                -ManagementServer 'MG01' `
                -WebSiteName 'MySite' `
                -WebConsoleAuthorizationMode 'Mixed'
        }

        It 'Should include the ManagementServer' {
            $script:result | Should -Match 'ManagementServer:"MG01"'
        }

        It 'Should include the WebSiteName' {
            $script:result | Should -Match 'WebSiteName:"MySite"'
        }

        It 'Should include the WebConsoleAuthorizationMode' {
            $script:result | Should -Match 'WebConsoleAuthorizationMode:"Mixed"'
        }
    }

    Context 'When providing custom parameter values for ReportServer' {
        BeforeAll {
            $script:result = Get-cScomParameter -Role ReportServer `
                -ManagementServer 'MG01' `
                -SRSInstance 'SQL01\SSRS' `
                -DataReaderUser 'DOMAIN\Reader' `
                -DataReaderPassword 'P@ssw0rd'
        }

        It 'Should include the ManagementServer' {
            $script:result | Should -Match 'ManagementServer:"MG01"'
        }

        It 'Should include the SRSInstance' {
            $script:result | Should -Match 'SRSInstance:"SQL01\\SSRS"'
        }

        It 'Should include the DataReaderUser' {
            $script:result | Should -Match 'DataReaderUser:"DOMAIN\\Reader"'
        }
    }

    Context 'When using default values for NativeConsole' {
        BeforeAll {
            $script:result = Get-cScomParameter -Role NativeConsole
        }

        It 'Should include the default InstallLocation' {
            $script:result | Should -Match 'InstallLocation:"C:\\Program Files\\Microsoft System Center\\Operations Manager"'
        }

        It 'Should include SendCEIPReports set to 0' {
            $script:result | Should -Match 'SendCEIPReports:"0"'
        }

        It 'Should include EnableErrorReporting set to Never' {
            $script:result | Should -Match 'EnableErrorReporting:"Never"'
        }
    }

    Context 'When return type is validated' {
        It 'Should return a string' {
            $result = Get-cScomParameter -Role NativeConsole
            $result | Should -BeOfType [string]
        }
    }
}
