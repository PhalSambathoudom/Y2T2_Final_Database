USE assetDB;

-- create view by Rak and Namkea 
-- 1.Asset detail
create view asset_details as 
select a.asset_id, a.asset_name, a.asset_status , t.type_name , r.room_id , b.building_name 
from asset a 
join type_of_asset t on a.type_id = t.type_id 
join room r on a.room_id = r.room_id 
join building b on r.building_id = b.building_id;

-- 2. Borrowed Assets
create view view_borrowed_assets as 
select bl.borrow_id, a.asset_name, concat(e.employee_firstname, ' ', e.employee_lastname) as full_name, bl.borrow_date
from borrow_log bl
join asset a on bl.asset_id = a.asset_id
join employees e on bl.employee_id = e.employee_id
where bl.item_status = 'Borrowed';

-- 3. Employee with Building 
create view view_employee_building as 
select e.employee_id, concat(e.employee_firstname, ' ', e.employee_lastname) as full_name, b.building_name
from employees e
join building b on e.building_id = b.building_id;

-- 4. Repair History
create view view_repair_history as 
select r.repair_id, a.asset_name, r.fix_date, r.reason, r.repair_cost
from repair_record r
join asset a on r.asset_id = a.asset_id;

-- 5. Purchase Summary
create view view_purchase_summary as 
select p.purchase_id, a.asset_name, p.purchase_date, p.amount
from purchase_record p
join asset a on p.asset_id = a.asset_id;

-- 6. Room with building
create view view_room_building as
select r.room_id, r.room_type, r.floor, b.building_name
from room r
join building b on r.building_id = b.building_id;

select * from view_room_building;
select * from view_purchase_summary;
select * from asset_details ;
select * from view_repair_history ;
select * from view_employee_building ;
select * from view_borrowed_assets;
