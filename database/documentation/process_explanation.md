Business Process Explanation
Process Name: Automated Medicine Dispensing & Inventory Tracking Department: Pharmacy / Inventory Management

1. Process Overview
This process models the lifecycle of a medication transaction within the health clinic, from the moment a patient presents a prescription to the final adjustment of inventory levels. The goal is to replace error-prone manual logs with an automated PL/SQL-driven system that ensures accuracy, safety, and accountability.

2. Key Actors & Responsibilities
Pharmacist (User): Initiates the dispensing request and validates the patient prescription physically.

Clinic Database (System): Automatically checks stock availability, enforces security rules (e.g., weekend-only updates), and logs transactions.

Administrator: Manages master data (adding new medicines or setting prices) under strict time-based security protocols.

3. Workflow Description
The process follows these logical steps, as depicted in the BPMN diagram:

Request Initiation: The Pharmacist inputs the Medicine ID and Quantity required for a patient.

Automated Validation (PL/SQL):

The system executes the check_stock_status function.

Decision Point: If stock is < 20, a warning is flagged. If stock is insufficient, the transaction is blocked immediately.

Transaction Execution:

If validation passes, the dispense_medicine procedure is triggered.

Atomic Action: The system simultaneously deducts the quantity from the STOCK_LEVEL table and inserts a record into the USAGE_LOG table.

Completion & Feedback: The system returns a success message to the Pharmacist, confirming the new stock level.

4. MIS Functions & Organizational Impact
This system supports critical Management Information System (MIS) functions:

Operational Control: Prevents dispensing expired or out-of-stock medication, ensuring patient safety.

Management Control: The "Weekend-Only" trigger (trg_medicine_security) prevents unauthorized data manipulation during busy weekdays, ensuring data integrity.

Strategic Planning: The Audit Log (ACCESS_AUDIT_LOG) provides top management with visibility into system usage and potential security breaches.

5. Analytics Opportunities
By centralizing data in the USAGE_LOG, the clinic enables advanced Business Intelligence:

Predictive Supply Chain: Using the predict_days_remaining function, procurement can order stock before it runs out.

Trend Analysis: The analyze_usage_growth window function helps identify disease outbreaks (e.g., a spike in Malaria medication usage) in real-time.