# Sampler Migration - Skill Update Notes

## Learnings from ScomDsc Migration (2026-03-12)

### DSC Community Class-Based Resource Specifics

1. **Class-based DSC resources go in `source/Classes/`** with numeric prefixes:
   - `001-009` — Enums (ScomEnsure, ScomRole, etc.)
   - `010-019` — Base/support classes (ScomReason, etc.)  
   - `020+` — DSC resource classes ([DscResource()] decorated)
   
2. **`prefix.ps1`** for class-based DSC modules needs:
   ```powershell
   using module .\Modules\DscResource.Base
   ```
   This ensures DscResource.Base is loaded before class definitions.

3. **NestedModule in build.yaml** — DscResource.Base and DscResource.Common 
   need `CopyOnly: true` entries so they're bundled with the built module.

4. **`build.yaml` DscTest section** — must `ExcludeModuleFile` the built
   `.psm1` for class-based resources (tested differently from MOF-based).

5. **DscResource.DocGenerator** — use `ClassResourceMetadata` instead of 
   `MofResourceMetadata` in `Generate_Markdown_For_DSC_Resources`.

### Build Log Location

- Never put build logs in `output/` — the Clean task deletes `output/*` 
  and will fail with file-in-use error.
- Use project root or temp directory instead (e.g., `build-test.log`).

### CHANGELOG.md Format

- All version entries MUST have dates: `## [1.0.0] - YYYY-MM-DD`
- Entries without dates cause ChangelogManagement parsing errors.

### GitVersion for Module Rename (Breaking Change)

- Set `next-version: 2.0.0` in GitVersion.yml for major version bump
- Use `regex: ^main$` under `master:` branch config when default branch is `main`

### Testing Class-Based DSC Resources with Pester 5

- **Use `using module ScomDsc`** at file top to make class types accessible.
  `Import-Module` alone does NOT export class types.
- **Do NOT also call `Import-Module -Force`** — this creates a second module
  session state. Mocks target the second state, but class methods run in the
  first, causing mocks to silently not apply.
- **`Should -Invoke` is unreliable for calls through class methods** — when
  a class's `Get()` method calls a mocked function, Pester may not track it.
  Verify behavior (return values, side effects) instead of invocation counts.
- **Public functions called from class methods** (e.g., `Test-cScomInstallationStatus`)
  need untyped or flexible parameters — the class passes `$this` (a class
  instance), not a hashtable.
- **PSModulePath setup in test BeforeAll** — when running outside Sampler's
  build pipeline, tests need to add `output/RequiredModules` and 
  `output/builtModule` to `$env:PSModulePath` manually.

### Get-cScomParameter Bug Pattern

- Functions with role-specific default hashtables must check `$PSBoundParameters`
  FIRST, then fall back to defaults. The anti-pattern is checking 
  `IsNullOrWhiteSpace($default)` first — this ignores bound params when
  a non-empty default exists.

### Reference Project

- **ComputerManagementDsc** is the best reference for class-based DSC resource
  modules on Sampler — it uses DscResource.Base, has class-based resources 
  in `source/Classes/`, and is actively maintained.
