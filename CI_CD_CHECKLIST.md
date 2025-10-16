# CI/CD Setup Checklist

Use this checklist to set up GitHub Actions deployment for FlightFinder API.

## Pre-requisites
- [x] Code pushed to GitHub repository (jsabellary/FlightFinder.API)
- [x] Azure Web App created (flightfinder-api.azurewebsites.net)
- [x] GitHub Actions workflow file exists (.github/workflows/azure-deploy.yml)
- [x] Project targets .NET 8.0

## Option 1: Azure Portal Setup (Recommended - 5 minutes)

- [ ] Open Azure Portal (https://portal.azure.com)
- [ ] Navigate to App Services ? flightfinder-api
- [ ] Open Deployment Center
- [ ] Configure GitHub as source
  - [ ] Authorize GitHub
  - [ ] Select organization: jsabellary
  - [ ] Select repository: FlightFinder.API
  - [ ] Select branch: main
- [ ] Choose authentication type:
  - [ ] User-assigned identity (recommended), OR
  - [ ] Basic authentication
- [ ] Click Save
- [ ] Wait for Azure to configure GitHub Actions
- [ ] Verify workflow starts running

## Option 2: Manual Secret Configuration (Advanced - 15 minutes)

- [ ] Install Azure CLI (if not installed)
- [ ] Login to Azure: `az login`
- [ ] Create service principal (see GITHUB_ACTIONS_SETUP.md)
- [ ] Copy clientId, tenantId, subscriptionId
- [ ] Go to GitHub repository Settings
- [ ] Navigate to Secrets and variables ? Actions
- [ ] Add secrets:
  - [ ] AZUREAPPSERVICE_CLIENTID
  - [ ] AZUREAPPSERVICE_TENANTID
  - [ ] AZUREAPPSERVICE_SUBSCRIPTIONID
- [ ] Configure federated credentials (for OIDC)
- [ ] Trigger workflow manually or push a commit

## Option 3: Publish Profile Method (Simplest - 3 minutes)

- [ ] Open Azure Portal
- [ ] Navigate to App Services ? flightfinder-api
- [ ] Download publish profile
- [ ] Go to GitHub repository Settings ? Secrets and variables ? Actions
- [ ] Add new secret:
  - [ ] Name: AZURE_WEBAPP_PUBLISH_PROFILE
  - [ ] Value: (paste entire contents of .PublishSettings file)
- [ ] Update workflow to use publish profile (see template)
- [ ] Push changes to trigger deployment

## Verification Steps

- [ ] Go to GitHub Actions tab
- [ ] Verify workflow is running/completed
- [ ] Check build job succeeded
- [ ] Check deploy job succeeded
- [ ] Test endpoint in browser:
  - [ ] https://flightfinder-api.azurewebsites.net/ (should return 200)
  - [ ] https://flightfinder-api.azurewebsites.net/api/airports (should return JSON array)
- [ ] Verify no 404 error

## Post-Setup

- [ ] Test automatic deployment:
  - [ ] Make a small code change
  - [ ] Commit and push to main
  - [ ] Verify workflow triggers automatically
  - [ ] Verify deployment completes
  - [ ] Test the API endpoint
- [ ] Document the deployment process for team
- [ ] Set up branch protection rules (optional)
- [ ] Configure deployment notifications (optional)

## Troubleshooting

If deployment fails:
- [ ] Check GitHub Actions logs for error messages
- [ ] Verify Azure credentials/secrets are correct
- [ ] Check Azure Portal ? Deployment Center ? Logs
- [ ] See GITHUB_ACTIONS_SETUP.md troubleshooting section
- [ ] Check Azure Portal ? Log Stream for runtime errors

## Current Status

**Created**: [Current Date]
**Last Updated**: [Current Date]
**Status**: ?? Awaiting CI/CD configuration
**Next Step**: Choose one of the 3 options above and complete the checklist

---

## Quick Reference

**GitHub Repository**: https://github.com/jsabellary/FlightFinder.API
**Azure Web App**: https://flightfinder-api.azurewebsites.net
**GitHub Actions**: https://github.com/jsabellary/FlightFinder.API/actions
**Azure Portal**: https://portal.azure.com

**Recommended Method**: Option 1 (Azure Portal Setup)
**Estimated Time**: 5 minutes
**Difficulty**: Easy ?
