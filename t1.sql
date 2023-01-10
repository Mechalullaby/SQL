# 数据库的创建，表的创建/删除，数据类型，给表增/删列，多行多列更新，添加数据，复制表

# 创建本课程使用的数据库（只用创建一次）
# CREATE DATABASE sql_shop;

# 创建表
# ctrL+? 多行注释
-- CREATE TABLE < 表名 >
-- ( < 列名 1> < 数据类型 > < 该列所需约束 > ,
--   < 列名 2> < 数据类型 > < 该列所需约束 > ,
--   < 列名 3> < 数据类型 > < 该列所需约束 > ,
--   < 列名 4> < 数据类型 > < 该列所需约束 > ,
--   .
--   .
--   < 该表的约束 1> , < 该表的约束 2> ,……);
CREATE TABLE product(
     product_id CHAR(4) NOT NULL, 
     product_name VARCHAR(100) NOT NULL, 
     product_type VARCHAR(32) NOT NULL, 
     sale_price INTEGER, 
     purchase_price INTEGER, 
     regist_date DATE, 
     PRIMARY KEY(product_id)
 )  ;

CREATE TABLE productins
(product_id    CHAR(4)      NOT NULL,
product_name   VARCHAR(100) NOT NULL,
product_type   VARCHAR(32)  NOT NULL,
sale_price     INTEGER      DEFAULT 0, -- 销售单价的默认值设定为0;
purchase_price INTEGER ,
regist_date    DATE ,
PRIMARY KEY (product_id)); 


-- 四种最基本的数据类型
-- INTEGER 型
-- 用来指定存储整数的列的数据类型（数字型），不能存储小数。
-- CHAR 型
-- 用来存储定长字符串，当列中存储的字符串长度达不到最大长度的时候，使用半角空格进行补足，由于会浪费存储空间，所以一般不使用。
-- VARCHAR 型
-- 用来存储可变长度字符串，定长字符串在字符数未达到最大长度时会用半角空格补足，但可变长字符串不同，即使字符数未达到最大长度，也不会用半角空格补足。
-- DATE 型
-- 用来指定存储日期（年月日）的列的数据类型（日期型）

-- NOT NULL是非空约束，即该列必须输入数据
-- PRIMARY KEY是主键约束，代表该列是唯一值，可以通过该列取出特定的行的数据

# 删除表
# DROP TABLE product;
# 删除的表是无法恢复的，只能重新插入，请执行删除操作时无比要谨慎

# ALTER TABLE，DDL（Data Definition Language，数据定义语言）用来创建或者删除存储数据用的数据库以及数据库中的表等对象
# 添加列，ALTER TABLE < 表名 > ADD COLUMN < 列的定义 >;
ALTER TABLE product ADD COLUMN product_name_pinyin VARCHAR(100);
# 删除列，ALTER TABLE < 表名 > DROP COLUMN < 列名 >;
ALTER TABLE product DROP COLUMN product_name_pinyin;

# 清空表的内容，比drop, delete快
TRUNCATE TABLE product;

# 数据更新
-- UPDATE <表名>
-- SET <列名> = <表达式> [, <列名2>=<表达式2>...];  
-- WHERE <条件>;  -- 可选，非常重要！！！
-- ORDER BY 子句;  --可选
-- LIMIT 子句; --可选

-- 修改所有的注册时间
UPDATE product
   SET regist_date = '2009-10-10';  
-- 仅修改部分商品的单价
UPDATE product
   SET sale_price = sale_price * 10
 WHERE product_type = '厨房用具';  

# 使用 UPDATE 也可以将列更新为 NULL（该更新俗称为NULL清空），只有未设置 NOT NULL 约束和主键约束的列才可以清空为NULL
-- 将商品编号为0008的数据（圆珠笔）的登记日期更新为NULL  
UPDATE product
   SET regist_date = NULL
 WHERE product_id = '0008'; 
 
# 多列更新，多条件更新
UPDATE product
   SET sale_price = sale_price * 10,
       purchase_price = purchase_price / 2
 WHERE product_type = '厨房用具';  

-- 一种很新的set
UPDATE employees_new
SET first_name =
(
    SELECT last_name
    FROM employees
    WHERE job_id = 100
),
last_name =
(
    SELECT first_name
    FROM employees
    WHERE job_id = 100
)
WHERE job_id = 100;

# 插入数据，INSERT INTO <表名> (列1, 列2, 列3, ……) VALUES (值1, 值2, 值3, ……); 
-- 包含列清单
INSERT INTO productins (product_id, product_name, product_type, 
sale_price, purchase_price, regist_date) VALUES ('0005', '高压锅', '厨房用具', 6800, 5000, '2009-01-15');
-- 省略列清单，省略表名后VALUES子句的值会默认按照从左到右的顺序赋给每一列
INSERT INTO productins 
VALUES ('0005', '高压锅', '厨房用具', 6800, 5000, '2009-01-15');  
# INSERT 语句中想给某一列赋予 NULL 值时，可以直接在 VALUES子句的值清单中写入 NULL

# 使用INSERT … SELECT 语句从其他表复制数据
-- 将商品表中的数据复制到商品复制表中
INSERT INTO productocpy (product_id, product_name, product_type, sale_price, purchase_price, regist_date)
SELECT product_id, product_name, product_type, sale_price, 
purchase_price, regist_date
FROM product; 

-- DML ：插入数据
START TRANSACTION;
INSERT INTO product VALUES('0001', 'T恤衫', '衣服', 1000, 500, '2009-09-20');
INSERT INTO product VALUES('0002', '打孔器', '办公用品', 500, 320, '2009-09-11');
INSERT INTO product VALUES('0003', '运动T恤', '衣服', 4000, 2800, NULL);
INSERT INTO product VALUES('0004', '菜刀', '厨房用具', 3000, 2800, '2009-09-20');
INSERT INTO product VALUES('0005', '高压锅', '厨房用具', 6800, 5000, '2009-01-15');
INSERT INTO product VALUES('0006', '叉子', '厨房用具', 500, NULL, '2009-09-20');
INSERT INTO product VALUES('0007', '擦菜板', '厨房用具', 880, 790, '2008-04-28');
INSERT INTO product VALUES('0008', '圆珠笔', '办公用品', 100, NULL, '2009-11-11');
COMMIT;

# 编写一条 CREATE TABLE 语句，用来创建一个包含表 1-A 中所列各项的表 Addressbook，
# 并为 regist_no （注册编号）列设置主键约束
create table addressbook(
regist_no integer not null,
`name` varchar(128) not null,
address varchar(256) not null,
tel_no char(10),
mail_address char(20),
primary key(regist_no)
); 
# 忘记加某一列，添加新列
alter table addressbook add column postal_code char(8) not null;
# 删表
drop table addressbook;
# 恢复表
create table addressbook(
regist_no integer not null,
`name` varchar(128) not null,
address varchar(256) not null,
tel_no char(10),
mail_address char(20),
postal_code char(8) not null,
primary key(regist_no)
); 


