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
