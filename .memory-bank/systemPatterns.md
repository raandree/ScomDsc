# ScomDsc - System Patterns

## Architecture

### DSC Resource Pattern (Class-Based)
All 12 DSC resources use class-based DSC with `[DscResource()]` attribute.
Resources implement `Get()`, `Set()`, `Test()` methods directly.
The `ScomReason` class provides Azure Machine Configuration compliance support.

### File Naming Convention (Sampler)
- Classes/Enums: `source/Classes/NNN.ScomName.ps1` (numeric prefix for load order)
  - `001-009` — Enums
  - `010-019` — Support classes (ScomReason)
  - `020+` — DSC resource classes
- Functions: `source/Public/<Verb>-cScom<Noun>.ps1`

### Dependency Pattern
Resources depend on `OperationsManager` PowerShell module (SCOM SDK).
`Resolve-cScomModule` locates it via `Get-Module -ListAvailable`, then disk search, then imports.
`DscResource.Base` provides the base class infrastructure (loaded via `using module` in prefix.ps1).

### Module Loading (Sampler/ModuleBuilder)
ModuleBuilder compiles all source files into a single `ScomDsc.psm1`:
1. `prefix.ps1` — `using module DscResource.Base` + DscResource.Common import
2. `Classes/*.ps1` — in numeric order (enums → classes → resources)
3. `Public/*.ps1` — exported functions

### Get-cScomParameter Pattern
Builds setup.exe command-line strings from role-specific parameter defaults.
Bound parameters override defaults; unbound parameters use role defaults.
Each role has a predefined parameter hashtable with sensible defaults.

## Key Design Decisions

- Class-based DSC over MOF-based (modern approach, simpler development)
- `Reasons` property on resources for Azure Policy compliance
- `IsSingleInstance` pattern for singleton settings resources
- Runtime dependency on `OperationsManager` module (not a build dependency)
- `Test-cScomInstallationStatus` accepts untyped `$ScomComponent` to work with both hashtable and class instances

## Testing Patterns for Class-Based DSC

- `using module ScomDsc` at file top loads class types (not `Import-Module`)
- Do NOT also `Import-Module -Force` — causes dual session state, breaks mocks
- `Should -Invoke` unreliable for calls through class methods; verify behavior instead
- Run tests only via detached `Start-Process`, never directly in VS Code terminal
