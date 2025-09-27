# SafeChain Fabric Network Health Check Guide

This guide helps you verify if your Fabric network is working correctly.

## 🚀 Quick Health Check

### Option 1: Automated Diagnostic
```cmd
cd fabric\scripts
.\diagnoseFabric.bat
```

### Option 2: Quick Check
```cmd
cd fabric\scripts
.\quickHealthCheck.bat
```

## 🔍 Manual Health Check Steps

### Step 1: Check Docker Status
```cmd
docker --version
docker ps
```
**Expected:** Docker version info and running containers

### Step 2: Check Fabric Containers
```cmd
docker ps --filter "name=peer0|orderer|couchdb"
```
**Expected:** 7 containers running:
- orderer.xcrm.com
- peer0.police.xcrm.com
- peer0.forensics.xcrm.com
- peer0.courts.xcrm.com
- couchdb-police
- couchdb-forensics
- couchdb-courts

### Step 3: Test Container Connectivity
```cmd
docker exec orderer.xcrm.com peer version
docker exec peer0.police.xcrm.com peer version
docker exec peer0.forensics.xcrm.com peer version
docker exec peer0.courts.xcrm.com peer version
```
**Expected:** Version information from each peer

### Step 4: Check Channel Status
```cmd
set CORE_PEER_LOCALMSPID=PoliceMSP
set CORE_PEER_ADDRESS=localhost:7051
set CORE_PEER_MSPCONFIGPATH=C:\Users\DYNAMIC\Desktop\DYNAMIC\Projects\Anonymous-Crime-Reporting-System\SafeChain\fabric\crypto-config\peerOrganizations\police.xcrm.com\users\Admin@police.xcrm.com\msp
set CORE_PEER_TLS_ENABLED=false

peer channel list
```
**Expected:** Shows "crimechannel" in the list

### Step 5: Check Chaincode Status
```cmd
peer lifecycle chaincode queryinstalled
peer lifecycle chaincode querycommitted --channelID crimechannel
```
**Expected:** Shows xcrm chaincode installed and committed

### Step 6: Test Chaincode Functions
```cmd
peer chaincode query -C crimechannel -n xcrm -c "{\"function\":\"GetCase\",\"Args\":[\"TEST-001\"]}"
```
**Expected:** Returns case data or appropriate response

## 🚨 Common Issues & Solutions

### Issue 1: Docker Not Running
**Symptoms:** `docker ps` fails
**Solution:** 
1. Start Docker Desktop
2. Wait for it to fully initialize
3. Try again

### Issue 2: Containers Not Starting
**Symptoms:** Missing containers in `docker ps`
**Solution:**
```cmd
cd fabric
docker-compose down
docker-compose up -d
```

### Issue 3: Channel Not Found
**Symptoms:** `peer channel list` shows no channels
**Solution:**
1. Check if channel creation scripts exist
2. Run channel creation scripts
3. Verify channel artifacts exist

### Issue 4: Chaincode Not Installed
**Symptoms:** `peer lifecycle chaincode queryinstalled` shows no chaincode
**Solution:**
```cmd
.\scripts\deployChaincode.sh
```

### Issue 5: Chaincode Functions Failing
**Symptoms:** Chaincode queries/invocations fail
**Solution:**
1. Check chaincode is committed to channel
2. Verify function names and parameters
3. Check container logs for errors

## 📊 Health Check Results

### ✅ Healthy Network Indicators:
- All 7 containers running
- Orderer responding to version queries
- Peers responding to version queries
- Channel exists and is accessible
- Chaincode is installed and committed
- Chaincode functions work
- Cross-organization access works

### ❌ Unhealthy Network Indicators:
- Missing containers
- Containers not responding
- Channel not found
- Chaincode not installed/committed
- Function calls failing
- Permission errors

## 🔧 Troubleshooting Commands

### Check Container Logs
```cmd
docker logs orderer.xcrm.com
docker logs peer0.police.xcrm.com
docker logs peer0.forensics.xcrm.com
docker logs peer0.courts.xcrm.com
```

### Restart Network
```cmd
cd fabric
docker-compose down
docker-compose up -d
```

### Check Network Status
```cmd
docker network ls
docker network inspect fabric_xcrm-network
```

### Check Volumes
```cmd
docker volume ls
```

## 📝 Health Check Checklist

- [ ] Docker Desktop is running
- [ ] All 7 containers are running
- [ ] Orderer is accessible
- [ ] All peers are accessible
- [ ] Channel exists
- [ ] Chaincode is installed
- [ ] Chaincode is committed
- [ ] Chaincode functions work
- [ ] Cross-organization access works
- [ ] No error logs in containers

## 🎯 Performance Indicators

### Good Performance:
- Container startup time < 30 seconds
- Peer version queries respond < 5 seconds
- Chaincode queries respond < 10 seconds
- No memory/CPU warnings in logs

### Poor Performance:
- Container startup time > 2 minutes
- Slow or failed peer responses
- High memory usage
- Frequent container restarts

## 📞 Getting Help

If issues persist:
1. Run the full diagnostic: `.\diagnoseFabric.bat`
2. Check container logs for specific errors
3. Verify all configuration files exist
4. Ensure crypto materials are properly generated
5. Check Docker Desktop resources (CPU/Memory)

## 🚀 Next Steps After Health Check

Once your network is healthy:
1. Deploy chaincode: `.\scripts\deployChaincode.sh`
2. Run comprehensive tests: `.\scripts\testFabricNetwork.bat`
3. Integrate with backend API
4. Monitor network performance
5. Set up automated health checks
