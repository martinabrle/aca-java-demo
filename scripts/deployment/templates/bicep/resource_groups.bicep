param location string = deployment().location

param acaRG string

// Rest of the parameteres are optional but recommended; typically, you would want to keep the application's state (DB, logs, container images, etc.)
// in a different resource group than the ACA resource group. This is to ensure that the ACA resource group can be deleted without affecting the
// application's state.

param acaTags string = '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST" }'

param containerRegistrySubscriptionId string = subscription().subscriptionId
param containerRegistryRG string = acaRG
param containerRegistryTags string = acaTags

param logAnalyticsSubscriptionId string = subscription().subscriptionId
param logAnalyticsRG string = acaRG
param logAnalyticsTags string = acaTags

param pgsqlSubscriptionId string = subscription().subscriptionId
param pgsqlRG string = acaRG
param pgsqlTags string = acaTags

var acaTagsVar = empty(acaTags) ? '{ "CostCentre": "DEV", "Department": "RESEARCH", "WorkloadType": "TEST" }' : acaTags
var logAnalyticsSubscriptionIdVar = empty(logAnalyticsSubscriptionId) ? subscription().subscriptionId : logAnalyticsSubscriptionId
var containerRegistrySubscriptionIdVar = empty(containerRegistrySubscriptionId) ? subscription().subscriptionId : containerRegistrySubscriptionId
var pgsqlSubscriptionIdVar = empty(pgsqlSubscriptionId) ? subscription().subscriptionId : pgsqlSubscriptionId

var containerRegistryRGVar = empty(containerRegistryRG) ? acaRG : containerRegistryRG
var logAnalyticsRGVar = empty(logAnalyticsRG) ? acaRG : logAnalyticsRG
var pgsqlRGVar = empty(pgsqlRG) ? acaRG : pgsqlRG

var acaTagsArray = json(acaTagsVar)
var containerRegistryTagsArray = json(empty(containerRegistryTags) ? acaTagsVar : containerRegistryTags)
var logAnalyticsTagsArray = json(empty(logAnalyticsTags) ? acaTagsVar : logAnalyticsTags)
var pgsqlTagsArray = json(pgsqlTags)


targetScope = 'subscription'

module logAnalyticsResourceGroup 'components/rg.bicep' = if (!empty(logAnalyticsRG)) {
  name: 'log-analytics-rg'
  scope: subscription(logAnalyticsSubscriptionIdVar)
  params: {
    name: logAnalyticsRGVar
    location: location
    tagsArray: logAnalyticsTagsArray
  }
}

module pgsqlResourceGroup 'components/rg.bicep' = {
  name: 'pgsql-rg'
  scope: subscription(pgsqlSubscriptionIdVar)
  params: {
    name: pgsqlRGVar
    location: location
    tagsArray: pgsqlTagsArray
  }
}

module containerRegistryResourceGroup 'components/rg.bicep' = {
  name: 'container-registry-rg'
  scope: subscription(containerRegistrySubscriptionIdVar)
  params: {
    name: containerRegistryRGVar
    location: location
    tagsArray: containerRegistryTagsArray
  }
}

module acaResourceGroup 'components/rg.bicep' = {
  name: 'aca-rg'
  params: {
    name: acaRG
    location: location
    tagsArray: acaTagsArray
  }
}
