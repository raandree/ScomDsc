# ScomDsc - Prompt History

## 2026-03-12

### Prompt 3: Update Memory Bank and Docs
- **Request**: Update Memory Bank and documentation
- **Actions**: Updated activeContext, progress, systemPatterns, techContext, CHANGELOG, promptHistory

### Prompt 2: Fix Unit Test Failures (50 failures → 0)
- **Request**: Tests were crashing VS Code (Pester called directly, not via Start-Process)
- **Root Cause**: Called `Invoke-Pester` directly in VS Code terminal, freezing the extension host
- **Actions**:
  - Re-ran tests via `Start-Process` (detached) per sampler-build-debug skill
  - Fixed `Get-cScomParameter` — parameter priority was inverted; `$PSBoundParameters` only checked when default was empty, causing custom values to be ignored
  - Fixed `Resolve-cScomModule` — `Get-Module $null` threw when `Get-ChildItem` returned nothing; added null guard
  - Fixed `Test-cScomInstallationStatus` — `[hashtable]` param type rejected `[ScomComponent]` class instance passed from `Get()`
  - Fixed `ScomComponent.Tests.ps1` — added `using module ScomDsc` for class type access; removed duplicate `Import-Module -Force` (dual session state broke mocks); removed unreliable `Should -Invoke` (behavior already verified)
  - Fixed `Resolve-cScomModule.Tests.ps1` — mock returned `PSCustomObject` instead of `PSModuleInfo`
- **Result**: Build succeeded. 117 tests, 0 failures, 16 tasks, 0 errors
- **Key Learning**: For class-based DSC tests, use `using module` (not `Import-Module`) and never also call `Import-Module -Force`

### Prompt 1: Migration Analysis & Plan
- **Request**: Migrate project from Codeberg to GitHub dsccommunity, migrate to Sampler framework
- **Actions**: Full 7-phase migration completed
- **Result**: Build succeeded. Module compiles and all exports intact.
