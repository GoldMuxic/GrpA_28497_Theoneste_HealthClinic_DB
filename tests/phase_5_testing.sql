-- Verify
SELECT * FROM MEDICINE;
-- TEST 1: View all medicines and their prices
SELECT medicine_id, name, category, unit_price, expiry_date 
FROM MEDICINE
ORDER BY name;

-- TEST 2: Try to insert INVALID data (Negative Stock)
-- EXPECTED RESULT: ORA-02290: check constraint violated
INSERT INTO STOCK_LEVEL (stock_id, medicine_id, quantity_available) 
VALUES (999, 101, -50);

-- TEST 3: Join Medicine with Stock to see Names and Quantities together
SELECT m.name, m.category, s.quantity_available, s.last_updated
FROM MEDICINE m
JOIN STOCK_LEVEL s ON m.medicine_id = s.medicine_id
WHERE s.quantity_available < 50; -- Filter for low stock

-- TEST 4: Count how many medicines exist per Category
SELECT category, COUNT(*) as total_medicines, AVG(unit_price) as average_price
FROM MEDICINE
GROUP BY category;