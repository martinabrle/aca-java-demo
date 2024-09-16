using 'resource_groups.bicep'

param location = 'eastus'

param aksRG = 'aks_development_rg'
param aksTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "true", "ArchitectureType": "AKS" }'

param containerRegistryRG = 'container_registry_rg'
param containerRegistryTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "false", "ArchitectureType": "CONTAINER_REGISTRY" }'
param containerRegistrySubscriptionId = '00000000-0000-0000-0000-000000000000'

param logAnalyticsSubscriptionId = '00000000-0000-0000-0000-000000000000'
param logAnalyticsRG = 'log_analytics_rg'
param logAnalyticsTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "false", "ArchitectureType": "LOGS" }'

param pgsqlSubscriptionId = '00000000-0000-0000-0000-000000000000'
param pgsqlRG = 'pgsql_rg'
param pgsqlTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "false", "ArchitectureType": "PGSQL" }'
