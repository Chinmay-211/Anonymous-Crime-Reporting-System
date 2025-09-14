#!/bin/bash
# joinExistingChannel.sh — Join peers to existing crimechannel

set -e

CHANNEL_NAME="crimechannel"

echo "============================="
echo " 🔗 Joining Police Peer to Channel"
echo "============================="

export FABRIC_CFG_PATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric"
export CORE_PEER_TLS_ENABLED=false

export CORE_PEER_LOCALMSPID="PoliceMSP"
export CORE_PEER_ADDRESS="localhost:7051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/users/Admin@police.xcrm.com/msp"

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

echo "==================================="
echo " 🎉 Peers joined channel successfully!"
echo "==================================="