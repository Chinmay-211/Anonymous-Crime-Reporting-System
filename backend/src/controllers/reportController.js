// This controller handles logic for report submission endpoints.
const mockResponse = require('../mocks/report-response.json');

/**
 * Handles the submission of a new report (FIR).
 */
const submitReport = (req, res) => {
    try {
        console.log("Received a new report submission:", req.body);
        // In a real app, this would call a service to interact with Fabric.
        res.status(201).json({
            ...mockResponse,
            submittedAt: new Date().toISOString()
        });
    } catch (error) {
        console.error("Error submitting report:", error);
        res.status(500).json({ message: "An error occurred while submitting the report." });
    }
};

module.exports = {
    submitReport
};
