const express = require('express');
const router = express.Router();
const policeController = require('../controllers/policeController');

router.get('/cases', policeController.getAllCases);

module.exports = router;