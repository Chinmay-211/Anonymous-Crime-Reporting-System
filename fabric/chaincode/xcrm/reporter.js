'use strict';

async function submitReport(ctx, caseId, details) {
    console.log("submitReport called with:", caseId, details);

    // For now, just return a dummy JSON object
    return {
        caseId,
        details,
        status: "REPORTED",
        timestamp: new Date().toISOString()
    };
}

async function getCase(ctx, caseId) {
    console.log("getCase called with:", caseId);

    // Dummy response
    return {
        caseId,
        details: "Sample case details",
        status: "PENDING"
    };
}

module.exports = { submitReport, getCase };
