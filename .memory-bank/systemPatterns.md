# ScomDsc - System Patterns

## Architecture

### DSC Resource Pattern (Class-Based)
All 12 DSC resources use class-based DSC with `[DscResource()]` attribute.
Resources implement `Get()`, `Set()`, `Test()` methods directly.
The `ScomReason` class provides Azure Machine Configuration compliance support.

### File Naming Convention (Current)
- Classes/Enums: `JHP_Scom<Name>.ps1` (prefix `JHP_` for namespace collision avoidance)
- Resources: `JHP_Scom<Name>.ps1`
- Functions: `<Verb>-cScom<Noun>.ps1`

### Dependency Pattern
Resources depend on `OperationsManager` PowerShell module (SCOM SDK).
`Resolve-cScomModule` locates and imports it at runtime.
`DscResource.Base` provides the base class infrastructure.

### Module Loading
The `.psm1` dot-sources files in order:
1. `internal/functions/` (currently empty)
2. `classes/` (enums first, then classes)
3. `functions/` (public functions)
4. `resources/` (DSC resources)
5. `internal/scripts/` (currently empty)

## Key Design Decisions

- Class-based DSC over MOF-based (modern approach, simpler development)
- `Reasons` property on resources for Azure Policy compliance
- `IsSingleInstance` pattern for singleton settings resources
- Runtime dependency on `OperationsManager` module (not a build dependency)
