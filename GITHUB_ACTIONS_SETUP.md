# GitHub Actions CI/CD Setup Guide

## Overview
This guide will help you configure GitHub Actions to automatically deploy your FlightFinder API to Azure whenever you push to the `main` branch.

## Current Status
? GitHub Actions workflow file is configured (`.github/workflows/azure-deploy.yml`)  
? Code is pushed to GitHub repository  
? Azure credentials not configured in GitHub Secrets  
? GitHub Actions deployment has not run yet

---

## Setup Method 1: Using Azure Portal (EASIEST - Recommended)

This method lets Azure automatically configure all the secrets for you.

### Steps:

1. **Go to Azure Portal**
   - Navigate to: https://portal.azure.com
   - Sign in with your Azure account

2. **Open your Web App**
   - Click **App Services** from the left menu
   - Click on **flightfinder-api**

3. **Open Deployment Center**
   - In the left menu, scroll down to **Deployment**
   - Click **Deployment Center**

4. **Configure GitHub Actions**
   - Source: Select **GitHub**
   - Click **Authorize** (if not already authorized)
   - Organization: Select **jsabellary**
   - Repository: Select **FlightFinder.API**
   - Branch: Select **main**

5. **Choose Authentication**
   - **Option A: User-assigned identity** (Recommended - more secure)
     - Select "User-assigned identity"
     - This uses Azure AD for authentication (no passwords)
   
   - **Option B: Basic authentication**
     - Uses publish profile (simpler but less secure)

6. **Save Configuration**
   - Click **Save** at the top
   - Azure will automatically:
     - Create/update the GitHub Actions workflow
     - Add required secrets to your GitHub repository
     - Trigger the first deployment

7. **Monitor Deployment**
   - Go to your GitHub repository
   - Click **Actions** tab
   - You should see a workflow running
   - Watch it build and deploy

### Result:
? GitHub Actions workflow configured  
? Azure credentials added as GitHub Secrets  
? Automatic deployment on every push to main  
? Your API will be live at: `https://flightfinder-api.azurewebsites.net/api/airports`

---

## Setup Method 2: Manual Secret Configuration (Advanced)

If you prefer to manually configure the secrets, follow these steps:

### Step 1: Create Azure Service Principal

```bash
# Login to Azure CLI
az login

# Get your subscription ID
az account show --query id -o tsv

# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "FlightFinderAPI-GitHub" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/FlightFinder/providers/Microsoft.Web/sites/flightfinder-api \
  --sdk-auth
```

**Save the entire JSON output!** It will look like:
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  ...
}
```

### Step 2: Configure Federated Credentials (For OIDC - More Secure)

```bash
# Get the App ID from the service principal
APP_ID=$(az ad sp list --display-name "FlightFinderAPI-GitHub" --query "[0].appId" -o tsv)

# Create federated credential
az ad app federated-credential create \
  --id $APP_ID \
  --parameters '{
    "name": "FlightFinderGitHub",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:jsabellary/FlightFinder.API:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### Step 3: Add Secrets to GitHub Repository

1. **Go to your GitHub repository**
   - https://github.com/jsabellary/FlightFinder.API

2. **Open Settings**
   - Click **Settings** tab
   - Click **Secrets and variables** ? **Actions**

3. **Add the following Repository Secrets:**
   - Click **New repository secret** for each:

   **For OIDC (Recommended):**
   - `AZUREAPPSERVICE_CLIENTID`: (clientId from JSON)
   - `AZUREAPPSERVICE_TENANTID`: (tenantId from JSON)
   - `AZUREAPPSERVICE_SUBSCRIPTIONID`: (subscriptionId from JSON)

   **OR for Basic Auth (simpler):**
   - `AZURE_WEBAPP_PUBLISH_PROFILE`: (download from Azure Portal)

### Step 4: Trigger Deployment

Option A: **Push a change**
```bash
git commit --allow-empty -m "Trigger GitHub Actions deployment"
git push origin main
```

Option B: **Manual trigger**
- Go to GitHub ? **Actions** tab
- Click on the workflow
- Click **Run workflow** button
- Select `main` branch
- Click **Run workflow**

---

## Setup Method 3: Using Publish Profile (Simplest - Less Secure)

This method uses a publish profile instead of service principal.

### Step 1: Download Publish Profile

1. **Azure Portal** ? **App Services** ? **flightfinder-api**
2. Click **Download publish profile** (top menu)
3. Save the `.PublishSettings` file

### Step 2: Update GitHub Actions Workflow

Replace the current workflow with this simpler version:

```yaml
name: Deploy to Azure Web App

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up .NET Core
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'

      - name: Build with dotnet
        run: dotnet build --configuration Release

      - name: dotnet publish
        run: dotnet publish -c Release -o ./publish

      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v3
        with:
          app-name: 'flightfinder-api'
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
          package: ./publish
```

### Step 3: Add Publish Profile to GitHub Secrets

1. **Open the downloaded `.PublishSettings` file** in a text editor
2. **Copy the entire contents**
3. **Go to GitHub repository** ? **Settings** ? **Secrets and variables** ? **Actions**
4. **New repository secret**:
   - Name: `AZURE_WEBAPP_PUBLISH_PROFILE`
   - Value: Paste the entire contents of the publish profile file
5. **Save**

### Step 4: Commit and Push

```bash
# If you updated the workflow file
git add .github/workflows/azure-deploy.yml
git commit -m "Update workflow to use publish profile"
git push origin main
```

---

## Verifying the CI/CD Pipeline

### 1. Check Workflow Status

- Go to: https://github.com/jsabellary/FlightFinder.API/actions
- You should see a workflow running or completed
- Click on it to see detailed logs

### 2. Monitor Deployment

**In GitHub Actions:**
- Build job: Compiles and publishes the app
- Deploy job: Deploys to Azure

**In Azure Portal:**
- App Service ? Deployment Center ? Logs
- Shows deployment history and status

### 3. Test the Endpoint

Once deployment succeeds:

```bash
# PowerShell
Invoke-WebRequest -Uri "https://flightfinder-api.azurewebsites.net/api/airports"

# Browser
https://flightfinder-api.azurewebsites.net/api/airports
```

Expected: JSON array of airports (not 404)

---

## Troubleshooting

### Issue: "Resource not found" or "Authentication failed"
**Solution:**
- Verify the service principal has Contributor role
- Check all three secrets are added correctly (CLIENT_ID, TENANT_ID, SUBSCRIPTION_ID)
- Try downloading and using publish profile instead

### Issue: Workflow doesn't trigger
**Solution:**
- Check `.github/workflows/azure-deploy.yml` exists in the repository
- Verify the workflow syntax is correct
- Try manual trigger: Actions ? Select workflow ? Run workflow

### Issue: Build succeeds but deploy fails
**Solution:**
- Check the secret name matches the workflow file
- For publish profile: Ensure no extra spaces or newlines when pasting
- For OIDC: Verify federated credential subject matches exactly

### Issue: Deployment succeeds but still 404
**Solution:**
- Wait 30-60 seconds for app to start
- Check Azure Portal ? Log Stream for startup errors
- Verify the correct files were deployed (check Kudu: yourapp.scm.azurewebsites.net)

---

## Recommended Setup

**For this project, I recommend Setup Method 1 (Azure Portal Deployment Center)** because:

? Automatic configuration - no manual secret creation  
? Azure manages the credentials securely  
? One-click setup  
? Supports both OIDC and publish profile  
? Updates your GitHub Actions workflow automatically  
? Easier to maintain  

---

## Next Steps After Setup

1. **Test the pipeline:**
   - Make a small code change
   - Commit and push to main
   - Watch it deploy automatically

2. **Add branch protection:**
   - Require pull requests for main branch
   - Require status checks to pass before merging

3. **Add deployment environments:**
   - Create separate dev/staging/production environments
   - Add approval gates for production deployments

4. **Monitor deployments:**
   - Set up notifications in GitHub Actions
   - Configure Application Insights in Azure

---

## Summary

To fix your 404 issue using proper CI/CD:

1. ? Go to Azure Portal ? App Services ? flightfinder-api ? Deployment Center
2. ? Configure GitHub Actions (select your repo)
3. ? Save (Azure configures everything automatically)
4. ? Wait for deployment to complete
5. ? Test: https://flightfinder-api.azurewebsites.net/api/airports

**No bypass, proper CI/CD pipeline, automatic deployments on every push!** ??
