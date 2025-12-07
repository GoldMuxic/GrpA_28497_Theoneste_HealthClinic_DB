SET SERVEROUTPUT ON;

-- TEST 1: Check if today is a Holiday (Should be empty unless you inserted today)
SELECT * FROM PUBLIC_HOLIDAYS WHERE holiday_date = TRUNC(SYSDATE);

-- TEST 2: Attempt to Update Price (On Sunday = ALLOWED)
-- If today is Sunday, this should work and log "ALLOWED".
UPDATE MEDICINE SET unit_price = 550 WHERE medicine_id = 101;

-- TEST 3: Insert a fake Holiday for TODAY to force a block
INSERT INTO PUBLIC_HOLIDAYS VALUES (TRUNC(SYSDATE), 'Test Holiday');
COMMIT;

-- TEST 4: Attempt Update again (On Holiday = DENIED)
-- This should FAIL with ORA-20005
UPDATE MEDICINE SET unit_price = 600 WHERE medicine_id = 101;

-- TEST 5: Verify the Audit Log
-- Expectation: You should see 'ALLOWED' for Test 2 and 'DENIED' for Test 4.
SELECT * FROM ACCESS_AUDIT_LOG ORDER BY log_time DESC;

-- CLEANUP (Remove the fake holiday)
DELETE FROM PUBLIC_HOLIDAYS WHERE description = 'Test Holiday';
COMMIT;