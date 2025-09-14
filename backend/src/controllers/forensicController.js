const mockForensicCases = require('../mocks/forensics.json');

exports.getForensicCases = (req, res) => {
    try {
        res.status(200).json(mockForensicCases);
    } catch (error) {
        res.status(500).json({ message: "Failed to retrieve forensic cases." });
    }
};