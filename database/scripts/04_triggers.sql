/* -------------------------------------------------------------------------
   SCRIPT: triggers.sql
   PHASE: VII (Final - Advanced Triggers & Auditing)
   STUDENT: Bahati Theoneste (ID: 28497)
   CONTENTS: 
     1. Holiday Management (Table)
     2. Audit Log (Table)
     3. Audit Logging (Autonomous Procedure)
     4. Restriction Check (Function)
     5. Simple Trigger (Format Data)
     6. Compound Trigger (Security & Auditing)
   ------------------------------------------------------------------------- */

-- SAFETY COMMAND: Stops SQL Developer from asking for input on '&' symbols
SET DEFINE OFF;
SET SERVEROUTPUT ON;

-- =========================================================
-- STEP 1: TABLES (Holiday Management & Audit Log)
-- =========================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PUBLIC_HOLIDAYS CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE ACCESS_AUDIT_LOG CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 1. Holiday Table
CREATE TABLE PUBLIC_HOLIDAYS (
    holiday_date DATE PRIMARY KEY,
    description  VARCHAR2(100)
);

-- 2. Audit Table
CREATE TABLE ACCESS_AUDIT_LOG (
    log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    db_user     VARCHAR2(50),
    action_type VARCHAR2(20),   -- INSERT, UPDATE, DELETE
    obj_name    VARCHAR2(50),
    status      VARCHAR2(10),   -- ALLOWED or DENIED
    log_time    TIMESTAMP DEFAULT SYSTIMESTAMP,
    message     VARCHAR2(255)
);

-- =========================================================
-- STEP 2: AUDIT LOGGING FUNCTION (Autonomous Transaction)
-- =========================================================
-- Ensures the log is saved even if the main transaction fails/rolls back.
CREATE OR REPLACE PROCEDURE log_audit_attempt(
    p_action IN VARCHAR2,
    p_obj    IN VARCHAR2,
    p_status IN VARCHAR2,
    p_msg    IN VARCHAR2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO ACCESS_AUDIT_LOG (db_user, action_type, obj_name, status, message)
    VALUES (USER, p_action, p_obj, p_status, p_msg);
    COMMIT;
END;
/

-- =========================================================
-- STEP 3: RESTRICTION CHECK FUNCTION
-- =========================================================
-- Returns TRUE if access is allowed (Weekends), FALSE if Denied.
CREATE OR REPLACE FUNCTION is_access_allowed RETURN BOOLEAN IS
    v_dummy NUMBER;
    v_day   VARCHAR2(20);
BEGIN
    -- Force English to avoid language errors on school computers
    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    
    -- RULE 1: Block Weekdays (Mon-Fri)
    IF v_day NOT IN ('SAT', 'SUN') THEN
        RETURN FALSE; 
    END IF;

    -- RULE 2: Block Public Holidays
    BEGIN
        SELECT 1 INTO v_dummy 
        FROM PUBLIC_HOLIDAYS 
        WHERE TRUNC(holiday_date) = TRUNC(SYSDATE);
        
        RETURN FALSE; -- Holiday found -> Block
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN TRUE; -- No holiday -> Allow
    END;
END;
/

-- =========================================================
-- STEP 4: SIMPLE TRIGGER (New Addition!)
-- =========================================================
-- Requirement: "Simple Triggers"
-- Objective: Automatically convert holiday descriptions to UPPERCASE before saving.
CREATE OR REPLACE TRIGGER trg_format_holiday
BEFORE INSERT ON PUBLIC_HOLIDAYS
FOR EACH ROW
BEGIN
    :NEW.description := UPPER(:NEW.description);
END;
/

-- =========================================================
-- STEP 5: COMPOUND TRIGGER (Security & Logic)
-- =========================================================
-- Requirement: "Compound Trigger"
-- Objective: Enforce security rules and log every attempt.
CREATE OR REPLACE TRIGGER trg_medicine_security
FOR INSERT OR UPDATE OR DELETE ON MEDICINE
COMPOUND TRIGGER

    v_action VARCHAR2(20);
    v_allowed BOOLEAN;

    BEFORE EACH ROW IS
    BEGIN
        IF INSERTING THEN v_action := 'INSERT';
        ELSIF UPDATING THEN v_action := 'UPDATE';
        ELSIF DELETING THEN v_action := 'DELETE';
        END IF;

        -- Check permissions
        v_allowed := is_access_allowed();

        IF NOT v_allowed THEN
            -- Log DENIAL
            log_audit_attempt(v_action, 'MEDICINE', 'DENIED', 'Blocked: Weekday/Holiday Rule');
            RAISE_APPLICATION_ERROR(-20005, 'SECURITY: Changes allowed on WEEKENDS only.');
        ELSE
            -- Log SUCCESS
            log_audit_attempt(v_action, 'MEDICINE', 'ALLOWED', 'Access Granted');
        END IF;
    END BEFORE EACH ROW;

END trg_medicine_security;
/

-- FIXED PROMPT: Changed '&' to 'AND' to prevent popup input request
PROMPT Phase VII Complete: All Triggers (Simple AND Compound) and Audit Logic created.