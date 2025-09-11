// This controller handles logic for court-related endpoints.
const mockCourtCases = require('../mocks/courts.json');

/**
 * Retrieves a list of cases relevant to the courts.
 */
const getCourtCases = (req, res) => {
    try {
        // In a real app, this would fetch data from a service
        // that interacts with the Fabric ledger.
        res.status(200).json(mockCourtCases);
    } catch (error) {
        console.error("Error fetching court cases:", error);
        res.status(500).json({ message: "Failed to retrieve court cases." });
    }
};

module.exports = {
    getCourtCases
};