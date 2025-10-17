// Azure Web App infrastructure for FlightFinder API
@description('The name of the web app')
param webAppName string = 'flightfinder-api'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The SKU for the App Service Plan')
param appServicePlanSku string = 'B1'

@description('The .NET framework version')
param dotnetVersion string = 'v8.0'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${webAppName}-plan'
  location: location
  sku: {
    name: appServicePlanSku
  }
  kind: 'app'
  properties: {
    reserved: false // false for Windows
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: dotnetVersion
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
  }
}

// Output the web app URL
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppName string = webApp.name
