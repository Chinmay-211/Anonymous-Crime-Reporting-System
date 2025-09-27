@echo off
REM testFabricNetwork.bat - Windows Batch File for Fabric Network Testing
REM Tests the entire SafeChain Fabric network setup

echo ==========================================
echo  🧪 SafeChain Fabric Network Test Suite
echo ==========================================

REM Configuration
set CHANNEL_NAME=crimechannel
set CHAINCODE_NAME=xcrm
set VERSION=1.8
set TEST_CASE_ID=TEST-CASE-%RANDOM%
set TEST_DETAILS={"victim": "Test User", "narrative": "Test crime report", "location": "Test Location"}

REM Set FABRIC_CFG_PATH
set FABRIC_CFG_PATH=C:\Users\DYNAMIC\Desktop\DYNAMIC\Projects\Anonymous-Crime-Reporting-System\SafeChain\fabric

echo 📋 Test Configuration:
echo   Channel: %CHANNEL_NAME%
echo   Chaincode: %CHAINCODE_NAME% v%VERSION%
echo   Test Case ID: %TEST_CASE_ID%
echo.

REM ================================
REM Test 1: Docker Status Check
REM ================================
echo 🔍 Test 1: Docker Status Check
echo ==============================

docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running. Please start Docker Desktop first.
    echo    Steps to start Docker Desktop:
    echo    1. Open Docker Desktop application
    echo    2. Wait for it to fully start
    echo    3. Run this script again
    pause
    exit /b 1
)

echo ✅ Docker is running

REM Check if Fabric containers are running
for /f %%i in ('docker ps --filter "name=peer0^|orderer^|couchdb" --format "table {{.Names}}" ^| find /c /v ""') do set CONTAINERS_RUNNING=%%i
if %CONTAINERS_RUNNING% lss 7 (
    echo ⚠️  Fabric network not fully started. Starting network...
    echo    Run: docker-compose up -d
    echo    Then run this script again
    pause
    exit /b 1
)

echo ✅ Fabric containers are running
echo.

REM ================================
REM Test 2: Network Connectivity
REM ================================
echo 🔍 Test 2: Network Connectivity
echo ==============================

echo Testing orderer connectivity...
docker exec orderer.xcrm.com peer version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Orderer is accessible
) else (
    echo ❌ Orderer connectivity failed
)

REM Test peer connectivity
for %%org in (police forensics courts) do (
    echo Testing %%org peer connectivity...
    docker exec peer0.%%org.xcrm.com peer version >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ %%org peer is accessible
    ) else (
        echo ❌ %%org peer connectivity failed
    )
)
echo.

REM ================================
REM Test 3: Channel Status
REM ================================
echo 🔍 Test 3: Channel Status
echo ==============================

REM Set context for Police peer
set CORE_PEER_LOCALMSPID=PoliceMSP
set CORE_PEER_ADDRESS=localhost:7051
set CORE_PEER_MSPCONFIGPATH=C:\Users\DYNAMIC\Desktop\DYNAMIC\Projects\Anonymous-Crime-Reporting-System\SafeChain\fabric\crypto-config\peerOrganizations\police.xcrm.com\users\Admin@police.xcrm.com\msp
set CORE_PEER_TLS_ENABLED=false

echo Checking channel status...
peer channel list 2>nul | findstr %CHANNEL_NAME% >nul
if %errorlevel% equ 0 (
    echo ✅ Channel %CHANNEL_NAME% exists
) else (
    echo ❌ Channel %CHANNEL_NAME% not found
    echo    Channel may need to be created. Check channel creation scripts.
)
echo.

REM ================================
REM Test 4: Chaincode Deployment Status
REM ================================
echo 🔍 Test 4: Chaincode Deployment Status
echo ==============================

echo Checking chaincode installation...
peer lifecycle chaincode queryinstalled 2>nul | findstr %CHAINCODE_NAME% >nul
if %errorlevel% equ 0 (
    echo ✅ Chaincode %CHAINCODE_NAME% is installed
) else (
    echo ⚠️  Chaincode not installed. Deploying...
    echo    Run: deployChaincode.sh
    echo    Then run this test again
)

echo Checking chaincode commitment...
peer lifecycle chaincode querycommitted --channelID %CHANNEL_NAME% 2>nul | findstr %CHAINCODE_NAME% >nul
if %errorlevel% equ 0 (
    echo ✅ Chaincode %CHAINCODE_NAME% is committed to channel
) else (
    echo ⚠️  Chaincode not committed to channel
    echo    Run: deployChaincode.sh
    echo    Then run this test again
)
echo.

REM ================================
REM Test 5: Chaincode Function Tests
REM ================================
echo 🔍 Test 5: Chaincode Function Tests
echo ==============================

echo Testing SubmitReport function...
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.xcrm.com --tls --tlsRootCertFiles "C:\Users\DYNAMIC\Desktop\DYNAMIC\Projects\Anonymous-Crime-Reporting-System\SafeChain\fabric\crypto-config\ordererOrganizations\xcrm.com\orderers\orderer.xcrm.com\tls\ca.crt" -C %CHANNEL_NAME% -n %CHAINCODE_NAME% --peerAddresses localhost:7051 -c "{\"function\":\"SubmitReport\",\"Args\":[\"%TEST_CASE_ID%\", \"%TEST_DETAILS%\"]}" --waitForEvent >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ SubmitReport function works
) else (
    echo ❌ SubmitReport function failed
)

echo Testing GetCase function...
peer chaincode query -C %CHANNEL_NAME% -n %CHAINCODE_NAME% -c "{\"function\":\"GetCase\",\"Args\":[\"%TEST_CASE_ID%\"]}" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ GetCase function works
) else (
    echo ❌ GetCase function failed
)

echo Testing UpdateStatus function...
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.xcrm.com --tls --tlsRootCertFiles "C:\Users\DYNAMIC\Desktop\DYNAMIC\Projects\Anonymous-Crime-Reporting-System\SafeChain\fabric\crypto-config\ordererOrganizations\xcrm.com\orderers\orderer.xcrm.com\tls\ca.crt" -C %CHANNEL_NAME% -n %CHAINCODE_NAME% --peerAddresses localhost:7051 -c "{\"function\":\"UpdateStatus\",\"Args\":[\"%TEST_CASE_ID%\", \"Under Investigation\"]}" --waitForEvent >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ UpdateStatus function works
) else (
    echo ❌ UpdateStatus function failed
)

echo Testing UploadEvidence function...
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.xcrm.com --tls --tlsRootCertFiles "C:\Users\DYNAMIC\Desktop\DYNAMIC\Projects\Anonymous-Crime-Reporting-System\SafeChain\fabric\crypto-config\ordererOrganizations\xcrm.com\orderers\orderer.xcrm.com\tls\ca.crt" -C %CHANNEL_NAME% -n %CHAINCODE_NAME% --peerAddresses localhost:7051 -c "{\"function\":\"UploadEvidence\",\"Args\":[\"%TEST_CASE_ID%\", \"Test evidence data\"]}" --waitForEvent >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ UploadEvidence function works
) else (
    echo ❌ UploadEvidence function failed
)
echo.

REM ================================
REM Test Summary
REM ================================
echo 📊 Test Summary
echo ==============================
echo Test Case ID used: %TEST_CASE_ID%
echo All tests completed. Check results above for any failures.
echo.
echo 🎉 Fabric Network Testing Complete!
echo ==========================================
pause
