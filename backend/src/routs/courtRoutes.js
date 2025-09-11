const express = require('express');
const router = express.Router();
const courtController = require('../controllers/courtController');

router.get('/courts/cases', courtController.getCourtCases);

module.exports = router;