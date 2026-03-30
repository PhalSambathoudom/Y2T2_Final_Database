DROP DATABASE IF EXISTS assetDB;
CREATE DATABASE assetDB;
USE assetDB;

-- 1. Building
CREATE TABLE building (
    building_id INT PRIMARY KEY,
    building_name VARCHAR(50)
) ENGINE=InnoDB;

-- 2. Room  
CREATE TABLE room (
    room_id	INT PRIMARY KEY ,
    floor VARCHAR(50),
    room_type VARCHAR(20) NOT NULL COMMENT 'storage | classroom',
    building_id INT NOT NULL,
    FOREIGN KEY (building_id) REFERENCES building(building_id)
) ENGINE=InnoDB;

-- 3. Classroom  
CREATE TABLE classroom (
    classroom_id INT PRIMARY KEY,
    classroom_name VARCHAR(50),
    room_id INT NOT NULL UNIQUE,
    FOREIGN KEY (room_id) REFERENCES room(room_id)
) ENGINE=InnoDB;

-- 4. Storage Room 
CREATE TABLE storage_room (
    storage_id INT PRIMARY KEY ,
    room_name  VARCHAR(50),
    room_id INT NOT NULL UNIQUE,
    FOREIGN KEY (room_id) REFERENCES room(room_id)
) ENGINE=InnoDB;

-- 5. Type of Asset
CREATE TABLE type_of_asset (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50)
) ENGINE=InnoDB;

-- 6. Asset
CREATE TABLE asset (
    asset_id INT PRIMARY KEY AUTO_INCREMENT,
    asset_name VARCHAR(50),
    asset_status VARCHAR(50),
    type_id INT,
    room_id INT,
    FOREIGN KEY (type_id) REFERENCES type_of_asset(type_id),
    FOREIGN KEY (room_id) REFERENCES room(room_id)
) ENGINE=InnoDB;

-- 7. Repair Record
CREATE TABLE repair_record (
    repair_id INT PRIMARY KEY AUTO_INCREMENT,
    asset_id INT,
    fix_date DATE,
    reason VARCHAR(100),
    repair_cost DECIMAL(10,2),
    FOREIGN KEY (asset_id) REFERENCES asset(asset_id)
) ENGINE=InnoDB;

-- 8. Purchase Record
CREATE TABLE purchase_record (
    purchase_id INT PRIMARY KEY AUTO_INCREMENT,
    purchase_date DATE,
    descriptions VARCHAR(100),
    asset_id INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (asset_id) REFERENCES asset(asset_id)
) ENGINE=InnoDB;

-- 9. Employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_firstname VARCHAR(50),
    employee_lastname VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    resign_date DATE NULL,
    phone_number VARCHAR(20),
    building_id INT,
    managed_room_id INT NULL,
    FOREIGN KEY (building_id) REFERENCES building(building_id),
    FOREIGN KEY (managed_room_id) REFERENCES room(room_id)
) ENGINE=InnoDB;

-- 10. Employees Address
CREATE TABLE employees_address (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    commune VARCHAR(50),
    district VARCHAR(50),
    province VARCHAR(50),
    street_number VARCHAR(50),
    zip_code VARCHAR(10),
    employee_id INT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

-- 11. Borrow Log
CREATE TABLE borrow_log (
    borrow_id INT PRIMARY KEY AUTO_INCREMENT,
    asset_id INT,
    employee_id INT,
    borrow_date DATE,
    return_date DATE NULL,
    item_status VARCHAR(20) NOT NULL DEFAULT 'Borrowed'
                COMMENT 'Borrowed | Returned',
    FOREIGN KEY (asset_id) REFERENCES asset(asset_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
) ENGINE=InnoDB;

-- 12. Audit Log
CREATE TABLE audit_log (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    action VARCHAR(20),
    action_date DATETIME
) ENGINE=InnoDB;


