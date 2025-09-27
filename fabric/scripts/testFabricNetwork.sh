#!/bin/bash
# testFabricNetwork.sh - Comprehensive Fabric Network Testing Script
# Tests the entire SafeChain Fabric network setup

set -e

echo "=========================================="
echo " 🧪 SafeChain Fabric Network Test Suite"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHANNEL_NAME="crimechannel"
CHAINCODE_NAME="xcrm"
VERSION="1.8"
TEST_CASE_ID="TEST-CASE-$(date +%s)"
TEST_DETAILS='{"victim": "Test User", "narrative": "Test crime report", "location": "Test Location", "timestamp": "'$(date -Iseconds)'"}'

# Set FABRIC_CFG_PATH
export FABRIC_CFG_PATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric"

echo -e "${BLUE}📋 Test Configuration:${NC}"
echo "  Channel: $CHANNEL_NAME"
echo "  Chaincode: $CHAINCODE_NAME v$VERSION"
echo "  Test Case ID: $TEST_CASE_ID"
echo ""

# ================================
# Test 1: Docker Status Check
# ================================
echo -e "${YELLOW}🔍 Test 1: Docker Status Check${NC}"
echo "=============================="

if ! docker ps > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker Desktop first.${NC}"
    echo "   Steps to start Docker Desktop:"
    echo "   1. Open Docker Desktop application"
    echo "   2. Wait for it to fully start"
    echo "   3. Run this script again"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Check if Fabric containers are running
CONTAINERS_RUNNING=$(docker ps --filter "name=peer0\|orderer\|couchdb" --format "table {{.Names}}" | wc -l)
if [ $CONTAINERS_RUNNING -lt 7 ]; then
    echo -e "${YELLOW}⚠️  Fabric network not fully started. Starting network...${NC}"
    echo "   Run: docker-compose up -d"
    echo "   Then run this script again"
    exit 1
fi

echo -e "${GREEN}✅ Fabric containers are running${NC}"
echo ""

# ================================
# Test 2: Network Connectivity
# ================================
echo -e "${YELLOW}🔍 Test 2: Network Connectivity${NC}"
echo "=============================="

# Test orderer connectivity
echo "Testing orderer connectivity..."
if docker exec orderer.xcrm.com peer version > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Orderer is accessible${NC}"
else
    echo -e "${RED}❌ Orderer connectivity failed${NC}"
fi

# Test peer connectivity
for org in police forensics courts; do
    echo "Testing $org peer connectivity..."
    if docker exec peer0.$org.xcrm.com peer version > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $org peer is accessible${NC}"
    else
        echo -e "${RED}❌ $org peer connectivity failed${NC}"
    fi
done
echo ""

# ================================
# Test 3: Channel Status
# ================================
echo -e "${YELLOW}🔍 Test 3: Channel Status${NC}"
echo "=============================="

# Set context for Police peer
export CORE_PEER_LOCALMSPID="PoliceMSP"
export CORE_PEER_ADDRESS="localhost:7051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/users/Admin@police.xcrm.com/msp"
export CORE_PEER_TLS_ENABLED=false

# Check if channel exists
echo "Checking channel status..."
CHANNEL_INFO=$(peer channel list 2>/dev/null | grep $CHANNEL_NAME || echo "")
if [ -n "$CHANNEL_INFO" ]; then
    echo -e "${GREEN}✅ Channel $CHANNEL_NAME exists${NC}"
else
    echo -e "${RED}❌ Channel $CHANNEL_NAME not found${NC}"
    echo "   Channel may need to be created. Check channel creation scripts."
fi
echo ""

# ================================
# Test 4: Chaincode Deployment Status
# ================================
echo -e "${YELLOW}🔍 Test 4: Chaincode Deployment Status${NC}"
echo "=============================="

# Check if chaincode is installed
echo "Checking chaincode installation..."
INSTALLED_CHAINCODES=$(peer lifecycle chaincode queryinstalled 2>/dev/null | grep $CHAINCODE_NAME || echo "")
if [ -n "$INSTALLED_CHAINCODES" ]; then
    echo -e "${GREEN}✅ Chaincode $CHAINCODE_NAME is installed${NC}"
else
    echo -e "${YELLOW}⚠️  Chaincode not installed. Deploying...${NC}"
    echo "   Run: ./deployChaincode.sh"
    echo "   Then run this test again"
fi

# Check if chaincode is committed
echo "Checking chaincode commitment..."
COMMITTED_CHAINCODES=$(peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME 2>/dev/null | grep $CHAINCODE_NAME || echo "")
if [ -n "$COMMITTED_CHAINCODES" ]; then
    echo -e "${GREEN}✅ Chaincode $CHAINCODE_NAME is committed to channel${NC}"
else
    echo -e "${YELLOW}⚠️  Chaincode not committed to channel${NC}"
    echo "   Run: ./deployChaincode.sh"
    echo "   Then run this test again"
fi
echo ""

# ================================
# Test 5: Chaincode Function Tests
# ================================
echo -e "${YELLOW}🔍 Test 5: Chaincode Function Tests${NC}"
echo "=============================="

# Test SubmitReport function
echo "Testing SubmitReport function..."
SUBMIT_RESULT=$(peer chaincode invoke \
    -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.xcrm.com \
    --tls \
    --tlsRootCertFiles "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/ordererOrganizations/xcrm.com/orderers/orderer.xcrm.com/tls/ca.crt" \
    -C $CHANNEL_NAME \
    -n $CHAINCODE_NAME \
    --peerAddresses localhost:7051 \
    -c "{\"function\":\"SubmitReport\",\"Args\":[\"$TEST_CASE_ID\", \"$TEST_DETAILS\"]}" \
    --waitForEvent 2>/dev/null || echo "FAILED")

if [[ "$SUBMIT_RESULT" == *"success"* ]] || [[ "$SUBMIT_RESULT" == *"Report submitted"* ]]; then
    echo -e "${GREEN}✅ SubmitReport function works${NC}"
else
    echo -e "${RED}❌ SubmitReport function failed${NC}"
    echo "   Result: $SUBMIT_RESULT"
fi

# Test GetCase function
echo "Testing GetCase function..."
GET_CASE_RESULT=$(peer chaincode query \
    -C $CHANNEL_NAME \
    -n $CHAINCODE_NAME \
    -c "{\"function\":\"GetCase\",\"Args\":[\"$TEST_CASE_ID\"]}" 2>/dev/null || echo "FAILED")

if [[ "$GET_CASE_RESULT" == *"Case data"* ]] || [[ "$GET_CASE_RESULT" == *"$TEST_CASE_ID"* ]]; then
    echo -e "${GREEN}✅ GetCase function works${NC}"
    echo "   Result: $GET_CASE_RESULT"
else
    echo -e "${RED}❌ GetCase function failed${NC}"
    echo "   Result: $GET_CASE_RESULT"
fi

# Test UpdateStatus function
echo "Testing UpdateStatus function..."
UPDATE_STATUS_RESULT=$(peer chaincode invoke \
    -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.xcrm.com \
    --tls \
    --tlsRootCertFiles "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/ordererOrganizations/xcrm.com/orderers/orderer.xcrm.com/tls/ca.crt" \
    -C $CHANNEL_NAME \
    -n $CHAINCODE_NAME \
    --peerAddresses localhost:7051 \
    -c "{\"function\":\"UpdateStatus\",\"Args\":[\"$TEST_CASE_ID\", \"Under Investigation\"]}" \
    --waitForEvent 2>/dev/null || echo "FAILED")

if [[ "$UPDATE_STATUS_RESULT" == *"success"* ]] || [[ "$UPDATE_STATUS_RESULT" == *"Status updated"* ]]; then
    echo -e "${GREEN}✅ UpdateStatus function works${NC}"
else
    echo -e "${RED}❌ UpdateStatus function failed${NC}"
    echo "   Result: $UPDATE_STATUS_RESULT"
fi

# Test UploadEvidence function
echo "Testing UploadEvidence function..."
UPLOAD_EVIDENCE_RESULT=$(peer chaincode invoke \
    -o localhost:7050 \
    --ordererTLSHostnameOverride orderer.xcrm.com \
    --tls \
    --tlsRootCertFiles "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/ordererOrganizations/xcrm.com/orderers/orderer.xcrm.com/tls/ca.crt" \
    -C $CHANNEL_NAME \
    -n $CHAINCODE_NAME \
    --peerAddresses localhost:7051 \
    -c "{\"function\":\"UploadEvidence\",\"Args\":[\"$TEST_CASE_ID\", \"Test evidence data\"]}" \
    --waitForEvent 2>/dev/null || echo "FAILED")

if [[ "$UPLOAD_EVIDENCE_RESULT" == *"success"* ]] || [[ "$UPLOAD_EVIDENCE_RESULT" == *"Evidence uploaded"* ]]; then
    echo -e "${GREEN}✅ UploadEvidence function works${NC}"
else
    echo -e "${RED}❌ UploadEvidence function failed${NC}"
    echo "   Result: $UPLOAD_EVIDENCE_RESULT"
fi

echo ""

# ================================
# Test 6: Cross-Organization Tests
# ================================
echo -e "${YELLOW}🔍 Test 6: Cross-Organization Tests${NC}"
echo "=============================="

# Test from Forensics perspective
echo "Testing from Forensics organization..."
export CORE_PEER_LOCALMSPID="ForensicsMSP"
export CORE_PEER_ADDRESS="localhost:8051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/forensics.xcrm.com/users/Admin@forensics.xcrm.com/msp"

FORENSICS_QUERY=$(peer chaincode query \
    -C $CHANNEL_NAME \
    -n $CHAINCODE_NAME \
    -c "{\"function\":\"GetCase\",\"Args\":[\"$TEST_CASE_ID\"]}" 2>/dev/null || echo "FAILED")

if [[ "$FORENSICS_QUERY" == *"Case data"* ]] || [[ "$FORENSICS_QUERY" == *"$TEST_CASE_ID"* ]]; then
    echo -e "${GREEN}✅ Forensics can access case data${NC}"
else
    echo -e "${RED}❌ Forensics cannot access case data${NC}"
fi

# Test from Courts perspective
echo "Testing from Courts organization..."
export CORE_PEER_LOCALMSPID="CourtsMSP"
export CORE_PEER_ADDRESS="localhost:9051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/courts.xcrm.com/users/Admin@courts.xcrm.com/msp"

COURTS_QUERY=$(peer chaincode query \
    -C $CHANNEL_NAME \
    -n $CHAINCODE_NAME \
    -c "{\"function\":\"GetCase\",\"Args\":[\"$TEST_CASE_ID\"]}" 2>/dev/null || echo "FAILED")

if [[ "$COURTS_QUERY" == *"Case data"* ]] || [[ "$COURTS_QUERY" == *"$TEST_CASE_ID"* ]]; then
    echo -e "${GREEN}✅ Courts can access case data${NC}"
else
    echo -e "${RED}❌ Courts cannot access case data${NC}"
fi

echo ""

# ================================
# Test Summary
# ================================
echo -e "${BLUE}📊 Test Summary${NC}"
echo "=============================="
echo "Test Case ID used: $TEST_CASE_ID"
echo "All tests completed. Check results above for any failures."
echo ""
echo -e "${GREEN}🎉 Fabric Network Testing Complete!${NC}"
echo "=========================================="
