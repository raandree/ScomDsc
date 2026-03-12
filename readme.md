# ScomDsc

[![Build Status](https://dev.azure.com/dsccommunity/ScomDsc/_apis/build/status/dsccommunity.ScomDsc?branchName=main)](https://dev.azure.com/dsccommunity/ScomDsc/_build/latest?definitionId=TBD&branchName=main)
![PowerShell Gallery](https://img.shields.io/powershellgallery/v/ScomDsc?label=ScomDsc)
[![codecov](https://codecov.io/gh/dsccommunity/ScomDsc/branch/main/graph/badge.svg)](https://codecov.io/gh/dsccommunity/ScomDsc)

Class-based DSC resources to manage SCOM components as well as install SCOM.
Looking for a schema-based (MOF) resource instead? Go to [xScom](https://github.com/dsccommunity/xscom).

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).

## Releases

For each merge to the branch `main` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out the DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing/).
This project uses the [Sampler](https://github.com/gaelcolas/Sampler) module
for build automation.

## Change Log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Documentation and Examples

For a full list of resources in ScomDsc and examples on their use,
check out the [ScomDsc wiki](https://github.com/dsccommunity/ScomDsc/wiki).

## Requirements

### Windows Management Framework 5.1

Required because this module implements class-based DSC resources.

### Required Modules

- `AutomatedLab.Common`
- `DscResource.Base`

## Resources

### ScomAgentApprovalSetting

Configure the Agent Approval Setting for the management group. Select between AutoApprove, AutoReject and Pending.

### ScomAlertResolutionSetting

Configure the alert resolution setting.

### ScomComponent

This resource is used for the installation or removal of all SCOM components.

### ScomDatabaseGroomingSetting

Configure settings for database cleanup.

### ScomDataWarehouseSetting

Data Warehouse configuration for a management server instance.

### ScomDiscovery

Configure discovery of an unsealed management pack.

### ScomErrorReportingSetting

Error Reporting configuration.

### ScomHeartbeatSetting

Agent heartbeat setting.

### ScomMaintenanceSchedule

Configure a maintenance schedule for one or more objects.

### ScomManagementPack

Import management packs either from file or from a string.

### ScomReportingSetting

Reporting Services configuration.

### ScomWebAddressSetting

Web Console setting.
