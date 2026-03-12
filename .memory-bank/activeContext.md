# ScomDsc - Active Context

## Current Status

Migration to Sampler COMPLETED. Unit tests all passing (117 tests, 0 failures).
Build pipeline: `build,test` succeeds end-to-end.

## Recent Changes (2026-03-12)

- Fixed `Get-cScomParameter` — custom values were ignored (defaults always used)
- Fixed `Resolve-cScomModule` — null guard for `Get-ChildItem` returning nothing
- Fixed `Test-cScomInstallationStatus` — `[hashtable]` param type blocked `[ScomComponent]` input
- Added `ScomComponent.Tests.ps1` — full unit tests for DSC resource class (36 tests)
- Added `Get-cScomParameter.Tests.ps1` — full unit tests (60 tests)
- Updated `Resolve-cScomModule.Tests.ps1` — PSModulePath setup for build context
- All 4 test files pass: 117 tests total

## Key Testing Pattern for Class-Based DSC

- Use `using module ScomDsc` at file top for class type access
- Do NOT also call `Import-Module -Force` (creates dual session state, breaks mocks)
- `Should -Invoke` may not track calls made through class methods; verify behavior instead
- Always run tests via `Start-Process` (detached), never directly in VS Code terminal

## Next Steps

- Run HQRM tests (`./build.ps1 -Tasks hqrmtest`)
- Set up Azure DevOps pipeline
- First release to PSGallery
