'use strict';

async function uploadEvidence(ctx, caseId, evidenceData) {
    console.log("uploadEvidence called with:", caseId, evidenceData);

    return {
        caseId,
        evidence: evidenceData,
        uploadedAt: new Date().toISOString()
    };
}

module.exports = { uploadEvidence };
