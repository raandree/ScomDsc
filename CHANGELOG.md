# Change log for ScomDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- BREAKING CHANGE: Renamed module from `cScom` to `ScomDsc` to align with
  DSC Community naming conventions.
- Migrated build system from legacy VSTS scripts to Sampler framework.
- Moved source code from `cScom/` to `source/` directory per Sampler conventions.
- Updated project URLs from Codeberg to GitHub (dsccommunity/ScomDsc).
- Added Azure Pipelines CI/CD configuration.
- Added GitVersion for semantic versioning.
- Added DscResource.Test for HQRM testing.
- Added DscResource.DocGenerator for documentation generation.
- Added codecov.yml for code coverage tracking.

## [1.2.0] - 2025-01-01

### Fixed

- ScomComponent: Fix Setup.exe hang on UNC paths in non-interactive sessions
  (Windows Server 2025).

## [1.0.5] - 2022-01-01

### Changed

- Compatibility with other resources by prefixing classes.
