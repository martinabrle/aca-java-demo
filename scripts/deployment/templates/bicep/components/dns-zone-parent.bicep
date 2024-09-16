@description('The name of the DNS zone to be created.  Must have at least 2 segments, e.g. hostname.org')
param zoneName string

param tagsArray object

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: zoneName
  location: 'global'
  tags: tagsArray
  properties: {
    zoneType: 'Public'
  }
}

output id string = dnsZone.id
output zoneName string = dnsZone.name
