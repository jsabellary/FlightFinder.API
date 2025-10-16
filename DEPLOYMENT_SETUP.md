# Azure Functions Deployment Setup Guide

## Problem Fixed

The GitHub Actions workflow was failing with the error:
```
No credentials found. Add an Azure login action before this action.
```

### Root Cause
The workflow was configured to use a publish profile (`AZURE_FUNCTIONAPP_PUBLISH_PROFILE` secret), but when that secret wasn't available, the Azure Functions action automatically fell back to RBAC authentication. However, no Azure login step was active, causing the deployment to fail.

### Solution Applied
1. **Enabled Azure CLI Login**: Uncommented and activated the Azure login step that uses RBAC credentials
2. **Removed Publish Profile Parameter**: Removed the `publish-profile` parameter to use RBAC authentication consistently
3. **Updated Documentation**: Changed comments to reflect the RBAC authentication requirement

## Required Setup Steps

To complete the deployment configuration, you need to set up Azure Service Principal credentials:

### 1. Create an Azure Service Principal

Run the following Azure CLI command to create a service principal:

```bash
az ad sp create-for-rbac --name "FlightFinder-GitHub-Actions" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
  --sdk-auth
```

Replace:
- `{subscription-id}` with your Azure subscription ID
- `{resource-group}` with your resource group name

This command will output JSON credentials like:
```json
{
  "clientId": "<client-id>",
  "clientSecret": "<client-secret>",
  "subscriptionId": "<subscription-id>",
  "tenantId": "<tenant-id>",
  ...
}
```

### 2. Add the Secret to GitHub

1. Go to your GitHub repository: https://github.com/jsabellary/FlightFinder.API
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `AZURE_RBAC_CREDENTIALS`
5. Value: Paste the entire JSON output from the previous step
6. Click **Add secret**

### 3. Verify Environment Configuration

The workflow uses the `dev` environment. Ensure this environment is configured in your repository:

1. Go to **Settings** → **Environments**
2. Create or verify the `dev` environment exists
3. Optionally, add environment protection rules if needed

## Alternative: Using Publish Profile

If you prefer to use a publish profile instead of RBAC authentication, you can:

1. Download the publish profile from your Azure Function App
2. Add it as a secret named `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`
3. Revert to the previous workflow configuration

However, RBAC authentication is recommended as it provides better security and control.

## Workflow Configuration

Current workflow settings:
- **Azure Function App Name**: `FlightFinder.API`
- **.NET Version**: `9.0.x`
- **Build Configuration**: Release
- **Output Path**: `./output`

To modify these settings, edit the `env` section in `.github/workflows/azure-functions-app-dotnet.yml`.

## Testing the Fix

Once you've added the `AZURE_RBAC_CREDENTIALS` secret:

1. Push a commit to the `main` branch
2. The workflow will automatically trigger
3. Monitor the workflow run in the **Actions** tab
4. The deployment should now succeed if credentials are correctly configured

## Troubleshooting

### If the workflow still fails:

1. **Verify the secret is set**: Check that `AZURE_RBAC_CREDENTIALS` exists in repository secrets
2. **Check service principal permissions**: Ensure the service principal has contributor access to the resource group
3. **Verify Azure Function App exists**: Confirm the function app named `FlightFinder.API` exists in Azure
4. **Review workflow logs**: Check the Actions tab for detailed error messages

### Common Issues:

- **Invalid credentials**: Regenerate the service principal and update the secret
- **Permission denied**: Grant proper RBAC roles to the service principal
- **Resource not found**: Verify the function app name matches exactly

## References

- [Azure Functions Action Documentation](https://github.com/Azure/functions-action)
- [Azure Service Principal Setup](https://github.com/Azure/functions-action#using-azure-service-principal-for-rbac-as-deployment-credential)
- [GitHub Actions for Azure](https://github.com/Azure/Actions)
