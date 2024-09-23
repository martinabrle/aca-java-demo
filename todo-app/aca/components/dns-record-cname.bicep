param dnsZoneName string
param dnsRecordName string
param dnsRecordValue string

resource dnsRecord 'Microsoft.Network/dnsZones/A@2023-07-01-preview' = {
  name: '${dnsZoneName}/${dnsRecordName}'
  properties: {
    TTL: 60
    CNAMERecord: {
      cname: dnsRecordValue
    }
  }
}
