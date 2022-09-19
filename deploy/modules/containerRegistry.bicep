param location string
param namePrefix string

@allowed([
  'nonprod'
  'prod'
])
param environmentType string

@minLength(5)
@maxLength(50)
@description('Name of the azure container registry (must be globally unique)')
param acrName string = '${namePrefix}${environmentType}aca'

@description('Enable an admin user that has push/pull permission to the registry.')
param acrAdminUserEnabled bool = false

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param acrSku string = 'Basic'

// azure container registry
resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

output acrLoginServer string = acr.properties.loginServer
