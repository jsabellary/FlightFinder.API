# Deployment Fix - Azure Resource Type Mismatch

## Problem Fixed

The GitHub Actions workflow `azure-functions-app-dotnet.yml` was failing with the error:

```
Error: Execution Exception (state: ValidateAzureResource) (step: Invocation)
Error:   Resource flightfinder-api of type Microsoft.Web/Sites doesn't exist.
```

## Root Cause

FlightFinder.API is a **standard ASP.NET Core Web API** application, not an Azure Functions app. The project had two workflows:

1. ✅ `azure-deploy.yml` - Correctly configured for Azure Web App deployment
2. ❌ `azure-functions-app-dotnet.yml` - Incorrectly trying to deploy to Azure Functions

Both workflows were triggered on push to `main`, causing the Functions workflow to fail every time.

## Solution Applied

**Disabled the `azure-functions-app-dotnet.yml` workflow** by:
- Removing the automatic trigger on push to main branch
- Adding explanatory comments
- Keeping `workflow_dispatch` option for manual execution if needed

## Next Steps for Deployment

To successfully deploy this application, ensure you have:

### 1. Azure Resource Setup

Create an **Azure Web App** (App Service) named `flightfinder-api`:

```bash
# Using Azure CLI
az webapp create \
  --name flightfinder-api \
  --resource-group <your-resource-group> \
  --plan <your-app-service-plan> \
  --runtime "DOTNETCORE:8.0"
```

**Important:** Make sure it's a **Web App**, not a **Functions App**.

### 2. GitHub Secrets Configuration

Configure the `AZURE_CREDENTIALS` secret in your GitHub repository:

1. Create an Azure Service Principal:
```bash
az ad sp create-for-rbac \
  --name "FlightFinderAPI-GitHub" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Web/sites/flightfinder-api \
  --sdk-auth
```

2. Copy the JSON output and add it as a GitHub secret:
   - Go to: Settings → Secrets and variables → Actions
   - Create secret: `AZURE_CREDENTIALS`
   - Paste the JSON from step 1

### 3. Test Deployment

After setup, test the deployment:

1. Push to main branch or manually trigger the `azure-deploy.yml` workflow
2. Check GitHub Actions tab for build/deploy status
3. Verify the API is running: `https://flightfinder-api.azurewebsites.net/api/airports`

## Alternative: Using Publish Profile

If you prefer simpler authentication, use the publish profile method:

1. Download publish profile from Azure Portal (App Service → Download publish profile)
2. Add as GitHub secret: `AZURE_WEBAPP_PUBLISH_PROFILE`
3. Update `azure-deploy.yml` deploy step:
```yaml
- name: Deploy to Azure Web App
  uses: azure/webapps-deploy@v3
  with:
    app-name: 'flightfinder-api'
    publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
    package: .
```

## Files Modified

- `.github/workflows/azure-functions-app-dotnet.yml` - Disabled automatic trigger

## Files Not Modified

- `.github/workflows/azure-deploy.yml` - Correct workflow, no changes needed
- Project files - Application code is correct as-is

## Verification

After this fix:
- ✅ No more "Resource doesn't exist" errors
- ✅ Only the correct Web App deployment workflow runs on push
- ✅ Functions workflow can still be run manually if needed for testing
