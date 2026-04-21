-- ============================================================
-- DKD Vending Machine System — Comprehensive Mock Data Seed
-- ------------------------------------------------------------
-- Schema-accurate (column names match dkd.sql CREATE TABLEs).
-- Wipes all business tables (TRUNCATE) then re-seeds everything:
--   regions, partners, nodes, vm types, vending machines,
--   channels, skus, sku classes, policies, roles, employees,
--   task types, tasks (60), task details, task daily rollups,
--   orders (~1 year of history), vendout telemetry, daily &
--   monthly partner rollups, and the auto-replenish alert config.
--
-- Usage:  mysql -uroot -p'' dkd < initialize_mock_data_full.sql
-- Safety: TRUNCATEs business tables first. sys_* tables untouched.
-- Requires: MySQL 8.0+ (uses WITH RECURSIVE CTE). cte_max_recursion_depth raised for order seeding.
-- ============================================================

SET @OLD_FK = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
SET @OLD_TZ = @@session.time_zone;
SET time_zone = '+00:00';
SET SESSION cte_max_recursion_depth = 5000;
SET @OLD_SQL_MODE = @@SESSION.sql_mode;
SET SESSION sql_mode = REPLACE(REPLACE(@@SESSION.sql_mode, 'ONLY_FULL_GROUP_BY,', ''), 'ONLY_FULL_GROUP_BY', '');

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
TRUNCATE TABLE tb_job;

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
-- Product images use picsum.photos with deterministic seeds — real photos, public CDN, always resolve.
INSERT INTO tb_sku (sku_id, sku_name, sku_image, brand_Name, unit, price, class_id, is_discount, create_time, update_time) VALUES
( 1, 'Coca-Cola Classic',  'https://picsum.photos/seed/dkd-sku-1/240/240',  'Coca-Cola',   '500ML', 350, 1, 0, NOW(), NOW()),
( 2, 'Pepsi Max',          'https://picsum.photos/seed/dkd-sku-2/240/240',  'Pepsi',       '500ML', 350, 1, 1, NOW(), NOW()),
( 3, 'Sprite',             'https://picsum.photos/seed/dkd-sku-3/240/240',  'Coca-Cola',   '500ML', 350, 1, 0, NOW(), NOW()),
( 4, 'Fanta Orange',       'https://picsum.photos/seed/dkd-sku-4/240/240',  'Coca-Cola',   '500ML', 350, 1, 0, NOW(), NOW()),
( 5, 'Nestea Lemon',       'https://picsum.photos/seed/dkd-sku-5/240/240',  'Nestle',      '500ML', 400, 1, 0, NOW(), NOW()),
( 6, 'Still Water 600',    'https://picsum.photos/seed/dkd-sku-6/240/240',  'AquaPure',    '600ML', 200, 1, 0, NOW(), NOW()),
( 7, 'Sparkling Water',    'https://picsum.photos/seed/dkd-sku-7/240/240',  'AquaPure',    '500ML', 300, 1, 0, NOW(), NOW()),
( 8, 'Orange Juice 100%',  'https://picsum.photos/seed/dkd-sku-8/240/240',  'FreshCo',     '350ML', 500, 3, 0, NOW(), NOW()),
( 9, 'Apple Juice',        'https://picsum.photos/seed/dkd-sku-9/240/240',  'FreshCo',     '350ML', 500, 3, 0, NOW(), NOW()),
(10, 'Kit-Kat 4-Finger',   'https://picsum.photos/seed/dkd-sku-10/240/240', 'Nestle',      '45G',   250, 4, 0, NOW(), NOW()),
(11, 'Snickers Bar',       'https://picsum.photos/seed/dkd-sku-11/240/240', 'Mars',        '50G',   300, 4, 0, NOW(), NOW()),
(12, 'M&M Peanut',         'https://picsum.photos/seed/dkd-sku-12/240/240', 'Mars',        '45G',   300, 4, 0, NOW(), NOW()),
(13, 'Lay''s Classic',     'https://picsum.photos/seed/dkd-sku-13/240/240', 'Lay''s',      '70G',   400, 2, 0, NOW(), NOW()),
(14, 'Doritos Nacho',      'https://picsum.photos/seed/dkd-sku-14/240/240', 'Frito',       '70G',   400, 2, 1, NOW(), NOW()),
(15, 'Oreo Cookies',       'https://picsum.photos/seed/dkd-sku-15/240/240', 'Mondelez',    '66G',   350, 4, 0, NOW(), NOW()),
(16, 'Pringles Original',  'https://picsum.photos/seed/dkd-sku-16/240/240', 'Pringles',    '110G',  550, 2, 0, NOW(), NOW()),
(17, 'Granola Bar',        'https://picsum.photos/seed/dkd-sku-17/240/240', 'Nature',      '40G',   250, 3, 0, NOW(), NOW()),
(18, 'Protein Bar',        'https://picsum.photos/seed/dkd-sku-18/240/240', 'FitLab',      '60G',   600, 3, 0, NOW(), NOW()),
(19, 'Gummy Bears',        'https://picsum.photos/seed/dkd-sku-19/240/240', 'Haribo',      '80G',   300, 4, 0, NOW(), NOW()),
(20, 'Dark Chocolate',     'https://picsum.photos/seed/dkd-sku-20/240/240', 'Lindt',       '100G',  800, 4, 0, NOW(), NOW()),
(21, 'Iced Coffee Latte',  'https://picsum.photos/seed/dkd-sku-21/240/240', 'Starbucks',   '250ML', 700, 6, 0, NOW(), NOW()),
(22, 'Hot Coffee Can',     'https://picsum.photos/seed/dkd-sku-22/240/240', 'Georgia',     '290ML', 450, 6, 0, NOW(), NOW()),
(23, 'Green Tea',          'https://picsum.photos/seed/dkd-sku-23/240/240', 'Ito En',      '500ML', 350, 6, 0, NOW(), NOW()),
(24, 'Yogurt Drink',       'https://picsum.photos/seed/dkd-sku-24/240/240', 'Yakult',      '100ML', 250, 5, 0, NOW(), NOW()),
(25, 'Fresh Salad Cup',    'https://picsum.photos/seed/dkd-sku-25/240/240', 'GreenGo',     '180G',  950, 5, 0, NOW(), NOW());

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
-- 13. Tasks  (PK = task_id)
--     status: 1=pending, 2=in-progress, 3=cancelled, 4=done
--     product_type_id: 1=Deploy, 2=Supply/Replenish, 3=Maintenance, 4=Revoke
--     Pending tasks may be UNASSIGNED (user_id = NULL) awaiting dispatch,
--     or assigned but not yet accepted by the operator.
-- ============================================================
INSERT INTO tb_task (task_id, task_code, task_status, create_type, inner_code, user_id, user_name, region_id, `desc`, product_type_id, assignor_id, addr, create_time, update_time) VALUES
-- ---------- DONE (25 tasks, spread over last 60 days) ----------
( 1, 'T20260215001', 4, 1, 'VM000001',  3, 'Liam Ops',     1, 'Replenish low beverages',        2, 1, 'Central Plaza Lobby',    DATE_SUB(NOW(), INTERVAL 58 DAY), DATE_SUB(NOW(), INTERVAL 58 DAY)),
( 2, 'T20260216002', 4, 1, 'VM000002',  4, 'Noah Ops',     1, 'Routine restock',                 2, 1, 'Central Plaza Lobby',    DATE_SUB(NOW(), INTERVAL 56 DAY), DATE_SUB(NOW(), INTERVAL 56 DAY)),
( 3, 'T20260218003', 4, 2, 'VM000003',  9, 'James Maint',  1, 'Coin slot stuck — cleared',       3, 1, 'Financial Tower',        DATE_SUB(NOW(), INTERVAL 54 DAY), DATE_SUB(NOW(), INTERVAL 54 DAY)),
( 4, 'T20260221004', 4, 1, 'VM000006',  5, 'Emma Ops',     2, 'Snack refill weekly',             2, 1, 'Engineering Building',   DATE_SUB(NOW(), INTERVAL 51 DAY), DATE_SUB(NOW(), INTERVAL 51 DAY)),
( 5, 'T20260223005', 4, 1, 'VM000007',  5, 'Emma Ops',     2, 'Student union top-up',            2, 1, 'Student Union',          DATE_SUB(NOW(), INTERVAL 48 DAY), DATE_SUB(NOW(), INTERVAL 48 DAY)),
( 6, 'T20260225006', 4, 2, 'VM000010', 11, 'Ethan Maint',  3, 'Temperature alarm — fixed',       3, 2, 'Airport Terminal B',     DATE_SUB(NOW(), INTERVAL 46 DAY), DATE_SUB(NOW(), INTERVAL 46 DAY)),
( 7, 'T20260228007', 4, 1, 'VM000013',  7, 'Mia Ops',      4, 'Weekend stock',                   2, 1, 'Riverside Apartments',   DATE_SUB(NOW(), INTERVAL 43 DAY), DATE_SUB(NOW(), INTERVAL 43 DAY)),
( 8, 'T20260303008', 4, 1, 'VM000016',  8, 'Zoe Ops',      5, 'Grand mall restock',              2, 1, 'Grand Mall — L1',        DATE_SUB(NOW(), INTERVAL 40 DAY), DATE_SUB(NOW(), INTERVAL 40 DAY)),
( 9, 'T20260306009', 4, 1, 'VM000019',  8, 'Zoe Ops',      5, 'Stadium event prep',              2, 1, 'Stadium Concourse',      DATE_SUB(NOW(), INTERVAL 37 DAY), DATE_SUB(NOW(), INTERVAL 37 DAY)),
(10, 'T20260308010', 4, 2, 'VM000005', 15, 'Mason Maint',  1, 'Payment reader replaced',         3, 1, 'City Hall Atrium',       DATE_SUB(NOW(), INTERVAL 35 DAY), DATE_SUB(NOW(), INTERVAL 35 DAY)),
(11, 'T20260311011', 4, 1, 'VM000008',  5, 'Emma Ops',     2, 'Low stock alert',                 2, 1, 'Library Annex',          DATE_SUB(NOW(), INTERVAL 32 DAY), DATE_SUB(NOW(), INTERVAL 32 DAY)),
(12, 'T20260313012', 4, 1, 'VM000011',  6, 'Ava Ops',      3, 'Transit hub refill',              2, 2, 'Airport Terminal B',     DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 30 DAY)),
(13, 'T20260316013', 4, 1, 'VM000014',  7, 'Mia Ops',      4, 'Mall Tuesday restock',            2, 1, 'Northgate Mall',         DATE_SUB(NOW(), INTERVAL 27 DAY), DATE_SUB(NOW(), INTERVAL 27 DAY)),
(14, 'T20260319014', 4, 1, 'VM000017',  8, 'Zoe Ops',      5, 'Cooler restock',                  2, 1, 'Grand Mall — L1',        DATE_SUB(NOW(), INTERVAL 24 DAY), DATE_SUB(NOW(), INTERVAL 24 DAY)),
(15, 'T20260322015', 4, 2, 'VM000015', 12, 'Lucas Maint',  4, 'Door sensor fix',                 3, 1, 'Community Center',       DATE_SUB(NOW(), INTERVAL 21 DAY), DATE_SUB(NOW(), INTERVAL 21 DAY)),
(16, 'T20260324016', 4, 1, 'VM000004',  4, 'Noah Ops',     1, 'Financial district top-up',       2, 1, 'Financial Tower',        DATE_SUB(NOW(), INTERVAL 19 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY)),
(17, 'T20260326017', 4, 1, 'VM000012',  6, 'Ava Ops',      3, 'Airport snack refill',            2, 2, 'Airport Terminal A',     DATE_SUB(NOW(), INTERVAL 17 DAY), DATE_SUB(NOW(), INTERVAL 17 DAY)),
(18, 'T20260328018', 4, 2, 'VM000009', 13, 'Henry Maint',  3, 'Fan replacement',                 3, 2, 'Metro Station North',    DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY)),
(19, 'T20260330019', 4, 1, 'VM000002',  3, 'Liam Ops',     1, 'Cold drink line refill',          2, 1, 'Central Plaza Lobby',    DATE_SUB(NOW(), INTERVAL 13 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY)),
(20, 'T20260401020', 4, 1, 'VM000006',  5, 'Emma Ops',     2, 'Campus restock',                  2, 1, 'Engineering Building',   DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY)),
(21, 'T20260403021', 4, 1, 'VM000018',  8, 'Zoe Ops',      5, 'Cinema lobby refill',             2, 1, 'Cinema Complex',         DATE_SUB(NOW(), INTERVAL  9 DAY), DATE_SUB(NOW(), INTERVAL  9 DAY)),
(22, 'T20260405022', 4, 2, 'VM000001',  9, 'James Maint',  1, 'Bill validator calibration',      3, 1, 'Central Plaza Lobby',    DATE_SUB(NOW(), INTERVAL  7 DAY), DATE_SUB(NOW(), INTERVAL  7 DAY)),
(23, 'T20260407023', 4, 1, 'VM000020',  3, 'Liam Ops',     1, 'Initial deployment — go-live',    1, 1, 'Harbor Walkway',         DATE_SUB(NOW(), INTERVAL  5 DAY), DATE_SUB(NOW(), INTERVAL  5 DAY)),
(24, 'T20260409024', 4, 1, 'VM000013',  7, 'Mia Ops',      4, 'Apartment block refill',          2, 1, 'Riverside Apartments',   DATE_SUB(NOW(), INTERVAL  3 DAY), DATE_SUB(NOW(), INTERVAL  3 DAY)),
(25, 'T20260411025', 4, 1, 'VM000016',  8, 'Zoe Ops',      5, 'Mall pre-weekend',                2, 1, 'Grand Mall — L1',        DATE_SUB(NOW(), INTERVAL  2 DAY), DATE_SUB(NOW(), INTERVAL  2 DAY)),
-- ---------- IN PROGRESS (15 tasks, last 7 days) ----------
(26, 'T20260410026', 2, 1, 'VM000001',  3, 'Liam Ops',     1, 'Refill cola & water',             2, 1, 'Central Plaza Lobby',    DATE_SUB(NOW(), INTERVAL  5 DAY), DATE_SUB(NOW(), INTERVAL  4 DAY)),
(27, 'T20260411027', 2, 1, 'VM000009',  6, 'Ava Ops',      3, 'Metro station refill',            2, 2, 'Metro Station North',    DATE_SUB(NOW(), INTERVAL  4 DAY), DATE_SUB(NOW(), INTERVAL  3 DAY)),
(28, 'T20260411028', 2, 2, 'VM000004',  9, 'James Maint',  1, 'Compressor noise diagnosis',      3, 1, 'Financial Tower',        DATE_SUB(NOW(), INTERVAL  4 DAY), DATE_SUB(NOW(), INTERVAL  2 DAY)),
(29, 'T20260412029', 2, 1, 'VM000011',  6, 'Ava Ops',      3, 'Airport hub restock',             2, 2, 'Airport Terminal B',     DATE_SUB(NOW(), INTERVAL  3 DAY), DATE_SUB(NOW(), INTERVAL  2 DAY)),
(30, 'T20260412030', 2, 1, 'VM000007',  5, 'Emma Ops',     2, 'Student union quick top-up',      2, 1, 'Student Union',          DATE_SUB(NOW(), INTERVAL  3 DAY), DATE_SUB(NOW(), INTERVAL  2 DAY)),
(31, 'T20260413031', 2, 1, 'VM000017',  8, 'Zoe Ops',      5, 'Mall L1 cooler refill',           2, 1, 'Grand Mall — L1',        DATE_SUB(NOW(), INTERVAL  2 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(32, 'T20260413032', 2, 2, 'VM000010', 11, 'Ethan Maint',  3, 'Display flicker troubleshooting', 3, 2, 'Airport Terminal B',     DATE_SUB(NOW(), INTERVAL  2 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(33, 'T20260414033', 2, 1, 'VM000014',  7, 'Mia Ops',      4, 'Northgate Mall refill',           2, 1, 'Northgate Mall',         DATE_SUB(NOW(), INTERVAL  2 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(34, 'T20260414034', 2, 1, 'VM000008',  5, 'Emma Ops',     2, 'Library quick restock',           2, 1, 'Library Annex',          DATE_SUB(NOW(), INTERVAL  2 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(35, 'T20260415035', 2, 2, 'VM000003', 12, 'Lucas Maint',  4, 'Card reader re-pair',             3, 1, 'Financial Tower',        DATE_SUB(NOW(), INTERVAL  1 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(36, 'T20260415036', 2, 1, 'VM000005',  4, 'Noah Ops',     1, 'City hall quick refill',          2, 1, 'City Hall Atrium',       DATE_SUB(NOW(), INTERVAL  1 DAY), NOW()),
(37, 'T20260415037', 2, 1, 'VM000019',  8, 'Zoe Ops',      5, 'Stadium pre-game top-up',         2, 1, 'Stadium Concourse',      DATE_SUB(NOW(), INTERVAL  1 DAY), NOW()),
(38, 'T20260416038', 2, 1, 'VM000012',  6, 'Ava Ops',      3, 'Terminal A snack refill',         2, 2, 'Airport Terminal A',     NOW(),                            NOW()),
(39, 'T20260416039', 2, 2, 'VM000015', 15, 'Mason Maint',  1, 'Temperature sensor replacement',  3, 1, 'Community Center',       NOW(),                            NOW()),
(40, 'T20260416040', 2, 1, 'VM000018',  7, 'Mia Ops',      4, 'Cinema lobby quick refill',       2, 1, 'Cinema Complex',         NOW(),                            NOW()),
-- ---------- PENDING — UNASSIGNED (8 tasks, awaiting dispatch) ----------
(41, 'T20260416041', 1, 0, 'VM000001', NULL, NULL,         1, 'Auto-generated: low stock',       2, 1, 'Central Plaza Lobby',    NOW(),                            NOW()),
(42, 'T20260416042', 1, 0, 'VM000006', NULL, NULL,         2, 'Auto-generated: snack isle low',  2, 1, 'Engineering Building',   NOW(),                            NOW()),
(43, 'T20260416043', 1, 0, 'VM000013', NULL, NULL,         4, 'Auto-generated: cooler empty',    2, 1, 'Riverside Apartments',   NOW(),                            NOW()),
(44, 'T20260416044', 1, 1, 'VM000002', NULL, NULL,         1, 'Scheduled weekly restock',        2, 1, 'Central Plaza Lobby',    NOW(),                            NOW()),
(45, 'T20260416045', 1, 1, 'VM000016', NULL, NULL,         5, 'Pre-weekend replenish',           2, 1, 'Grand Mall — L1',        NOW(),                            NOW()),
(46, 'T20260416046', 1, 1, 'VM000011', NULL, NULL,         3, 'Transit hub morning refill',      2, 2, 'Airport Terminal B',     NOW(),                            NOW()),
(47, 'T20260416047', 1, 1, 'VM000020', NULL, NULL,         1, 'New install commissioning',       1, 1, 'Harbor Walkway',         NOW(),                            NOW()),
(48, 'T20260416048', 1, 1, 'VM000014', NULL, NULL,         4, 'Mall Tuesday restock',            2, 1, 'Northgate Mall',         NOW(),                            NOW()),
-- ---------- PENDING — ASSIGNED (7 tasks, waiting for operator to accept) ----------
(49, 'T20260415049', 1, 1, 'VM000007',  5, 'Emma Ops',     2, 'Student union evening refill',    2, 1, 'Student Union',          DATE_SUB(NOW(), INTERVAL  1 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(50, 'T20260415050', 1, 2, 'VM000013', 12, 'Lucas Maint',  4, 'Light flicker report',            3, 1, 'Riverside Apartments',   DATE_SUB(NOW(), INTERVAL  1 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(51, 'T20260415051', 1, 1, 'VM000019',  8, 'Zoe Ops',      5, 'Stadium event day prep',          2, 1, 'Stadium Concourse',      DATE_SUB(NOW(), INTERVAL  1 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(52, 'T20260415052', 1, 2, 'VM000018', 13, 'Henry Maint',  5, 'Card reader intermittent',        3, 2, 'Cinema Complex',         DATE_SUB(NOW(), INTERVAL  1 DAY), DATE_SUB(NOW(), INTERVAL  1 DAY)),
(53, 'T20260416053', 1, 1, 'VM000003',  4, 'Noah Ops',     1, 'Financial tower evening refill',  2, 1, 'Financial Tower',        NOW(),                            NOW()),
(54, 'T20260416054', 1, 1, 'VM000017',  8, 'Zoe Ops',      5, 'Mall late-day top-up',            2, 1, 'Grand Mall — L1',        NOW(),                            NOW()),
(55, 'T20260416055', 1, 2, 'VM000005', 15, 'Mason Maint',  1, 'Coin box full — empty',           4, 1, 'City Hall Atrium',       NOW(),                            NOW()),
-- ---------- CANCELLED (5 tasks, with reason in desc) ----------
(56, 'T20260309056', 3, 1, 'VM000015',  7, 'Mia Ops',      4, 'Cancelled: duplicate request',    2, 1, 'Community Center',       DATE_SUB(NOW(), INTERVAL 38 DAY), DATE_SUB(NOW(), INTERVAL 37 DAY)),
(57, 'T20260328057', 3, 2, 'VM000005', 15, 'Mason Maint',  1, 'Cancelled: false alarm',          3, 1, 'City Hall Atrium',       DATE_SUB(NOW(), INTERVAL 19 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY)),
(58, 'T20260402058', 3, 1, 'VM000010',  6, 'Ava Ops',      3, 'Cancelled: machine taken offline',2, 2, 'Airport Terminal B',     DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 13 DAY)),
(59, 'T20260410059', 3, 1, 'VM000009',  5, 'Emma Ops',     2, 'Cancelled: operator unavailable', 2, 1, 'Metro Station North',    DATE_SUB(NOW(), INTERVAL  6 DAY), DATE_SUB(NOW(), INTERVAL  5 DAY)),
(60, 'T20260414060', 3, 2, 'VM000008', 11, 'Ethan Maint',  2, 'Cancelled: resolved remotely',    3, 2, 'Library Annex',          DATE_SUB(NOW(), INTERVAL  2 DAY), DATE_SUB(NOW(), INTERVAL  2 DAY));

-- Task details (replenish / supply tasks only — productTypeId = 2).
-- Built by joining to tb_sku so sku_name/sku_image always match sku_id.
INSERT INTO tb_task_details (task_id, channel_code, expect_capacity, sku_id, sku_name, sku_image)
SELECT td.task_id, td.channel_code, td.expect_capacity, s.sku_id, s.sku_name, s.sku_image
FROM (
    -- Done tasks
    SELECT  1 AS task_id, '1-2' AS channel_code,  8 AS expect_capacity,  2 AS sku_id UNION ALL
    SELECT  1, '2-2',  9,  8 UNION ALL
    SELECT  1, '4-2', 10, 20 UNION ALL
    SELECT  2, '1-5', 10,  5 UNION ALL
    SELECT  4, '1-1',  8,  1 UNION ALL
    SELECT  4, '1-2',  8,  2 UNION ALL
    SELECT  5, '2-2',  9,  8 UNION ALL
    SELECT  7, '3-2',  7, 14 UNION ALL
    SELECT  8, '4-3',  6, 21 UNION ALL
    SELECT 11, '5-1',  5, 25 UNION ALL
    SELECT 12, '1-1',  9,  1 UNION ALL
    SELECT 13, '3-1',  8, 13 UNION ALL
    SELECT 14, '4-1', 10, 19 UNION ALL
    SELECT 16, '1-3',  9,  3 UNION ALL
    SELECT 17, '3-4',  8, 16 UNION ALL
    SELECT 19, '1-1',  9,  1 UNION ALL
    SELECT 20, '2-1',  9,  7 UNION ALL
    SELECT 21, '4-2', 10, 20 UNION ALL
    SELECT 24, '3-2',  8, 14 UNION ALL
    SELECT 25, '1-2',  9,  2 UNION ALL
    -- In-progress tasks
    SELECT 26, '1-2',  8,  2 UNION ALL
    SELECT 26, '1-5', 10,  5 UNION ALL
    SELECT 27, '2-3',  9,  9 UNION ALL
    SELECT 29, '1-1',  9,  1 UNION ALL
    SELECT 29, '3-1',  8, 13 UNION ALL
    SELECT 30, '2-2',  9,  8 UNION ALL
    SELECT 31, '1-4',  9,  4 UNION ALL
    SELECT 33, '3-4',  8, 16 UNION ALL
    SELECT 34, '4-1', 10, 19 UNION ALL
    SELECT 36, '1-1',  9,  1 UNION ALL
    SELECT 37, '2-1', 10,  7 UNION ALL
    SELECT 37, '3-2',  9, 14 UNION ALL
    SELECT 38, '3-4',  8, 16 UNION ALL
    SELECT 40, '4-3',  7, 21 UNION ALL
    -- Pending (unassigned) — planned targets
    SELECT 41, '1-1', 10,  1 UNION ALL
    SELECT 41, '3-6', 10, 18 UNION ALL
    SELECT 42, '2-2',  9,  8 UNION ALL
    SELECT 43, '4-2', 10, 20 UNION ALL
    SELECT 44, '1-3',  9,  3 UNION ALL
    SELECT 44, '2-1', 10,  7 UNION ALL
    SELECT 45, '4-1', 10, 19 UNION ALL
    SELECT 46, '1-1',  9,  1 UNION ALL
    SELECT 48, '3-1',  8, 13 UNION ALL
    -- Pending (assigned)
    SELECT 49, '2-2',  9,  8 UNION ALL
    SELECT 51, '5-1', 10, 25 UNION ALL
    SELECT 53, '1-2',  9,  2 UNION ALL
    SELECT 54, '4-3',  8, 21
) td
JOIN tb_sku s ON s.sku_id = td.sku_id;

-- Task daily rollups (by employee, last 10 days of activity)
INSERT INTO tb_task_collect (user_id, finish_count, progress_count, cancel_count, collect_date) VALUES
( 3, 3, 1, 0, CURDATE() - INTERVAL 1 DAY),
( 3, 2, 0, 0, CURDATE() - INTERVAL 5 DAY),
( 4, 3, 1, 0, CURDATE() - INTERVAL 2 DAY),
( 4, 2, 0, 0, CURDATE() - INTERVAL 6 DAY),
( 5, 4, 2, 1, CURDATE() - INTERVAL 3 DAY),
( 5, 3, 0, 0, CURDATE() - INTERVAL 7 DAY),
( 6, 2, 2, 0, CURDATE() - INTERVAL 2 DAY),
( 6, 1, 0, 0, CURDATE() - INTERVAL 9 DAY),
( 7, 3, 1, 1, CURDATE() - INTERVAL 4 DAY),
( 8, 4, 2, 0, CURDATE() - INTERVAL 1 DAY),
( 8, 3, 0, 0, CURDATE() - INTERVAL 8 DAY),
( 9, 2, 1, 0, CURDATE() - INTERVAL 3 DAY),
(11, 1, 1, 1, CURDATE() - INTERVAL 2 DAY),
(12, 1, 1, 0, CURDATE() - INTERVAL 1 DAY),
(13, 1, 0, 0, CURDATE() - INTERVAL 5 DAY),
(15, 1, 1, 1, CURDATE() - INTERVAL 6 DAY);

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
    SELECT 0 AS n UNION ALL SELECT n+1 FROM seq WHERE n < 2021
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

-- Vendout telemetry (only for orders that successfully dispensed; recent sample)
INSERT INTO tb_vendout_running (order_no, inner_code, channel_code, status, create_time, update_time)
SELECT order_no, inner_code, channel_code, '1', create_time, update_time
FROM tb_order
WHERE status = 2
ORDER BY create_time DESC
LIMIT 500;

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

-- ============================================================
-- 16. Monthly rollups by partner+region+month (for analytics dashboards)
-- ============================================================
INSERT INTO tb_order_month_collect (id, partner_id, partner_name, region_id, region_name, order_total_money, order_total_count, month, year)
SELECT
    (YEAR(o.create_time) * 100000000) + (MONTH(o.create_time) * 1000000) + (o.partner_id * 1000) + o.region_id AS id,
    o.partner_id,
    p.partner_name,
    o.region_id,
    MAX(o.region_name)  AS region_name,
    SUM(o.amount)       AS order_total_money,
    COUNT(*)            AS order_total_count,
    MONTH(o.create_time) AS month,
    YEAR(o.create_time)  AS year
FROM tb_order o
JOIN tb_partner p ON p.id = o.partner_id
WHERE o.status = 2 AND o.pay_status = 1
GROUP BY YEAR(o.create_time), MONTH(o.create_time), o.partner_id, p.partner_name, o.region_id;

-- ============================================================
-- 17. Auto-replenish alert config (single-row singleton)
-- ============================================================
INSERT INTO tb_job (id, alert_value) VALUES (1, 20);

SET FOREIGN_KEY_CHECKS = @OLD_FK;

-- ============================================================
-- Sanity (run manually)
-- ============================================================
-- SELECT 'regions'  AS tbl, COUNT(*) FROM tb_region
-- UNION ALL SELECT 'partners',          COUNT(*) FROM tb_partner
-- UNION ALL SELECT 'nodes',             COUNT(*) FROM tb_node
-- UNION ALL SELECT 'vm_types',          COUNT(*) FROM tb_vm_type
-- UNION ALL SELECT 'machines',          COUNT(*) FROM tb_vending_machine
-- UNION ALL SELECT 'channels',          COUNT(*) FROM tb_channel
-- UNION ALL SELECT 'sku_classes',       COUNT(*) FROM tb_sku_class
-- UNION ALL SELECT 'skus',              COUNT(*) FROM tb_sku
-- UNION ALL SELECT 'roles',             COUNT(*) FROM tb_role
-- UNION ALL SELECT 'emps',              COUNT(*) FROM tb_emp
-- UNION ALL SELECT 'task_types',        COUNT(*) FROM tb_task_type
-- UNION ALL SELECT 'tasks',             COUNT(*) FROM tb_task
-- UNION ALL SELECT 'task_details',      COUNT(*) FROM tb_task_details
-- UNION ALL SELECT 'task_collect',      COUNT(*) FROM tb_task_collect
-- UNION ALL SELECT 'policies',          COUNT(*) FROM tb_policy
-- UNION ALL SELECT 'orders',            COUNT(*) FROM tb_order
-- UNION ALL SELECT 'order_collect',     COUNT(*) FROM tb_order_collect
-- UNION ALL SELECT 'order_month_collect', COUNT(*) FROM tb_order_month_collect
-- UNION ALL SELECT 'vendout_running',   COUNT(*) FROM tb_vendout_running
-- UNION ALL SELECT 'job',               COUNT(*) FROM tb_job;

SET time_zone = @OLD_TZ;
SET SESSION sql_mode = @OLD_SQL_MODE;
