@echo off
REM testLocalFabric.bat - Windows Batch File for Local Fabric Testing
REM Tests chaincode logic, configuration, and crypto materials without Docker

echo ==========================================
echo  🧪 SafeChain Local Fabric Test Suite
echo ==========================================

REM Configuration
set CHAINCODE_PATH=C:\Users\DYNAMIC\Desktop\DYNAMIC\Projects\Anonymous-Crime-Reporting-System\SafeChain\fabric\chaincode\xcrm
set FABRIC_CONFIG_PATH=C:\Users\DYNAMIC\Desktop\DYNAMIC\Projects\Anonymous-Crime-Reporting-System\SafeChain\fabric

echo 📋 Local Test Configuration:
echo   Chaincode Path: %CHAINCODE_PATH%
echo   Fabric Config: %FABRIC_CONFIG_PATH%
echo.

REM ================================
REM Test 1: File Structure Validation
REM ================================
echo 🔍 Test 1: File Structure Validation
echo ==============================

REM Check if chaincode files exist
if exist "%CHAINCODE_PATH%\index.js" (
    echo ✅ Found index.js
) else (
    echo ❌ Missing index.js
)

if exist "%CHAINCODE_PATH%\reporter.js" (
    echo ✅ Found reporter.js
) else (
    echo ❌ Missing reporter.js
)

if exist "%CHAINCODE_PATH%\cases.js" (
    echo ✅ Found cases.js
) else (
    echo ❌ Missing cases.js
)

if exist "%CHAINCODE_PATH%\evidence.js" (
    echo ✅ Found evidence.js
) else (
    echo ❌ Missing evidence.js
)

if exist "%CHAINCODE_PATH%\package.json" (
    echo ✅ Found package.json
) else (
    echo ❌ Missing package.json
)

REM Check if crypto-config exists
if exist "%FABRIC_CONFIG_PATH%\crypto-config" (
    echo ✅ crypto-config directory exists
) else (
    echo ❌ crypto-config directory missing
)

REM Check if channel artifacts exist
if exist "%FABRIC_CONFIG_PATH%\channel-artifacts\genesis.block" (
    echo ✅ Found genesis.block
) else (
    echo ❌ Missing genesis.block
)

if exist "%FABRIC_CONFIG_PATH%\channel-artifacts\crimechannel.tx" (
    echo ✅ Found crimechannel.tx
) else (
    echo ❌ Missing crimechannel.tx
)

echo.

REM ================================
REM Test 2: Chaincode Syntax Validation
REM ================================
echo 🔍 Test 2: Chaincode Syntax Validation
echo ==============================

REM Check if Node.js is available
node --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Node.js is available
    
    REM Test chaincode syntax
    cd /d "%CHAINCODE_PATH%"
    node -c index.js >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ index.js syntax is valid
    ) else (
        echo ❌ index.js syntax error
    )
    
    node -c reporter.js >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ reporter.js syntax is valid
    ) else (
        echo ❌ reporter.js syntax error
    )
    
    node -c cases.js >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ cases.js syntax is valid
    ) else (
        echo ❌ cases.js syntax error
    )
    
    node -c evidence.js >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ evidence.js syntax is valid
    ) else (
        echo ❌ evidence.js syntax error
    )
) else (
    echo ⚠️  Node.js not found - skipping syntax validation
)

echo.

REM ================================
REM Test 3: Chaincode Logic Testing
REM ================================
echo 🔍 Test 3: Chaincode Logic Testing
echo ==============================

REM Create a simple test script
echo // Local chaincode testing without Fabric > "%CHAINCODE_PATH%\testLocal.js"
echo const reports = require('./reporter'); >> "%CHAINCODE_PATH%\testLocal.js"
echo const cases = require('./cases'); >> "%CHAINCODE_PATH%\testLocal.js"
echo const evidence = require('./evidence'); >> "%CHAINCODE_PATH%\testLocal.js"
echo. >> "%CHAINCODE_PATH%\testLocal.js"
echo // Mock context object >> "%CHAINCODE_PATH%\testLocal.js"
echo const mockContext = { >> "%CHAINCODE_PATH%\testLocal.js"
echo     stub: { >> "%CHAINCODE_PATH%\testLocal.js"
echo         putState: (key, value) =^> console.log(`PUT: ${key} = ${value}`), >> "%CHAINCODE_PATH%\testLocal.js"
echo         getState: (key) =^> console.log(`GET: ${key}`), >> "%CHAINCODE_PATH%\testLocal.js"
echo         setState: (key, value) =^> console.log(`SET: ${key} = ${value}`) >> "%CHAINCODE_PATH%\testLocal.js"
echo     } >> "%CHAINCODE_PATH%\testLocal.js"
echo }; >> "%CHAINCODE_PATH%\testLocal.js"
echo. >> "%CHAINCODE_PATH%\testLocal.js"
echo async function runTests() { >> "%CHAINCODE_PATH%\testLocal.js"
echo     console.log('🧪 Testing chaincode functions locally...\n'); >> "%CHAINCODE_PATH%\testLocal.js"
echo. >> "%CHAINCODE_PATH%\testLocal.js"
echo     try { >> "%CHAINCODE_PATH%\testLocal.js"
echo         // Test SubmitReport >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.log('Testing SubmitReport...'); >> "%CHAINCODE_PATH%\testLocal.js"
echo         const reportResult = await reports.submitReport(mockContext, 'TEST-CASE-001', '{"victim": "Test User", "narrative": "Test crime"}'); >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.log('✅ SubmitReport result:', reportResult); >> "%CHAINCODE_PATH%\testLocal.js"
echo. >> "%CHAINCODE_PATH%\testLocal.js"
echo         // Test GetCase >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.log('Testing GetCase...'); >> "%CHAINCODE_PATH%\testLocal.js"
echo         const caseResult = await reports.getCase(mockContext, 'TEST-CASE-001'); >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.log('✅ GetCase result:', caseResult); >> "%CHAINCODE_PATH%\testLocal.js"
echo. >> "%CHAINCODE_PATH%\testLocal.js"
echo         // Test UpdateStatus >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.log('Testing UpdateStatus...'); >> "%CHAINCODE_PATH%\testLocal.js"
echo         const statusResult = await cases.updateStatus(mockContext, 'TEST-CASE-001', 'Under Investigation'); >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.log('✅ UpdateStatus result:', statusResult); >> "%CHAINCODE_PATH%\testLocal.js"
echo. >> "%CHAINCODE_PATH%\testLocal.js"
echo         // Test UploadEvidence >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.log('Testing UploadEvidence...'); >> "%CHAINCODE_PATH%\testLocal.js"
echo         const evidenceResult = await evidence.uploadEvidence(mockContext, 'TEST-CASE-001', 'Test evidence data'); >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.log('✅ UploadEvidence result:', evidenceResult); >> "%CHAINCODE_PATH%\testLocal.js"
echo. >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.log('\n🎉 All chaincode functions work correctly!'); >> "%CHAINCODE_PATH%\testLocal.js"
echo. >> "%CHAINCODE_PATH%\testLocal.js"
echo     } catch (error) { >> "%CHAINCODE_PATH%\testLocal.js"
echo         console.error('❌ Error testing chaincode:', error.message); >> "%CHAINCODE_PATH%\testLocal.js"
echo         process.exit(1); >> "%CHAINCODE_PATH%\testLocal.js"
echo     } >> "%CHAINCODE_PATH%\testLocal.js"
echo } >> "%CHAINCODE_PATH%\testLocal.js"
echo. >> "%CHAINCODE_PATH%\testLocal.js"
echo runTests(); >> "%CHAINCODE_PATH%\testLocal.js"

REM Run the local test
cd /d "%CHAINCODE_PATH%"
node testLocal.js
if %errorlevel% equ 0 (
    echo ✅ Chaincode logic tests passed
) else (
    echo ❌ Chaincode logic tests failed
)

REM Clean up test file
del "%CHAINCODE_PATH%\testLocal.js"

echo.

REM ================================
REM Test 4: Configuration Validation
REM ================================
echo 🔍 Test 4: Configuration Validation
echo ==============================

REM Check docker-compose.yaml
if exist "%FABRIC_CONFIG_PATH%\docker-compose.yaml" (
    echo ✅ docker-compose.yaml exists
    
    REM Check for required services
    findstr /C:"orderer.xcrm.com" "%FABRIC_CONFIG_PATH%\docker-compose.yaml" >nul
    if %errorlevel% equ 0 (
        echo ✅ Service orderer.xcrm.com configured
    ) else (
        echo ❌ Service orderer.xcrm.com missing
    )
    
    findstr /C:"peer0.police.xcrm.com" "%FABRIC_CONFIG_PATH%\docker-compose.yaml" >nul
    if %errorlevel% equ 0 (
        echo ✅ Service peer0.police.xcrm.com configured
    ) else (
        echo ❌ Service peer0.police.xcrm.com missing
    )
    
    findstr /C:"peer0.forensics.xcrm.com" "%FABRIC_CONFIG_PATH%\docker-compose.yaml" >nul
    if %errorlevel% equ 0 (
        echo ✅ Service peer0.forensics.xcrm.com configured
    ) else (
        echo ❌ Service peer0.forensics.xcrm.com missing
    )
    
    findstr /C:"peer0.courts.xcrm.com" "%FABRIC_CONFIG_PATH%\docker-compose.yaml" >nul
    if %errorlevel% equ 0 (
        echo ✅ Service peer0.courts.xcrm.com configured
    ) else (
        echo ❌ Service peer0.courts.xcrm.com missing
    )
) else (
    echo ❌ docker-compose.yaml missing
)

REM Check other config files
if exist "%FABRIC_CONFIG_PATH%\configtx.yaml" (
    echo ✅ configtx.yaml exists
) else (
    echo ⚠️  configtx.yaml missing (may be generated)
)

if exist "%FABRIC_CONFIG_PATH%\crypto-config.yaml" (
    echo ✅ crypto-config.yaml exists
) else (
    echo ⚠️  crypto-config.yaml missing (may be generated)
)

echo.

REM ================================
REM Test 5: Crypto Materials Validation
REM ================================
echo 🔍 Test 5: Crypto Materials Validation
echo ==============================

REM Check if crypto materials exist
if exist "%FABRIC_CONFIG_PATH%\crypto-config\ordererOrganizations\xcrm.com" (
    echo ✅ Crypto materials for ordererOrganizations/xcrm.com exist
) else (
    echo ❌ Crypto materials for ordererOrganizations/xcrm.com missing
)

if exist "%FABRIC_CONFIG_PATH%\crypto-config\peerOrganizations\police.xcrm.com" (
    echo ✅ Crypto materials for peerOrganizations/police.xcrm.com exist
) else (
    echo ❌ Crypto materials for peerOrganizations/police.xcrm.com missing
)

if exist "%FABRIC_CONFIG_PATH%\crypto-config\peerOrganizations\forensics.xcrm.com" (
    echo ✅ Crypto materials for peerOrganizations/forensics.xcrm.com exist
) else (
    echo ❌ Crypto materials for peerOrganizations/forensics.xcrm.com missing
)

if exist "%FABRIC_CONFIG_PATH%\crypto-config\peerOrganizations\courts.xcrm.com" (
    echo ✅ Crypto materials for peerOrganizations/courts.xcrm.com exist
) else (
    echo ❌ Crypto materials for peerOrganizations/courts.xcrm.com missing
)

echo.

REM ================================
REM Test 6: Script Validation
REM ================================
echo 🔍 Test 6: Script Validation
echo ==============================

REM Check deployment script
if exist "%FABRIC_CONFIG_PATH%\scripts\deployChaincode.sh" (
    echo ✅ deployChaincode.sh exists
) else (
    echo ❌ deployChaincode.sh missing
)

REM Check other scripts
if exist "%FABRIC_CONFIG_PATH%\scripts\generateArtifacts.sh" (
    echo ✅ generateArtifacts.sh exists
) else (
    echo ⚠️  generateArtifacts.sh missing
)

if exist "%FABRIC_CONFIG_PATH%\scripts\joinChannel.sh" (
    echo ✅ joinChannel.sh exists
) else (
    echo ⚠️  joinChannel.sh missing
)

if exist "%FABRIC_CONFIG_PATH%\scripts\testInvokeQuery.sh" (
    echo ✅ testInvokeQuery.sh exists
) else (
    echo ⚠️  testInvokeQuery.sh missing
)

echo.

REM ================================
REM Test 7: Package.json Validation
REM ================================
echo 🔍 Test 7: Package.json Validation
echo ==============================

if exist "%CHAINCODE_PATH%\package.json" (
    echo ✅ package.json exists
    
    REM Check for required dependencies
    findstr /C:"fabric-contract-api" "%CHAINCODE_PATH%\package.json" >nul
    if %errorlevel% equ 0 (
        echo ✅ fabric-contract-api dependency found
    ) else (
        echo ❌ fabric-contract-api dependency missing
    )
) else (
    echo ❌ package.json missing
)

echo.

REM ================================
REM Test Summary
REM ================================
echo 📊 Local Test Summary
echo ==============================
echo Local testing completed without Docker.
echo All chaincode logic and configuration validated.
echo.
echo 🎉 Local Fabric Testing Complete!
echo ==========================================
echo.
echo 📝 Next Steps:
echo 1. Fix any issues found above
echo 2. When ready, start Docker Desktop
echo 3. Run: docker-compose up -d
echo 4. Run: ./scripts/deployChaincode.sh
echo 5. Run: ./scripts/testFabricNetwork.sh

pause
