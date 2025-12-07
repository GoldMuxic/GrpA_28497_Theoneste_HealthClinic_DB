SET SERVEROUTPUT ON;

-- ---------------------------------------------------------
-- TEST 1: Check Stock Status (Function)
-- ---------------------------------------------------------
-- Should return 'OK', 'WARNING', or 'CRITICAL'
SELECT pkg_clinic_management.check_stock_status(101) AS status_med_101 FROM DUAL;
SELECT pkg_clinic_management.check_stock_status(103) AS status_med_103 FROM DUAL; -- (Low stock item)

-- ---------------------------------------------------------
-- TEST 2: Dispense Medicine (Procedure + Transaction)
-- ---------------------------------------------------------
-- Should say "Success: Dispensed 5 units..."
EXEC pkg_clinic_management.dispense_medicine(101, 5, 'Patient: John Doe');

-- ---------------------------------------------------------
-- TEST 3: Restock with OUT Parameter
-- ---------------------------------------------------------
-- This tests the specific "IN/OUT" requirement
VAR new_stock_count NUMBER;
EXEC pkg_clinic_management.restock_medicine(101, 20, :new_stock_count);
PRINT new_stock_count;

-- ---------------------------------------------------------
-- TEST 4: Advanced Analytics (Window Functions)
-- ---------------------------------------------------------
-- Test RANK (Most expensive medicine in category)
SELECT medicine_id, category, unit_price, 
       pkg_clinic_management.get_category_rank(medicine_id) AS price_rank
FROM MEDICINE
WHERE medicine_id IN (101, 103);

-- Test LAG (Growth Analysis - Run dispense twice to see change)
EXEC pkg_clinic_management.dispense_medicine(101, 10, 'Patient: Jane Doe'); 
SELECT pkg_clinic_management.analyze_usage_growth(101) AS usage_trend FROM DUAL;

-- ---------------------------------------------------------
-- TEST 5: Error Handling & Logging (IMPORTANT)
-- ---------------------------------------------------------
-- Force an error by asking for too much medicine (1000 units)
EXEC pkg_clinic_management.dispense_medicine(103, 1000, 'Greedy Patient');

-- Prove that the error was logged in the table
SELECT * FROM ERROR_LOG;

-- ---------------------------------------------------------
-- TEST 6: Explicit Cursor Report
-- ---------------------------------------------------------
EXEC pkg_clinic_management.generate_expiry_report;