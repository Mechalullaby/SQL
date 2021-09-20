-- 用来选取product type列为衣服’的记录的SELECT语句
SELECT product_name, product_type
  FROM product
 WHERE product_type = '衣服';
-- 也可以选取出不是查询条件的列（条件列与输出列不同）
SELECT product_name
  FROM product
 WHERE product_type = '衣服';
-- SQL语句可以使用AS关键字为列设定别名（用中文时需要双引号（“”））
SELECT product_id     AS id,
       product_name   AS name,
       purchase_price AS "进货单价"
  FROM product;
-- 使用DISTINCT删除product_type列中重复的数据
SELECT DISTINCT product_type
  FROM product;
/* 对字符串使用不等号
首先创建chars并插入数据
选取出大于‘2’的SELECT语句*/
-- DDL：创建表
CREATE TABLE chars
(chr CHAR(3)NOT NULL,
PRIMARY KEY(chr));
-- 选取出大于'2'的数据的SELECT语句('2'为字符串)
SELECT chr
  FROM chars
 WHERE chr > '2';
-- 选取NULL的记录
SELECT product_name，purchase_price
  FROM product
 WHERE purchase_price IS NULL;
-- 选取不为NULL的记录
SELECT product_name，purchase_price
  FROM product
 WHERE purchase_price IS NOT NULL;
-- 通过使用括号让OR运算符先于AND运算符执行
SELECT product_name, product_type, regist_date
  FROM product
 WHERE product_type = '办公用品'
   AND ( regist_date = '2009-09-11'
        OR regist_date = '2009-09-20');
-- 练习题
SELECT product_name, regist_date
FROM product
WHERE regist_date > '2009-4-28';
SELECT *
FROM product
WHERE sale_price >= purchase_price + 500;
SELECT product_name,  product_type
FROM product
WHERE sale_price * 0.9 - purchase_price > 100 
AND ( product_name = '办公用品'
	OR product_name = '厨房用具');

-- 计算全部数据的行数（包含NULL）
SELECT COUNT(*)
  FROM product;
-- 计算NULL以外数据的行数
SELECT COUNT(purchase_price)
  FROM product;
-- 计算销售单价和进货单价的合计值
SELECT SUM(sale_price), SUM(purchase_price) 
  FROM product;
-- 计算销售单价和进货单价的平均值
SELECT AVG(sale_price), AVG(purchase_price)
  FROM product;
-- MAX和MIN也可用于非数值型数据
SELECT MAX(regist_date), MIN(regist_date)
  FROM product;
-- 计算去除重复数据后的数据行数
SELECT COUNT(DISTINCT product_type)
 FROM product;
-- 是否使用DISTINCT时的动作差异（SUM函数）
SELECT SUM(sale_price), SUM(DISTINCT sale_price)
 FROM product;
-- 按照商品种类统计数据行数
SELECT product_type, COUNT(*)
  FROM product
 GROUP BY product_type;

SELECT purchase_price, COUNT(*)
  FROM product
 WHERE product_type = '衣服'
 GROUP BY purchase_price;
-- 数字
SELECT product_type, COUNT(*)
  FROM product
 GROUP BY product_type
HAVING COUNT(*) = 2;
-- 错误形式（因为product_name不包含在GROUP BY聚合键中）
SELECT product_type, COUNT(*)
  FROM product
 GROUP BY product_type
HAVING product_name = '圆珠笔';
-- 降序排列
SELECT product_id, product_name, sale_price, purchase_price
  FROM product
 ORDER BY sale_price DESC;
-- 多个排序键
SELECT product_id, product_name, sale_price, purchase_price
  FROM product
 ORDER BY sale_price, product_id;
-- 当用于排序的列名中含有NULL时，NULL会在开头或末尾进行汇总。
SELECT product_id, product_name, sale_price, purchase_price
  FROM product
 ORDER BY purchase_price;
-- 在ORDER BY中可以使用别名，但是在GROUP BY中不能使用别名
-- 6
SELECT product_type, SUM(sale_price), SUM(purchase_price)
FROM product
GROUP BY product_type
HAVING SUM(sale_price) > SUM(purchase_price)*1.5;
SELECT *
FROM product
ORDER BY regist_date DESC, sale_price;





