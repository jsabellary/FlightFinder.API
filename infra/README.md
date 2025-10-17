# Azure Infrastructure

This directory contains Infrastructure as Code (IaC) using Bicep templates to provision Azure resources for the FlightFinder API.

## Resources Created

The `main.bicep` template creates the following Azure resources:

1. **App Service Plan** (`flightfinder-api-plan`)
   - SKU: B1 (Basic tier)
   - OS: Windows
   - Region: Matches resource group location (default: East US)

2. **Web App** (`flightfinder-api`)
   - Type: `Microsoft.Web/sites` (Azure Web App)
   - Runtime: .NET 8.0
   - HTTPS Only: Enabled
   - TLS Version: 1.2 minimum
   - HTTP/2: Enabled
   - Always On: Enabled

## Deployment

The infrastructure is automatically deployed by the GitHub Actions workflow (`.github/workflows/azure-deploy.yml`) before the application is built and deployed.

### Manual Deployment

If you need to deploy the infrastructure manually:

```bash
# Login to Azure
az login

# Create resource group (if it doesn't exist)
az group create \
  --name FlightFinder \
  --location eastus

# Deploy infrastructure
az deployment group create \
  --resource-group FlightFinder \
  --template-file ./infra/main.bicep \
  --parameters webAppName=flightfinder-api
```

## Parameters

You can customize the deployment using these parameters:

- `webAppName` (default: `flightfinder-api`) - Name of the web app
- `location` (default: resource group location) - Azure region
- `appServicePlanSku` (default: `B1`) - App Service Plan pricing tier
- `dotnetVersion` (default: `v8.0`) - .NET runtime version

Example with custom parameters:

```bash
az deployment group create \
  --resource-group FlightFinder \
  --template-file ./infra/main.bicep \
  --parameters webAppName=my-custom-name \
  --parameters appServicePlanSku=S1
```

## Important Notes

- The template creates an **Azure Web App** (App Service), not an Azure Functions App
- This is required for ASP.NET Core Web API projects
- The infrastructure deployment is idempotent - running it multiple times is safe
- If resources already exist, they will be updated to match the template configuration
