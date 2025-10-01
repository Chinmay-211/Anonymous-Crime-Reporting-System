'use strict';

async function updateStatus(ctx, caseId, status) {
    console.log("updateStatus called with:", caseId, status);

    return {
        caseId,
        status,
        updatedAt: new Date().toISOString()
    };
}

module.exports = { updateStatus };
