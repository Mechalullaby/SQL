-- 视图
-- 作视图时会根据创建视图的SELECT语句生成一张虚拟表，然后在这张虚拟表上做SQL操作
-- 通过定义视图可以将频繁使用的SELECT语句保存以提高效率
-- 通过定义视图可以使用户看到的数据更加清晰
-- 通过定义视图可以不对外公开数据表全部字段，增强数据的保密性
-- 通过定义视图可以降低数据的冗余

-- 基本语法
-- CREATE VIEW <视图名称>(<列名1>,<列名2>,...) AS <SELECT语句>

-- SELECT 语句中列的排列顺序和视图中列的排列顺序相同
-- SELECT 语句中的第 1 列就是视图中的第 1 列， SELECT 语句中的第 2 列就是视图中的第 2 列
-- 视图的列名是在视图名称之后的列表中定义的
-- 视图名在数据库中需要是唯一的，不能与其他视图和表重名
-- 在视图上继续创建视图的语法没有错误，但是多重视图会降低 SQL 的性能

-- 在一般的DBMS中定义视图时不能使用ORDER BY语句
-- 因为视图和表一样，数据行都是没有顺序的
-- 错误示范
CREATE VIEW productsum (product_type, cnt_product)
AS
SELECT product_type, COUNT(*)
  FROM product
 GROUP BY product_type
 ORDER BY product_type;
 
-- 在 MySQL中视图的定义是允许使用 ORDER BY 语句的
-- 但是若从特定视图进行选择，而该视图使用了自己的 ORDER BY 语句
-- 则视图定义中的 ORDER BY 将被忽略
-- 所以尽量不用

-- 基于单表的视图
CREATE VIEW productsum (product_type, cnt_product)
AS
SELECT product_type, COUNT(*)
  FROM product
 GROUP BY product_type ;

-- 基于多表的视图
-- 首先创建新表
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
 WHERE product.product_id = shop_product.product_id; -- 可以不是select的列，但是group by必须是

-- 在视图上查询
SELECT sale_price, shop_name
  FROM view_shop_product
 WHERE product_type = '衣服';

-- 修改视图
ALTER VIEW productSum
    AS
        SELECT product_type, sale_price
          FROM Product
         WHERE regist_date > '2009-09-11';

/*对于一个视图来说，如果包含以下结构的任意一种都是不可以被更新的：
聚合函数 SUM()、MIN()、MAX()、COUNT() 等
- DISTINCT 关键字
- GROUP BY 子句
- HAVING 子句
- UNION 或 UNION ALL 运算符
- FROM 子句中包含多个表
视图归根结底还是从表派生出来的，因此，如果原表可以更新，那么 视图中的数据也可以更新
反之亦然，如果视图发生了改变，而原表没有进行相应更新的话，就无法保证数据的一致性了*/

-- 更新视图
UPDATE productsum
   SET sale_price = '5000'
 WHERE product_type = '办公用品';
-- 原表数据也被更新，视图只是原表的一个窗口，所以它修改也只能修改透过窗口能看到的内容
-- 这里虽然修改成功了，但是并不推荐这种使用方式
-- 在创建视图时也尽量使用限制不允许通过视图来修改表
-- 就是说不建议更新视图吗

-- 删除视图
DROP VIEW productSum;

-- 子查询
-- 子查询是一次性的，所以子查询不会像视图那样保存在存储介质中， 而是在 SELECT 语句执行之后就消失了
SELECT product_type, cnt_product
FROM (SELECT *
        FROM (SELECT product_type, 
                      COUNT(*) AS cnt_product
                FROM product 
               GROUP BY product_type) AS productsum
       WHERE cnt_product = 4) AS productsum2;
/*虽然嵌套子查询可以查询出结果，但是随着子查询嵌套的层数的叠加，
SQL语句不仅会难以理解而且执行效率也会很差，所以要尽量避免这样的使用*/


-- 标量子查询（即只返回一个值）
-- 通常任何可以使用单一值的位置都可以使用----能够使用常数或者列名的地方

-- 查询出销售单价高于平均销售单价的商品
SELECT product_id, product_name, sale_price
  FROM product
 WHERE sale_price > (SELECT AVG(sale_price) FROM product);

-- 选取数据的时候加上平均值
SELECT product_id,
       product_name,
       sale_price,
       (SELECT AVG(sale_price)
          FROM product) AS avg_price
  FROM product;

-- 关联子查询
-- 首先执行不带WHERE的主查询
-- 根据主查询讯结果匹配product_type，获取子查询结果
-- 将子查询结果再与主查询结合执行完整的SQL语句

-- 选取出各商品种类中高于该商品种类的平均销售单价的商品
SELECT product_type, product_name, sale_price
  FROM product AS p1
 WHERE sale_price > (SELECT AVG(sale_price)
					   FROM product AS p2
                      WHERE p1.product_type =p2.product_type
					  GROUP BY product_type);

-- 练习3.1 满足下述三个条件的视图（视图名称为 ViewPractice5_1）
-- 条件 1：销售单价大于等于 1000 日元
-- 条件 2：登记日期是 2009 年 9 月 20 日
-- 条件 3：包含商品名称、销售单价和登记日期三列
drop VIEW IF EXISTS ViewPractice5_1;
CREATE VIEW ViewPractice5_1 (product_name, sale_price, regist_date)
AS
SELECT product_name, sale_price, regist_date
  FROM product
 where sale_price >= 1000 
   and regist_date = '2009-09-20';

-- 3.2 插入数据
INSERT INTO ViewPractice5_1 VALUES (' 刀子 ', 300, '2009-11-02');
-- underlying table doesn't have a default value

-- 3.3 
SELECT product_id,
       product_name,
       product_type,
       sale_price, 
       (SELECT AVG(sale_price)
          FROM product) AS sale_price_all
  FROM product;

-- 3.4 AvgPriceByType
CREATE VIEW AvgPriceByType AS
SELECT product_id,
       product_name,
       product_type,
       sale_price,
       (SELECT AVG(sale_price)
		  FROM product AS p2
		 WHERE p1.product_type =p2.product_type
	     GROUP BY product_type) as avg_sale_price -- 各商品种类的平均销售单价
  FROM product AS p1;


-- 各种各样的函数
-- 函数大致分为如下几类：
-- - 算术函数 （用来进行数值计算的函数）
-- - 字符串函数 （用来进行字符串操作的函数）
-- - 日期函数 （用来进行日期操作的函数）
-- - 转换函数 （用来转换数据类型和值的函数）
-- - 聚合函数 （用来进行数据聚合的函数）

-- DDL ：创建表
USE sql_shop;
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
-- MOD( 被除数，除数 )
-- ROUND( 对象数值，保留小数的位数 ), 保留小数的位数 为变量时，可能会遇到错误
SELECT m,
	   ABS(m) AS abs_col ,
	   n, 
	   p,
	   MOD(n, p) AS mod_col,
	   ROUND(m,1) AS round_colS
FROM samplemath;


-- 字符串函数
-- DDL ：创建表
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

-- CONCAT – 拼接
-- 语法：CONCAT(str1, str2, str3)
-- MySQL中使用 CONCAT 函数进行拼接。

-- LENGTH – 字符串长度
-- 语法：LENGTH( 字符串 )

-- LOWER – 小写转换
-- LOWER 函数只能针对英文字母使用，它会将参数中的字符串全都转换为小写
-- 类似的， UPPER 函数用于大写转换。

-- REPLACE – 字符串的替换
-- 语法：REPLACE( 对象字符串，替换前的字符串，替换后的字符串 )
-- 把 对象字符串 中的 替换前字符串 换成 替换后字符串

-- SUBSTRING – 字符串的截取
-- 语法：SUBSTRING （对象字符串 FROM 截取的起始位置 FOR 截取的字符数）
-- 使用 SUBSTRING 函数 可以截取出字符串中的一部分字符串
-- 截取的起始位置从字符串最左侧开始计算，索引值起始为1
SELECT
	str1,
    str2,
    str3,
    concat(str1,str2,str3) as str_concat,
    length(str1) as len_str,
    lower(str1) as low_str,
    replace(str1, str2, str3) as rep_str,
    substring(str1 from 3 for 2) as sub_str
from
	samplestr;

-- SUBSTRING_INDEX – 字符串按索引截取
-- 语法：SUBSTRING_INDEX (原始字符串， 分隔符，n)
-- 该函数用来获取原始字符串按照分隔符分割后，第 n 个分隔符之前（或之后）的子字符串
-- 支持正向和反向索引，索引起始值分别为 1 和 -1。
SELECT SUBSTRING_INDEX('www.mysql.com', '.', 2);
-- www.mysql
SELECT SUBSTRING_INDEX('www.mysql.com', '.', -2);
-- mysql.com
-- 获取第2个元素/第n个元素可以采用二次拆分的写法
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX('www.mysql.com', '.', 2), '.', -1);


-- 日期函数
-- CURRENT_DATE – 获取当前日期
SELECT CURRENT_DATE;
-- CURRENT_TIME – 当前时间
SELECT CURRENT_TIME;
-- CURRENT_TIMESTAMP – 当前日期和时间
SELECT CURRENT_TIMESTAMP;

-- EXTRACT – 截取日期元素
-- 语法：EXTRACT(日期元素 FROM 日期)
-- 使用 EXTRACT 函数可以截取出日期数据中的一部分，例如“年”
-- “月”，或者“小时”“秒”等。该函数的返回值并不是日期类型而是数值类型
SELECT CURRENT_TIMESTAMP as now,
EXTRACT(YEAR   FROM CURRENT_TIMESTAMP) AS year,
EXTRACT(MONTH  FROM CURRENT_TIMESTAMP) AS month,
EXTRACT(DAY    FROM CURRENT_TIMESTAMP) AS day,
EXTRACT(HOUR   FROM CURRENT_TIMESTAMP) AS hour,
EXTRACT(MINUTE FROM CURRENT_TIMESTAMP) AS MINute,
EXTRACT(SECOND FROM CURRENT_TIMESTAMP) AS second;


-- 转换函数

-- CAST – 类型转换
-- 将字符串类型转换为数值类型
SELECT CAST('0001' AS SIGNED INTEGER) AS int_col;
-- 将字符串类型转换为日期类型
SELECT CAST('2009-12-14' AS DATE) AS date_col;

-- COALESCE – 将NULL转换为其他值
-- 语法：COALESCE(数据1，数据2，数据3……)
-- COALESCE 是 SQL 特有的函数。该函数会返回可变参数 A 中左侧开始第1个不是NULL的值
-- 参数个数是可变的，因此可以根据需要无限增加
-- 在 SQL 语句中将 NULL 转换为其他值时就会用到转换函数
SELECT COALESCE(NULL, 11) AS col_1,
COALESCE(NULL, 'hello world', NULL) AS col_2,
COALESCE(NULL, NULL, '2020-11-01', 1) AS col_3;


-- 谓词就是返回值为真值的函数，包括TRUE / FALSE / UNKNOWN。
-- 谓词主要有以下几个：
-- LIKE
-- BETWEEN
-- IS NULL、IS NOT NULL
-- IN
-- EXISTS

-- LIKE谓词 – 用于字符串的部分一致查询
-- 部分一致大体可以分为前方一致、中间一致和后方一致三种类型
-- DDL ：创建表
CREATE TABLE samplelike
( strcol VARCHAR(6) NOT NULL,
PRIMARY KEY (strcol));
-- DML ：插入数据
START TRANSACTION; -- 开始事务
INSERT INTO samplelike (strcol) VALUES ('abcddd');
INSERT INTO samplelike (strcol) VALUES ('dddabc');
INSERT INTO samplelike (strcol) VALUES ('abdddc');
INSERT INTO samplelike (strcol) VALUES ('abcdd');
INSERT INTO samplelike (strcol) VALUES ('ddabc');
INSERT INTO samplelike (strcol) VALUES ('abddc');
COMMIT; -- 提交事务

-- 前方一致
SELECT *
FROM samplelike
WHERE strcol LIKE 'ddd%';
-- 中间一致，%ddd%
-- 后方一致，%ddd
-- _下划线匹配任意 1 个字符
-- 使用 _（下划线）来代替 %，与 % 不同的是，它代表了“任意 1 个字符”
SELECT *
FROM samplelike
WHERE strcol LIKE 'abc__';

-- BETWEEN谓词 – 用于范围查询
-- 选取销售单价为100～ 1000元的商品
SELECT product_name, sale_price
FROM product
WHERE sale_price BETWEEN 100 AND 1000;
-- 闭区间，如果不想让结果中包含临界值，那就必须使用 < 和 >

-- IS NULL、 IS NOT NULL – 用于判断是否为NULL
SELECT product_name, purchase_price
FROM product
WHERE purchase_price IS NULL;
-- 想要选取 NULL 以外的数据时，需要使用IS NOT NULL

-- IN谓词 – OR的简便用法
-- 通过OR指定多个进货单价进行查询（多个查询条件取并集）
SELECT product_name, purchase_price
FROM product
WHERE purchase_price = 320
OR purchase_price = 500
OR purchase_price = 5000;
-- 没问题但是不够简洁
-- 可以使用IN 谓词`IN(值1, 值2, 值3, …)来替换上述 SQL 语句
SELECT product_name, purchase_price
FROM product
WHERE purchase_price IN (320, 500, 5000);

-- 希望选取出“进货单价不是 320 元、 500 元、 5000 元”的商品时
SELECT product_name, purchase_price
FROM product
WHERE purchase_price NOT IN (320, 500, 5000); -- 添加not

-- 使用IN 和 NOT IN 时是无法选取出NULL数据的
-- NULL 只能使用 IS NULL 和 IS NOT NULL 来进行判断

-- 使用子查询作为IN谓词的参数

-- DDL ：创建表
DROP TABLE IF EXISTS shopproduct;
CREATE TABLE shopproduct
(  shop_id CHAR(4)     NOT NULL,
 shop_name VARCHAR(200) NOT NULL,
product_id CHAR(4)      NOT NULL,
  quantity INTEGER      NOT NULL,
PRIMARY KEY (shop_id, product_id) -- 指定主键
);
-- DML ：插入数据
START TRANSACTION; -- 开始事务
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000A', '东京', '0001', 30);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000A', '东京', '0002', 50);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000A', '东京', '0003', 15);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000B', '名古屋', '0002', 30);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000B', '名古屋', '0003', 120);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000B', '名古屋', '0004', 20);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000B', '名古屋', '0006', 10);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000B', '名古屋', '0007', 40);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000C', '大阪', '0003', 20);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000C', '大阪', '0004', 50);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000C', '大阪', '0006', 90);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000C', '大阪', '0007', 70);
INSERT INTO shopproduct (shop_id, shop_name, product_id, quantity) VALUES ('000D', '福冈', '0001', 100);
COMMIT; -- 提交事务
-- 由于单独使用商店编号（shop_id）或者商品编号（product_id）不能区分表中每一行数据
-- 因此指定了 2 列作为主键（primary key）对商店和商品进行组合，用来唯一确定每一行数据

-- 需要取出大阪在售商品的销售单价
-- step1：取出大阪门店的在售商品 `product_id`
SELECT product_id
FROM shopproduct
WHERE shop_id = '000C';
-- step2：取出大阪门店在售商品的销售单价 `sale_price`
SELECT product_name, sale_price
FROM product
WHERE product_id IN (SELECT product_id
					   FROM shopproduct
					  WHERE shop_id = '000C');
-- 子查询展开后的结果
SELECT product_name, sale_price
FROM product
WHERE product_id IN ('0003', '0004', '0006', '0007');

-- in 谓词也能实现，那为什么还要使用子查询呢？
-- 实际生活中，某个门店的在售商品是不断变化的，使用 in 谓词就需要经常更新 sql 语句，降低了效率，提高了维护成本
-- 实际上，某个门店的在售商品可能有成百上千个，手工维护在售商品编号真是个大工程
-- 使用子查询即可保持 sql 语句不变，极大提高了程序的可维护性

-- NOT IN 使用子查询作为参数，取出未在大阪门店销售的商品的销售单价
SELECT product_name, sale_price
  FROM product
 WHERE product_id NOT IN (SELECT product_id
                            FROM shopproduct
                           WHERE shop_id = '000A');


-- EXIST 谓词
-- 使用 EXIST 选取出大阪门店在售商品的销售单价
SELECT product_name, sale_price
  FROM product AS p
 WHERE EXISTS (SELECT * -- 这里可以书写适当的常数，如1，但是*是习惯
                 FROM shopproduct AS sp
                WHERE sp.shop_id = '000C'
                  AND sp.product_id = p.product_id);

-- EXIST 通常会使用关联子查询作为参数
-- 子查询中的SELECT *，由于 EXIST 只关心记录是否存在
SELECT product_name, sale_price
  FROM product AS p
 WHERE NOT EXISTS (SELECT *
                     FROM shopproduct AS sp
                    WHERE sp.shop_id = '000A'
                      AND sp.product_id = p.product_id);


-- CASE 表达式
SELECT  product_name,
        CASE WHEN product_type = '衣服' THEN CONCAT('A ： ',product_type)
             WHEN product_type = '办公用品'  THEN CONCAT('B ： ',product_type)
             WHEN product_type = '厨房用具'  THEN CONCAT('C ： ',product_type)
             ELSE NULL
        END AS abc_product_type
  FROM  product;
-- ELSE 子句也可以省略不写，这时会被默认为 ELSE NUL，但一般写上
-- CASE 表达式最后的“END”是不能省略的，请大家特别注意不要遗漏

-- 行的方向上不同种类的聚合（这里是 sum）
SELECT product_type,
       SUM(sale_price) AS sum_price
  FROM product
 GROUP BY product_type; 

-- 对按照商品种类计算出的销售单价合计值进行行列转换
SELECT SUM(CASE WHEN product_type = '衣服' THEN sale_price ELSE 0 END) AS sum_price_clothes,
       SUM(CASE WHEN product_type = '厨房用具' THEN sale_price ELSE 0 END) AS sum_price_kitchen,
       SUM(CASE WHEN product_type = '办公用品' THEN sale_price ELSE 0 END) AS sum_price_office
  FROM product;

-- DDL ：创建表
create table score_table (
`name` VARCHAR(32)  NOT NULL,
`subject` VARCHAR(32)  NOT NULL,
score INTEGER
);
-- DML ：插入数据
START TRANSACTION; -- 开始事务
insert into score_table (`name`, `subject`, score) values ('张三', '语文', 93);
insert into score_table (`name`, `subject`, score) values ('张三', '数学', 88);
insert into score_table (`name`, `subject`, score) values ('张三', '英语', 91);
insert into score_table (`name`, `subject`, score) values ('李四', '语文', 87);
insert into score_table (`name`, `subject`, score) values ('李四', '数学', 90);
insert into score_table (`name`, `subject`, score) values ('李四', '英语', 77);
COMMIT; -- 提交事务

-- CASE WHEN 实现数字列 score 行转列
SELECT name,
       CASE WHEN subject = '语文' THEN score ELSE null END as chinese,
       SUM(CASE WHEN subject = '数学' THEN score ELSE null END) as math,
       SUM(CASE WHEN subject = '英语' THEN score ELSE null END) as english
  FROM score_table
 GROUP BY name;
-- CASE WHEN 实现文本列 subject 行转列
SELECT name,
       MAX(CASE WHEN subject = '语文' THEN subject ELSE null END) as chinese,
       MAX(CASE WHEN subject = '数学' THEN subject ELSE null END) as math,
       MIN(CASE WHEN subject = '英语' THEN subject ELSE null END) as english
  FROM score_table
 GROUP BY name;
-- 当待转换列为数字时，可以使用SUM AVG MAX MIN等聚合函数；
-- 当待转换列为文本时，可以使用MAX MIN等聚合函数

-- 3.5 
-- 运算或者函数中含有 NULL 时，结果全都会变为NULL

-- 3.6
SELECT product_name, purchase_price
  FROM product
 WHERE purchase_price not IN (500, 2800, 5000, null);
-- not in中有null时不会返回数据，想找null只能用is (not) null

-- 3.7
-- 低档商品：销售单价在1000日元以下（T恤衫、办公用品、叉子、擦菜板、 圆珠笔）
-- 中档商品：销售单价在1001日元以上3000日元以下（菜刀）
-- 高档商品：销售单价在3001日元以上（运动T恤、高压锅）
SELECT SUM(CASE WHEN sale_price <= 1000 THEN 1 ELSE 0 END) AS low_price,
SUM(CASE WHEN sale_price BETWEEN 1001 AND 3000 THEN 1 ELSE 0 END) AS mid_price,
SUM(CASE WHEN sale_price >= 3001 THEN 1 ELSE 0 END) AS high_price
FROM product;

SELECT CASE WHEN sale_price <= 1000 THEN 1 ELSE 0 END AS low_price,
CASE WHEN sale_price BETWEEN 1001 AND 3000 THEN 1 ELSE 0 END AS mid_price,
CASE WHEN sale_price >= 3001 THEN 1 ELSE 0 END AS high_price
FROM product;









