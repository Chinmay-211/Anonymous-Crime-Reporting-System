#!/bin/bash
# deployChaincode.sh — Windows-ready, NO TLS for peers (dev), TLS for orderer
# Packages, installs, approves, and commits xcrm chaincode

set -e

# === CONFIG ===
CHANNEL_NAME="crimechannel"
CHAINCODE_NAME="xcrm"
VERSION="1.8"           # Bumped to avoid conflicts
SEQUENCE="1"            # Start fresh
CHAINCODE_PATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/chaincode/xcrm"
PACKAGE_NAME="./${CHAINCODE_NAME}_${VERSION}.tar.gz"

# Orderer TLS root cert file path
ORDERER_TLS_ROOTCERT="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/ordererOrganizations/xcrm.com/orderers/orderer.xcrm.com/tls/ca.crt"

# Set FABRIC_CFG_PATH for this session
export FABRIC_CFG_PATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric"

echo "============================="
echo " 📦 Packaging Chaincode"
echo "============================="

# Clean old package
rm -f "$PACKAGE_NAME"

# Package chaincode
peer lifecycle chaincode package "$PACKAGE_NAME" --path "$CHAINCODE_PATH" --lang node --label "${CHAINCODE_NAME}_${VERSION}"
echo "✅ Chaincode packaged: $PACKAGE_NAME"

# =============================
# Install on Police Peer — NO TLS
# =============================
echo "============================="
echo " ⚙️ Installing Chaincode on Police Peer"
echo "============================="

export CORE_PEER_LOCALMSPID="PoliceMSP"
export CORE_PEER_ADDRESS="localhost:7051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/users/Admin@police.xcrm.com/msp"
export CORE_PEER_TLS_ENABLED=false

peer lifecycle chaincode install "$PACKAGE_NAME"
echo "✅ Installed on Police peer"

# =============================
# Install on Forensics Peer — NO TLS
# =============================
echo "============================="
echo " ⚙️ Installing Chaincode on Forensics Peer"
echo "============================="

export CORE_PEER_LOCALMSPID="ForensicsMSP"
export CORE_PEER_ADDRESS="localhost:8051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/forensics.xcrm.com/users/Admin@forensics.xcrm.com/msp"
export CORE_PEER_TLS_ENABLED=false

peer lifecycle chaincode install "$PACKAGE_NAME"
echo "✅ Installed on Forensics peer"

# =============================
# Install on Courts Peer — NO TLS
# =============================
echo "============================="
echo " ⚙️ Installing Chaincode on Courts Peer"
echo "============================="

export CORE_PEER_LOCALMSPID="CourtsMSP"
export CORE_PEER_ADDRESS="localhost:9051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/courts.xcrm.com/users/Admin@courts.xcrm.com/msp"
export CORE_PEER_TLS_ENABLED=false

peer lifecycle chaincode install "$PACKAGE_NAME"
echo "✅ Installed on Courts peer"

# =============================
# Extract Package ID for approval
# =============================
echo "============================="
echo " 🔍 Querying installed chaincodes to get package ID"
echo "============================="

PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r --arg LABEL "${CHAINCODE_NAME}_${VERSION}" '.installed_chaincodes[] | select(.label == $LABEL) | .package_id')

if [ -z "$PACKAGE_ID" ]; then
  echo "❌ Could not find package ID for label ${CHAINCODE_NAME}_${VERSION}"
  exit 1
fi
echo "✅ Found package ID: $PACKAGE_ID"

# =============================
# Approve for Police — NO TLS for peer, TLS for orderer
# =============================
echo "============================="
echo " ✅ Approving Chaincode Definition — Police"
echo "============================="

export CORE_PEER_LOCALMSPID="PoliceMSP"
export CORE_PEER_ADDRESS="localhost:7051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/users/Admin@police.xcrm.com/msp"
export CORE_PEER_TLS_ENABLED=false

peer lifecycle chaincode approveformyorg \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  --tls \
  --tlsRootCertFiles "$ORDERER_TLS_ROOTCERT" \
  --channelID "$CHANNEL_NAME" \
  --name "$CHAINCODE_NAME" \
  --version "$VERSION" \
  --package-id "$PACKAGE_ID" \
  --sequence "$SEQUENCE" \
  --peerAddresses localhost:7051
echo "✅ Approved by Police"

# =============================
# Approve for Forensics — NO TLS for peer, TLS for orderer
# =============================
echo "============================="
echo " ✅ Approving Chaincode Definition — Forensics"
echo "============================="

export CORE_PEER_LOCALMSPID="ForensicsMSP"
export CORE_PEER_ADDRESS="localhost:8051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/forensics.xcrm.com/users/Admin@forensics.xcrm.com/msp"
export CORE_PEER_TLS_ENABLED=false

peer lifecycle chaincode approveformyorg \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  --tls \
  --tlsRootCertFiles "$ORDERER_TLS_ROOTCERT" \
  --channelID "$CHANNEL_NAME" \
  --name "$CHAINCODE_NAME" \
  --version "$VERSION" \
  --package-id "$PACKAGE_ID" \
  --sequence "$SEQUENCE" \
  --peerAddresses localhost:8051
echo "✅ Approved by Forensics"

# =============================
# Approve for Courts — NO TLS for peer, TLS for orderer
# =============================
echo "============================="
echo " ✅ Approving Chaincode Definition — Courts"
echo "============================="

export CORE_PEER_LOCALMSPID="CourtsMSP"
export CORE_PEER_ADDRESS="localhost:9051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/courts.xcrm.com/users/Admin@courts.xcrm.com/msp"
export CORE_PEER_TLS_ENABLED=false

peer lifecycle chaincode approveformyorg \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  --tls \
  --tlsRootCertFiles "$ORDERER_TLS_ROOTCERT" \
  --channelID "$CHANNEL_NAME" \
  --name "$CHAINCODE_NAME" \
  --version "$VERSION" \
  --package-id "$PACKAGE_ID" \
  --sequence "$SEQUENCE" \
  --peerAddresses localhost:9051
echo "✅ Approved by Courts"

# =============================
# Commit Chaincode — NO TLS for peers, TLS for orderer
# =============================
echo "============================="
echo " 🚀 Committing Chaincode to Channel"
echo "============================="

export CORE_PEER_LOCALMSPID="PoliceMSP"
export CORE_PEER_ADDRESS="localhost:7051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/users/Admin@police.xcrm.com/msp"
export CORE_PEER_TLS_ENABLED=false

peer lifecycle chaincode commit \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  --tls \
  --tlsRootCertFiles "$ORDERER_TLS_ROOTCERT" \
  --channelID "$CHANNEL_NAME" \
  --name "$CHAINCODE_NAME" \
  --version "$VERSION" \
  --sequence "$SEQUENCE" \
  --peerAddresses localhost:7051 \
  --peerAddresses localhost:8051 \
  --peerAddresses localhost:9051
echo "✅ Chaincode committed to channel $CHANNEL_NAME"

echo "==================================="
echo " 🎉 Chaincode deployed successfully!"
echo "==================================="