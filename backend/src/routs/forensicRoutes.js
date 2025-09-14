const express = require('express');
const router = express.Router();
const forensicController = require('../controllers/forensicController');

router.get('/forensics/cases', forensicController.getForensicCases);

module.exports = router;