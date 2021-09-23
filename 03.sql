CREATE VIEW productsum (product_type, cnt_product)
AS
SELECT product_type, COUNT(*)
  FROM product
 GROUP BY product_type ;

CREATE TABLE shop_product
(shop_id    CHAR(4)       NOT NULL,
 shop_name  VARCHAR(200)  NOT NULL,
 product_id CHAR(4)       NOT NULL,
 quantity   INTEGER       NOT NULL,
 PRIMARY KEY (shop_id, product_id));
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000A',	'东京',		'0001',	30);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000A',	'东京',		'0002',	50);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000A',	'东京',		'0003',	15);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000B',	'名古屋',	'0002',	30);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000B',	'名古屋',	'0003',	120);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000B',	'名古屋',	'0004',	20);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000B',	'名古屋',	'0006',	10);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000B',	'名古屋',	'0007',	40);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000C',	'大阪',		'0003',	20);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000C',	'大阪',		'0004',	50);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000C',	'大阪',		'0006',	90);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000C',	'大阪',		'0007',	70);
INSERT INTO shop_product (shop_id, shop_name, product_id, quantity) VALUES ('000D',	'福冈',		'0001',	100);

CREATE VIEW view_shop_product(product_type, sale_price, shop_name)
AS
SELECT product_type, sale_price, shop_name
  FROM product,
       shop_product
 WHERE product.product_id = shop_product.product_id;

SELECT sale_price, shop_name
  FROM view_shop_product
 WHERE product_type = '衣服';
 
ALTER VIEW productSum
    AS
        SELECT product_type, sale_price
          FROM Product
         WHERE regist_date > '2009-09-11';
         
UPDATE productsum
   SET sale_price = '5000'
 WHERE product_type = '办公用品';
 
-- DROP VIEW productSum;

SELECT stu_name
FROM (
         SELECT stu_name, COUNT(*) AS stu_cnt
          FROM students_info
          GROUP BY stu_age) AS studentSum;

-- 通过标量子查询语句查询出销售单价高于平均销售单价的商品
SELECT product_id, product_name, sale_price
  FROM product
 WHERE sale_price > (SELECT AVG(sale_price) FROM product);
 
SELECT product_id,
       product_name,
       sale_price,
       (SELECT AVG(sale_price)
          FROM product) AS avg_price
  FROM product;

-- 查询出销售单价高于平均销售单价的商品
SELECT product_type, product_name, sale_price
  FROM product AS p1
 WHERE sale_price > (SELECT AVG(sale_price)
                       FROM product AS p2
                      WHERE p1.product_type = p2.product_type
   GROUP BY product_type);

-- 3.1
DROP VIEW ViewPractice5_1;
CREATE VIEW ViewPractice5_1(product_name, sale_price, regist_date)
AS
SELECT product_name, sale_price, regist_date
  FROM product
 WHERE sale_price >= 1000 AND regist_date = '2009-09-20';
SELECT * FROM ViewPractice5_1;
-- 3.2
INSERT INTO ViewPractice5_1 VALUES ('刀子', 300, '2009-11-02');
-- 3.3
SELECT *,
       (SELECT AVG(sale_price)
          FROM product) AS sale_price_all
  FROM product;
-- 3.4
CREATE VIEW AvgPriceByType AS
SELECT product_id, 
	   product_name, 
       product_type, 
       sale_price, 
       (SELECT AVG(sale_price)
		FROM product AS p2
		WHERE p1.product_type = p2.product_type
		GROUP BY product_type) AS AvgPriceByType
FROM product p1;

-- DDL ：创建表
USE shop;
DROP TABLE IF EXISTS samplemath;
CREATE TABLE samplemath
(m float(10,3),
n INT,
p INT);

-- DDL ：创建表
USE shop;
DROP TABLE IF EXISTS samplemath;
CREATE TABLE samplemath
(m float(10,3),
n INT,
p INT);

-- DML ：插入数据
START TRANSACTION; -- 开始事务
INSERT INTO samplemath(m, n, p) VALUES (500, 0, NULL);
INSERT INTO samplemath(m, n, p) VALUES (-180, 0, NULL);
INSERT INTO samplemath(m, n, p) VALUES (NULL, NULL, NULL);
INSERT INTO samplemath(m, n, p) VALUES (NULL, 7, 3);
INSERT INTO samplemath(m, n, p) VALUES (NULL, 5, 2);
INSERT INTO samplemath(m, n, p) VALUES (NULL, 4, NULL);
INSERT INTO samplemath(m, n, p) VALUES (8, NULL, 3);
INSERT INTO samplemath(m, n, p) VALUES (2.27, 1, NULL);
INSERT INTO samplemath(m, n, p) VALUES (5.555,2, NULL);
INSERT INTO samplemath(m, n, p) VALUES (NULL, 1, NULL);
INSERT INTO samplemath(m, n, p) VALUES (8.76, NULL, NULL);
COMMIT; -- 提交事务
-- 查询表内容
SELECT * FROM samplemath;
-- 算数函数
SELECT m,
ABS(m) AS abs_col ,
n, p,
MOD(n, p) AS mod_col,
ROUND(m,1) AS round_colS
FROM samplemath;

-- DDL ：创建表
USE  shop;
DROP TABLE IF EXISTS samplestr;
CREATE TABLE samplestr
(str1 VARCHAR (40),
str2 VARCHAR (40),
str3 VARCHAR (40)
);
-- DML：插入数据
START TRANSACTION;
INSERT INTO samplestr (str1, str2, str3) VALUES ('opx',	'rt', NULL);
INSERT INTO samplestr (str1, str2, str3) VALUES ('abc', 'def', NULL);
INSERT INTO samplestr (str1, str2, str3) VALUES ('太阳',	'月亮', '火星');
INSERT INTO samplestr (str1, str2, str3) VALUES ('aaa',	NULL, NULL);
INSERT INTO samplestr (str1, str2, str3) VALUES (NULL, 'xyz', NULL);
INSERT INTO samplestr (str1, str2, str3) VALUES ('@!#$%', NULL, NULL);
INSERT INTO samplestr (str1, str2, str3) VALUES ('ABC', NULL, NULL);
INSERT INTO samplestr (str1, str2, str3) VALUES ('aBC', NULL, NULL);
INSERT INTO samplestr (str1, str2, str3) VALUES ('abc哈哈',  'abc', 'ABC');
INSERT INTO samplestr (str1, str2, str3) VALUES ('abcdefabc', 'abc', 'ABC');
INSERT INTO samplestr (str1, str2, str3) VALUES ('micmic', 'i', 'I');
COMMIT;
-- 确认表中的内容
SELECT * FROM samplestr;
-- 字符串函数
SELECT str1,
	   str2,
       str3,
       CONCAT(str1, str2, str3) AS str_concat,
       LENGTH(str1) AS len_str,
       LOWER(str1) AS low_str, -- UPPER()
       REPLACE(str1, str2, str3) AS rep_str, -- 把str1中有str2的部分换成str3
       SUBSTRING(str1 FROM 3 FOR 2) AS sub_str -- 对象字符串 FROM 截取的起始位置 FOR 截取的字符数
FROM samplestr;

-- 获取原始字符串按照分隔符分割后，第 n 个分隔符之前（或之后）的子字符串
SELECT SUBSTRING_INDEX('www.mysql.com', '.', 2);
SELECT SUBSTRING_INDEX('www.mysql.com', '.', -2);
-- 获取第2个元素/第n个元素可以采用二次拆分的写法
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX('www.mysql.com', '.', 2), '.', -1);

SELECT CURRENT_DATE; -- 获取当前日期
SELECT CURRENT_TIME; -- 当前时间
SELECT CURRENT_TIMESTAMP; -- 日期时间

-- 截取日期元素
SELECT CURRENT_TIMESTAMP as now,
EXTRACT(YEAR   FROM CURRENT_TIMESTAMP) AS year,
EXTRACT(MONTH  FROM CURRENT_TIMESTAMP) AS month,
EXTRACT(DAY    FROM CURRENT_TIMESTAMP) AS day,
EXTRACT(HOUR   FROM CURRENT_TIMESTAMP) AS hour,
EXTRACT(MINUTE FROM CURRENT_TIMESTAMP) AS MINute,
EXTRACT(SECOND FROM CURRENT_TIMESTAMP) AS second;

-- 将字符串类型转换为数值类型
SELECT CAST('0001' AS SIGNED INTEGER) AS int_col;
-- 将字符串类型转换为日期类型
SELECT CAST('2009-12-14' AS DATE) AS date_col;
-- 返回可变参数 A 中左侧开始第 1个不是NULL的值
SELECT COALESCE(NULL, 11) AS col_1,
COALESCE(NULL, 'hello world', NULL) AS col_2,
COALESCE(NULL, NULL, '2020-11-01') AS col_3;

-- DDL ：创建表
CREATE TABLE samplelike
( strcol VARCHAR(6) NOT NULL,
PRIMARY KEY (strcol)
);
-- DML ：插入数据
START TRANSACTION; -- 开始事务
INSERT INTO samplelike (strcol) VALUES ('abcddd');
INSERT INTO samplelike (strcol) VALUES ('dddabc');
INSERT INTO samplelike (strcol) VALUES ('abdddc');
INSERT INTO samplelike (strcol) VALUES ('abcdd');
INSERT INTO samplelike (strcol) VALUES ('ddabc');
INSERT INTO samplelike (strcol) VALUES ('abddc');
COMMIT; -- 提交事务
SELECT * FROM samplelike;

SELECT *
FROM samplelike
WHERE strcol LIKE 'ddd%'; -- %ddd, %ddd%
SELECT *
FROM samplelike
WHERE strcol LIKE 'abc__'; -- _代表一个字符

-- 选取销售单价为100～1000元的商品
SELECT product_name, sale_price
FROM product
WHERE sale_price BETWEEN 100 AND 1000; -- 闭区间，开区间要用><

SELECT product_name, purchase_price
FROM product
WHERE purchase_price IS NULL; -- IS NOT NULL
-- 多个条件查询
SELECT product_name, purchase_price
FROM product
WHERE purchase_price IN (320, 500, 5000); -- NOT IN

-- 使用子查询作为IN谓词的参数: 取出大阪在售商品的销售单价
-- step1：取出大阪门店的在售商品 `product_id`
SELECT product_id
FROM shop_product
WHERE shop_id = '000C';
-- step2：取出大阪门店在售商品的销售单价 `sale_price`
SELECT product_name, sale_price
FROM product
WHERE product_id IN (SELECT product_id
  FROM shop_product
  WHERE shop_id = '000C'); -- 可not in

-- EXIST通常使用关联子查询作为参数
SELECT product_name, sale_price
  FROM product AS p
 WHERE EXISTS (SELECT *
                 FROM shop_product AS sp
                WHERE sp.shop_id = '000C'
                  AND sp.product_id = p.product_id); -- 可not exist

SELECT  product_name,
        CASE WHEN product_type = '衣服' THEN CONCAT('A ： ',product_type)
             WHEN product_type = '办公用品' THEN CONCAT('B ： ',product_type)
             WHEN product_type = '厨房用具' THEN CONCAT('C ： ',product_type)
             ELSE NULL
        END AS abc_product_type
  FROM  product;

-- 对按照商品种类计算出的销售单价合计值进行行列转换
SELECT SUM(CASE WHEN product_type = '衣服' THEN sale_price ELSE 0 END) AS sum_price_clothes,
       SUM(CASE WHEN product_type = '厨房用具' THEN sale_price ELSE 0 END) AS sum_price_kitchen,
       SUM(CASE WHEN product_type = '办公用品' THEN sale_price ELSE 0 END) AS sum_price_office
  FROM product;

-- CASE WHEN 实现数字列 score 行转列
SELECT name,
       SUM(CASE WHEN subject = '语文' THEN score ELSE null END) as chinese,
       SUM(CASE WHEN subject = '数学' THEN score ELSE null END) as math,
       SUM(CASE WHEN subject = '外语' THEN score ELSE null END) as english
  FROM score
 GROUP BY name;

-- CASE WHEN 实现文本列 subject 行转列
SELECT name,
       MAX(CASE WHEN subject = '语文' THEN subject ELSE null END) as chinese,
       MAX(CASE WHEN subject = '数学' THEN subject ELSE null END) as math,
       MIN(CASE WHEN subject = '外语' THEN subject ELSE null END) as english
  FROM score
 GROUP BY name;

-- 3.7
SELECT SUM(CASE WHEN sale_price <= 1000 THEN 1 ELSE null END) as low_price,
       SUM(CASE WHEN sale_price BETWEEN 1001 AND 3000 THEN 1 ELSE null END) as mid_price,
       SUM(CASE WHEN sale_price >= 3001 THEN 1 ELSE null END) as high_price
FROM product
;









