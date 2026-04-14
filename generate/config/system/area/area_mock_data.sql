-- 模拟数据：区划管理（10 条）
-- 省级（2 条）
INSERT INTO sys_area (name, code, parent_code, ancestors, area_level, sort, create_by, create_time) VALUES
('北京市', '11', '0', '0', '1', 1, 'admin', NOW()),
('河北省', '13', '0', '0', '1', 2, 'admin', NOW());

-- 地级市（3 条）
INSERT INTO sys_area (name, code, parent_code, ancestors, area_level, sort, create_by, create_time) VALUES
('石家庄市', '1301', '13', '0,13', '2', 1, 'admin', NOW()),
('唐山市', '1302', '13', '0,13', '2', 2, 'admin', NOW()),
('北京市市辖区', '1101', '11', '0,11', '2', 1, 'admin', NOW());

-- 县/区（3 条）
INSERT INTO sys_area (name, code, parent_code, ancestors, area_level, sort, create_by, create_time) VALUES
('长安区', '130102', '1301', '0,13,1301', '3', 1, 'admin', NOW()),
('桥西区', '130104', '1301', '0,13,1301', '3', 2, 'admin', NOW()),
('朝阳区', '110105', '1101', '0,11,1101', '3', 1, 'admin', NOW());

-- 乡镇/街道（2 条）
INSERT INTO sys_area (name, code, parent_code, ancestors, area_level, sort, create_by, create_time) VALUES
('建北街道', '130102001', '130102', '0,13,1301,130102', '4', 1, 'admin', NOW()),
('和平西路街道', '130102002', '130102', '0,13,1301,130102', '4', 2, 'admin', NOW());
