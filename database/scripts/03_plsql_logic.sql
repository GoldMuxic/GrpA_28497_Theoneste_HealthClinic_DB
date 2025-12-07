/* -------------------------------------------------------------------------
   SCRIPT: plsql_logic.sql
   PHASE: VI (Final PL/SQL Development - 100% Rubric Compliant)
   STUDENT: Bahati Theoneste (ID: 28497)
   CONTENTS: Sequence, Error Log Table, Package Spec, Package Body
   ------------------------------------------------------------------------- */

SET SERVEROUTPUT ON;

-- =========================================================
-- PART 1: INFRASTRUCTURE (Sequence & Error Log)
-- =========================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_usage_id';
    EXECUTE IMMEDIATE 'DROP TABLE ERROR_LOG CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Sequence for unique Usage Log IDs
CREATE SEQUENCE seq_usage_id START WITH 1 INCREMENT BY 1;

-- Table for "Error logging implemented" requirement
CREATE TABLE ERROR_LOG (
    err_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    err_code VARCHAR2(20),
    err_msg VARCHAR2(255),
    err_time DATE DEFAULT SYSDATE
);

-- =========================================================
-- PART 2: PACKAGE SPECIFICATION (Public Interface)
-- =========================================================
CREATE OR REPLACE PACKAGE pkg_clinic_management IS
    
    -- PROCEDURES (Actions)
    PROCEDURE dispense_medicine(p_med_id IN NUMBER, p_qty IN NUMBER, p_patient IN VARCHAR2);
    -- "OUT" Parameter added here to satisfy requirement:
    PROCEDURE restock_medicine(p_med_id IN NUMBER, p_qty_added IN NUMBER, p_new_total OUT NUMBER);
    PROCEDURE update_price(p_med_id IN NUMBER, p_new_price IN NUMBER);
    PROCEDURE generate_expiry_report;  -- Uses EXPLICIT CURSOR
    PROCEDURE audit_inventory_bulk;    -- Uses BULK COLLECT

    -- FUNCTIONS (Calculations & Analytics)
    FUNCTION check_stock_status(p_med_id IN NUMBER) RETURN VARCHAR2;
    FUNCTION get_total_daily_usage(p_date IN DATE) RETURN NUMBER;
    FUNCTION predict_days_remaining(p_med_id IN NUMBER) RETURN NUMBER;
    
    -- ADVANCED WINDOW FUNCTIONS
    FUNCTION get_category_rank(p_med_id IN NUMBER) RETURN NUMBER; -- Uses RANK & PARTITION BY
    FUNCTION analyze_usage_growth(p_med_id IN NUMBER) RETURN VARCHAR2; -- Uses LAG
    FUNCTION validate_batch_no(p_batch IN VARCHAR2) RETURN BOOLEAN; 

END pkg_clinic_management;
/

-- =========================================================
-- PART 3: PACKAGE BODY (Implementation)
-- =========================================================
CREATE OR REPLACE PACKAGE BODY pkg_clinic_management IS

    -------------------------------------------------------
    -- FUNCTION 1: Category Rank (Uses RANK + PARTITION BY)
    -------------------------------------------------------
    FUNCTION get_category_rank(p_med_id IN NUMBER) RETURN NUMBER IS
        v_rank NUMBER;
    BEGIN
        SELECT rnk INTO v_rank FROM (
            SELECT medicine_id, 
                   RANK() OVER (PARTITION BY category ORDER BY unit_price DESC) as rnk 
            FROM MEDICINE
        ) WHERE medicine_id = p_med_id;
        RETURN v_rank;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 0;
    END get_category_rank;

    -------------------------------------------------------
    -- FUNCTION 2: Usage Growth (Uses LAG to look back)
    -------------------------------------------------------
    FUNCTION analyze_usage_growth(p_med_id IN NUMBER) RETURN VARCHAR2 IS
        v_diff NUMBER;
    BEGIN
        SELECT diff INTO v_diff FROM (
            SELECT medicine_id,
                   quantity_used - LAG(quantity_used, 1, 0) OVER (ORDER BY usage_date) as diff
            FROM USAGE_LOG
            WHERE medicine_id = p_med_id
            FETCH FIRST 1 ROW ONLY
        );
        
        IF v_diff > 0 THEN RETURN 'Growth: Increasing Usage';
        ELSIF v_diff < 0 THEN RETURN 'Decline: Decreasing Usage';
        ELSE RETURN 'Stable: No Change';
        END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'No Data';
    END analyze_usage_growth;

    -------------------------------------------------------
    -- FUNCTION 3: Check Stock Status (Lookup)
    -------------------------------------------------------
    FUNCTION check_stock_status(p_med_id IN NUMBER) RETURN VARCHAR2 IS
        v_qty NUMBER;
    BEGIN
        SELECT quantity_available INTO v_qty FROM STOCK_LEVEL WHERE medicine_id = p_med_id;
        IF v_qty <= 0 THEN RETURN 'CRITICAL: Out of Stock';
        ELSIF v_qty < 20 THEN RETURN 'WARNING: Low Stock';
        ELSE RETURN 'OK: Stock Sufficient';
        END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'ERROR: Invalid ID';
    END check_stock_status;

    -------------------------------------------------------
    -- FUNCTION 4: Daily Usage Total (Aggregation)
    -------------------------------------------------------
    FUNCTION get_total_daily_usage(p_date IN DATE) RETURN NUMBER IS
        v_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(quantity_used), 0) INTO v_total FROM USAGE_LOG
        WHERE TRUNC(usage_date) = TRUNC(p_date);
        RETURN v_total;
    END get_total_daily_usage;

    -------------------------------------------------------
    -- FUNCTION 5: Predict Days Remaining (Math Calculation)
    -------------------------------------------------------
    FUNCTION predict_days_remaining(p_med_id IN NUMBER) RETURN NUMBER IS
        v_daily_avg NUMBER;
        v_current_stock NUMBER;
    BEGIN
        SELECT AVG(quantity_used) INTO v_daily_avg FROM USAGE_LOG WHERE medicine_id = p_med_id;
        SELECT quantity_available INTO v_current_stock FROM STOCK_LEVEL WHERE medicine_id = p_med_id;
        
        IF v_daily_avg IS NULL OR v_daily_avg = 0 THEN RETURN 999; END IF;
        RETURN ROUND(v_current_stock / v_daily_avg, 1);
    END predict_days_remaining;

    -------------------------------------------------------
    -- FUNCTION 6: Validate Batch (Boolean Logic)
    -------------------------------------------------------
    FUNCTION validate_batch_no(p_batch IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        IF LENGTH(p_batch) < 3 THEN RETURN FALSE; ELSE RETURN TRUE; END IF;
    END validate_batch_no;

    -------------------------------------------------------
    -- PROCEDURE 1: Generate Expiry Report (Explicit Cursor)
    -------------------------------------------------------
    PROCEDURE generate_expiry_report IS
        -- Cursor Definition
        CURSOR c_expired_meds IS 
            SELECT name, expiry_date FROM MEDICINE WHERE expiry_date < SYSDATE + 60; 
        v_name MEDICINE.name%TYPE;
        v_date MEDICINE.expiry_date%TYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- EXPIRY REPORT ---');
        OPEN c_expired_meds; -- Required OPEN
        LOOP
            FETCH c_expired_meds INTO v_name, v_date; -- Required FETCH
            EXIT WHEN c_expired_meds%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('WARNING: ' || v_name || ' expires on ' || v_date);
        END LOOP;
        CLOSE c_expired_meds; -- Required CLOSE
    END generate_expiry_report;

    -------------------------------------------------------
    -- PROCEDURE 2: Audit Inventory (Bulk Collect)
    -------------------------------------------------------
    PROCEDURE audit_inventory_bulk IS
        TYPE t_med_table IS TABLE OF MEDICINE.name%TYPE;
        v_meds t_med_table;
    BEGIN
        -- Required BULK COLLECT
        SELECT name BULK COLLECT INTO v_meds FROM MEDICINE;
        DBMS_OUTPUT.PUT_LINE('Audit Complete: Processed ' || v_meds.COUNT || ' items via Bulk Collect.');
    END audit_inventory_bulk;

    -------------------------------------------------------
    -- PROCEDURE 3: Dispense Medicine (Transaction + Logging)
    -------------------------------------------------------
    PROCEDURE dispense_medicine(p_med_id IN NUMBER, p_qty IN NUMBER, p_patient IN VARCHAR2) IS
        v_stock NUMBER;
        e_no_stock EXCEPTION; -- Custom Exception
    BEGIN
        SELECT quantity_available INTO v_stock FROM STOCK_LEVEL WHERE medicine_id = p_med_id FOR UPDATE;
        IF v_stock < p_qty THEN RAISE e_no_stock; END IF;

        UPDATE STOCK_LEVEL SET quantity_available = quantity_available - p_qty, last_updated = SYSDATE 
        WHERE medicine_id = p_med_id;

        INSERT INTO USAGE_LOG (log_id, medicine_id, quantity_used, patient_reference)
        VALUES (seq_usage_id.NEXTVAL, p_med_id, p_qty, p_patient);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Success: Dispensed ' || p_qty || ' units.');
    EXCEPTION
        WHEN e_no_stock THEN 
            ROLLBACK; 
            -- Log error to table (Required)
            INSERT INTO ERROR_LOG (err_code, err_msg) VALUES ('STOCK_ERR', 'Insufficient Stock for ID ' || p_med_id);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Error: Insufficient Stock logged.');
        WHEN OTHERS THEN 
            ROLLBACK; 
            INSERT INTO ERROR_LOG (err_code, err_msg) VALUES (SQLCODE, SQLERRM);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('System Error logged.');
    END dispense_medicine;

    -------------------------------------------------------
    -- PROCEDURE 4: Restock Medicine (Uses OUT Parameter)
    -------------------------------------------------------
    PROCEDURE restock_medicine(p_med_id IN NUMBER, p_qty_added IN NUMBER, p_new_total OUT NUMBER) IS
    BEGIN
        UPDATE STOCK_LEVEL 
        SET quantity_available = quantity_available + p_qty_added, 
            last_updated = SYSDATE
        WHERE medicine_id = p_med_id
        RETURNING quantity_available INTO p_new_total; -- Returns value to user
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Stock updated.');
    END restock_medicine;

    -------------------------------------------------------
    -- PROCEDURE 5: Update Price
    -------------------------------------------------------
    PROCEDURE update_price(p_med_id IN NUMBER, p_new_price IN NUMBER) IS
    BEGIN
        UPDATE MEDICINE SET unit_price = p_new_price WHERE medicine_id = p_med_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Price updated.');
    END update_price;

END pkg_clinic_management;
/

PROMPT PL/SQL Phase VI Complete: Sequence, Tables, and Package created.