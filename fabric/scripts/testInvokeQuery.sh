#!/bin/bash
# testInvokeQuery.sh — Smoke test chaincode functions: SubmitReport + GetCase
# Assumes chaincode is deployed and committed on crimechannel.
# Uses Police peer as default invoker.

set -e

CHANNEL_NAME="crimechannel"
CHAINCODE_NAME="xcrm"
TEST_CASE_ID="CASE-001"
TEST_DETAILS='{"victim": "John Doe", "narrative": "Robbery at Main St"}'

echo "============================="
echo " 🔥 Testing Chaincode: SubmitReport"
echo "============================="

# Set context to Police peer (can write to CaseDetailsCollection)
export CORE_PEER_LOCALMSPID="PoliceMSP"
export CORE_PEER_ADDRESS="peer0.police.xcrm.com:7051"
export CORE_PEER_TLS_ROOTCERT_FILE="/fabric/crypto-config/peerOrganizations/police.xcrm.com/peers/peer0.police.xcrm.com/tls/ca.crt"
export CORE_PEER_MSPCONFIGPATH="/fabric/crypto-config/peerOrganizations/police.xcrm.com/users/Admin@police.xcrm.com/msp"

# Invoke SubmitReport
peer chaincode invoke \
  -o orderer.xcrm.com:7050 \
  --tls \
  --cafile /fabric/crypto-config/ordererOrganizations/xcrm.com/orderers/orderer.xcrm.com/msp/tlscacerts/tlsca.xcrm.com-cert.pem \
  -C $CHANNEL_NAME \
  -n $CHAINCODE_NAME \
  --peerAddresses peer0.police.xcrm.com:7051 \
  --tlsRootCertFiles /fabric/crypto-config/peerOrganizations/police.xcrm.com/peers/peer0.police.xcrm.com/tls/ca.crt \
  -c "{\"function\":\"SubmitReport\",\"Args\":[\"$TEST_CASE_ID\", \"$TEST_DETAILS\"]}" \
  --waitForEvent
if [ $? -ne 0 ]; then
  echo "❌ SubmitReport invocation failed"
  exit 1
fi
echo "✅ SubmitReport succeeded for case $TEST_CASE_ID"

echo "============================="
echo " 🔍 Testing Chaincode: GetCase"
echo "============================="

# Query GetCase
RESULT=$(peer chaincode query \
  -C $CHANNEL_NAME \
  -n $CHAINCODE_NAME \
  -c "{\"function\":\"GetCase\",\"Args\":[\"$TEST_CASE_ID\"]}")
if [ $? -ne 0 ]; then
  echo "❌ GetCase query failed"
  exit 1
fi

echo "✅ GetCase returned: $RESULT"

echo "==================================="
echo " 🎉 Smoke test completed successfully!"
echo "==================================="