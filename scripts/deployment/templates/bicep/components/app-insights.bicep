param name string
param logAnalyticsStringId string
param location string
param tagsArray object

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tagsArray
  kind: 'java'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsStringId
  }
}

output appInsightsName string = appInsights.name
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

