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

### CHANGELOG.md Format

- All version entries MUST have dates: `## [1.0.0] - YYYY-MM-DD`
- Entries without dates cause ChangelogManagement parsing errors.

### GitVersion for Module Rename (Breaking Change)

- Set `next-version: 2.0.0` in GitVersion.yml for major version bump
- Use `regex: ^main$` under `master:` branch config when default branch is `main`

### Reference Project

- **ComputerManagementDsc** is the best reference for class-based DSC resource
  modules on Sampler — it uses DscResource.Base, has class-based resources 
  in `source/Classes/`, and is actively maintained.
