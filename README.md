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

### ? Quick Deploy (Recommended)

**Use the provided PowerShell script:**

```powershell
.\deploy-to-azure.ps1
```

This script will:
- ? Check Azure CLI is installed and logged in
- ? Create Resource Group (if needed)
- ? Create App Service Plan (if needed)
- ? Create Web App (if needed)
- ? Build and publish the application
- ? Deploy to Azure
- ? Test the endpoint

**First time? Install Azure CLI:**
- Download: https://aka.ms/installazurecliwindows
- Then run: `az login`

### Alternative Deployment Options

#### Option 1: Manual Azure CLI
```bash
# Login to Azure
az login

# Create resource group (if needed)
az group create --name FlightFinder --location eastus

# Create App Service plan (if needed)
az appservice plan create --name FlightFinderPlan --resource-group FlightFinder --sku B1

# Create web app (if needed)
az webapp create --name flightfinder-api --resource-group FlightFinder --plan FlightFinderPlan --runtime "DOTNET:8.0"

# Build and deploy
dotnet publish -c Release -o ./publish
cd publish
tar -czf ../deploy.tar.gz *
cd ..
az webapp deployment source config-zip --resource-group FlightFinder --name flightfinder-api --src deploy.tar.gz
```

#### Option 2: Visual Studio Publish
1. Right-click the project in Solution Explorer
2. Select **Publish**
3. Choose **Azure**
4. Select **Azure App Service (Windows)**
5. Sign in and select/create your web app
6. Click **Publish**

#### Option 3: GitHub Actions (For Continuous Deployment)
1. Go to your Azure Web App in Azure Portal
2. Navigate to **Deployment Center**
3. Select **GitHub Actions** as deployment source
4. Authorize GitHub and select repository: `jsabellary/FlightFinder.API`
5. Azure will configure the workflow and secrets automatically
6. Every push to `main` will trigger deployment

**Required GitHub Secrets (if setting up manually):**
- `AZUREAPPSERVICE_CLIENTID`
- `AZUREAPPSERVICE_TENANTID`
- `AZUREAPPSERVICE_SUBSCRIPTIONID`

### Prerequisites
- Azure subscription
- Azure CLI installed (for script/CLI deployment)
- .NET 8.0 SDK installed

### Troubleshooting

**Issue: "Azure CLI not found"**
- Install Azure CLI: https://aka.ms/installazurecliwindows
- Restart your terminal after installation

**Issue: 404 Not Found on /api/airports**
- ? App hasn't been deployed yet ? Use `.\deploy-to-azure.ps1`
- ? App is still starting ? Wait 30-60 seconds after deployment
- ? Wrong URL ? Verify: `https://flightfinder-api.azurewebsites.net/api/airports`

**Issue: 500 Internal Server Error**
- Check Azure Portal ? App Service ? Log Stream
- Verify FlightFinder.Shared.dll is in the deployment
- Check Application Insights for detailed errors

**Issue: "The resource group doesn't exist"**
- Run the PowerShell script - it will create it automatically
- Or create manually: `az group create --name FlightFinder --location eastus`

**Issue: GitHub Actions workflow failing**
- Ensure Azure credentials are configured in GitHub Secrets
- Or use Azure Portal Deployment Center to auto-configure

### Verify Deployment

After deployment, test the endpoints:

```bash
# PowerShell
Invoke-WebRequest -Uri "https://flightfinder-api.azurewebsites.net/api/airports"

# curl (Git Bash/Linux/Mac)
curl https://flightfinder-api.azurewebsites.net/api/airports

# Browser
https://flightfinder-api.azurewebsites.net/api/airports
```

Expected response: JSON array of airports with Code, DisplayName, Latitude, and Longitude.

### Current Status
? Project targeting .NET 8.0 (LTS - Azure compatible)
? Web.config configured for Azure App Service
? GitHub Actions workflow ready
? PowerShell deployment script ready
?? **Action Required**: Run deployment using one of the methods above

## Architecture

- **Framework**: ASP.NET Core 8.0
- **API Style**: RESTful with attribute routing
- **CORS**: Enabled for all origins (configure for production)
- **Compression**: Response compression enabled
- **Hosting**: Compatible with Azure App Service, IIS, Docker
