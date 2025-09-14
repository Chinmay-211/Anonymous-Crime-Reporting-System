#!/bin/bash
# generateArtifacts.sh — Generates crypto material, genesis block, and channel config for xCRM
# Assumes crypto-config.yaml and configtx.yaml are in current or config directory.
# Outputs all artifacts to /fabric/channel-artifacts/

set -e

echo "============================="
echo " 🚀 Generating Crypto Material"
echo "============================="

# Create output directory if not exists
mkdir -p /fabric/channel-artifacts

# Generate crypto material for Orderer + 3 Orgs
cryptogen generate --config=./crypto-config.yaml --output=/fabric/crypto-config
if [ $? -ne 0 ]; then
  echo "❌ Failed to generate crypto material"
  exit 1
fi
echo "✅ Crypto material generated in /fabric/crypto-config"

echo "============================="
echo " 🧱 Generating Genesis Block"
echo "============================="

# Generate genesis block for system channel
configtxgen -profile OrdererGenesis \
            -channelID system-channel \
            -outputBlock /fabric/channel-artifacts/genesis.block
if [ $? -ne  0 ]; then
  echo "❌ Failed to generate genesis.block"
  exit 1
fi
echo "✅ Genesis block created: /fabric/channel-artifacts/genesis.block"

echo "============================="
echo " 📄 Generating Channel Tx"
echo "============================="

# Generate channel creation transaction
configtxgen -profile CrimeChannel \
            -channelID crimechannel \
            -outputCreateChannelTx /fabric/channel-artifacts/crimechannel.tx
if [ $? -ne 0 ]; then
  echo "❌ Failed to generate crimechannel.tx"
  exit 1
fi
echo "✅ Channel transaction created: /fabric/channel-artifacts/crimechannel.tx"

echo "============================="
echo " ⚓ Generating Anchor Peer Updates"
echo "============================="

# Generate anchor peer update for PoliceOrg
configtxgen -profile CrimeChannel \
            -channelID crimechannel \
            -asOrg PoliceOrg \
            -outputAnchorPeersUpdate /fabric/channel-artifacts/PoliceMSPanchors.tx
if [ $? -ne 0 ]; then
  echo "❌ Failed to generate Police anchor update"
  exit 1
fi
echo "✅ Police anchor peers update: /fabric/channel-artifacts/PoliceMSPanchors.tx"

# Generate anchor peer update for ForensicsOrg
configtxgen -profile CrimeChannel \
            -channelID crimechannel \
            -asOrg ForensicsOrg \
            -outputAnchorPeersUpdate /fabric/channel-artifacts/ForensicsMSPanchors.tx
if [ $? -ne 0 ]; then
  echo "❌ Failed to generate Forensics anchor update"
  exit 1
fi
echo "✅ Forensics anchor peers update: /fabric/channel-artifacts/ForensicsMSPanchors.tx"

# Generate anchor peer update for CourtsOrg
configtxgen -profile CrimeChannel \
            -channelID crimechannel \
            -asOrg CourtsOrg \
            -outputAnchorPeersUpdate /fabric/channel-artifacts/CourtsMSPanchors.tx
if [ $? -ne 0 ]; then
  echo "❌ Failed to generate Courts anchor update"
  exit 1
fi
echo "✅ Courts anchor peers update: /fabric/channel-artifacts/CourtsMSPanchors.tx"

echo "==================================="
echo " 🎉 All artifacts generated successfully!"
echo "==================================="