param location string = resourceGroup().location
param namePrefix string = 'wviriya'

@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
param external bool = false

@allowed([
  'agw'
  'afdx'
])
param loadBalancerType string = 'agw'

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

module privateDNSZone 'modules/privateDnsZone.bicep' =  {
  name: '${namePrefix}-privateDNSZone'
  params: {
    privateDnsZoneName: containerApp.outputs.domain
    vnetName: vnet.outputs.name
    acaIp: containerApp.outputs.lbIp
  }
}

module appGateway 'modules/appGateway.bicep' = if (loadBalancerType=='agw' && !external) {
  name: '${namePrefix}-appGateway'
  params: {
    location: location
    namePrefix: namePrefix
    environmentType: environmentType
    vnetName: vnet.outputs.name
    containerAppFqdn: containerApp.outputs.fqdn
  }
}

module frontDoor 'modules/frontdoor.bicep' = if (loadBalancerType=='afdx') {
  name: '${namePrefix}-frontDoor'
  params: {
    namePrefix: namePrefix
    environmentType: environmentType
    hostName: containerApp.outputs.fqdn
  }
}


