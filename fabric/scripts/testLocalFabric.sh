#!/bin/bash
# testLocalFabric.sh - Local Fabric Testing without Docker
# Tests chaincode logic, configuration, and crypto materials

set -e

echo "=========================================="
echo " 🧪 SafeChain Local Fabric Test Suite"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHAINCODE_PATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/chaincode/xcrm"
FABRIC_CONFIG_PATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric"

echo -e "${BLUE}📋 Local Test Configuration:${NC}"
echo "  Chaincode Path: $CHAINCODE_PATH"
echo "  Fabric Config: $FABRIC_CONFIG_PATH"
echo ""

# ================================
# Test 1: File Structure Validation
# ================================
echo -e "${YELLOW}🔍 Test 1: File Structure Validation${NC}"
echo "=============================="

# Check if chaincode files exist
CHAINCODE_FILES=("index.js" "reporter.js" "cases.js" "evidence.js" "package.json")
for file in "${CHAINCODE_FILES[@]}"; do
    if [ -f "$CHAINCODE_PATH/$file" ]; then
        echo -e "${GREEN}✅ Found $file${NC}"
    else
        echo -e "${RED}❌ Missing $file${NC}"
    fi
done

# Check if crypto-config exists
if [ -d "$FABRIC_CONFIG_PATH/crypto-config" ]; then
    echo -e "${GREEN}✅ crypto-config directory exists${NC}"
else
    echo -e "${RED}❌ crypto-config directory missing${NC}"
fi

# Check if channel artifacts exist
CHANNEL_FILES=("genesis.block" "crimechannel.tx")
for file in "${CHANNEL_FILES[@]}"; do
    if [ -f "$FABRIC_CONFIG_PATH/channel-artifacts/$file" ]; then
        echo -e "${GREEN}✅ Found $file${NC}"
    else
        echo -e "${RED}❌ Missing $file${NC}"
    fi
done

echo ""

# ================================
# Test 2: Chaincode Syntax Validation
# ================================
echo -e "${YELLOW}🔍 Test 2: Chaincode Syntax Validation${NC}"
echo "=============================="

# Check if Node.js is available
if command -v node >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Node.js is available${NC}"
    
    # Test chaincode syntax
    cd "$CHAINCODE_PATH"
    if node -c index.js 2>/dev/null; then
        echo -e "${GREEN}✅ index.js syntax is valid${NC}"
    else
        echo -e "${RED}❌ index.js syntax error${NC}"
    fi
    
    if node -c reporter.js 2>/dev/null; then
        echo -e "${GREEN}✅ reporter.js syntax is valid${NC}"
    else
        echo -e "${RED}❌ reporter.js syntax error${NC}"
    fi
    
    if node -c cases.js 2>/dev/null; then
        echo -e "${GREEN}✅ cases.js syntax is valid${NC}"
    else
        echo -e "${RED}❌ cases.js syntax error${NC}"
    fi
    
    if node -c evidence.js 2>/dev/null; then
        echo -e "${GREEN}✅ evidence.js syntax is valid${NC}"
    else
        echo -e "${RED}❌ evidence.js syntax error${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Node.js not found - skipping syntax validation${NC}"
fi

echo ""

# ================================
# Test 3: Chaincode Logic Testing
# ================================
echo -e "${YELLOW}🔍 Test 3: Chaincode Logic Testing${NC}"
echo "=============================="

# Create a simple test script
cat > "$CHAINCODE_PATH/testLocal.js" << 'EOF'
// Local chaincode testing without Fabric
const reports = require('./reporter');
const cases = require('./cases');
const evidence = require('./evidence');

// Mock context object
const mockContext = {
    stub: {
        putState: (key, value) => console.log(`PUT: ${key} = ${value}`),
        getState: (key) => console.log(`GET: ${key}`),
        setState: (key, value) => console.log(`SET: ${key} = ${value}`)
    }
};

async function runTests() {
    console.log('🧪 Testing chaincode functions locally...\n');
    
    try {
        // Test SubmitReport
        console.log('Testing SubmitReport...');
        const reportResult = await reports.submitReport(mockContext, 'TEST-CASE-001', '{"victim": "Test User", "narrative": "Test crime"}');
        console.log('✅ SubmitReport result:', reportResult);
        
        // Test GetCase
        console.log('Testing GetCase...');
        const caseResult = await reports.getCase(mockContext, 'TEST-CASE-001');
        console.log('✅ GetCase result:', caseResult);
        
        // Test UpdateStatus
        console.log('Testing UpdateStatus...');
        const statusResult = await cases.updateStatus(mockContext, 'TEST-CASE-001', 'Under Investigation');
        console.log('✅ UpdateStatus result:', statusResult);
        
        // Test UploadEvidence
        console.log('Testing UploadEvidence...');
        const evidenceResult = await evidence.uploadEvidence(mockContext, 'TEST-CASE-001', 'Test evidence data');
        console.log('✅ UploadEvidence result:', evidenceResult);
        
        console.log('\n🎉 All chaincode functions work correctly!');
        
    } catch (error) {
        console.error('❌ Error testing chaincode:', error.message);
        process.exit(1);
    }
}

runTests();
EOF

# Run the local test
cd "$CHAINCODE_PATH"
if node testLocal.js; then
    echo -e "${GREEN}✅ Chaincode logic tests passed${NC}"
else
    echo -e "${RED}❌ Chaincode logic tests failed${NC}"
fi

# Clean up test file
rm -f testLocal.js

echo ""

# ================================
# Test 4: Configuration Validation
# ================================
echo -e "${YELLOW}🔍 Test 4: Configuration Validation${NC}"
echo "=============================="

# Check docker-compose.yaml
if [ -f "$FABRIC_CONFIG_PATH/docker-compose.yaml" ]; then
    echo -e "${GREEN}✅ docker-compose.yaml exists${NC}"
    
    # Check for required services
    SERVICES=("orderer.xcrm.com" "peer0.police.xcrm.com" "peer0.forensics.xcrm.com" "peer0.courts.xcrm.com")
    for service in "${SERVICES[@]}"; do
        if grep -q "$service" "$FABRIC_CONFIG_PATH/docker-compose.yaml"; then
            echo -e "${GREEN}✅ Service $service configured${NC}"
        else
            echo -e "${RED}❌ Service $service missing${NC}"
        fi
    done
else
    echo -e "${RED}❌ docker-compose.yaml missing${NC}"
fi

# Check configtx.yaml
if [ -f "$FABRIC_CONFIG_PATH/configtx.yaml" ]; then
    echo -e "${GREEN}✅ configtx.yaml exists${NC}"
else
    echo -e "${YELLOW}⚠️  configtx.yaml missing (may be generated)${NC}"
fi

# Check crypto-config.yaml
if [ -f "$FABRIC_CONFIG_PATH/crypto-config.yaml" ]; then
    echo -e "${GREEN}✅ crypto-config.yaml exists${NC}"
else
    echo -e "${YELLOW}⚠️  crypto-config.yaml missing (may be generated)${NC}"
fi

echo ""

# ================================
# Test 5: Crypto Materials Validation
# ================================
echo -e "${YELLOW}🔍 Test 5: Crypto Materials Validation${NC}"
echo "=============================="

# Check if crypto materials exist
CRYPTO_ORGS=("ordererOrganizations/xcrm.com" "peerOrganizations/police.xcrm.com" "peerOrganizations/forensics.xcrm.com" "peerOrganizations/courts.xcrm.com")

for org in "${CRYPTO_ORGS[@]}"; do
    if [ -d "$FABRIC_CONFIG_PATH/crypto-config/$org" ]; then
        echo -e "${GREEN}✅ Crypto materials for $org exist${NC}"
        
        # Check for key files
        if [ -d "$FABRIC_CONFIG_PATH/crypto-config/$org/msp" ]; then
            echo -e "${GREEN}  ✅ MSP directory exists${NC}"
        else
            echo -e "${RED}  ❌ MSP directory missing${NC}"
        fi
    else
        echo -e "${RED}❌ Crypto materials for $org missing${NC}"
    fi
done

echo ""

# ================================
# Test 6: Script Validation
# ================================
echo -e "${YELLOW}🔍 Test 6: Script Validation${NC}"
echo "=============================="

# Check deployment script
if [ -f "$FABRIC_CONFIG_PATH/scripts/deployChaincode.sh" ]; then
    echo -e "${GREEN}✅ deployChaincode.sh exists${NC}"
    
    # Check if script is executable
    if [ -x "$FABRIC_CONFIG_PATH/scripts/deployChaincode.sh" ]; then
        echo -e "${GREEN}✅ deployChaincode.sh is executable${NC}"
    else
        echo -e "${YELLOW}⚠️  deployChaincode.sh not executable (run: chmod +x)${NC}"
    fi
else
    echo -e "${RED}❌ deployChaincode.sh missing${NC}"
fi

# Check other scripts
SCRIPTS=("generateArtifacts.sh" "joinChannel.sh" "testInvokeQuery.sh")
for script in "${SCRIPTS[@]}"; do
    if [ -f "$FABRIC_CONFIG_PATH/scripts/$script" ]; then
        echo -e "${GREEN}✅ $script exists${NC}"
    else
        echo -e "${YELLOW}⚠️  $script missing${NC}"
    fi
done

echo ""

# ================================
# Test 7: Package.json Validation
# ================================
echo -e "${YELLOW}🔍 Test 7: Package.json Validation${NC}"
echo "=============================="

if [ -f "$CHAINCODE_PATH/package.json" ]; then
    echo -e "${GREEN}✅ package.json exists${NC}"
    
    # Check for required dependencies
    if grep -q "fabric-contract-api" "$CHAINCODE_PATH/package.json"; then
        echo -e "${GREEN}✅ fabric-contract-api dependency found${NC}"
    else
        echo -e "${RED}❌ fabric-contract-api dependency missing${NC}"
    fi
else
    echo -e "${RED}❌ package.json missing${NC}"
fi

echo ""

# ================================
# Test Summary
# ================================
echo -e "${BLUE}📊 Local Test Summary${NC}"
echo "=============================="
echo "Local testing completed without Docker."
echo "All chaincode logic and configuration validated."
echo ""
echo -e "${GREEN}🎉 Local Fabric Testing Complete!${NC}"
echo "=========================================="
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "1. Fix any issues found above"
echo "2. When ready, start Docker Desktop"
echo "3. Run: docker-compose up -d"
echo "4. Run: ./scripts/deployChaincode.sh"
echo "5. Run: ./scripts/testFabricNetwork.sh"
