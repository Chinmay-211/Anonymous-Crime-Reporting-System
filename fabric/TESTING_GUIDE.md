# SafeChain Fabric Network Testing Guide

This guide provides step-by-step instructions for testing the SafeChain Fabric network.

## Prerequisites

1. **Docker Desktop** - Must be installed and running
2. **Hyperledger Fabric Binaries** - peer, orderer, configtxgen, cryptogen
3. **jq** - JSON processor (for script parsing)

## Quick Start Testing

### Step 1: Start Docker Desktop
1. Open Docker Desktop application
2. Wait for it to fully start (green icon in system tray)
3. Verify with: `docker ps`

### Step 2: Start Fabric Network
```bash
cd fabric
docker-compose up -d
```

Wait for all containers to start (should see 7 containers):
- orderer.xcrm.com
- peer0.police.xcrm.com
- peer0.forensics.xcrm.com
- peer0.courts.xcrm.com
- couchdb-police
- couchdb-forensics
- couchdb-courts

### Step 3: Run Comprehensive Test

**For Linux/Mac:**
```bash
chmod +x scripts/testFabricNetwork.sh
./scripts/testFabricNetwork.sh
```

**For Windows:**
```cmd
scripts\testFabricNetwork.bat
```

## Manual Testing Steps

If you prefer to test manually, follow these steps:

### 1. Verify Network Status
```bash
# Check Docker containers
docker ps

# Check network connectivity
docker exec orderer.xcrm.com peer version
docker exec peer0.police.xcrm.com peer version
docker exec peer0.forensics.xcrm.com peer version
docker exec peer0.courts.xcrm.com peer version
```

### 2. Check Channel Status
```bash
# Set environment for Police peer
export CORE_PEER_LOCALMSPID="PoliceMSP"
export CORE_PEER_ADDRESS="localhost:7051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/police.xcrm.com/users/Admin@police.xcrm.com/msp"
export CORE_PEER_TLS_ENABLED=false

# List channels
peer channel list
```

### 3. Deploy Chaincode (if not already deployed)
```bash
# Run the deployment script
./scripts/deployChaincode.sh
```

### 4. Test Chaincode Functions

#### Test SubmitReport
```bash
peer chaincode invoke \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  --tls \
  --tlsRootCertFiles "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/ordererOrganizations/xcrm.com/orderers/orderer.xcrm.com/tls/ca.crt" \
  -C crimechannel \
  -n xcrm \
  --peerAddresses localhost:7051 \
  -c '{"function":"SubmitReport","Args":["CASE-001", "{\"victim\": \"John Doe\", \"narrative\": \"Robbery at Main St\"}"]}' \
  --waitForEvent
```

#### Test GetCase
```bash
peer chaincode query \
  -C crimechannel \
  -n xcrm \
  -c '{"function":"GetCase","Args":["CASE-001"]}'
```

#### Test UpdateStatus
```bash
peer chaincode invoke \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  --tls \
  --tlsRootCertFiles "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/ordererOrganizations/xcrm.com/orderers/orderer.xcrm.com/tls/ca.crt" \
  -C crimechannel \
  -n xcrm \
  --peerAddresses localhost:7051 \
  -c '{"function":"UpdateStatus","Args":["CASE-001", "Under Investigation"]}' \
  --waitForEvent
```

#### Test UploadEvidence
```bash
peer chaincode invoke \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.xcrm.com \
  --tls \
  --tlsRootCertFiles "C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/ordererOrganizations/xcrm.com/orderers/orderer.xcrm.com/tls/ca.crt" \
  -C crimechannel \
  -n xcrm \
  --peerAddresses localhost:7051 \
  -c '{"function":"UploadEvidence","Args":["CASE-001", "Evidence data"]}' \
  --waitForEvent
```

### 5. Test Cross-Organization Access

#### Test from Forensics
```bash
export CORE_PEER_LOCALMSPID="ForensicsMSP"
export CORE_PEER_ADDRESS="localhost:8051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/forensics.xcrm.com/users/Admin@forensics.xcrm.com/msp"

peer chaincode query \
  -C crimechannel \
  -n xcrm \
  -c '{"function":"GetCase","Args":["CASE-001"]}'
```

#### Test from Courts
```bash
export CORE_PEER_LOCALMSPID="CourtsMSP"
export CORE_PEER_ADDRESS="localhost:9051"
export CORE_PEER_MSPCONFIGPATH="C:/Users/DYNAMIC/Desktop/DYNAMIC/Projects/Anonymous-Crime-Reporting-System/SafeChain/fabric/crypto-config/peerOrganizations/courts.xcrm.com/users/Admin@courts.xcrm.com/msp"

peer chaincode query \
  -C crimechannel \
  -n xcrm \
  -c '{"function":"GetCase","Args":["CASE-001"]}'
```

## Troubleshooting

### Common Issues

1. **Docker not running**
   - Start Docker Desktop
   - Wait for it to fully initialize

2. **Containers not starting**
   - Check Docker logs: `docker-compose logs`
   - Restart network: `docker-compose down && docker-compose up -d`

3. **Channel not found**
   - Channel may need to be created
   - Check if channel creation scripts exist

4. **Chaincode not installed**
   - Run `./scripts/deployChaincode.sh`
   - Check for errors in deployment logs

5. **Permission errors**
   - Ensure you're running from the correct directory
   - Check file paths in scripts

### Debug Commands

```bash
# Check container logs
docker logs orderer.xcrm.com
docker logs peer0.police.xcrm.com
docker logs peer0.forensics.xcrm.com
docker logs peer0.courts.xcrm.com

# Check network status
docker network ls
docker network inspect fabric_xcrm-network

# Check volumes
docker volume ls
```

## Expected Results

### Successful Test Output
- ✅ Docker is running
- ✅ Fabric containers are running
- ✅ Orderer is accessible
- ✅ All peers are accessible
- ✅ Channel exists
- ✅ Chaincode is installed and committed
- ✅ All chaincode functions work
- ✅ Cross-organization access works

### Test Data
The test creates a case with ID `TEST-CASE-<timestamp>` and tests all functions with this case.

## Next Steps

After successful testing:
1. Integrate with backend API
2. Implement PDC (Private Data Collections)
3. Add more sophisticated chaincode logic
4. Implement proper error handling
5. Add performance testing
