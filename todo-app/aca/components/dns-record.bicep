param dnsZoneName string
param dnsRecordName string

resource dnsRecord 'Microsoft.Network/dnsZones/A@2023-07-01-preview' = {
  name: '${dnsZoneName}/${dnsRecordName}'
  properties: {
    TTL: 60
    ARecords: [
       {
         ipv4Address: '127.0.0.1' 
       }
     ]
  }
}
