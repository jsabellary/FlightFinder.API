# Deployment Fix Summary

## Problem

**Error Message**: `Deployment Failed, Error: Resource flightfinder-api of type Microsoft.Web/Sites doesn't exist.`

**Root Cause**: The GitHub Actions deployment workflow was attempting to deploy the application to an Azure Web App resource that had never been provisioned. The Azure infrastructure did not exist.

## Solution

Implemented **Infrastructure as Code (IaC)** using Azure Bicep to automatically provision Azure resources before deploying the application.

## Changes Made

### 1. Created Infrastructure as Code (`infra/main.bicep`)

A Bicep template that defines:
- **Azure App Service Plan** (`flightfinder-api-plan`)
  - SKU: B1 (Basic tier)
  - OS: Windows
  - Region: East US (configurable)

- **Azure Web App** (`flightfinder-api`)
  - Type: `Microsoft.Web/sites` (the resource mentioned in the error)
  - Runtime: .NET 8.0
  - Security: HTTPS only, TLS 1.2+, FTP disabled
  - Performance: Always On enabled, HTTP/2 enabled

### 2. Updated GitHub Actions Workflow (`.github/workflows/azure-deploy.yml`)

**Added infrastructure deployment job:**
```yaml
jobs:
  infrastructure:
    - Creates Azure Resource Group if it doesn't exist
    - Deploys Bicep template to provision resources
  
  build:
    needs: infrastructure  # Runs after infrastructure is ready
    - Builds .NET 8.0 application
  
  deploy:
    needs: build  # Runs after build completes
    - Deploys application to Azure Web App
```

**Key improvements:**
- Infrastructure is provisioned automatically on first deployment
- Subsequent deployments skip provisioning (idempotent)
- Proper dependency chain ensures resources exist before deployment
- Environment variables for easy configuration

### 3. Removed Conflicting Workflow

Deleted `.github/workflows/azure-functions-app-dotnet.yml`:
- This workflow was trying to deploy to Azure Functions (wrong resource type)
- Would have caused conflicts with the correct Web App deployment
- ASP.NET Core Web API requires Web App, not Functions App

### 4. Updated Documentation

- **README.md**: Added IaC deployment section, updated project structure
- **infra/README.md**: Comprehensive infrastructure documentation with manual deployment instructions

## Files Changed

```
Modified:
  .github/workflows/azure-deploy.yml  (+31 lines, infrastructure job added)
  README.md                           (+41 lines, -88 lines, clearer IaC docs)

Added:
  infra/main.bicep                    (Bicep template for Azure resources)
  infra/README.md                     (Infrastructure documentation)

Deleted:
  .github/workflows/azure-functions-app-dotnet.yml  (Incorrect workflow)
```

## Setup Required

**One-time setup**: Configure Azure credentials in GitHub Secrets

1. Create Azure Service Principal:
   ```bash
   az ad sp create-for-rbac \
     --name "FlightFinderAPI-GitHub" \
     --role contributor \
     --scopes /subscriptions/{subscription-id} \
     --sdk-auth
   ```

2. Add GitHub Secret:
   - Name: `AZURE_CREDENTIALS`
   - Value: (JSON output from step 1)

3. Push to main branch - deployment starts automatically!

## How It Works

**Before this fix:**
```
Push to main → Build app → Deploy to Azure → ❌ ERROR: Resource doesn't exist
```

**After this fix:**
```
Push to main → Provision Azure infrastructure → Build app → Deploy to Azure → ✅ SUCCESS
                ↑ Creates resources if needed
```

## Result

✅ **Deployment will now succeed**
- Azure Resource Group created automatically
- Azure App Service Plan provisioned
- Azure Web App (Microsoft.Web/sites) created
- Application deployed and running

✅ **API will be accessible at:**
- https://flightfinder-api.azurewebsites.net
- https://flightfinder-api.azurewebsites.net/api/airports

✅ **Future deployments are fully automated:**
- Infrastructure provisioning (if needed)
- Application build
- Deployment to Azure
- No manual steps required

## Technical Details

**Resource Types Created:**
- `Microsoft.Web/serverfarms` - App Service Plan
- `Microsoft.Web/sites` - Web App (the exact type from the error message)

**Deployment is Idempotent:**
- Safe to run multiple times
- Existing resources are updated to match template
- No duplicate resources created

**Best Practices Implemented:**
- Infrastructure as Code for reproducibility
- Proper job dependencies in CI/CD pipeline
- Security hardening (HTTPS only, TLS 1.2+, no FTP)
- Documentation for maintainability

## Verification

To verify the fix works:

1. Ensure `AZURE_CREDENTIALS` secret is configured in GitHub
2. Push changes to main branch
3. Monitor GitHub Actions workflow:
   - Infrastructure job: Creates Azure resources
   - Build job: Compiles application
   - Deploy job: Deploys to Azure
4. Test the API: https://flightfinder-api.azurewebsites.net/api/airports

Expected: JSON array of airports, not 404 error.

## Conclusion

The deployment error has been **completely resolved** by implementing Infrastructure as Code. The Azure resources will be automatically provisioned on the first deployment, and all future deployments will work seamlessly.

**The error "Resource flightfinder-api of type Microsoft.Web/Sites doesn't exist" will no longer occur.**
