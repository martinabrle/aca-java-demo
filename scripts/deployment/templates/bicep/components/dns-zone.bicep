@description('The name of the DNS zone to be created.  Must have at least 2 segments, e.g. hostname.org')
param zoneName string

@description('The name of an existing parent DNS zone.')
param parentZoneName string

@description('The name of an existing parent DNS zone\'s resource group.')
param parentZoneRG string = ''

@description('Subscription id of an existing parent DNS zone.')
param parentZoneSubscriptionId string = ''

param parentZoneTagsArray object

param tagsArray object

module parentDnsZoneModule './dns-zone-parent.bicep' = {
  name: 'dns-zone-parent'
  scope: resourceGroup(parentZoneSubscriptionId, parentZoneRG)
  params: {
    zoneName: parentZoneName
    tagsArray: parentZoneTagsArray
  }
}

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: '${zoneName}.${parentZoneName}'
  location: 'global'
  dependsOn: [
    parentDnsZoneModule
  ]
  tags: tagsArray
  properties: {
    zoneType: 'Public'
  }
}

module dnsZoneParentRecordNS './dns-zone-parent-ns-record.bicep' = {
  name: 'dns-zone-parent-record'
  scope: resourceGroup(parentZoneSubscriptionId, parentZoneRG)
  params: {
    nameServers: dnsZone.properties.nameServers
    parentZoneName: parentZoneName
    zoneName: zoneName
  }
}
