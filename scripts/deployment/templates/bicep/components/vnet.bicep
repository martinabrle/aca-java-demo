param name string
param aksSubnetName string
param appGatewaySubnetName string
param location string
param tagsArray object

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.240.0.0/16' ]
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: '10.240.0.0/20' //10.240.0.1 - 10.240.15.254
        }
      }
      {
        name: appGatewaySubnetName
        properties: {
          addressPrefix: '10.240.16.0/24' //10.240.16.1 - 10.240.16.254
        }
      }
    ]
  }
  tags: tagsArray
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: aksSubnetName
}


resource appGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: appGatewaySubnetName
}

output aksSubnetId string = aksSubnet.id
output appGatewaySubnetId string = appGatewaySubnet.id
output vnetId string = vnet.id
output vnetName string = vnet.name
output aksSubnetName string = aksSubnet.name
output appGatewaySubnetName string = appGatewaySubnet.name
