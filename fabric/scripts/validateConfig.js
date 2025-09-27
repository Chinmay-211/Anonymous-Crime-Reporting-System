// validateConfig.js - Configuration validation for SafeChain Fabric network
// Validates all configuration files and crypto materials

const fs = require('fs');
const path = require('path');

// Configuration paths
const FABRIC_CONFIG_PATH = path.join(__dirname, '..');
const CHAINCODE_PATH = path.join(FABRIC_CONFIG_PATH, 'chaincode', 'xcrm');

// Colors for console output
const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

function checkFile(filePath, description) {
    if (fs.existsSync(filePath)) {
        log(`✅ ${description}`, 'green');
        return true;
    } else {
        log(`❌ ${description}`, 'red');
        return false;
    }
}

function checkDirectory(dirPath, description) {
    if (fs.existsSync(dirPath) && fs.statSync(dirPath).isDirectory()) {
        log(`✅ ${description}`, 'green');
        return true;
    } else {
        log(`❌ ${description}`, 'red');
        return false;
    }
}

function validateDockerCompose() {
    log('\n🔍 Validating Docker Compose Configuration', 'blue');
    log('==========================================', 'blue');
    
    const dockerComposePath = path.join(FABRIC_CONFIG_PATH, 'docker-compose.yaml');
    if (!checkFile(dockerComposePath, 'docker-compose.yaml exists')) {
        return false;
    }
    
    try {
        const content = fs.readFileSync(dockerComposePath, 'utf8');
        
        // Check for required services
        const requiredServices = [
            'orderer.xcrm.com',
            'peer0.police.xcrm.com',
            'peer0.forensics.xcrm.com',
            'peer0.courts.xcrm.com',
            'couchdb-police',
            'couchdb-forensics',
            'couchdb-courts'
        ];
        
        let allServicesFound = true;
        for (const service of requiredServices) {
            if (content.includes(service)) {
                log(`✅ Service ${service} configured`, 'green');
            } else {
                log(`❌ Service ${service} missing`, 'red');
                allServicesFound = false;
            }
        }
        
        return allServicesFound;
    } catch (error) {
        log(`❌ Error reading docker-compose.yaml: ${error.message}`, 'red');
        return false;
    }
}

function validateChaincode() {
    log('\n🔍 Validating Chaincode Structure', 'blue');
    log('=================================', 'blue');
    
    const chaincodeFiles = [
        'index.js',
        'reporter.js',
        'cases.js',
        'evidence.js',
        'package.json'
    ];
    
    let allFilesExist = true;
    for (const file of chaincodeFiles) {
        if (!checkFile(path.join(CHAINCODE_PATH, file), `${file} exists`)) {
            allFilesExist = false;
        }
    }
    
    // Validate package.json
    const packageJsonPath = path.join(CHAINCODE_PATH, 'package.json');
    if (fs.existsSync(packageJsonPath)) {
        try {
            const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
            
            if (packageJson.dependencies && packageJson.dependencies['fabric-contract-api']) {
                log('✅ fabric-contract-api dependency found', 'green');
            } else {
                log('❌ fabric-contract-api dependency missing', 'red');
                allFilesExist = false;
            }
        } catch (error) {
            log(`❌ Error parsing package.json: ${error.message}`, 'red');
            allFilesExist = false;
        }
    }
    
    return allFilesExist;
}

function validateCryptoMaterials() {
    log('\n🔍 Validating Crypto Materials', 'blue');
    log('==============================', 'blue');
    
    const cryptoConfigPath = path.join(FABRIC_CONFIG_PATH, 'crypto-config');
    if (!checkDirectory(cryptoConfigPath, 'crypto-config directory exists')) {
        return false;
    }
    
    const organizations = [
        'ordererOrganizations/xcrm.com',
        'peerOrganizations/police.xcrm.com',
        'peerOrganizations/forensics.xcrm.com',
        'peerOrganizations/courts.xcrm.com'
    ];
    
    let allOrgsExist = true;
    for (const org of organizations) {
        const orgPath = path.join(cryptoConfigPath, org);
        if (!checkDirectory(orgPath, `Crypto materials for ${org} exist`)) {
            allOrgsExist = false;
        }
    }
    
    return allOrgsExist;
}

function validateChannelArtifacts() {
    log('\n🔍 Validating Channel Artifacts', 'blue');
    log('=================================', 'blue');
    
    const channelArtifactsPath = path.join(FABRIC_CONFIG_PATH, 'channel-artifacts');
    if (!checkDirectory(channelArtifactsPath, 'channel-artifacts directory exists')) {
        return false;
    }
    
    const artifacts = [
        'genesis.block',
        'crimechannel.tx'
    ];
    
    let allArtifactsExist = true;
    for (const artifact of artifacts) {
        if (!checkFile(path.join(channelArtifactsPath, artifact), `${artifact} exists`)) {
            allArtifactsExist = false;
        }
    }
    
    return allArtifactsExist;
}

function validateScripts() {
    log('\n🔍 Validating Scripts', 'blue');
    log('=====================', 'blue');
    
    const scriptsPath = path.join(FABRIC_CONFIG_PATH, 'scripts');
    if (!checkDirectory(scriptsPath, 'scripts directory exists')) {
        return false;
    }
    
    const scripts = [
        'deployChaincode.sh',
        'generateArtifacts.sh',
        'joinChannel.sh',
        'testInvokeQuery.sh'
    ];
    
    let allScriptsExist = true;
    for (const script of scripts) {
        if (!checkFile(path.join(scriptsPath, script), `${script} exists`)) {
            allScriptsExist = false;
        }
    }
    
    return allScriptsExist;
}

function validateChaincodeSyntax() {
    log('\n🔍 Validating Chaincode Syntax', 'blue');
    log('================================', 'blue');
    
    const chaincodeFiles = ['index.js', 'reporter.js', 'cases.js', 'evidence.js'];
    let allSyntaxValid = true;
    
    for (const file of chaincodeFiles) {
        const filePath = path.join(CHAINCODE_PATH, file);
        if (fs.existsSync(filePath)) {
            try {
                // Simple syntax check by requiring the file
                delete require.cache[require.resolve(filePath)];
                require(filePath);
                log(`✅ ${file} syntax is valid`, 'green');
            } catch (error) {
                log(`❌ ${file} syntax error: ${error.message}`, 'red');
                allSyntaxValid = false;
            }
        }
    }
    
    return allSyntaxValid;
}

async function runValidation() {
    log('🧪 SafeChain Fabric Configuration Validation', 'bright');
    log('==============================================', 'bright');
    log('');
    
    const results = {
        dockerCompose: validateDockerCompose(),
        chaincode: validateChaincode(),
        cryptoMaterials: validateCryptoMaterials(),
        channelArtifacts: validateChannelArtifacts(),
        scripts: validateScripts(),
        syntax: validateChaincodeSyntax()
    };
    
    log('\n📊 Validation Summary', 'blue');
    log('=======================', 'blue');
    
    const totalTests = Object.keys(results).length;
    const passedTests = Object.values(results).filter(Boolean).length;
    
    log(`Total tests: ${totalTests}`, 'cyan');
    log(`Passed: ${passedTests}`, 'green');
    log(`Failed: ${totalTests - passedTests}`, 'red');
    
    if (passedTests === totalTests) {
        log('\n🎉 All validations passed!', 'green');
        log('Your Fabric network is ready for deployment.', 'green');
    } else {
        log('\n⚠️  Some validations failed.', 'yellow');
        log('Please fix the issues above before proceeding.', 'yellow');
    }
    
    log('\n📝 Next Steps:', 'cyan');
    log('1. Fix any validation errors', 'cyan');
    log('2. Start Docker Desktop', 'cyan');
    log('3. Run: docker-compose up -d', 'cyan');
    log('4. Run: ./scripts/deployChaincode.sh', 'cyan');
    log('5. Run: ./scripts/testFabricNetwork.sh', 'cyan');
}

// Run validation if this file is executed directly
if (require.main === module) {
    runValidation().catch(console.error);
}

module.exports = { runValidation };
