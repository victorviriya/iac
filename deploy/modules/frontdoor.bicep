param namePrefix string

@allowed([
  'nonprod'
  'prod'
])
param environmentType string
param frontDoorName string = '${namePrefix}${environmentType}'

@description('The domain name of the backend. Must be an IP address or FQDN.')
param hostName string

var profileName = '${frontDoorName}-prof'
var endpointName = '${frontDoorName}-afd'
var originName = 'defaultOrigin'
var originGroupName = 'defaultOriginGroup'
var routeName = 'defaultRoute'

resource profile 'Microsoft.Cdn/profiles@2022-05-01-preview' = {
  name: profileName
  location: 'global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: endpointName
  parent: profile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: originGroupName
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: originName
  parent: originGroup
  properties: {
    hostName: hostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: hostName
    priority: 1
    weight: 1000
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: routeName
  parent: endpoint
  dependsOn:[
    origin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}
