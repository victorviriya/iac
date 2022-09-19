param location string = resourceGroup().location
param namePrefix string = 'wviriya'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
param external bool = false

module vnet 'modules/network.bicep' = {
  name: '${namePrefix}-vnet'
  params: {
    location: location
    namePrefix: namePrefix
    environmentType: environmentType
  }
}

module containerApp 'modules/containerApp.bicep' = {
  name: '${namePrefix}-containerApp'
  params: {
    location: location
    namePrefix: namePrefix
    environmentType: environmentType
    vnetName: vnet.outputs.name
    external: external
  }
}

module appGateway 'modules/appGateway.bicep' = if (!external) {
  name: '${namePrefix}-appGateway'
  params: {
    location: location
    namePrefix: namePrefix
    environmentType: environmentType
    vnetName: vnet.outputs.name
    containerAppFqdn: containerApp.outputs.fqdn
  }
}

module frontDoor 'modules/frontdoor.bicep' = if (external) {
  name: '${namePrefix}-frontDoor'
  params: {
    namePrefix: namePrefix
    environmentType: environmentType
    backendAddress: containerApp.outputs.fqdn
  }
}


