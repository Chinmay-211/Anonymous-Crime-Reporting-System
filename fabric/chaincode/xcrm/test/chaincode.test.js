'use strict';

const { Context } = require('fabric-contract-api');
const { expect } = require('chai');
const sinon = require('sinon');

// Import your contract
const { contracts } = require('../index');
const XCRMContract = contracts[0];

describe('XCRMContract Stub Tests', () => {
    let contract, ctx;

    beforeEach(() => {
        contract = new XCRMContract();

        // Mock Fabric context
        ctx = new Context();
        ctx.stub = {
            putState: sinon.stub(),
            getState: sinon.stub(),
            deleteState: sinon.stub(),
        };
    });

    it('should submit a report', async () => {
        const result = await contract.submitReport(ctx, "CASE123", { crime: "Theft", location: "NYC" });
        expect(result).to.have.property("caseId", "CASE123");
        expect(result).to.have.property("status", "REPORTED");
        console.log("submitReport output:", result);
    });

    it('should get a case', async () => {
        const result = await contract.getCase(ctx, "CASE123");
        expect(result).to.have.property("caseId", "CASE123");
        console.log("getCase output:", result);
    });

    it('should update case status', async () => {
        const result = await contract.updateStatus(ctx, "CASE123", "INVESTIGATING");
        expect(result).to.have.property("status", "INVESTIGATING");
        console.log("updateStatus output:", result);
    });

    it('should upload evidence', async () => {
        const result = await contract.uploadEvidence(ctx, "CASE123", { type: "Image", hash: "abc123" });
        expect(result).to.have.property("evidence");
        console.log("uploadEvidence output:", result);
    });
});
