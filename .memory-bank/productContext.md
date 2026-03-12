# ScomDsc - Product Context

## Purpose

ScomDsc provides Infrastructure-as-Code capabilities for System Center Operations Manager (SCOM) deployments. It allows administrators to declaratively configure SCOM components, management packs, discovery settings, and operational parameters using PowerShell Desired State Configuration (DSC).

## Problems Solved

1. **Manual SCOM Configuration**: Eliminates manual, error-prone SCOM setup by providing repeatable DSC configurations
2. **Configuration Drift**: Continuously enforces desired SCOM state
3. **Complex Deployments**: Simplifies multi-role SCOM deployments (Management Server, Web Console, Report Server, Console)
4. **Operational Settings**: Manages heartbeat, alert resolution, database grooming, error reporting, and maintenance schedules

## Target Users

- System Administrators managing SCOM environments
- DevOps engineers automating infrastructure
- DSC configuration data management (e.g., with Datum)

## UX Goals

- Simple, declarative DSC resource syntax
- Predictable behavior with `Reasons` property for Azure Machine Configuration compliance
- Support for both interactive and non-interactive (CI/CD) scenarios
