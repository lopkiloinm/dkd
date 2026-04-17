-- ============================================================
-- DKD Vending Machine System — Comprehensive Mock Data Seed
-- ------------------------------------------------------------
-- Schema-accurate (column names match dkd.sql CREATE TABLEs).
-- Covers every business table EXCEPT real payment-gateway artifacts
-- (orders carry pay_type/pay_status fields but no callback / refund
-- records and no consumer wallet state).
--
-- Usage:  mysql -uroot -p'' dkd < initialize_mock_data_full.sql
-- Safety: TRUNCATEs business tables first. sys_* tables untouched.
-- Requires: MySQL 8.0+ (uses WITH RECURSIVE CTE).
-- ============================================================

SET @OLD_FK = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
SET @OLD_TZ = @@session.time_zone;
SET time_zone = '+00:00';

TRUNCATE TABLE tb_order_month_collect;
TRUNCATE TABLE tb_order_collect;
TRUNCATE TABLE tb_order;
TRUNCATE TABLE tb_vendout_running;
TRUNCATE TABLE tb_task_details;
TRUNCATE TABLE tb_task_collect;
TRUNCATE TABLE tb_task;
TRUNCATE TABLE tb_task_type;
TRUNCATE TABLE tb_channel;
TRUNCATE TABLE tb_vending_machine;
TRUNCATE TABLE tb_vm_type;
TRUNCATE TABLE tb_node;
TRUNCATE TABLE tb_emp;
TRUNCATE TABLE tb_role;
TRUNCATE TABLE tb_partner;
TRUNCATE TABLE tb_region;
TRUNCATE TABLE tb_policy;
TRUNCATE TABLE tb_sku;
TRUNCATE TABLE tb_sku_class;

-- ============================================================
-- 1. Regions
-- ============================================================
INSERT INTO tb_region (id, region_name, create_time, update_time, remark) VALUES
(1, 'Downtown Core',        NOW(), NOW(), 'High-traffic CBD'),
(2, 'University District',  NOW(), NOW(), 'Campus coverage'),
(3, 'Transit Hub',          NOW(), NOW(), 'Stations & airports'),
(4, 'Suburban North',       NOW(), NOW(), 'Residential north'),
(5, 'Entertainment Zone',   NOW(), NOW(), 'Malls & stadiums');

-- ============================================================
-- 2. Partners
-- ============================================================
INSERT INTO tb_partner (id, partner_name, contact_person, contact_phone, profit_ratio, account, password, create_time, update_time) VALUES
(1, 'Skyline Realty',      'Alice Chen',    '13800000001', 30, 'skyline',   '$2a$10$HMoV13bMmm.IRbh5tczyf.fZemJQmk.1IigU9HBrzi/zUXXLmNfZa', NOW(), NOW()),
(2, 'Metro Properties',    'Bob Wang',      '13800000002', 25, 'metro',     '$2a$10$HMoV13bMmm.IRbh5tczyf.fZemJQmk.1IigU9HBrzi/zUXXLmNfZa', NOW(), NOW()),
(3, 'Campus Services Co.', 'Carol Li',      '13800000003', 28, 'campus',    '$2a$10$HMoV13bMmm.IRbh5tczyf.fZemJQmk.1IigU9HBrzi/zUXXLmNfZa', NOW(), NOW()),
(4, 'Transit Holdings',    'David Zhou',    '13800000004', 22, 'transit',   '$2a$10$HMoV13bMmm.IRbh5tczyf.fZemJQmk.1IigU9HBrzi/zUXXLmNfZa', NOW(), NOW()),
(5, 'Mall Group Inc.',     'Eva Huang',     '13800000005', 20, 'mallgroup', '$2a$10$HMoV13bMmm.IRbh5tczyf.fZemJQmk.1IigU9HBrzi/zUXXLmNfZa', NOW(), NOW()),
(6, 'Stadium Ventures',    'Frank Sun',     '13800000006', 18, 'stadium',   '$2a$10$HMoV13bMmm.IRbh5tczyf.fZemJQmk.1IigU9HBrzi/zUXXLmNfZa', NOW(), NOW());

-- ============================================================
-- 3. Nodes (placement points) — 3 per region
-- ============================================================
INSERT INTO tb_node (id, node_name, address, business_type, region_id, partner_id, create_time, update_time) VALUES
( 1, 'Central Plaza Lobby',    '100 Main St, Downtown',    1, 1, 1, NOW(), NOW()),
( 2, 'Financial Tower',        '250 Wall Ave, Downtown',   1, 1, 1, NOW(), NOW()),
( 3, 'City Hall Atrium',       '1 Civic Center, Downtown', 1, 1, 2, NOW(), NOW()),
( 4, 'Engineering Building',   'Campus East Gate',         1, 2, 3, NOW(), NOW()),
( 5, 'Student Union',          'University Quad',          1, 2, 3, NOW(), NOW()),
( 6, 'Library Annex',          'Main Library Lvl 2',       1, 2, 3, NOW(), NOW()),
( 7, 'Metro Station North',    'Line 1, North Entrance',   2, 3, 4, NOW(), NOW()),
( 8, 'Airport Terminal B',     'Gate 22 Concourse',        2, 3, 4, NOW(), NOW()),
( 9, 'Bus Interchange',        'Level 1 Ticketing',        2, 3, 4, NOW(), NOW()),
(10, 'Riverside Apartments',   '500 Riverside Dr',         1, 4, 2, NOW(), NOW()),
(11, 'Northgate Mall',         '2000 North Ave',           1, 4, 5, NOW(), NOW()),
(12, 'Community Center',       '88 Parkview Rd',           1, 4, 2, NOW(), NOW()),
(13, 'Grand Mall — L1',        'Entertainment Blvd',       1, 5, 5, NOW(), NOW()),
(14, 'Cinema Complex',         'Cinema Blvd',              1, 5, 5, NOW(), NOW()),
(15, 'Stadium Concourse',      'Sports Arena Gate A',      1, 5, 6, NOW(), NOW());

-- ============================================================
-- 4. VM Types
-- ============================================================
INSERT INTO tb_vm_type (id, name, model, image, vm_row, vm_col, channel_max_capacity) VALUES
(1, 'Beverage Tower',  'BV-5x6',  'https://cdn.dkd.example/vmtypes/bv5x6.png',  5, 6, 10),
(2, 'Snack Combo',     'SC-4x6',  'https://cdn.dkd.example/vmtypes/sc4x6.png',  4, 6,  8),
(3, 'Compact Mini',    'CM-3x4',  'https://cdn.dkd.example/vmtypes/cm3x4.png',  3, 4,  6),
(4, 'Fresh Cooler',    'FC-4x5',  'https://cdn.dkd.example/vmtypes/fc4x5.png',  4, 5,  8);

-- ============================================================
-- 5. SKU Classes  (PK = class_id)
-- ============================================================
INSERT INTO tb_sku_class (class_id, class_name, parent_id) VALUES
(1, 'Beverages',     0),
(2, 'Snacks',        0),
(3, 'Healthy',       0),
(4, 'Confectionery', 0),
(5, 'Fresh',         0),
(6, 'Hot Drinks',    0);

-- ============================================================
-- 6. SKUs  (PK = sku_id; prices in cents)
-- ============================================================
INSERT INTO tb_sku (sku_id, sku_name, sku_image, brand_Name, unit, price, class_id, is_discount, create_time, update_time) VALUES
( 1, 'Coca-Cola Classic',  'https://cdn.dkd.example/sku/1.png',  'Coca-Cola',   '500ML', 350, 1, 0, NOW(), NOW()),
( 2, 'Pepsi Max',          'https://cdn.dkd.example/sku/2.png',  'Pepsi',       '500ML', 350, 1, 1, NOW(), NOW()),
( 3, 'Sprite',             'https://cdn.dkd.example/sku/3.png',  'Coca-Cola',   '500ML', 350, 1, 0, NOW(), NOW()),
( 4, 'Fanta Orange',       'https://cdn.dkd.example/sku/4.png',  'Coca-Cola',   '500ML', 350, 1, 0, NOW(), NOW()),
( 5, 'Nestea Lemon',       'https://cdn.dkd.example/sku/5.png',  'Nestle',      '500ML', 400, 1, 0, NOW(), NOW()),
( 6, 'Still Water 600',    'https://cdn.dkd.example/sku/6.png',  'AquaPure',    '600ML', 200, 1, 0, NOW(), NOW()),
( 7, 'Sparkling Water',    'https://cdn.dkd.example/sku/7.png',  'AquaPure',    '500ML', 300, 1, 0, NOW(), NOW()),
( 8, 'Orange Juice 100%',  'https://cdn.dkd.example/sku/8.png',  'FreshCo',     '350ML', 500, 3, 0, NOW(), NOW()),
( 9, 'Apple Juice',        'https://cdn.dkd.example/sku/9.png',  'FreshCo',     '350ML', 500, 3, 0, NOW(), NOW()),
(10, 'Kit-Kat 4-Finger',   'https://cdn.dkd.example/sku/10.png', 'Nestle',      '45G',   250, 4, 0, NOW(), NOW()),
(11, 'Snickers Bar',       'https://cdn.dkd.example/sku/11.png', 'Mars',        '50G',   300, 4, 0, NOW(), NOW()),
(12, 'M&M Peanut',         'https://cdn.dkd.example/sku/12.png', 'Mars',        '45G',   300, 4, 0, NOW(), NOW()),
(13, 'Lay''s Classic',     'https://cdn.dkd.example/sku/13.png', 'Lay''s',      '70G',   400, 2, 0, NOW(), NOW()),
(14, 'Doritos Nacho',      'https://cdn.dkd.example/sku/14.png', 'Frito',       '70G',   400, 2, 1, NOW(), NOW()),
(15, 'Oreo Cookies',       'https://cdn.dkd.example/sku/15.png', 'Mondelez',    '66G',   350, 4, 0, NOW(), NOW()),
(16, 'Pringles Original',  'https://cdn.dkd.example/sku/16.png', 'Pringles',    '110G',  550, 2, 0, NOW(), NOW()),
(17, 'Granola Bar',        'https://cdn.dkd.example/sku/17.png', 'Nature',      '40G',   250, 3, 0, NOW(), NOW()),
(18, 'Protein Bar',        'https://cdn.dkd.example/sku/18.png', 'FitLab',      '60G',   600, 3, 0, NOW(), NOW()),
(19, 'Gummy Bears',        'https://cdn.dkd.example/sku/19.png', 'Haribo',      '80G',   300, 4, 0, NOW(), NOW()),
(20, 'Dark Chocolate',     'https://cdn.dkd.example/sku/20.png', 'Lindt',       '100G',  800, 4, 0, NOW(), NOW()),
(21, 'Iced Coffee Latte',  'https://cdn.dkd.example/sku/21.png', 'Starbucks',   '250ML', 700, 6, 0, NOW(), NOW()),
(22, 'Hot Coffee Can',     'https://cdn.dkd.example/sku/22.png', 'Georgia',     '290ML', 450, 6, 0, NOW(), NOW()),
(23, 'Green Tea',          'https://cdn.dkd.example/sku/23.png', 'Ito En',      '500ML', 350, 6, 0, NOW(), NOW()),
(24, 'Yogurt Drink',       'https://cdn.dkd.example/sku/24.png', 'Yakult',      '100ML', 250, 5, 0, NOW(), NOW()),
(25, 'Fresh Salad Cup',    'https://cdn.dkd.example/sku/25.png', 'GreenGo',     '180G',  950, 5, 0, NOW(), NOW());

-- ============================================================
-- 7. Pricing Policies  (PK = policy_id)
-- ============================================================
INSERT INTO tb_policy (policy_id, policy_name, discount, create_time, update_time) VALUES
(1, 'Standard Price',  100, NOW(), NOW()),
(2, '10% Off Promo',    90, NOW(), NOW()),
(3, '20% Off Weekday',  80, NOW(), NOW()),
(4, '30% Clearance',    70, NOW(), NOW()),
(5, 'Happy Hour 50%',   50, NOW(), NOW());

-- ============================================================
-- 8. Field-ops Roles  (separate from sys_role)
-- ============================================================
INSERT INTO tb_role (role_id, role_code, role_name) VALUES
(1, '1001', 'Task Admin'),
(2, '1002', 'Operations'),
(3, '1003', 'Maintenance');

-- ============================================================
-- 9. Employees
-- ============================================================
INSERT INTO tb_emp (id, user_name, region_id, region_name, role_id, role_code, role_name, mobile, image, status, create_time, update_time) VALUES
( 1, 'Tom Admin',      1, 'Downtown Core',       1, '1001', 'Task Admin',    '13900000001', 'https://cdn.dkd.example/avatar/1.png',  1, NOW(), NOW()),
( 2, 'Olivia Admin',   3, 'Transit Hub',         1, '1001', 'Task Admin',    '13900000002', 'https://cdn.dkd.example/avatar/2.png',  1, NOW(), NOW()),
( 3, 'Liam Ops',       1, 'Downtown Core',       2, '1002', 'Operations',    '13900000003', 'https://cdn.dkd.example/avatar/3.png',  1, NOW(), NOW()),
( 4, 'Noah Ops',       1, 'Downtown Core',       2, '1002', 'Operations',    '13900000004', 'https://cdn.dkd.example/avatar/4.png',  1, NOW(), NOW()),
( 5, 'Emma Ops',       2, 'University District', 2, '1002', 'Operations',    '13900000005', 'https://cdn.dkd.example/avatar/5.png',  1, NOW(), NOW()),
( 6, 'Ava Ops',        3, 'Transit Hub',         2, '1002', 'Operations',    '13900000006', 'https://cdn.dkd.example/avatar/6.png',  1, NOW(), NOW()),
( 7, 'Mia Ops',        4, 'Suburban North',      2, '1002', 'Operations',    '13900000007', 'https://cdn.dkd.example/avatar/7.png',  1, NOW(), NOW()),
( 8, 'Zoe Ops',        5, 'Entertainment Zone',  2, '1002', 'Operations',    '13900000008', 'https://cdn.dkd.example/avatar/8.png',  1, NOW(), NOW()),
( 9, 'James Maint',    1, 'Downtown Core',       3, '1003', 'Maintenance',   '13900000009', 'https://cdn.dkd.example/avatar/9.png',  1, NOW(), NOW()),
(10, 'William Maint',  2, 'University District', 3, '1003', 'Maintenance',   '13900000010', 'https://cdn.dkd.example/avatar/10.png', 1, NOW(), NOW()),
(11, 'Ethan Maint',    3, 'Transit Hub',         3, '1003', 'Maintenance',   '13900000011', 'https://cdn.dkd.example/avatar/11.png', 1, NOW(), NOW()),
(12, 'Lucas Maint',    4, 'Suburban North',      3, '1003', 'Maintenance',   '13900000012', 'https://cdn.dkd.example/avatar/12.png', 1, NOW(), NOW()),
(13, 'Henry Maint',    5, 'Entertainment Zone',  3, '1003', 'Maintenance',   '13900000013', 'https://cdn.dkd.example/avatar/13.png', 1, NOW(), NOW()),
(14, 'Sofia Ops',      2, 'University District', 2, '1002', 'Operations',    '13900000014', 'https://cdn.dkd.example/avatar/14.png', 0, NOW(), NOW()),
(15, 'Mason Maint',    1, 'Downtown Core',       3, '1003', 'Maintenance',   '13900000015', 'https://cdn.dkd.example/avatar/15.png', 1, NOW(), NOW());

-- ============================================================
-- 10. Task Types  (type: 1=maintenance, 2=operations)
-- ============================================================
INSERT INTO tb_task_type (type_id, type_name, type) VALUES
(1, 'Deploy Machine',  1),
(2, 'Replenish Stock', 2),
(3, 'Repair / Fix',    1),
(4, 'Remove Machine',  1);

-- ============================================================
-- 11. Vending Machines  (20 total)
--     vm_status: 0=uninstalled 1=running 3=decommissioned
--     last_supply_time is NOT NULL (default '2000-01-01')
-- ============================================================
INSERT INTO tb_vending_machine (id, inner_code, channel_max_capacity, node_id, addr, last_supply_time, business_type, region_id, partner_id, vm_type_id, vm_status, running_status, longitudes, latitude, client_id, policy_id, create_time, update_time) VALUES
( 1, 'VM000001', 10,  1, 'Central Plaza Lobby',   DATE_SUB(NOW(), INTERVAL 2 DAY),  1, 1, 1, 1, 1, '{"statusCode":"1001","status":true}',  116.404, 39.915, 'mqtt-client-00001', 1, DATE_SUB(NOW(), INTERVAL 180 DAY), NOW()),
( 2, 'VM000002', 10,  1, 'Central Plaza Lobby',   DATE_SUB(NOW(), INTERVAL 1 DAY),  1, 1, 1, 1, 1, '{"statusCode":"1001","status":true}',  116.404, 39.915, 'mqtt-client-00002', 1, DATE_SUB(NOW(), INTERVAL 180 DAY), NOW()),
( 3, 'VM000003',  8,  2, 'Financial Tower',       DATE_SUB(NOW(), INTERVAL 3 DAY),  1, 1, 1, 2, 1, '{"statusCode":"1001","status":true}',  116.420, 39.920, 'mqtt-client-00003', 1, DATE_SUB(NOW(), INTERVAL 170 DAY), NOW()),
( 4, 'VM000004',  6,  2, 'Financial Tower',       DATE_SUB(NOW(), INTERVAL 5 DAY),  1, 1, 1, 3, 1, '{"statusCode":"1001","status":true}',  116.420, 39.920, 'mqtt-client-00004', 2, DATE_SUB(NOW(), INTERVAL 160 DAY), NOW()),
( 5, 'VM000005', 10,  3, 'City Hall Atrium',      DATE_SUB(NOW(), INTERVAL 4 DAY),  1, 1, 2, 1, 1, '{"statusCode":"1002","status":false}', 116.408, 39.908, 'mqtt-client-00005', 1, DATE_SUB(NOW(), INTERVAL 150 DAY), NOW()),
( 6, 'VM000006',  8,  4, 'Engineering Building',  DATE_SUB(NOW(), INTERVAL 1 DAY),  1, 2, 3, 2, 1, '{"statusCode":"1001","status":true}',  116.315, 39.984, 'mqtt-client-00006', 1, DATE_SUB(NOW(), INTERVAL 140 DAY), NOW()),
( 7, 'VM000007', 10,  5, 'Student Union',         DATE_SUB(NOW(), INTERVAL 2 DAY),  1, 2, 3, 1, 1, '{"statusCode":"1001","status":true}',  116.316, 39.986, 'mqtt-client-00007', 1, DATE_SUB(NOW(), INTERVAL 140 DAY), NOW()),
( 8, 'VM000008',  6,  6, 'Library Annex',         DATE_SUB(NOW(), INTERVAL 7 DAY),  1, 2, 3, 3, 1, '{"statusCode":"1001","status":true}',  116.317, 39.987, 'mqtt-client-00008', 3, DATE_SUB(NOW(), INTERVAL 130 DAY), NOW()),
( 9, 'VM000009', 10,  7, 'Metro Station North',   DATE_SUB(NOW(), INTERVAL 1 DAY),  2, 3, 4, 1, 1, '{"statusCode":"1001","status":true}',  116.456, 40.012, 'mqtt-client-00009', 1, DATE_SUB(NOW(), INTERVAL 120 DAY), NOW()),
(10, 'VM000010', 10,  8, 'Airport Terminal B',    DATE_SUB(NOW(), INTERVAL 1 DAY),  2, 3, 4, 1, 1, '{"statusCode":"1001","status":true}',  116.597, 40.072, 'mqtt-client-00010', 1, DATE_SUB(NOW(), INTERVAL 120 DAY), NOW()),
(11, 'VM000011',  8,  8, 'Airport Terminal B',    DATE_SUB(NOW(), INTERVAL 2 DAY),  2, 3, 4, 2, 1, '{"statusCode":"1001","status":true}',  116.597, 40.072, 'mqtt-client-00011', 2, DATE_SUB(NOW(), INTERVAL 120 DAY), NOW()),
(12, 'VM000012',  8,  9, 'Bus Interchange',       DATE_SUB(NOW(), INTERVAL 3 DAY),  2, 3, 4, 4, 1, '{"statusCode":"1001","status":true}',  116.432, 39.953, 'mqtt-client-00012', 1, DATE_SUB(NOW(), INTERVAL 110 DAY), NOW()),
(13, 'VM000013', 10, 10, 'Riverside Apartments',  DATE_SUB(NOW(), INTERVAL 6 DAY),  1, 4, 2, 1, 1, '{"statusCode":"1001","status":true}',  116.344, 40.089, 'mqtt-client-00013', 1, DATE_SUB(NOW(), INTERVAL 100 DAY), NOW()),
(14, 'VM000014',  8, 11, 'Northgate Mall',        DATE_SUB(NOW(), INTERVAL 1 DAY),  1, 4, 5, 2, 1, '{"statusCode":"1001","status":true}',  116.348, 40.094, 'mqtt-client-00014', 4, DATE_SUB(NOW(), INTERVAL 95 DAY),  NOW()),
(15, 'VM000015',  6, 12, 'Community Center',      DATE_SUB(NOW(), INTERVAL 10 DAY), 1, 4, 2, 3, 1, '{"statusCode":"1003","status":false}', 116.355, 40.101, 'mqtt-client-00015', 1, DATE_SUB(NOW(), INTERVAL 90 DAY),  NOW()),
(16, 'VM000016', 10, 13, 'Grand Mall — L1',       DATE_SUB(NOW(), INTERVAL 1 DAY),  1, 5, 5, 1, 1, '{"statusCode":"1001","status":true}',  116.489, 39.822, 'mqtt-client-00016', 2, DATE_SUB(NOW(), INTERVAL 80 DAY),  NOW()),
(17, 'VM000017',  8, 13, 'Grand Mall — L1',       DATE_SUB(NOW(), INTERVAL 2 DAY),  1, 5, 5, 4, 1, '{"statusCode":"1001","status":true}',  116.489, 39.822, 'mqtt-client-00017', 1, DATE_SUB(NOW(), INTERVAL 80 DAY),  NOW()),
(18, 'VM000018',  8, 14, 'Cinema Complex',        DATE_SUB(NOW(), INTERVAL 4 DAY),  1, 5, 5, 2, 1, '{"statusCode":"1001","status":true}',  116.491, 39.825, 'mqtt-client-00018', 1, DATE_SUB(NOW(), INTERVAL 70 DAY),  NOW()),
(19, 'VM000019', 10, 15, 'Stadium Concourse',     DATE_SUB(NOW(), INTERVAL 1 DAY),  1, 5, 6, 1, 1, '{"statusCode":"1001","status":true}',  116.396, 39.991, 'mqtt-client-00019', 5, DATE_SUB(NOW(), INTERVAL 60 DAY),  NOW());
-- VM 20 left unassigned on purpose — requires a node before insert
INSERT INTO tb_vending_machine (id, inner_code, channel_max_capacity, node_id, addr, last_supply_time, business_type, region_id, partner_id, vm_type_id, vm_status, running_status, client_id, create_time, update_time) VALUES
(20, 'VM000020', 0, 1, '(awaiting deployment)', '2000-01-01 00:00:00', 1, 1, 1, 1, 0, NULL, NULL, DATE_SUB(NOW(), INTERVAL 30 DAY), NOW());

-- ============================================================
-- 12. Channels — machine 1 hand-tuned, machines 2..19 via CTE
-- ============================================================
INSERT INTO tb_channel (channel_code, sku_id, vm_id, inner_code, max_capacity, current_capacity, last_supply_time, create_time, update_time) VALUES
('1-1',  1, 1, 'VM000001', 10, 8,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('1-2',  2, 1, 'VM000001', 10, 2,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('1-3',  3, 1, 'VM000001', 10, 9,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('1-4',  4, 1, 'VM000001', 10, 10, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('1-5',  5, 1, 'VM000001', 10, 0,  DATE_SUB(NOW(), INTERVAL 5 DAY), NOW(), NOW()),
('1-6',  6, 1, 'VM000001', 10, 7,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('2-1',  7, 1, 'VM000001', 10, 6,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('2-2',  8, 1, 'VM000001', 10, 1,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('2-3',  9, 1, 'VM000001', 10, 9,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('2-4', 10, 1, 'VM000001', 10, 10, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('2-5', 11, 1, 'VM000001', 10, 7,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('2-6', 12, 1, 'VM000001', 10, 8,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('3-1', 13, 1, 'VM000001', 10, 9,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('3-2', 14, 1, 'VM000001', 10, 3,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('3-3', 15, 1, 'VM000001', 10, 10, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('3-4', 16, 1, 'VM000001', 10, 8,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('3-5', 17, 1, 'VM000001', 10, 7,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('3-6', 18, 1, 'VM000001', 10, 10, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('4-1', 19, 1, 'VM000001', 10, 9,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('4-2', 20, 1, 'VM000001', 10, 0,  DATE_SUB(NOW(), INTERVAL 8 DAY), NOW(), NOW()),
('4-3', 21, 1, 'VM000001', 10, 6,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('4-4', 22, 1, 'VM000001', 10, 8,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('4-5', 23, 1, 'VM000001', 10, 7,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('4-6', 24, 1, 'VM000001', 10, 9,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('5-1', 25, 1, 'VM000001', 10, 5,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('5-2',  1, 1, 'VM000001', 10, 8,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('5-3',  2, 1, 'VM000001', 10, 10, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('5-4',  3, 1, 'VM000001', 10, 7,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('5-5',  4, 1, 'VM000001', 10, 9,  DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
('5-6',  5, 1, 'VM000001', 10, 10, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW(), NOW());

-- Machines 2..19: 70% healthy / 20% low (1..3) / 10% empty
INSERT INTO tb_channel (channel_code, sku_id, vm_id, inner_code, max_capacity, current_capacity, last_supply_time, create_time, update_time)
WITH RECURSIVE nums AS (
    SELECT 1 AS n UNION ALL SELECT n+1 FROM nums WHERE n < 30
),
vm_cols AS (
    SELECT m.id AS vm_id, m.inner_code, m.channel_max_capacity, m.vm_row, m.vm_col
    FROM tb_vending_machine m
    JOIN tb_vm_type t ON t.id = m.vm_type_id
    CROSS JOIN ( SELECT 1 AS one ) one
)
SELECT
    CONCAT(
        CEIL(n.n / t.vm_col),
        '-',
        ((n.n - 1) MOD t.vm_col) + 1
    ) AS channel_code,
    ((n.n - 1) MOD 25) + 1                                                       AS sku_id,
    m.id                                                                         AS vm_id,
    m.inner_code,
    m.channel_max_capacity                                                       AS max_capacity,
    CASE
        WHEN (n.n + m.id) % 10 = 0                THEN 0
        WHEN (n.n + m.id) % 10 IN (1, 2)          THEN 1 + ((n.n * m.id) % 3)
        ELSE 6 + ((n.n * 3 + m.id) % 5)
    END                                                                          AS current_capacity,
    DATE_SUB(NOW(), INTERVAL 1 + ((m.id * 7 + n.n) % 7) DAY)                     AS last_supply_time,
    NOW(),
    NOW()
FROM tb_vending_machine m
JOIN tb_vm_type t ON t.id = m.vm_type_id
JOIN nums n ON n.n <= t.vm_row * t.vm_col
WHERE m.id BETWEEN 2 AND 19;

-- ============================================================
-- 13. Tasks  (PK = task_id, status: 1=pending 2=accepted 3=cancelled 4=done)
-- ============================================================
INSERT INTO tb_task (task_id, task_code, task_status, create_type, inner_code, user_id, user_name, region_id, `desc`, product_type_id, assignor_id, addr, create_time, update_time) VALUES
-- completed
( 1, 'T20260201001', 4, 1, 'VM000001',  3, 'Liam Ops',     1, 'Replenish low beverages',  2, 1, 'Central Plaza Lobby',    DATE_SUB(NOW(), INTERVAL 55 DAY), DATE_SUB(NOW(), INTERVAL 55 DAY)),
( 2, 'T20260201002', 4, 1, 'VM000002',  4, 'Noah Ops',     1, 'Routine restock',          2, 1, 'Central Plaza Lobby',    DATE_SUB(NOW(), INTERVAL 52 DAY), DATE_SUB(NOW(), INTERVAL 52 DAY)),
( 3, 'T20260205003', 4, 2, 'VM000003',  9, 'James Maint',  1, 'Coin slot stuck',          3, 1, 'Financial Tower',        DATE_SUB(NOW(), INTERVAL 48 DAY), DATE_SUB(NOW(), INTERVAL 48 DAY)),
( 4, 'T20260210004', 4, 1, 'VM000006',  5, 'Emma Ops',     2, 'Replenish snacks',         2, 1, 'Engineering Building',   DATE_SUB(NOW(), INTERVAL 42 DAY), DATE_SUB(NOW(), INTERVAL 42 DAY)),
( 5, 'T20260212005', 4, 1, 'VM000007',  5, 'Emma Ops',     2, 'Student union top-up',     2, 1, 'Student Union',          DATE_SUB(NOW(), INTERVAL 40 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY)),
( 6, 'T20260214006', 4, 2, 'VM000010', 11, 'Ethan Maint',  3, 'Temperature alarm',        3, 2, 'Airport Terminal B',     DATE_SUB(NOW(), INTERVAL 38 DAY), DATE_SUB(NOW(), INTERVAL 38 DAY)),
( 7, 'T20260218007', 4, 1, 'VM000013',  7, 'Mia Ops',      4, 'Weekend stock',            2, 1, 'Riverside Apartments',   DATE_SUB(NOW(), INTERVAL 34 DAY), DATE_SUB(NOW(), INTERVAL 34 DAY)),
( 8, 'T20260222008', 4, 1, 'VM000016',  8, 'Zoe Ops',      5, 'Grand mall restock',       2, 1, 'Grand Mall — L1',        DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
( 9, 'T20260225009', 4, 1, 'VM000019',  8, 'Zoe Ops',      5, 'Stadium event prep',       2, 1, 'Stadium Concourse',      DATE_SUB(NOW(), INTERVAL 27 DAY), DATE_SUB(NOW(), INTERVAL 27 DAY)),
(10, 'T20260301010', 4, 2, 'VM000005', 15, 'Mason Maint',  1, 'Payment reader replaced',  3, 1, 'City Hall Atrium',       DATE_SUB(NOW(), INTERVAL 23 DAY), DATE_SUB(NOW(), INTERVAL 23 DAY)),
(11, 'T20260305011', 4, 1, 'VM000008',  5, 'Emma Ops',     2, 'Low stock alert',          2, 1, 'Library Annex',          DATE_SUB(NOW(), INTERVAL 19 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY)),
(12, 'T20260308012', 4, 1, 'VM000011',  6, 'Ava Ops',      3, 'Transit hub refill',       2, 2, 'Airport Terminal B',     DATE_SUB(NOW(), INTERVAL 16 DAY), DATE_SUB(NOW(), INTERVAL 16 DAY)),
(13, 'T20260312013', 4, 1, 'VM000014',  7, 'Mia Ops',      4, 'Mall Tuesday restock',     2, 1, 'Northgate Mall',         DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY)),
(14, 'T20260315014', 4, 1, 'VM000017',  8, 'Zoe Ops',      5, 'Cooler restock',           2, 1, 'Grand Mall — L1',        DATE_SUB(NOW(), INTERVAL  9 DAY), DATE_SUB(NOW(), INTERVAL  9 DAY)),
(15, 'T20260318015', 4, 2, 'VM000015', 12, 'Lucas Maint',  4, 'Door sensor fix',          3, 1, 'Community Center',       DATE_SUB(NOW(), INTERVAL  6 DAY), DATE_SUB(NOW(), INTERVAL  6 DAY)),
-- accepted / in-progress
(16, 'T20260320016', 2, 1, 'VM000001',  3, 'Liam Ops',     1, 'Refill cola line',         2, 1, 'Central Plaza Lobby',    DATE_SUB(NOW(), INTERVAL  4 DAY), DATE_SUB(NOW(), INTERVAL  3 DAY)),
(17, 'T20260321017', 2, 1, 'VM000009',  6, 'Ava Ops',      3, 'Metro station refill',     2, 2, 'Metro Station North',    DATE_SUB(NOW(), INTERVAL  3 DAY), DATE_SUB(NOW(), INTERVAL  2 DAY)),
(18, 'T20260321018', 2, 2, 'VM000004',  9, 'James Maint',  1, 'Compressor noise',         3, 1, 'Financial Tower',        DATE_SUB(NOW(), INTERVAL  3 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
-- pending
(19, 'T20260322019', 1, 1, 'VM000002',  4, 'Noah Ops',     1, 'Routine weekly restock',   2, 1, 'Central Plaza Lobby',    DATE_SUB(NOW(), INTERVAL  2 DAY), DATE_SUB(NOW(), INTERVAL  2 DAY)),
(20, 'T20260322020', 1, 1, 'VM000007',  5, 'Emma Ops',     2, 'Snack isle low',           2, 1, 'Student Union',          DATE_SUB(NOW(), INTERVAL  2 DAY), DATE_SUB(NOW(), INTERVAL  2 DAY)),
(21, 'T20260323021', 1, 2, 'VM000013', 12, 'Lucas Maint',  4, 'Light flicker report',     3, 1, 'Riverside Apartments',   DATE_SUB(NOW(), INTERVAL  1 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(22, 'T20260323022', 1, 1, 'VM000016',  8, 'Zoe Ops',      5, 'Pre-weekend replenish',    2, 1, 'Grand Mall — L1',        DATE_SUB(NOW(), INTERVAL  1 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(23, 'T20260324023', 1, 1, 'VM000019',  8, 'Zoe Ops',      5, 'Big game prep',            2, 1, 'Stadium Concourse',      NOW(),                            NOW()),
(24, 'T20260324024', 1, 2, 'VM000018', 13, 'Henry Maint',  5, 'Card reader intermittent', 3, 2, 'Cinema Complex',         NOW(),                            NOW()),
(25, 'T20260324025', 1, 1, 'VM000020',  3, 'Liam Ops',     1, 'Initial deployment',       1, 1, 'TBD',                    NOW(),                            NOW()),
-- cancelled
(26, 'T20260215026', 3, 1, 'VM000015',  7, 'Mia Ops',      4, 'Duplicate request',        2, 1, 'Community Center',       DATE_SUB(NOW(), INTERVAL 37 DAY), DATE_SUB(NOW(), INTERVAL 36 DAY)),
(27, 'T20260310027', 3, 2, 'VM000005', 15, 'Mason Maint',  1, 'False alarm',              3, 1, 'City Hall Atrium',       DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY));

-- Task details (replenish expect-capacities)
INSERT INTO tb_task_details (task_id, channel_code, expect_capacity, sku_id, sku_name, sku_image) VALUES
( 1, '1-2',  8,  2, 'Pepsi Max',         'https://cdn.dkd.example/sku/2.png'),
( 1, '2-2',  9,  8, 'Orange Juice 100%', 'https://cdn.dkd.example/sku/8.png'),
( 1, '4-2', 10, 20, 'Dark Chocolate',    'https://cdn.dkd.example/sku/20.png'),
( 2, '1-5', 10,  5, 'Nestea Lemon',      'https://cdn.dkd.example/sku/5.png'),
( 4, '1-1',  8,  1, 'Coca-Cola Classic', 'https://cdn.dkd.example/sku/1.png'),
( 4, '1-2',  8,  2, 'Pepsi Max',         'https://cdn.dkd.example/sku/2.png'),
( 5, '2-2',  9,  8, 'Orange Juice 100%', 'https://cdn.dkd.example/sku/8.png'),
( 7, '3-2',  7, 14, 'Doritos Nacho',     'https://cdn.dkd.example/sku/14.png'),
( 8, '4-3',  6, 21, 'Iced Coffee Latte', 'https://cdn.dkd.example/sku/21.png'),
(11, '5-1',  5, 25, 'Fresh Salad Cup',   'https://cdn.dkd.example/sku/25.png'),
(16, '1-2',  8,  2, 'Pepsi Max',         'https://cdn.dkd.example/sku/2.png'),
(16, '1-5', 10,  5, 'Nestea Lemon',      'https://cdn.dkd.example/sku/5.png'),
(17, '2-3',  9,  9, 'Apple Juice',       'https://cdn.dkd.example/sku/9.png'),
(19, '1-1', 10,  1, 'Coca-Cola Classic', 'https://cdn.dkd.example/sku/1.png'),
(19, '3-6', 10, 18, 'Protein Bar',       'https://cdn.dkd.example/sku/18.png'),
(20, '2-2',  9,  8, 'Orange Juice 100%', 'https://cdn.dkd.example/sku/8.png'),
(22, '4-2', 10, 20, 'Dark Chocolate',    'https://cdn.dkd.example/sku/20.png'),
(23, '5-1', 10, 25, 'Fresh Salad Cup',   'https://cdn.dkd.example/sku/25.png');

-- Task daily rollups (by employee)
INSERT INTO tb_task_collect (user_id, finish_count, progress_count, cancel_count, collect_date) VALUES
( 3, 2, 1, 0, CURDATE() - INTERVAL 1 DAY),
( 4, 2, 0, 0, CURDATE() - INTERVAL 2 DAY),
( 5, 3, 0, 0, CURDATE() - INTERVAL 3 DAY),
( 6, 1, 1, 0, CURDATE() - INTERVAL 2 DAY),
( 7, 2, 0, 1, CURDATE() - INTERVAL 5 DAY),
( 8, 3, 0, 0, CURDATE() - INTERVAL 7 DAY),
( 9, 2, 1, 0, CURDATE() - INTERVAL 2 DAY),
(11, 1, 0, 0, CURDATE() - INTERVAL 4 DAY),
(12, 1, 1, 0, CURDATE() - INTERVAL 1 DAY),
(15, 1, 0, 1, CURDATE() - INTERVAL 6 DAY);

-- ============================================================
-- 14. Orders  — 90-day distribution, id supplied via ROW_NUMBER.
--     tb_order.id is NOT AUTO_INCREMENT so we generate from base.
--     pay_status 1 = paid; 0 = abandoned. No refund state changed.
-- ============================================================
INSERT INTO tb_order (
    id, order_no, third_no, inner_code, channel_code, sku_id, sku_name, class_id, status,
    amount, price, pay_type, pay_status, bill,
    addr, region_id, region_name, business_type, partner_id,
    open_id, node_id, node_name, cancel_desc,
    create_time, update_time
)
WITH RECURSIVE seq AS (
    SELECT 0 AS n UNION ALL SELECT n+1 FROM seq WHERE n < 499
),
vm AS (
    SELECT m.id AS vm_id, m.inner_code, m.addr, m.node_id, m.partner_id, m.region_id, m.business_type,
           n.node_name, r.region_name, p.profit_ratio
    FROM tb_vending_machine m
    JOIN tb_node n   ON n.id = m.node_id
    JOIN tb_region r ON r.id = m.region_id
    JOIN tb_partner p ON p.id = m.partner_id
    WHERE m.vm_status = 1
),
orders AS (
    SELECT
        seq.n,
        vm.*,
        sku.sku_id   AS o_sku_id,
        sku.sku_name AS o_sku_name,
        sku.class_id AS o_class_id,
        sku.price    AS o_price,
        ROW_NUMBER() OVER () AS rn
    FROM seq
    CROSS JOIN vm
    JOIN tb_sku sku ON sku.sku_id = ((seq.n + vm.vm_id) % 25) + 1
    WHERE (seq.n + vm.vm_id) % 7 != 0
)
SELECT
    1700000000000000000 + rn                                                          AS id,
    CONCAT(inner_code, LPAD(CAST(UNIX_TIMESTAMP(NOW()) AS CHAR), 10, '0'), LPAD(rn, 6, '0')) AS order_no,
    NULL                                                                              AS third_no,
    inner_code,
    CONCAT(CEIL(((n % 30) + 1) / 6), '-', ((n % 6) + 1))                              AS channel_code,
    o_sku_id                                                                          AS sku_id,
    o_sku_name                                                                        AS sku_name,
    o_class_id                                                                        AS class_id,
    CASE WHEN n % 25 = 0 THEN 3  -- dispense-fail  ~4%
         WHEN n % 50 = 7 THEN 0  -- pay-pending    ~2%
         WHEN n % 77 = 5 THEN 4  -- cancelled      ~1%
         ELSE 2 END                                                                   AS status,
    o_price                                                                           AS amount,
    o_price                                                                           AS price,
    CASE WHEN n % 3 = 0 THEN 'wxpay' ELSE 'alipay' END                                AS pay_type,
    CASE WHEN n % 25 = 0 OR n % 50 = 7 OR n % 77 = 5 THEN 0 ELSE 1 END                AS pay_status,
    FLOOR(o_price * profit_ratio / 100)                                               AS bill,
    addr, region_id, region_name, business_type, partner_id,
    CONCAT('mock_openid_', LPAD(n % 120, 3, '0'))                                     AS open_id,
    node_id, node_name, ''                                                            AS cancel_desc,
    DATE_SUB(NOW(), INTERVAL n * 260 MINUTE)                                          AS create_time,
    DATE_SUB(NOW(), INTERVAL n * 260 MINUTE)                                          AS update_time
FROM orders;

-- Vendout telemetry (only for orders that successfully dispensed)
INSERT INTO tb_vendout_running (order_no, inner_code, channel_code, status, create_time, update_time)
SELECT order_no, inner_code, channel_code, '1', create_time, update_time
FROM tb_order
WHERE status = 2
ORDER BY create_time DESC
LIMIT 200;

-- ============================================================
-- 15. Daily rollups by partner+node+date
-- ============================================================
INSERT INTO tb_order_collect (id, partner_id, partner_name, order_total_money, order_date, total_bill, node_id, node_name, order_count, ratio, region_name)
SELECT
    (UNIX_TIMESTAMP(DATE(o.create_time)) * 10000) + (o.partner_id * 100) + (o.node_id % 100) AS id,
    o.partner_id,
    p.partner_name,
    SUM(o.amount)                 AS order_total_money,
    DATE(o.create_time)           AS order_date,
    SUM(o.bill)                   AS total_bill,
    o.node_id,
    MAX(o.node_name)              AS node_name,
    COUNT(*)                      AS order_count,
    p.profit_ratio                AS ratio,
    MAX(o.region_name)            AS region_name
FROM tb_order o
JOIN tb_partner p ON p.id = o.partner_id
WHERE o.status = 2 AND o.pay_status = 1
GROUP BY DATE(o.create_time), o.partner_id, p.partner_name, p.profit_ratio, o.node_id;

SET FOREIGN_KEY_CHECKS = @OLD_FK;

-- ============================================================
-- Sanity (run manually)
-- ============================================================
-- SELECT 'regions'  AS tbl, COUNT(*) FROM tb_region
-- UNION ALL SELECT 'partners',        COUNT(*) FROM tb_partner
-- UNION ALL SELECT 'nodes',           COUNT(*) FROM tb_node
-- UNION ALL SELECT 'vm_types',        COUNT(*) FROM tb_vm_type
-- UNION ALL SELECT 'machines',        COUNT(*) FROM tb_vending_machine
-- UNION ALL SELECT 'channels',        COUNT(*) FROM tb_channel
-- UNION ALL SELECT 'sku_classes',     COUNT(*) FROM tb_sku_class
-- UNION ALL SELECT 'skus',            COUNT(*) FROM tb_sku
-- UNION ALL SELECT 'roles',           COUNT(*) FROM tb_role
-- UNION ALL SELECT 'emps',            COUNT(*) FROM tb_emp
-- UNION ALL SELECT 'task_types',      COUNT(*) FROM tb_task_type
-- UNION ALL SELECT 'tasks',           COUNT(*) FROM tb_task
-- UNION ALL SELECT 'task_details',    COUNT(*) FROM tb_task_details
-- UNION ALL SELECT 'task_collect',    COUNT(*) FROM tb_task_collect
-- UNION ALL SELECT 'policies',        COUNT(*) FROM tb_policy
-- UNION ALL SELECT 'orders',          COUNT(*) FROM tb_order
-- UNION ALL SELECT 'order_collect',   COUNT(*) FROM tb_order_collect
-- UNION ALL SELECT 'vendout_running', COUNT(*) FROM tb_vendout_running;

SET time_zone = @OLD_TZ;
