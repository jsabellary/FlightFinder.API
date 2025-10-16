@echo off
echo ========================================
echo Building FlightFinder API for Azure
echo ========================================
echo.

dotnet publish -c Release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo Build successful!
    echo ========================================
    echo.
    echo Published files are in: bin\Release\net8.0\publish\
    echo.
    echo Next steps:
    echo 1. Open Visual Studio
    echo 2. Right-click the FlightFinder.API project
    echo 3. Click 'Publish...'
    echo 4. Select Azure App Service
    echo 5. Choose 'flightfinder-api'
    echo 6. Click Publish
    echo.
    echo OR see DEPLOYMENT_GUIDE.md for all deployment options
    echo ========================================
) else (
    echo.
    echo Build failed! Check the errors above.
    echo.
)

pause
