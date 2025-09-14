# API Specification & Contract

This document outlines the API contract for the Evidence Management System.

---
## 2. Reporter API
### Submit a new Report (FIR)
* **Endpoint:** `POST /api/report`
* **Success Response (201 Created):**
    ```json
    {
      "success": true,
      "message": "FIR has been successfully submitted...",
      "firId": "FIR-2025-09-10-a1b2c3d4",
      "trackingId": "TRACK-XYZ-789012"
    }
    ```
(And so on for the rest of the file)