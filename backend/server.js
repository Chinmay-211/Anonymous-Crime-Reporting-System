// Load environment variables from a .env file if it exists
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

// --- Route Imports ---
const reportRoutes = require('../backend/src/routs/reportRoutes');
const policeRoutes = require('../backend/src/routs/policeRoutes');
const forensicRoutes = require('../backend/src/routs/forensicRoutes');
const courtRoutes = require('../backend/src/routs/courtRoutes');

// --- App Initialization ---
const app = express();

// --- Middleware ---
app.use(cors()); // Enables Cross-Origin Resource Sharing for all routes
app.use(express.json()); // Parses incoming requests with JSON payloads
app.use(morgan('dev')); // Logs HTTP requests to the console for debugging

// --- Health Check Endpoint ---
app.get('/health', (req, res) => {
    res.status(200).json({ status: "ok", timestamp: new Date().toISOString() });
});

// --- API Routes Registration ---
app.use('/api', reportRoutes);
app.use('/api', policeRoutes);
app.use('/api', forensicRoutes);
app.use('/api', courtRoutes);

// --- Server Startup ---
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});