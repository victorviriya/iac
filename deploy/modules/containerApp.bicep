param location string
param namePrefix string
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
param containerAppName string = '${namePrefix}-aca'
param containerAppEnvName string = '${namePrefix}-${environmentType}-aca'
param containerAppLogAnalyticsName string = '${namePrefix}-${environmentType}-log'
@description('Minimum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param minReplica int = 1

@description('Maximum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param maxReplica int = 3

param external bool = true

param vnetName string

var frontendContainerImage = 'mcr.microsoft.com/azuredocs/azure-vote-front:v1'
var backendContainerImage = 'mcr.microsoft.com/oss/bitnami/redis:6.0.8'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  name: '${vnetName}/default'
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: containerAppLogAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: containerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    vnetConfiguration: {
      infrastructureSubnetId: subnet.id
      internal: !external
    }
  }
}

resource aca 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        allowInsecure: true
        external: external
        targetPort: 80
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      revisionSuffix: 'firstrevision'
      containers: [
        {
          name: containerAppName
          image: frontendContainerImage
          env: [
            {
              name: 'REDIS'
              value: 'localhost'
            }
          ]
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
        }
        {
          name: 'redis'
          image: backendContainerImage
          env: [
            {
              name: 'ALLOW_EMPTY_PASSWORD'
              value: 'yes'
            }
          ]
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplica
        maxReplicas: maxReplica
        rules: [
          {
            name: 'http-requests'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

output fqdn string = aca.properties.configuration.ingress.fqdn
