# ScomDsc - Project Brief

## Overview

ScomDsc (current module name: `cScom`) is a PowerShell DSC resource module for deploying and configuring System Center Operations Manager (SCOM). It provides class-based DSC resources as a modern alternative to the schema-based (MOF) xScom module.

## Repository Migration

- **From**: Codeberg (`codeberg.org/nyanhp/cScom`)
- **To**: GitHub (`github.com/dsccommunity/ScomDsc`)

## Core Requirements

- Migrate from legacy build system to Sampler framework
- Rename module from `cScom` to `ScomDsc` (matching dsccommunity naming conventions)
- Adopt dsccommunity standards for CI/CD, testing, and project structure
- Preserve module GUID: `b4632b7c-b7c6-4b99-ae83-f95199630ec0`
- Maintain backward compatibility for DSC resource names

## Module Capabilities

- 12 class-based DSC resources for SCOM management
- 3 exported functions (helper utilities)
- 6 enums/classes for type definitions
- Runtime dependencies: `AutomatedLab.Common`, `DscResource.Base`

## Stakeholders

- Author: Jan-Hendrik Peters
- Organization: DSC Community
- License: MIT
