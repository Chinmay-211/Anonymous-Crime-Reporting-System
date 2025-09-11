const mockCases = require('../mocks/cases.json');

exports.getAllCases = (req, res) => {
    try {
        res.status(200).json(mockCases);
    } catch (error) {
        res.status(500).json({ message: "Failed to retrieve cases." });
    }
};