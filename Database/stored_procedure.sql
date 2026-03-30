use assetDB;
DELIMITER //
DROP PROCEDURE IF EXISTS getAssetsNeedRepair;
CREATE PROCEDURE getAssetsNeedRepair()
BEGIN
    SELECT
        a.asset_id,
        a.asset_name,
        a.asset_status,
        t.type_name,
        a.room_id
    FROM Asset a
    JOIN type_of_asset t ON a.type_id = t.type_id
    WHERE a.asset_status = 'Needs Repair';
END //

DROP PROCEDURE IF EXISTS showStorageRoom;
CREATE PROCEDURE showStorageRoom (storageId INT)
BEGIN
    SELECT
        sr.storage_id,
        sr.room_name,
		r.floor,
        r.building_id,
        sr.storage_status
    FROM storage_room sr
    LEFT JOIN room  r ON sr.room_id  = r.room_id
    WHERE sr.storage_id = storageId
    GROUP BY sr.storage_id, sr.room_name,  r.floor, r.building_id, sr.storage_status;
END //

DROP PROCEDURE IF EXISTS getAllAssets;
CREATE PROCEDURE getAllAssets()
BEGIN
    SELECT
        a.asset_id,
        a.asset_name,
        a.asset_status,
        t.type_name,
        r.room_id,
        r.floor,
        b.building_name
    FROM asset a
    JOIN type_of_asset t ON a.type_id     = t.type_id
    JOIN room        r ON a.room_id     = r.room_id
    JOIN building    b ON r.building_id = b.building_id
    ORDER BY a.asset_id;
END //

DROP PROCEDURE IF EXISTS addNewAsset;
CREATE PROCEDURE addNewAsset(
    assetName VARCHAR(50),
    assetStatus VARCHAR(50),
    typeId INT,
    roomId INT
)
BEGIN

    INSERT INTO asset (asset_name, asset_status, type_id, room_id)
    VALUES (assetName, assetStatus, typeId, roomId);

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('asset',  'INSERT', NOW());
END //

DROP PROCEDURE IF EXISTS showAuditLog;
CREATE PROCEDURE showAuditLog()
BEGIN
    SELECT * from audit_log;
END //

DROP PROCEDURE IF EXISTS updateAsset;
CREATE PROCEDURE updateAsset(
    assetId INT,
    assetName VARCHAR(50),
    assetStatus VARCHAR(50),
    typeId INT,
    roomId INT
)
BEGIN
    UPDATE asset
    SET 
        asset_name = assetName,
        asset_status = assetStatus,
        type_id = typeId,
        room_id = roomId
    WHERE asset_id = assetId;

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('asset', 'UPDATE', NOW());

END //

DROP PROCEDURE IF EXISTS addRepairRecord;
CREATE PROCEDURE addRepairRecord(
    assetId INT,
    fixDate DATE,
    reason VARCHAR(100),
    repairCost DECIMAL(10,2)
)
BEGIN

    INSERT INTO repair_record (asset_id, fix_date, reason, repair_cost)
    VALUES (assetId, fixDate, reason, repairCost);

    UPDATE asset
    SET asset_status = 'Good'
    WHERE asset_id = assetId;
    
	INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('asset', 'UPDATE', NOW());
    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('repair_record', 'INSERT', NOW());

END //

DROP PROCEDURE IF EXISTS showRepairRecord;
CREATE PROCEDURE showRepairRecord()
 BEGIN
	SELECT * FROM repair_record;
 END //

DROP PROCEDURE IF EXISTS addPurchaseRecord;
CREATE PROCEDURE addPurchaseRecord(
    purchaseDate DATE,
    descriptions  VARCHAR(100),
    assetId      INT,
    amount        DECIMAL(10,2)
)
BEGIN

    INSERT INTO purchase_record (purchase_date, descriptions, asset_id, amount)
    VALUES (purchaseDate, descriptions, assetId, amount);

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('purchase_record', 'INSERT', NOW());
END //

DROP PROCEDURE IF EXISTS showPurchaseRecord;
CREATE PROCEDURE showPurchaseRecord()
BEGIN
    SELECT * from purchase_record;
END //

DROP PROCEDURE IF EXISTS addEmployee;
CREATE PROCEDURE addEmployee(
    firstName       VARCHAR(50),
    lastName        VARCHAR(50),
    salary          DECIMAL(10,2),
    hireDate        DATE,
    resignDate      DATE,
    phoneNumber     VARCHAR(20),
    buildingId      INT,
    managedRoomId   INT,
    commune         VARCHAR(50),
    district        VARCHAR(50),
    province        VARCHAR(50),
    streetNumber    VARCHAR(50),
    zipCode         VARCHAR(10)
)
BEGIN


    INSERT INTO employees 
        (employee_firstname, employee_lastname, salary, hire_date, resign_date, phone_number, building_id, managed_room_id)
    VALUES 
        (firstName, lastName, salary, hireDate, resignDate, phoneNumber, buildingId, managedRoomId);

    INSERT INTO employees_address
        (commune, district, province, street_number, zip_code, employee_id)
    VALUES
        (commune, district, province, streetNumber, zipCode, LAST_INSERT_ID());

    INSERT INTO audit_log 
        (table_name, action, action_date)
    VALUES 
        ('employees', 'INSERT', NOW());

    INSERT INTO audit_log 
        (table_name, action, action_date)
    VALUES 
        ('employees_address', 'INSERT', NOW());

END //

DROP PROCEDURE IF EXISTS showEmployeeRecord;
CREATE PROCEDURE showEmployeeRecord()
BEGIN
    SELECT 
        e.employee_id,
        e.employee_firstname,
        e.employee_lastname,
        e.salary,
        e.hire_date,
        e.resign_date,
        e.phone_number,
        e.building_id,
        e.managed_room_id,
        ea.commune,
        ea.district,
        ea.province,
        ea.street_number,
        ea.zip_code
    FROM employees e
    LEFT JOIN employees_address ea 
        ON e.employee_id = ea.employee_id;
END //

DROP PROCEDURE IF EXISTS resignEmployee;
CREATE PROCEDURE resignEmployee(
    employeeId INT,
    resignDate VARCHAR(50)
)
BEGIN
    UPDATE employees
    SET resign_date = resignDate
    WHERE employee_id = employeeId;

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('employees', 'UPDATE', NOW());
END //

DROP PROCEDURE IF EXISTS deleteAsset;
CREATE PROCEDURE deleteAsset(assetId INT)
BEGIN
    DELETE FROM asset
    WHERE asset_id = assetId;

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('asset', 'DELETE', NOW());
END // 

DROP PROCEDURE IF EXISTS deleteRepairRecord;
CREATE PROCEDURE deleteRepairRecord(repairId INT)
BEGIN
    DELETE FROM repair_record
    WHERE repair_id = repairId;

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('repair_record', 'DELETE', NOW());
END //

DROP PROCEDURE IF EXISTS deletePurchaseRecord;
CREATE PROCEDURE deletePurchaseRecord(purchaseId INT)
BEGIN
    DELETE FROM purchase_record
    WHERE purchase_id = purchaseId;

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('purchase_record', 'DELETE', NOW());
END //

DROP PROCEDURE IF EXISTS deleteEmployee;
CREATE PROCEDURE deleteEmployee(employeeId INT)
BEGIN
    DELETE FROM employees_address
    WHERE employee_id = employeeId;

    DELETE FROM employees
    WHERE employee_id = employeeId;

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('employees', 'DELETE', NOW());

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('employees_address', 'DELETE', NOW());
END //

DROP PROCEDURE IF EXISTS borrowAsset;
CREATE PROCEDURE borrowAsset(
    employeeId INT,
    assetId INT,
    borrowDate DATE
)
BEGIN
    DECLARE currentRoom INT;

    SELECT room_id INTO currentRoom
    FROM asset
    WHERE asset_id = assetId;

    IF currentRoom IS NOT NULL AND EXISTS (SELECT 1 FROM storage_room WHERE room_id = currentRoom) THEN

        IF EXISTS (SELECT 1 FROM borrow_log WHERE asset_id = assetId AND item_status = 'Borrowed') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Asset already borrowed.';
        ELSE
            INSERT INTO borrow_log (employee_id, asset_id, borrow_date, item_status)
            VALUES (employeeId, assetId, borrowDate, 'Borrowed');

            INSERT INTO audit_log (table_name, action, action_date)
            VALUES ('borrow_log', 'INSERT', NOW());
        END IF;

    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Asset is not in storage room. Cannot borrow.';
    END IF;
END //

DROP PROCEDURE IF EXISTS showAllAssetInStorageRoom;
CREATE PROCEDURE showAllAssetInStorageRoom()
BEGIN
    SELECT 
        a.asset_id,
        a.asset_name,
        a.asset_status,
        t.type_name,
        sr.storage_id,
        sr.room_name,
        r.floor,
        b.building_name
    FROM asset a
    JOIN type_of_asset t ON a.type_id = t.type_id
    JOIN storage_room sr ON a.room_id = sr.room_id
    JOIN room r ON sr.room_id = r.room_id
    JOIN building b ON r.building_id = b.building_id
    ORDER BY sr.storage_id, a.asset_id;
END //

DROP PROCEDURE IF EXISTS showBorrowLog;
CREATE PROCEDURE showBorrowLog()
BEGIN
    SELECT * from borrow_log;
END //

DROP PROCEDURE IF EXISTS returnAsset;
CREATE PROCEDURE returnAsset(
    employeeId INT,
    assetId INT,
    returnDate DATE
)
BEGIN
 
    UPDATE borrow_log
    SET return_date = returnDate
    WHERE asset_id = assetId
      AND employee_id = employeeId;
      
	UPDATE borrow_log
    SET item_status = 'Returned'
    WHERE asset_id = assetId
      AND employee_id = employeeId;

    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('borrow_log', 'UPDATE', NOW());
END //

DROP PROCEDURE IF EXISTS showBorrowLogByAssetId;
CREATE PROCEDURE showBorrowLogByAssetId(assetId INT)
BEGIN
    SELECT 
    b.borrow_id, b.asset_id, b.employee_id, b.borrow_date, b.return_date, b.item_status
    FROM borrow_log b
    WHERE b.asset_id = assetId
    ORDER BY b.borrow_id;
END //

DELIMITER ;
