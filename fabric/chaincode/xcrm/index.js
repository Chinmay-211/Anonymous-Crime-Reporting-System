'use strict';

const { Contract } = require('fabric-contract-api');
const reports = require('./reporter');
const cases = require('./cases');
const evidence = require('./evidence');

class XCRMContract extends Contract {
    async submitReport(ctx, caseId, details) {
        console.log("submitReport invoked", caseId, details);
        return await reports.submitReport(ctx, caseId, details);
    }

    async getCase(ctx, caseId) {
        console.log("getCase invoked", caseId);
        return await reports.getCase(ctx, caseId);
    }

    async updateStatus(ctx, caseId, status) {
        console.log("updateStatus invoked", caseId, status);
        return await cases.updateStatus(ctx, caseId, status);
    }

    async uploadEvidence(ctx, caseId, evidenceData) {
        console.log("uploadEvidence invoked", caseId, evidenceData);
        return await evidence.uploadEvidence(ctx, caseId, evidenceData);
    }
}

module.exports.contracts = [XCRMContract];
