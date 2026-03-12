# ScomDsc - Tech Context

## Current State (Pre-Migration)

### Module Structure
- **Module name**: `cScom` (in `cScom/` directory)
- **Module GUID**: `b4632b7c-b7c6-4b99-ae83-f95199630ec0`
- **Current version**: 1.2.0
- **PowerShell version**: 5.1
- **Root module**: `cScom.psm1` (dot-sources all .ps1 files at runtime)

### Source Layout
```
cScom/
  cScom.psd1              # Module manifest
  cScom.psm1              # Dot-source loader
  classes/                # 6 files: enums (ScomRole, ScomEnsure, ScomApprovalType,
                          #   ScomMaintenanceModeReason, ScomReportSetting) + ScomReason class
  functions/              # 3 public functions: Get-cScomParameter, Resolve-cScomModule,
                          #   Test-cScomInstallationStatus
  resources/              # 12 DSC resources (class-based, [DscResource()] attribute)
  internal/functions/     # Empty (placeholder)
  internal/scripts/       # Empty (placeholder)
  Examples/               # 1 example configuration
```

### DSC Resources (all class-based)
ScomComponent, ScomManagementPack, ScomDiscovery, ScomMaintenanceSchedule,
ScomAgentApprovalSetting, ScomAlertResolutionSetting, ScomDatabaseGroomingSetting,
ScomDataWarehouseSetting, ScomErrorReportingSetting, ScomHeartbeatSetting,
ScomReportingSetting, ScomWebAddressSetting

### Runtime Dependencies
- `AutomatedLab.Common`
- `DscResource.Base`

### Build System (Legacy)
- `build/vsts-prerequisites.ps1` — installs Pester, PSScriptAnalyzer, and module deps
- `build/vsts-build.ps1` — builds the module by concatenating .ps1 into .psm1, publishes to PSGallery
- `build/vsts-validate.ps1` — calls `tests/pester.ps1`
- No `build.ps1`, no `build.yaml`, no `RequiredModules.psd1`
- Version management: manual in manifest + auto-increment from PSGallery in vsts-build

### Test Framework
- **Pester 5** (uses `[PesterConfiguration]::Default`)
- `tests/pester.ps1` — custom test runner (not Sampler)
- `tests/general/` — manifest, help, file integrity, PSScriptAnalyzer tests
- `tests/functions/` — 1 unit test file (Test-cScomInstallationStatus.tests.ps1)
- `tests/helpers/WebAdministrationStub.psm1` — stub module for tests

### CI/CD
- Azure DevOps (VSTS) oriented scripts, but NO azure-pipelines.yml
- No GitVersion, no CHANGELOG.md
- .gitignore: `publish`, `TestResults`
- No .gitattributes

### Project URLs (legacy, needs update)
- LicenseUri: `https://codeberg.org/nyanhp/cScom/raw/branch/main/LICENSE`
- ProjectUri: `https://codeberg.org/nyanhp/cScom`

## Target State (Post-Migration)

### Reference Project
ComputerManagementDsc (dsccommunity) — actively maintained, class-based DSC resources, full Sampler stack.

### Tech Stack
- Sampler build framework
- ModuleBuilder for module compilation
- InvokeBuild as task runner
- GitVersion for semantic versioning
- Pester 5 (Sampler-integrated)
- Azure Pipelines CI/CD
- DscResource.Test for HQRM tests
- DscResource.DocGenerator for documentation
- Codecov.io for coverage reporting
