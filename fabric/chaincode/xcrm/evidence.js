// /fabric/chaincode/xcrm/evidence.js
// Handles evidence upload (to be stored in PDC later)

/**
 * Uploads forensic or digital evidence (PDC target: ForensicReportsCollection)
 */
async function uploadEvidence(ctx, caseId, evidence) {
    console.log(`[evidence.uploadEvidence] Called with caseId: ${caseId}`);
    return `Evidence uploaded for case ${caseId}`;
}

// Export functions for use in main contract
module.exports = {
    uploadEvidence
};