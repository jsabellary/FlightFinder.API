# FlightFinder API

ASP.NET Core Web API for flight search functionality.

## Endpoints

- `GET /api/airports` - Returns list of available airports
- `POST /api/flightsearch` - Search for flights

## Local Development

1. Run the application:
   ```bash
   dotnet run
   ```

2. Access the API:
   - Default: http://localhost:5000
   - Development: https://localhost:5001

## Azure Deployment

### Prerequisites
- Azure subscription
- Azure Web App created (flightfinder-api.azurewebsites.net)
- .NET 8.0 runtime configured on Azure App Service

### Deployment Options

#### Option 1: GitHub Actions (Recommended)
The repository includes a GitHub Actions workflow (`.github/workflows/azure-deploy.yml`) that automatically deploys to Azure on push to main branch.

**Setup:**
1. In Azure Portal, go to your Web App
2. Navigate to Deployment Center
3. Choose GitHub Actions
4. Configure federated credentials or publish profile
5. Set the following secrets in GitHub repository settings:
   - `AZUREAPPSERVICE_CLIENTID`
   - `AZUREAPPSERVICE_TENANTID`
   - `AZUREAPPSERVICE_SUBSCRIPTIONID`

#### Option 2: Visual Studio Publish
1. Right-click the project
2. Select "Publish"
3. Choose "Azure"
4. Select your Azure Web App
5. Click "Publish"

#### Option 3: Azure CLI
```bash
# Login to Azure
az login

# Create resource group (if needed)
az group create --name FlightFinder --location eastus

# Create App Service plan (if needed)
az appservice plan create --name FlightFinderPlan --resource-group FlightFinder --sku B1 --is-linux

# Create web app (if needed)
az webapp create --name flightfinder-api --resource-group FlightFinder --plan FlightFinderPlan --runtime "DOTNETCORE:8.0"

# Deploy using zip
dotnet publish -c Release -o ./publish
cd publish
zip -r ../deploy.zip .
cd ..
az webapp deployment source config-zip --resource-group FlightFinder --name flightfinder-api --src deploy.zip
```

#### Option 4: Azure Web App Publish Profile
```bash
dotnet publish -c Release /p:PublishProfile=AzureAppService
```

### Troubleshooting

**Issue: 404 Not Found**
- Verify the app is running: Visit https://flightfinder-api.azurewebsites.net/
- Check Application Insights or Log Stream in Azure Portal
- Ensure .NET 8.0 runtime is configured

**Issue: 500 Internal Server Error**
- Enable detailed errors by setting `ASPNETCORE_ENVIRONMENT=Development` in Application Settings
- Check the Log Stream in Azure Portal
- Verify FlightFinder.Shared.dll is included in deployment

**Issue: App not starting**
- Verify target framework is .NET 8.0 (not .NET 9.0)
- Check that all dependencies are included
- Review Kudu diagnostic logs

### Current Status
? Project updated to .NET 8.0 for Azure compatibility
? GitHub Actions workflow configured
? Web.config added for proper hosting
?? **Action Required**: Configure Azure credentials in GitHub Secrets to enable automatic deployment

## API Testing

```bash
# Test airports endpoint
curl https://flightfinder-api.azurewebsites.net/api/airports

# Test root endpoint
curl https://flightfinder-api.azurewebsites.net/
```

Expected response from `/api/airports`: JSON array of airport objects with Code, DisplayName, Latitude, and Longitude.
