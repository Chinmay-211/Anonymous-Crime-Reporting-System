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

# Set FABRIC_CFG_PATH for this session
export FABRIC_CFG_PATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric"

echo "============================="
echo " 📦 Packaging Chaincode"
echo "============================="

# Clean old package
rm -f "$PACKAGE_NAME"

# Package chaincode
peer lifecycle chaincode package "$PACKAGE_NAME" --path "$CHAINCODE_PATH" --lang node --label "${CHAINCODE_NAME}_${VERSION}"
if [ $? -ne 0 ]; then
  echo "❌ Failed to package chaincode"
  exit 1
fi
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

peer lifecycle chaincode install "$PACKAGE_NAME" --peerAddresses localhost:7051
if [ $? -ne 0 ]; then
  echo "❌ Failed to install chaincode on Police peer"
  exit 1
fi
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

peer lifecycle chaincode install "$PACKAGE_NAME" --peerAddresses localhost:8051
if [ $? -ne 0 ]; then
  echo "❌ Failed to install chaincode on Forensics peer"
  exit 1
fi
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

peer lifecycle chaincode install "$PACKAGE_NAME" --peerAddresses localhost:9051
if [ $? -ne 0 ]; then
  echo "❌ Failed to install chaincode on Courts peer"
  exit 1
fi
echo "✅ Installed on Courts peer"

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

PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq -r '.installed_chaincodes[0].package_id')
if [ -z "$PACKAGE_ID" ]; then
  echo "❌ Could not find package ID"
  exit 1
fi

peer lifecycle chaincode approveformyorg \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  --channelID "$CHANNEL_NAME" \
  --name "$CHAINCODE_NAME" \
  --version "$VERSION" \
  --package-id "$PACKAGE_ID" \
  --sequence "$SEQUENCE" \
  --peerAddresses localhost:7051
if [ $? -ne 0 ]; then
  echo "❌ Failed to approve chaincode for Police"
  exit 1
fi
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
  --channelID "$CHANNEL_NAME" \
  --name "$CHAINCODE_NAME" \
  --version "$VERSION" \
  --package-id "$PACKAGE_ID" \
  --sequence "$SEQUENCE" \
  --peerAddresses localhost:8051
if [ $? -ne 0 ]; then
  echo "❌ Failed to approve chaincode for Forensics"
  exit 1
fi
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
  --channelID "$CHANNEL_NAME" \
  --name "$CHAINCODE_NAME" \
  --version "$VERSION" \
  --package-id "$PACKAGE_ID" \
  --sequence "$SEQUENCE" \
  --peerAddresses localhost:9051
if [ $? -ne 0 ]; then
  echo "❌ Failed to approve chaincode for Courts"
  exit 1
fi
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
  --channelID "$CHANNEL_NAME" \
  --name "$CHAINCODE_NAME" \
  --version "$VERSION" \
  --sequence "$SEQUENCE" \
  --peerAddresses localhost:7051 \
  --peerAddresses localhost:8051 \
  --peerAddresses localhost:9051
if [ $? -ne 0 ]; then
  echo "❌ Failed to commit chaincode"
  exit 1
fi
echo "✅ Chaincode committed to channel $CHANNEL_NAME"

echo "==================================="
echo " 🎉 Chaincode deployed successfully!"
echo "==================================="