param dnsZoneName string
param dnsRecordName string

resource dnsRecord 'Microsoft.Network/privateDnsZones/A@2024-06-01' = {
  name: '${dnsZoneName}/${dnsRecordName}'
  properties: {
    ttl: 300
    aRecords: [
      {
        ipv4Address: '127.0.0.1'
      }
    ]
  }
}
