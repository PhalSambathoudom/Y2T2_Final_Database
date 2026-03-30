USE assetDB;

-- 1. Get all employees who manage at least one room
SELECT *
FROM employees
WHERE managed_room_id IS NOT NULL;

-- 2. Get all employee full names (firstname + lastname)
SELECT CONCAT(employee_firstname, ' ', employee_lastname) AS full_name
FROM employees;

-- 3. Find employees who work in the building that has the most rooms
SELECT employee_firstname, employee_lastname
FROM employees
WHERE building_id = (
    SELECT building_id
    FROM room
    GROUP BY building_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- 4. Get all assets that have a repair record
SELECT asset_id, asset_name
FROM asset
WHERE asset_id IN (SELECT asset_id FROM repair_record);

-- 5. Get all assets that have no repair records
SELECT asset_id, asset_name
FROM asset
WHERE asset_id NOT IN (SELECT asset_id FROM repair_record);

-- 6. Get assets with their highest repair cost
SELECT a.asset_name,
       (SELECT MAX(repair_cost)
        FROM repair_record r
        WHERE r.asset_id = a.asset_id) AS highest_repair_cost
FROM asset a;

-- 7. Get the asset that cost the most total repairs
SELECT asset_id, 
       (SELECT SUM(repair_cost)
        FROM repair_record r
        WHERE r.asset_id = a.asset_id) AS total_repair
FROM asset a
ORDER BY total_repair DESC
LIMIT 1;

-- 8. Employees earning more than the average salary
SELECT employee_firstname, employee_lastname, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 9. All classrooms located in buildings that have more than 10 rooms
SELECT classroom_name
FROM classroom
WHERE room_id IN (
    SELECT room_id
    FROM room
    WHERE building_id IN (
        SELECT building_id
        FROM room
        GROUP BY building_id
        HAVING COUNT(*) > 10
    )
);

-- 10. Get assets placed in the same room as asset ID = 1
SELECT asset_name
FROM asset
WHERE room_id = (
    SELECT room_id FROM asset WHERE asset_id = 1
);

-- 11. Find employees living in Phnom Penh
SELECT e.employee_firstname, e.employee_lastname
FROM employees e
WHERE e.employee_id IN (
    SELECT employee_id
    FROM employees_address
    WHERE province = 'Phnom Penh'
);

-- 12. Current borrowed items (not yet returned)
SELECT *
FROM borrow_log
WHERE borrow_id IN (
    SELECT borrow_id
    FROM borrow_log
    WHERE return_date IS NULL
);

-- 13. Total purchase amount for assets of type 'Printer'
SELECT SUM(amount) AS total_printer_spending
FROM purchase_record
WHERE asset_id IN (
    SELECT asset_id 
    FROM asset
    WHERE type_id = (SELECT type_id FROM type_of_asset WHERE type_name = 'Printer')
);

-- 14. Building with the most employees
SELECT building_id
FROM employees
GROUP BY building_id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 15. Rooms containing assets with 'Needs Repair' status
SELECT room_id
FROM room
WHERE room_id IN (
    SELECT room_id
    FROM asset
    WHERE asset_status = 'Needs Repair'
);

-- 16. Employees who borrowed expensive assets (purchase amount > 1000)
SELECT e.employee_firstname, e.employee_lastname
FROM employees e
WHERE e.employee_id IN (
    SELECT employee_id
    FROM borrow_log
    WHERE asset_id IN (
        SELECT asset_id
        FROM purchase_record
        WHERE amount > 1000
    )
);

-- 17. Tables with more than 2 actions recorded
SELECT *
FROM audit_log
WHERE table_name IN (
    SELECT table_name
    FROM audit_log
    GROUP BY table_name
    HAVING COUNT(*) > 2
);
