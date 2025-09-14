// /fabric/chaincode/xcrm/cases.js
// Handles investigation status updates

/**
 * Updates the status of a case (e.g., "Under Investigation", "Closed")
 */
async function updateStatus(ctx, caseId, status) {
    console.log(`[cases.updateStatus] Called with caseId: ${caseId}, new status: ${status}`);
    return `Status updated for case ${caseId} to: ${status}`;
}

// Export functions for use in main contract
module.exports = {
    updateStatus
};