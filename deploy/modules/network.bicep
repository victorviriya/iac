param location string
param namePrefix string

@allowed([
  'nonprod'
  'prod'
])
param environmentType string
param vnetName string = '${namePrefix}-${environmentType}-vnet'
param addressPrefix string = '10.0.0.0/16'
param defaultSubnetPrefix string = '10.0.0.0/23'
param gatewaySubnetPrefix string = '10.0.2.0/28'

// virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    } 
    subnets: [
      {
        name: 'Default'
        properties: {
          addressPrefix: defaultSubnetPrefix
        }
      }
      {
        name: 'AppGatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

output name string = vnet.name
