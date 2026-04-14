-- 修复 sys_area 的 ancestors 字段，使其符合 RuoYi 框架规范
-- 规则：
--   1. ancestors 只包含祖先编码，不包含自身
--   2. 分隔符为逗号 ,（与 sys_dept 一致）
--   3. 省级（level 1）ancestors = '0'
--   4. 市级 ancestors = '0,省级code'
--   5. 县级 ancestors = '0,省级code,市级code'
--   6. 乡镇级 ancestors = '0,省级code,市级code,县级code'

-- 步骤1：先临时清空 ancestors
UPDATE sys_area SET ancestors = '';

-- 步骤2：省级（area_level=1），ancestors = '0'
UPDATE sys_area SET ancestors = '0' WHERE area_level = '1';

-- 步骤3：市级（area_level=2），ancestors = '0,省级code'
UPDATE sys_area a2
INNER JOIN sys_area a1 ON a2.parent_code = a1.code
SET a2.ancestors = CONCAT(a1.ancestors, ',', a1.code)
WHERE a2.area_level = '2';

-- 步骤4：县级（area_level=3），ancestors = '0,省级code,市级code'
UPDATE sys_area a3
INNER JOIN sys_area a2 ON a3.parent_code = a2.code
INNER JOIN sys_area a1 ON a2.parent_code = a1.code
SET a3.ancestors = CONCAT(a1.ancestors, ',', a1.code, ',', a2.code)
WHERE a3.area_level = '3';

-- 步骤5：乡镇级（area_level=4），ancestors = '0,省级code,市级code,县级code'
UPDATE sys_area a4
INNER JOIN sys_area a3 ON a4.parent_code = a3.code
INNER JOIN sys_area a2 ON a3.parent_code = a2.code
INNER JOIN sys_area a1 ON a2.parent_code = a1.code
SET a4.ancestors = CONCAT(a1.ancestors, ',', a1.code, ',', a2.code, ',', a3.code)
WHERE a4.area_level = '4';
