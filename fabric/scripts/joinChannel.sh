#!/bin/bash
# joinChannel.sh — Create and join crimechannel (TLS disabled for peers)

set -e

CHANNEL_NAME="crimechannel"
ORDERER_CA="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/ordererOrganizations/xcrm.com/orderers/orderer.xcrm.com/msp/tlscacerts/tlsca.xcrm.com-cert.pem"

echo "============================="
echo " 🚧 Creating Channel"
echo "============================="

export FABRIC_CFG_PATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric"

# Create channel — USE TLS for orderer
export CORE_PEER_TLS_ENABLED=true

export CORE_PEER_LOCALMSPID="PoliceMSP"
export CORE_PEER_ADDRESS="localhost:7051"
export CORE_PEER_TLS_ROOTCERT_FILE="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/peers/peer0.police.xcrm.com/tls/ca.crt"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/users/Admin@police.xcrm.com/msp"

peer channel create \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  -c "$CHANNEL_NAME" \
  -f "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/channel-artifacts/crimechannel.tx" \
  --tls \
  --cafile "$ORDERER_CA"
if [ $? -ne 0 ]; then
  echo "❌ Failed to create channel"
  exit 1
fi
echo "✅ Channel created: $CHANNEL_NAME.block"

echo "============================="
echo " 🔗 Joining Police Peer to Channel"
echo "============================="

# JOIN CHANNEL — DISABLE TLS for peers
export CORE_PEER_TLS_ENABLED=false

peer channel join -b "$CHANNEL_NAME.block"
if [ $? -ne 0 ]; then
  echo "❌ Failed to join channel"
  exit 1
fi
echo "✅ Police peer joined channel"

echo "============================="
echo " 🔗 Joining Forensics Peer to Channel"
echo "============================="

export CORE_PEER_LOCALMSPID="ForensicsMSP"
export CORE_PEER_ADDRESS="localhost:8051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/forensics.xcrm.com/users/Admin@forensics.xcrm.com/msp"

peer channel join -b "$CHANNEL_NAME.block"
if [ $? -ne 0 ]; then
  echo "❌ Failed to join channel"
  exit 1
fi
echo "✅ Forensics peer joined channel"

echo "============================="
echo " 🔗 Joining Courts Peer to Channel"
echo "============================="

export CORE_PEER_LOCALMSPID="CourtsMSP"
export CORE_PEER_ADDRESS="localhost:9051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/courts.xcrm.com/users/Admin@courts.xcrm.com/msp"

peer channel join -b "$CHANNEL_NAME.block"
if [ $? -ne 0 ]; then
  echo "❌ Failed to join channel"
  exit 1
fi
echo "✅ Courts peer joined channel"

echo "============================="
echo " ⚓ Updating Anchor Peers"
echo "============================="

# UPDATE ANCHOR PEERS — USE TLS for orderer
export CORE_PEER_TLS_ENABLED=true

# Police anchor peer
export CORE_PEER_LOCALMSPID="PoliceMSP"
export CORE_PEER_ADDRESS="localhost:7051"
export CORE_PEER_TLS_ROOTCERT_FILE="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/peers/peer0.police.xcrm.com/tls/ca.crt"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/users/Admin@police.xcrm.com/msp"

peer channel update \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  -c "$CHANNEL_NAME" \
  -f "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/channel-artifacts/PoliceMSPanchors.tx" \
  --tls \
  --cafile "$ORDERER_CA"
if [ $? -ne 0 ]; then
  echo "❌ Failed to update Police anchor peer"
  exit 1
fi
echo "✅ Police anchor peer updated"

# Forensics anchor peer
export CORE_PEER_LOCALMSPID="ForensicsMSP"
export CORE_PEER_ADDRESS="localhost:8051"
export CORE_PEER_TLS_ROOTCERT_FILE="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/forensics.xcrm.com/peers/peer0.forensics.xcrm.com/tls/ca.crt"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/forensics.xcrm.com/users/Admin@forensics.xcrm.com/msp"

peer channel update \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  -c "$CHANNEL_NAME" \
  -f "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/channel-artifacts/ForensicsMSPanchors.tx" \
  --tls \
  --cafile "$ORDERER_CA"
if [ $? -ne 0 ]; then
  echo "❌ Failed to update Forensics anchor peer"
  exit 1
fi
echo "✅ Forensics anchor peer updated"

# Courts anchor peer
export CORE_PEER_LOCALMSPID="CourtsMSP"
export CORE_PEER_ADDRESS="localhost:9051"
export CORE_PEER_TLS_ROOTCERT_FILE="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/courts.xcrm.com/peers/peer0.courts.xcrm.com/tls/ca.crt"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/courts.xcrm.com/users/Admin@courts.xcrm.com/msp"

peer channel update \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  -c "$CHANNEL_NAME" \
  -f "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/channel-artifacts/CourtsMSPanchors.tx" \
  --tls \
  --cafile "$ORDERER_CA"
if [ $? -ne 0 ]; then
  echo "❌ Failed to update Courts anchor peer"
  exit 1
fi
echo "✅ Courts anchor peer updated"

echo "==================================="
echo " 🎉 Channel created and joined successfully!"
echo "==================================="