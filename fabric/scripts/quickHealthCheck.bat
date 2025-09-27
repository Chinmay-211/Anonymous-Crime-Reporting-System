@echo off
REM quickHealthCheck.bat - Quick Fabric Network Health Check
REM Fast diagnostic to check if Fabric is working

echo 🔍 Quick Fabric Health Check
echo =============================

REM Check Docker
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker not running - Start Docker Desktop
    goto :end
)

REM Check containers
set CONTAINER_COUNT=0
for %%c in (orderer.xcrm.com peer0.police.xcrm.com peer0.forensics.xcrm.com peer0.courts.xcrm.com) do (
    docker ps --filter "name=%%c" --format "{{.Names}}" | findstr /C:"%%c" >nul
    if %errorlevel% equ 0 set /a CONTAINER_COUNT+=1
)

if %CONTAINER_COUNT% lss 4 (
    echo ❌ Not all containers running (%CONTAINER_COUNT%/4)
    echo    Run: docker-compose up -d
    goto :end
)

REM Quick connectivity test
docker exec orderer.xcrm.com peer version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Orderer not responding
    goto :end
)

echo ✅ Fabric network is healthy!
echo    All containers running
echo    Orderer responding
echo    Ready for operations

:end
pause
