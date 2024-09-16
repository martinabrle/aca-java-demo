@description('The name of an existing parent DNS zone.')
param parentZoneName string
param zoneName string
param nameServers array

resource parentDnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: parentZoneName
}

resource dnsZoneRecord 'Microsoft.Network/dnsZones/NS@2023-07-01-preview' = {
  parent: parentDnsZone
  name: zoneName
  properties: {
    TTL: 172800
    NSRecords: [for nameServer in nameServers : {
        nsdname: nameServer
    }]
  }
}
