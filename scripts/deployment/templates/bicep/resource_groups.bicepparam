using 'resource_groups.bicep'

param location = 'eastus'

param acaRG = 'aca_development_rg'
param acaTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "true", "ArchitectureType": "ACA" }'

param containerRegistryRG = 'container_registry_rg'
param containerRegistryTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "false", "ArchitectureType": "CONTAINER_REGISTRY" }'
param containerRegistrySubscriptionId = '00000000-0000-0000-0000-000000000000'

param logAnalyticsSubscriptionId = '00000000-0000-0000-0000-000000000000'
param logAnalyticsRG = 'log_analytics_rg'
param logAnalyticsTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "false", "ArchitectureType": "LOGS" }'

param pgsqlSubscriptionId = '00000000-0000-0000-0000-000000000000'
param pgsqlRG = 'pgsql_rg'
param pgsqlTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "false", "ArchitectureType": "PGSQL" }'
