param location string = deployment().location

param acaRG string
param acaTags string

param containerRegistrySubscriptionId string
param containerRegistryRG string
param containerRegistryTags string

param logAnalyticsSubscriptionId string
param logAnalyticsRG string
param logAnalyticsTags string

param pgsqlSubscriptionId string
param pgsqlRG string
param pgsqlTags string

var acaTagsArray = json(acaTags)
var containerRegistryTagsArray = json(containerRegistryTags)
var logAnalyticsTagsArray = json(logAnalyticsTags)
var pgsqlTagsArray = json(pgsqlTags)

targetScope = 'subscription'

module logAnalyticsResourceGroup 'components/rg.bicep' = {
  name: 'log-analytics-rg'
  scope: subscription(logAnalyticsSubscriptionId)
  params: {
    name: logAnalyticsRG
    location: location
    tagsArray: logAnalyticsTagsArray
  }
}

module pgsqlResourceGroup 'components/rg.bicep' = {
  name: 'pgsql-rg'
  scope: subscription(pgsqlSubscriptionId)
  params: {
    name: pgsqlRG
    location: location
    tagsArray: pgsqlTagsArray
  }
}

module containerRegistryResourceGroup 'components/rg.bicep' = {
  name: 'container-registry-rg'
  scope: subscription(containerRegistrySubscriptionId)
  params: {
    name: containerRegistryRG
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
