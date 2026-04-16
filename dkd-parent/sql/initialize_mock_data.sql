-- Initialize Mock Data for Admin Dashboard
-- This file creates sample data for testing the admin dashboard features
-- Note: Using existing region IDs (6-10) and node IDs (31-35) from database

-- Insert sample partners first (required by foreign key constraints)
INSERT INTO tb_partner (partner_name, contact_person, contact_phone, profit_ratio, create_time, update_time) VALUES
('Partner A', 'Alice Manager', '1234567890', 30, NOW(), NOW()),
('Partner B', 'Bob Manager', '2345678901', 25, NOW(), NOW()),
('Partner C', 'Charlie Manager', '3456789012', 20, NOW(), NOW()),
('Partner D', 'Diana Manager', '4567890123', 15, NOW(), NOW()),
('Partner E', 'Edward Manager', '5678901234', 10, NOW(), NOW())
ON DUPLICATE KEY UPDATE update_time = NOW();

-- Insert sample vending machines with different statuses (using existing node IDs)
INSERT INTO tb_vending_machine (inner_code, node_id, addr, business_type, region_id, partner_id, vm_type_id, vm_status, create_time, update_time) VALUES
('VM001', 31, 'Downtown Mall', 1, 6, 1, 1, 1, NOW(), NOW()),
('VM002', 32, 'Airport Terminal', 1, 7, 2, 1, 0, NOW(), NOW()),
('VM003', 33, 'Central Station', 1, 8, 3, 1, 1, NOW(), NOW()),
('VM004', 34, 'Shopping Center', 1, 9, 4, 1, 2, NOW(), NOW()),
('VM005', 35, 'Business District', 1, 10, 5, 1, 3, NOW(), NOW())
ON DUPLICATE KEY UPDATE update_time = NOW();

-- Insert sample SKUs (using actual schema)
INSERT INTO tb_sku (sku_name, sku_image, brand_Name, unit, price, class_id, is_discount, create_time, update_time) VALUES
('Product A', '/static/product1.png', 'Brand A', 'piece', 500, 1, 0, NOW(), NOW()),
('Product B', '/static/product2.png', 'Brand B', 'piece', 350, 1, 0, NOW(), NOW()),
('Product C', '/static/product3.png', 'Brand C', 'piece', 400, 1, 0, NOW(), NOW()),
('Product D', '/static/product4.png', 'Brand D', 'piece', 600, 1, 0, NOW(), NOW()),
('Product E', '/static/product5.png', 'Brand E', 'piece', 250, 1, 0, NOW(), NOW())
ON DUPLICATE KEY UPDATE update_time = NOW();

-- Insert sample orders for revenue calculation (using actual schema)
INSERT INTO tb_order (id, order_no, inner_code, sku_id, sku_name, class_id, status, amount, price, pay_type, pay_status, addr, region_id, region_name, partner_id, node_id, node_name, create_time, update_time) VALUES
(1001, 'ORD001', 'VM001', 1, 'Product A', 1, 2, 500, 500, 'wechat', 2, 'Downtown Mall', 6, 'Downtown', 1, 31, 'Downtown', DATE_SUB(NOW(), INTERVAL 30 DAY), NOW()),
(1002, 'ORD002', 'VM001', 2, 'Product B', 1, 2, 450, 450, 'alipay', 2, 'Downtown Mall', 6, 'Downtown', 1, 31, 'Downtown', DATE_SUB(NOW(), INTERVAL 25 DAY), NOW()),
(1003, 'ORD003', 'VM002', 3, 'Product C', 1, 2, 300, 300, 'wechat', 2, 'Airport Terminal', 7, 'Mall Area', 2, 32, 'Mall A', DATE_SUB(NOW(), INTERVAL 20 DAY), NOW()),
(1004, 'ORD004', 'VM003', 4, 'Product D', 1, 2, 600, 600, 'alipay', 2, 'Central Station', 8, 'Airport', 3, 33, 'Airport', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW()),
(1005, 'ORD005', 'VM003', 5, 'Product E', 1, 2, 550, 550, 'wechat', 2, 'Central Station', 8, 'Airport', 3, 33, 'Airport', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW()),
(1006, 'ORD006', 'VM001', 1, 'Product A', 1, 2, 400, 400, 'alipay', 2, 'Downtown Mall', 6, 'Downtown', 1, 31, 'Downtown', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
(1007, 'ORD007', 'VM004', 2, 'Product B', 1, 2, 350, 350, 'wechat', 2, 'Shopping Center', 9, 'Station', 4, 34, 'Station', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
(1008, 'ORD008', 'VM005', 3, 'Product C', 1, 2, 200, 200, 'alipay', 2, 'Business District', 10, 'Business District', 5, 35, 'Business District', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
(1009, 'ORD009', 'VM001', 4, 'Product D', 1, 2, 480, 480, 'wechat', 2, 'Downtown Mall', 6, 'Downtown', 1, 31, 'Downtown', NOW(), NOW()),
(1010, 'ORD010', 'VM003', 5, 'Product E', 1, 2, 520, 520, 'alipay', 2, 'Central Station', 8, 'Airport', 3, 33, 'Airport', NOW(), NOW())
ON DUPLICATE KEY UPDATE update_time = NOW();

-- Insert sample channels with stock levels (using actual vm_id values from database)
INSERT INTO tb_channel (channel_code, sku_id, vm_id, inner_code, max_capacity, current_capacity, create_time, update_time) VALUES
('CH001', 1, 117, 'VM001', 100, 15, NOW(), NOW()),
('CH002', 2, 117, 'VM001', 80, 45, NOW(), NOW()),
('CH003', 3, 118, 'VM002', 50, 8, NOW(), NOW()),
('CH004', 4, 119, 'VM003', 60, 20, NOW(), NOW()),
('CH005', 5, 120, 'VM004', 40, 5, NOW(), NOW())
ON DUPLICATE KEY UPDATE update_time = NOW();

-- Insert sample task types (using actual schema)
INSERT INTO tb_task_type (type_id, type_name, type) VALUES
(1, 'Restock', 1),
(2, 'Maintenance', 2),
(3, 'Emergency Repair', 3)
ON DUPLICATE KEY UPDATE type_name = VALUES(type_name);

-- Insert sample tasks with different priorities (using actual schema)
INSERT INTO tb_task (task_code, task_status, create_type, inner_code, user_id, user_name, `desc`, product_type_id, assignor_id, addr, create_time, update_time) VALUES
('TASK001', 1, 1, 'VM001', 1, 'John Doe', 'Restock Machine #123', 1, 1, 'Downtown Mall', NOW(), NOW()),
('TASK002', 1, 1, 'VM002', 2, 'Jane Smith', 'Maintenance Machine #456', 2, 2, 'Airport Terminal', NOW(), NOW()),
('TASK003', 1, 1, 'VM003', 3, 'Bob Johnson', 'Check Payment System', 1, 3, 'Central Station', NOW(), NOW()),
('TASK004', 1, 3, 'VM004', 1, 'John Doe', 'Emergency Repair', 3, 1, 'Shopping Center', NOW(), NOW()),
('TASK005', 1, 1, 'VM005', 2, 'Jane Smith', 'Restock Machine #789', 1, 2, 'Business District', NOW(), NOW())
ON DUPLICATE KEY UPDATE update_time = NOW();

-- Insert sample employees (using actual schema)
INSERT INTO tb_emp (user_name, region_id, region_name, role_id, role_code, role_name, mobile, image, status, create_time, update_time) VALUES
('John Doe', 6, 'Downtown', 1, 'EMP', 'Technician', '1234567890', '/static/avatar1.png', 1, NOW(), NOW()),
('Jane Smith', 7, 'Mall Area', 2, 'EMP', 'Technician', '2345678901', '/static/avatar2.png', 1, NOW(), NOW()),
('Bob Johnson', 8, 'Airport', 1, 'EMP', 'Technician', '3456789012', '/static/avatar3.png', 1, NOW(), NOW()),
('Alice Williams', 9, 'Station', 2, 'EMP', 'Technician', '4567890123', '/static/avatar4.png', 1, NOW(), NOW()),
('Charlie Brown', 10, 'Business District', 1, 'EMP', 'Technician', '5678901234', '/static/avatar5.png', 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE update_time = NOW();
