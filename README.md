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

## CI/CD Deployment (Recommended)

### ? Quick Setup - Azure Portal Method

**This is the recommended way to fix the 404 error and enable proper CI/CD:**

1. **Go to Azure Portal**: https://portal.azure.com
2. **Navigate to**: App Services ? **flightfinder-api**
3. **Click**: Deployment Center (left menu under "Deployment")
4. **Configure**:
   - Source: **GitHub**
   - Authorize and select:
     - Organization: **jsabellary**
     - Repository: **FlightFinder.API**
     - Branch: **main**
   - Authentication: Choose **User-assigned identity** (recommended) or **Basic**
5. **Click Save**

**That's it!** Azure will:
- ? Configure GitHub Actions workflow
- ? Add required secrets to your GitHub repository
- ? Trigger the first deployment
- ? Deploy automatically on every push to `main`

**Result**: https://flightfinder-api.azurewebsites.net/api/airports will work!

### ?? Detailed CI/CD Setup

For detailed instructions including manual setup options, see: **[GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)**

The guide covers:
- Azure Portal setup (easiest)
- Manual service principal creation
- Publish profile method
- Troubleshooting GitHub Actions
- Pipeline verification

### Current CI/CD Status

? GitHub Actions workflow configured (`.github/workflows/azure-deploy.yml`)  
? Repository set up on GitHub  
? .NET 8.0 (Azure compatible)  
?? **Action Required**: Configure Azure credentials (see above)

Once configured, every push to `main` will automatically:
1. Build the application
2. Run tests (if added)
3. Deploy to Azure App Service
4. Make the API available at the live endpoint

---

## Manual Deployment (Not Recommended)

If you need to deploy manually for testing (bypasses CI/CD), see: **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)**

However, **using CI/CD is strongly recommended** for:
- ? Automated deployments
- ? Consistent builds
- ? Deployment history
- ? Easy rollbacks
- ? No local environment dependencies

---

## Verifying Deployment

After CI/CD is set up and deployment completes:

### Check GitHub Actions
- Go to: https://github.com/jsabellary/FlightFinder.API/actions
- Verify the workflow ran successfully
- Check build and deployment logs

### Test the API

**PowerShell:**
```powershell
Invoke-WebRequest -Uri "https://flightfinder-api.azurewebsites.net/api/airports"
```

**Browser:**
```
https://flightfinder-api.azurewebsites.net/api/airports
```

**Expected Response:**
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

### Monitor Deployments

**GitHub:**
- Repository ? Actions tab
- View workflow runs and logs

**Azure Portal:**
- App Service ? Deployment Center ? Logs
- App Service ? Log Stream (for runtime logs)

---

## Troubleshooting 404 Error

**Issue**: `https://flightfinder-api.azurewebsites.net/api/airports` returns 404

**Root Cause**: Application hasn't been deployed yet (web app is empty)

**Solution**: Set up CI/CD pipeline using Azure Portal method (see above)

**After CI/CD Setup**:
1. Deployment triggers automatically when you push to `main`
2. Wait 2-3 minutes for first deployment
3. Test the endpoint
4. Future deployments happen automatically on every push

---

## Project Structure

```
FlightFinder.API/
??? Controllers/
?   ??? AirportsController.cs      # GET /api/airports
?   ??? FlightSearchController.cs  # POST /api/flightsearch
??? Properties/
?   ??? launchSettings.json        # Local dev settings
?   ??? PublishProfiles/           # Deployment profiles
??? .github/
?   ??? workflows/
?       ??? azure-deploy.yml       # GitHub Actions CI/CD
??? Program.cs                     # Application entry point
??? Startup.cs                     # Service configuration
??? SampleData.cs                  # Airport data
??? web.config                     # IIS/Azure configuration
??? FlightFinder.API.csproj        # Project file (.NET 8.0)
```

---

## Architecture

- **Framework**: ASP.NET Core 8.0 (LTS)
- **API Style**: RESTful with attribute routing
- **CORS**: Enabled for all origins (configure for production)
- **Compression**: Response compression enabled
- **Hosting**: Azure App Service (Windows)
- **CI/CD**: GitHub Actions
- **Deployment**: Automated on push to main branch

---

## Development Workflow

1. **Make changes** in your local environment
2. **Test locally**: `dotnet run`
3. **Commit changes**: `git commit -m "Your message"`
4. **Push to GitHub**: `git push origin main`
5. **GitHub Actions automatically**:
   - Builds the application
   - Publishes artifacts
   - Deploys to Azure
6. **Verify** at https://flightfinder-api.azurewebsites.net/api/airports

---

## Next Steps

### Immediate
- [ ] Configure CI/CD using Azure Portal Deployment Center
- [ ] Verify first deployment succeeds
- [ ] Test the API endpoints

### Future Enhancements
- [ ] Add unit tests to CI/CD pipeline
- [ ] Set up staging environment
- [ ] Add Application Insights for monitoring
- [ ] Configure custom domain
- [ ] Add API authentication
- [ ] Implement rate limiting

---

## Resources

- **GitHub Actions Setup**: [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)
- **Manual Deployment**: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **GitHub Repository**: https://github.com/jsabellary/FlightFinder.API
- **Azure Portal**: https://portal.azure.com
- **Live API**: https://flightfinder-api.azurewebsites.net
