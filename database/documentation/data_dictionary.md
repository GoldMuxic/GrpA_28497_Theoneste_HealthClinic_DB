# Data Dictionary

## 1. MEDICINE Table
*Stores static details about drugs.*

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **MEDICINE_ID** | NUMBER(10) | PK, NOT NULL | Unique identifier for each medicine type. |
| **NAME** | VARCHAR2(100) | NOT NULL | The commercial name of the medication. |
| **CATEGORY** | VARCHAR2(50) | None | Classification (e.g., Antibiotic, Painkiller). |
| **UNIT_PRICE** | NUMBER(10,2) | None | Cost per unit (RWF). |
| **EXPIRY_DATE** | DATE | NOT NULL | Date when the batch expires. |
| **BATCH_NO** | VARCHAR2(50) | UNIQUE | Manufacturer batch number for tracking. |

## 2. STOCK_LEVEL Table
*Tracks current inventory quantity.*

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **STOCK_ID** | NUMBER(10) | PK, NOT NULL | Unique ID for stock records. |
| **MEDICINE_ID** | NUMBER(10) | FK | Links to MEDICINE table. |
| **QUANTITY_AVAILABLE** | NUMBER(10) | CHECK (>= 0) | Current count. Cannot be negative. |
| **LAST_UPDATED** | DATE | DEFAULT SYSDATE | Timestamp of last stock change. |

## 3. USAGE_LOG Table
*Records every time medicine is dispensed.*

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **LOG_ID** | NUMBER(10) | PK, NOT NULL | Unique transaction ID. |
| **MEDICINE_ID** | NUMBER(10) | FK | Identifies medicine dispensed. |
| **QUANTITY_USED** | NUMBER(10) | NOT NULL | Amount dispensed. |
| **USAGE_DATE** | DATE | DEFAULT SYSDATE | Exact time of dispensing. |
| **PATIENT_REFERENCE** | VARCHAR2(50) | None | Anonymized patient ID/Name. |

## 4. PUBLIC_HOLIDAYS Table
*Manages dates when modifications are blocked.*

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **HOLIDAY_DATE** | DATE | PK | The specific date of the holiday. |
| **DESCRIPTION** | VARCHAR2(100) | None | Name of the holiday (e.g., Christmas). |

## 5. ACCESS_AUDIT_LOG Table
*Security audit trail for allowed/denied actions.*

| Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| **LOG_ID** | NUMBER | PK | Auto-generated ID. |
| **DB_USER** | VARCHAR2(50) | None | Database user who attempted action. |
| **ACTION_TYPE** | VARCHAR2(20) | None | INSERT, UPDATE, or DELETE. |
| **STATUS** | VARCHAR2(10) | None | 'ALLOWED' or 'DENIED'. |
| **MESSAGE** | VARCHAR2(255) | None | Reason for block or success message. |