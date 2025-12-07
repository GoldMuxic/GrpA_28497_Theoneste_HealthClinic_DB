# Health Clinic Medicine Management System

**Student:** Bahati Theoneste
**ID:** 28497
**Group:** A (Monday)
**Course:** INSY 8311 - PL/SQL Database Development
**Lecturer:** Eric Maniraguha (`eric.maniraguha@auca.ac.rw`)
**Institution:** Adventist University of Central Africa (AUCA)

---

## 1. Project Overview
### **Problem Statement**
The clinic previously relied on manual record-keeping for medicine inventory, leading to critical issues such as:
* **Stockouts:** Essential medicines running out without warning.
* **Expired Medication:** Batches expiring unnoticed, posing patient safety risks.
* **Security Gaps:** Unrestricted access allowing unauthorized staff to alter prices or stock levels at any time.

### **Solution**
This project delivers a **secure, automated PL/SQL database solution** that transforms inventory management. It features real-time stock deduction, predictive analytics for supply planning, and a strict "Weekend-Only" security protocol for administrative updates.

---

## 2. Technical Architecture
* **Database Engine:** Oracle Database 23ai / 19c (Pluggable Database Architecture).
* **Schema Owner:** `ADMIN_28497`
* **Storage:** Custom Tablespaces (`TBS_CLINIC_DATA`, `TBS_CLINIC_IDX`) for optimized performance.
* **Core Logic:**
    * **Packages:** `pkg_clinic_management` (Encapsulated business logic).
    * **Triggers:** Compound triggers for security and autonomous transactions for auditing.
    * **Analytics:** Window Functions (`RANK`, `LAG`) for trend analysis.

---

## 3. Quick Start Guide
To deploy this project, execute the scripts in the `database/scripts/` folder in the following strict order:

1.  **`01_infrastructure.sql`**: Creates the PDB, Tablespaces, and Admin User.
2.  **`02_tables.sql`**: Creates 3NF tables (`MEDICINE`, `STOCK_LEVEL`, `USAGE_LOG`) and populates 50+ test records.
3.  **`03_plsql_logic.sql`**: Compiles the `pkg_clinic_management` package containing all Procedures and Functions.
4.  **`04_triggers.sql`**: Activates the Security Compound Trigger and Holiday Management system.

---

## 4. Key Features & Testing Results
The system has been rigorously tested to ensure data integrity and security compliance.

| Feature | Description | Status |
| :--- | :--- | :--- |
| **Transaction Management** | `dispense_medicine` procedure atomically updates stock and logs usage, rolling back on errors. | ✅ **Passed** |
| **Predictive Analytics** | `predict_days_remaining` function calculates exactly when stock will run out based on daily usage averages. | ✅ **Passed** |
| **Security Rules** | **CRITICAL:** Updates are strictly **BLOCKED** on Weekdays (Mon-Fri) and Public Holidays using a Compound Trigger. | ✅ **Passed** |
| **Auditing** | Autonomous transactions log every access attempt (Allowed or Denied) to `ACCESS_AUDIT_LOG`. | ✅ **Passed** |
| **Business Intelligence** | `analyze_usage_growth` uses `LAG()` to determine if medicine consumption is "Increasing" or "Declining". | ✅ **Passed** |

---

## 5. Documentation Links
* **[Business Process Model (BPMN)](database/documentation/GrpA_28497_Theoneste_HealthClinic_BPMN.png):** Visual workflow of the dispensing process.
* **[Entity Relationship Diagram (ERD)](database/documentation/GrpA_28497_Theoneste_HealthClinic_ERD.png):** Database schema and relationships.
* **[Data Dictionary](database/documentation/data_dictionary.md):** Detailed definition of all tables, columns, and constraints.

---

## 6. Innovation & Complexity (Bonus Features)
This project exceeds standard requirements by implementing **Predictive Intelligence** rather than just passive storage:

1.  **Smart Stock Prediction:** Unlike basic systems that just say "Low Stock," this system uses the `predict_days_remaining` function. It calculates the **average daily consumption** to tell the pharmacist *exactly* how many days the current supply will last (e.g., *"Enough for 4.5 days"*).
2.  **Trend Analysis via Window Functions:** The system uses `LAG()` and `RANK()` functions to analyze usage trends over time, automatically flagging if a medicine's usage is "Growing" (potential outbreak) or "Declining."
3.  **Resilient Security Architecture:** The implementation of **Autonomous Transactions** in the audit log ensures that security violations are recorded *even if* the unauthorized transaction itself is rolled back/blocked.

---

