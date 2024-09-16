using 'main.bicep'

param location = 'eastus'

param aksName = 'aks-development'
param aksAdminGroupObjectId = '00000000-0000-0000-0000-000000000000'
param aksTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "true", "ArchitectureType": "AKS" }'

param pgsqlName = 'martinabrle'
param pgsqlAADAdminGroupName = 'PGSQL-Admins'
param pgsqlAADAdminGroupObjectId = '00000000-0000-0000-0000-000000000000'
param pgsqlTodoAppDbName = 'tododb'
param todoAppDbUserName = 'todo_app'
param pgsqlPetClinicDbName = 'petclinicdb'
param petClinicCustsSvcDbUserName = 'pet_clinic_custs_svc'
param petClinicVetsSvcDbUserName = 'pet_clinic_vets_svc'
param petClinicVisitsSvcDbUserName = 'pet_clinic_visits_svc'

param pgsqlSubscriptionId = '00000000-0000-0000-0000-000000000000'
param pgsqlRG = 'pgsql_rg'
param pgsqlTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "false", "ArchitectureType": "PGSQL" }'

param petClinicGitConfigRepoUri = 'https://github.com/********/aks-java-demo-config'
param petClinicGitConfigRepoUserName = '********'
param petClinicGitConfigRepoPassword = 'PAT_********'

param logAnalyticsName = 'YOUR_LOG_ANALYTICS_WORKSPACE_NAME'
param logAnalyticsSubscriptionId = '00000000-0000-0000-0000-000000000000'
param logAnalyticsRG = 'log_analytics_rg'
param logAnalyticsTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "false", "ArchitectureType": "LOGS" }'

param containerRegistryName = 'CONTAINER_REGISTRY_NAME'
param containerRegistrySubscriptionId = '00000000-0000-0000-0000-000000000000'
param containerRegistryRG = 'container_registry_rg'
param containerRegistryTags = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST", "DeleteNightly": "false", "ArchitectureType": "CONTAINER_REGISTRY" }'

