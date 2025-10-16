# PowerShell script to deploy FlightFinder API to Azure
# Prerequisites: Azure CLI installed and logged in

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroup = "FlightFinder",
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = "flightfinder-api",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$AppServicePlan = "FlightFinderPlan"
)

Write-Host "=== FlightFinder API Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az version --query '\"azure-cli\"' -o tsv 2>$null
    if ($azVersion) {
        Write-Host "? Azure CLI is installed (version $azVersion)" -ForegroundColor Green
    }
} catch {
    Write-Host "? Azure CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "  Install from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

# Check if logged in
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
$accountInfo = az account show 2>$null
if (-not $accountInfo) {
    Write-Host "You are not logged in to Azure." -ForegroundColor Yellow
    Write-Host "Please login..." -ForegroundColor Yellow
    az login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "? Login failed" -ForegroundColor Red
        exit 1
    }
}

$currentAccount = az account show --query "{name:name, id:id}" -o table
Write-Host "? Logged in to Azure:" -ForegroundColor Green
Write-Host $currentAccount

Write-Host ""
Write-Host "Deployment Configuration:" -ForegroundColor Cyan
Write-Host "  Resource Group: $ResourceGroup"
Write-Host "  App Service Plan: $AppServicePlan"
Write-Host "  Web App Name: $AppName"
Write-Host "  Location: $Location"
Write-Host ""

# Ask for confirmation
$confirm = Read-Host "Continue with deployment? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Deployment cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Step 1: Building the application..." -ForegroundColor Cyan
dotnet publish -c Release -o ./publish
if ($LASTEXITCODE -ne 0) {
    Write-Host "? Build failed" -ForegroundColor Red
    exit 1
}
Write-Host "? Build successful" -ForegroundColor Green

Write-Host ""
Write-Host "Step 2: Creating deployment package..." -ForegroundColor Cyan
Push-Location ./publish
if (Test-Path "../deploy.zip") {
    Remove-Item "../deploy.zip" -Force
}
Compress-Archive -Path * -DestinationPath ../deploy.zip
Pop-Location
Write-Host "? Deployment package created" -ForegroundColor Green

Write-Host ""
Write-Host "Step 3: Checking Azure resources..." -ForegroundColor Cyan

# Check if resource group exists
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "false") {
    Write-Host "Creating resource group '$ResourceGroup'..." -ForegroundColor Yellow
    az group create --name $ResourceGroup --location $Location
    if ($LASTEXITCODE -eq 0) {
        Write-Host "? Resource group created" -ForegroundColor Green
    } else {
        Write-Host "? Failed to create resource group" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "? Resource group exists" -ForegroundColor Green
}

# Check if App Service Plan exists
$planExists = az appservice plan show --name $AppServicePlan --resource-group $ResourceGroup 2>$null
if (-not $planExists) {
    Write-Host "Creating App Service Plan '$AppServicePlan'..." -ForegroundColor Yellow
    az appservice plan create --name $AppServicePlan --resource-group $ResourceGroup --sku B1 --location $Location
    if ($LASTEXITCODE -eq 0) {
        Write-Host "? App Service Plan created" -ForegroundColor Green
    } else {
        Write-Host "? Failed to create App Service Plan" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "? App Service Plan exists" -ForegroundColor Green
}

# Check if Web App exists
$webAppExists = az webapp show --name $AppName --resource-group $ResourceGroup 2>$null
if (-not $webAppExists) {
    Write-Host "Creating Web App '$AppName'..." -ForegroundColor Yellow
    az webapp create --name $AppName --resource-group $ResourceGroup --plan $AppServicePlan --runtime "DOTNET:8.0"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "? Web App created" -ForegroundColor Green
    } else {
        Write-Host "? Failed to create Web App" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "? Web App exists" -ForegroundColor Green
    # Ensure runtime is set to .NET 8.0
    az webapp config set --name $AppName --resource-group $ResourceGroup --use-32bit-worker-process false
}

Write-Host ""
Write-Host "Step 4: Deploying application..." -ForegroundColor Cyan
az webapp deployment source config-zip --resource-group $ResourceGroup --name $AppName --src ./deploy.zip

if ($LASTEXITCODE -eq 0) {
    Write-Host "? Deployment successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== Deployment Complete ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your application is now available at:" -ForegroundColor Green
    Write-Host "  https://$AppName.azurewebsites.net" -ForegroundColor White
    Write-Host ""
    Write-Host "API Endpoints:" -ForegroundColor Green
    Write-Host "  GET https://$AppName.azurewebsites.net/api/airports" -ForegroundColor White
    Write-Host "  POST https://$AppName.azurewebsites.net/api/flightsearch" -ForegroundColor White
    Write-Host ""
    
    # Test the endpoint
    Write-Host "Testing endpoint..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    try {
        $response = Invoke-WebRequest -Uri "https://$AppName.azurewebsites.net/api/airports" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "? API is responding successfully!" -ForegroundColor Green
        }
    } catch {
        Write-Host "? API might still be starting up. Wait a moment and try:" -ForegroundColor Yellow
        Write-Host "  https://$AppName.azurewebsites.net/api/airports" -ForegroundColor White
    }
} else {
    Write-Host "? Deployment failed" -ForegroundColor Red
    exit 1
}

# Cleanup
if (Test-Path "./deploy.zip") {
    Remove-Item "./deploy.zip" -Force
}
