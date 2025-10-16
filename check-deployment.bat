@echo off
echo ========================================
echo FlightFinder API - Deployment Status Check
echo ========================================
echo.

echo Checking GitHub repository status...
echo Repository: https://github.com/jsabellary/FlightFinder.API
echo.

echo Checking Azure Web App...
echo Web App: https://flightfinder-api.azurewebsites.net
echo.

echo Testing root endpoint...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://flightfinder-api.azurewebsites.net/' -UseBasicParsing -TimeoutSec 10; Write-Host 'Root endpoint: ' -NoNewline; Write-Host 'OK (Status: ' $response.StatusCode ')' -ForegroundColor Green } catch { Write-Host 'Root endpoint: ' -NoNewline; Write-Host 'FAILED' -ForegroundColor Red }"

echo.
echo Testing API endpoint...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://flightfinder-api.azurewebsites.net/api/airports' -UseBasicParsing -TimeoutSec 10; Write-Host 'API endpoint: ' -NoNewline; Write-Host 'OK (Status: ' $response.StatusCode ')' -ForegroundColor Green; Write-Host ''; Write-Host 'Response preview:'; $response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)) + '...' } catch { Write-Host 'API endpoint: ' -NoNewline; Write-Host 'FAILED (Status: ' $_.Exception.Response.StatusCode.value__ ')' -ForegroundColor Red; Write-Host 'This means the app has NOT been deployed yet.' -ForegroundColor Yellow }"

echo.
echo ========================================
echo Next Steps:
echo ========================================
echo.
echo If API endpoint shows FAILED (404):
echo   1. Open CI_CD_CHECKLIST.md
echo   2. Follow Option 1: Azure Portal Setup
echo   3. This will configure GitHub Actions to deploy automatically
echo.
echo GitHub Actions: https://github.com/jsabellary/FlightFinder.API/actions
echo Azure Portal: https://portal.azure.com
echo.

pause
