# Manual Deployment Guide for FlightFinder API

## The Problem
Your API endpoint `https://flightfinder-api.azurewebsites.net/api/airports` is returning 404 because **the application hasn't been deployed to Azure yet**.

## Why is it 404?
- ? The Azure Web App exists (root returns 200 OK)
- ? The FlightFinder API code is NOT deployed to the web app
- The web app is likely showing a default Azure landing page

## Solution: Deploy the Application

You have 3 options to deploy:

---

## Option 1: Visual Studio Publish (EASIEST - Recommended)

1. **Open the solution in Visual Studio 2022**

2. **Right-click on the `FlightFinder.API` project** in Solution Explorer

3. **Click "Publish..."**

4. **Click "New"** to create a publish profile

5. **Select:**
   - Target: **Azure**
   - Specific target: **Azure App Service (Windows)**

6. **Sign in** with your Azure account

7. **Select existing App Service:**
   - Subscription: (your subscription)
   - Resource Group: Should see your resource group
   - App Service: **flightfinder-api**

8. **Click "Finish"**

9. **Click "Publish"** button

10. **Wait for deployment** (usually 1-2 minutes)

11. **Test the endpoint:**
    ```
    https://flightfinder-api.azurewebsites.net/api/airports
    ```

---

## Option 2: Download Publish Profile from Azure Portal

1. **Go to Azure Portal**: https://portal.azure.com

2. **Navigate to App Services** ? **flightfinder-api**

3. **Click "Download publish profile"** (top menu)

4. **Save the file** (e.g., `flightfinder-api.PublishSettings`)

5. **In Visual Studio:**
   - Right-click project ? **Publish**
   - Click **New**
   - Click **Import Profile**
   - Select the downloaded `.PublishSettings` file
   - Click **Publish**

---

## Option 3: Install Azure CLI and Use Script

1. **Install Azure CLI:**
   - Download: https://aka.ms/installazurecliwindows
   - Run the installer
   - **Restart PowerShell/Terminal**

2. **Login to Azure:**
   ```powershell
   az login
   ```

3. **Run the deployment script:**
   ```powershell
   .\deploy-to-azure.ps1
   ```

---

## Option 4: Use Azure Cloud Shell (No Installation Required)

1. **Go to Azure Portal**: https://portal.azure.com

2. **Click the Cloud Shell icon** (>_) in the top menu bar

3. **Select "Bash" or "PowerShell"**

4. **Upload your published files:**
   - First, build locally:
     ```powershell
     dotnet publish -c Release -o ./publish
     ```
   - Zip the publish folder:
     ```powershell
     Compress-Archive -Path ./publish/* -DestinationPath deploy.zip
     ```
   - In Cloud Shell, click **Upload** button
   - Upload `deploy.zip`

5. **Run deployment command:**
   ```bash
   az webapp deployment source config-zip \
     --resource-group FlightFinder \
     --name flightfinder-api \
     --src deploy.zip
   ```

---

## Verify Deployment

After deploying using ANY of the above methods, test:

### PowerShell:
```powershell
Invoke-WebRequest -Uri "https://flightfinder-api.azurewebsites.net/api/airports"
```

### Browser:
Open: https://flightfinder-api.azurewebsites.net/api/airports

### Expected Result:
```json
[
  {
    "Code": "ATL",
    "DisplayName": "Atlanta",
    "Latitude": 33.640411,
    "Longitude": -84.419853
  },
  ...
]
```

---

## Why Visual Studio Publish is Recommended

- ? No additional software to install
- ? Visual Studio handles authentication automatically
- ? One-click deployment
- ? Can save profile for future deployments
- ? Shows deployment progress in Output window
- ? Automatically opens browser to test

---

## Next Steps After First Deployment

Once you've deployed successfully using Visual Studio:

1. **Enable Continuous Deployment** (Optional):
   - Set up GitHub Actions for automatic deployment
   - Every push to `main` will deploy automatically

2. **Monitor your app**:
   - Azure Portal ? App Service ? Log Stream
   - Set up Application Insights for detailed monitoring

3. **Configure custom domain** (Optional):
   - Azure Portal ? App Service ? Custom domains

---

## Need Help?

- **Can't find the web app in Visual Studio?**
  - Make sure you're signed in to the correct Azure account
  - Check you have permissions to the subscription

- **Publish fails with authentication error?**
  - Sign out and sign back in to Visual Studio
  - Tools ? Options ? Azure Service Authentication ? Clear credentials

- **Still getting 404 after deployment?**
  - Check Azure Portal ? App Service ? Log Stream for errors
  - Verify the deployment completed successfully
  - Wait 30-60 seconds for the app to start

