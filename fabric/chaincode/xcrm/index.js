// /fabric/chaincode/xcrm/index.js
// Main contract entry point — delegates to modular logic files

'use strict';

const { Contract } = require('fabric-contract-api');

// Import modular logic
const reports = require('./reporter');
const cases = require('./cases');
const evidence = require('./evidence');

/**
 * XCRMContract - Cross-Blockchain Crime Management System
 * Delegates all logic to modular files for scalability and separation of concerns.
 */
class XCRMContract extends Contract {

    async SubmitReport(ctx, caseId, details) {
        return await reports.submitReport(ctx, caseId, details);
    }

    async GetCase(ctx, caseId) {
        return await reports.getCase(ctx, caseId);
    }

    async UpdateStatus(ctx, caseId, status) {
        return await cases.updateStatus(ctx, caseId, status);
    }

    async UploadEvidence(ctx, caseId, evidence) {
        return await evidence.uploadEvidence(ctx, caseId, evidence);
    }

}

// Export for Fabric lifecycle
module.exports = XCRMContract;