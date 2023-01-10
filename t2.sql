# select
-- 用来选取product type列为衣服’的记录的SELECT语句
SELECT product_name, product_type
  FROM product
 WHERE product_type = '衣服';
-- 也可以选取出不是查询条件的列（条件列与输出列不同）
SELECT product_name
  FROM product
 WHERE product_type = '衣服';

-- 星号（*）代表全部列的意思。
-- SQL中可以随意使用换行符，不影响语句执行（但不可插入空行）。
-- 设定汉语别名时需要使用双引号（"）括起来。
-- 在SELECT语句中使用DISTINCT可以删除重复行。
-- 注释是SQL语句中用来标识说明或者注意事项的部分。分为1行注释"-- "和多行注释两种"/* */"

-- 想要查询出全部列时，可以使用代表所有列的星号（*）。
SELECT *
  FROM product;
-- SQL语句可以使用AS关键字为列设定别名（用中文时需要双引号（“”））。
SELECT product_id     AS id,
       product_name   AS name,
       purchase_price AS "进货单价"
  FROM product;
-- 使用DISTINCT删除product_type列中重复的数据
SELECT DISTINCT product_type
  FROM product;

-- <> 不等于, >= 大于等于, <= 小于等于
-- 字符串类型的数据原则上按照字典顺序进行排序，不能与数字的大小顺序混淆

-- SQL语句中也可以使用运算表达式
SELECT product_name, sale_price, sale_price * 2 AS "sale_price x2"
  FROM product;

-- WHERE子句的条件表达式中也可以使用计算表达式
SELECT product_name, sale_price, purchase_price
  FROM product
 WHERE sale_price-purchase_price >= 500;

/* 对字符串使用不等号
首先创建chars并插入数据
选取出大于‘2’的SELECT语句*/
-- DDL：创建表
CREATE TABLE chars(
chr CHAR(3) NOT NULL,
PRIMARY KEY(chr)
);
-- 选取出大于'2'的数据的SELECT语句('2'为字符串)
SELECT chr
  FROM chars
 WHERE chr > '2';

-- 不能使用运算符（><=）来选null！！！！！！
-- 选取NULL的记录
SELECT product_name,purchase_price
  FROM product
 WHERE purchase_price IS NULL;
-- 选取不为NULL的记录
SELECT product_name,purchase_price
  FROM product
 WHERE purchase_price IS NOT NULL;

-- 想要表示“不是……”时，除了前文的<>运算符外，还存在另外一个表示否定、使用范围更广的运算符：NOT
-- 选取出销售单价大于等于1000日元的记录
SELECT product_name, product_type, sale_price
  FROM product
 WHERE sale_price >= 1000;
 -- 向代码清单2-30的查询条件中添加NOT运算符
SELECT product_name, product_type, sale_price
  FROM product
 WHERE NOT sale_price >= 1000;

-- 当希望同时使用多个查询条件时，可以使用AND或者OR运算符
-- AND 运算符优先于 OR 运算符，想要优先执行OR运算，可以使用括号
-- “商品种类为办公用品”并且“登记日期是 2009 年 9 月 11 日或者 2009 年 9 月 20 日”
-- 通过使用括号让OR运算符先于AND运算符执行
SELECT product_name, product_type, regist_date
  FROM product
 WHERE product_type = '办公用品'
   AND ( regist_date = '2009-09-11'
        OR regist_date = '2009-09-20');

-- 真值表见`真值表.png`, `三值真值表.png`
/*含有NULL时的真值
这时真值是除真假之外的第三种值——不确定（UNKNOWN）
一般的逻辑运算并不存在这第三种值。SQL 之外的语言也基本上只使用真和假这两种真值
与通常的逻辑运算被称为二值逻辑相对，只有 SQL 中的逻辑运算被称为三值逻辑*/

-- 从product（商品）表中选取出“登记日期（regist）在2009年4月28日之后”的商品
-- 查询结果要包含product_name和regist_date两列
select product_name, regist_date
  from product
 where regist_date > '2009-04-28';

/*SELECT语句能够从product表中取出“销售单价（saleprice）
比进货单价（purchase price）高出500日元以上”的商品*/
select product_name, sale_price, purchase_price
from product
where sale_price-purchase_price >= 500;
-- or sale_price >= 500+purchase_price

/*从product表中选取出满足“销售单价打九折之后利润高于100日元的办公用品和厨房用具”条件的记录
查询结果要包括product_name列、product_type列
以及销售单价打九折之后的利润（别名设定为profit）*/
SELECT product_name, product_type, sale_price*0.9-purchase_price as profit
from product
where sale_price*0.9-purchase_price>=100
	and (product_type = '办公用品' 
		or product_type = '厨房用具') ; -- 不能用profit>=100

-- SQL中用于汇总的函数叫做聚合函数。以下五个是最常用的聚合函数：
-- COUNT：计算表中的记录数（行数）
-- SUM：计算表中数值列中数据的合计值
-- AVG：计算表中数值列中数据的平均值
-- MAX：求出表中任意列中数据的最大值
-- MIN：求出表中任意列中数据的最小值
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
 FROM product; -- 有两个商品价格都是500，因此结果差500

-- COUNT函数的结果根据参数的不同而不同。COUNT(*)会得到包含NULL的数据行数，而COUNT(<列名>)会得到NULL之外的数据行数。
-- 聚合函数会将NULL排除在外。但COUNT(*)例外，并不会排除NULL。
-- MAX/MIN函数几乎适用于所有数据类型的列。SUM/AVG函数只适用于数值类型的列。
-- 想要计算值的种类时，可以在COUNT函数的参数中使用DISTINCT。
-- 在聚合函数的参数中使用DISTINCT，可以删除重复数据

-- GROUP BY
-- 按照商品种类统计数据行数
SELECT product_type, COUNT(*)
  FROM product
 GROUP BY product_type;
 -- 不含GROUP BY
SELECT product_type, COUNT(*)
  FROM product;
-- 简单来说不使用group by, count只会算总数不管product_type

-- 包含null时，null会作为一组特殊数据
SELECT purchase_price, COUNT(*)
  FROM product
 GROUP BY purchase_price;

-- 严格的顺序
SELECT purchase_price, COUNT(*)
  FROM product
 WHERE product_type = '衣服'
 GROUP BY purchase_price;

/*使用COUNT等聚合函数时，SELECT子句中如果出现列名，只能是GROUP BY子句中指定的列名（也就是聚合键）
SELECT子句中可以通过AS来指定别名，但在GROUP BY中不能使用别名，因为在DBMS中 ,SELECT子句在GROUP BY子句后执行*/

-- having, 用于聚合完后的筛选，语法类似where
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
-- 正确示范
SELECT product_type, COUNT(*)
  FROM product
 GROUP BY product_type
HAVING product_type = '衣服';

-- SQL中的执行结果是随机排列的，当需要按照特定顺序排序时，可已使用ORDER BY子句
-- 默认为升序排列（越来越大），降序排列为DESC
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

-- FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY，因此order by中可以使用别名，但是group by不行

-- 练习5，先where再group by

-- 求出销售单价（sale_price列）合计值大于进货单价（purchase_price列）合计值1.5倍的商品种类
SELECT product_type, sum(sale_price) as sum, sum(purchase_price) as sum
from product
group by product_type
having sum(sale_price)> sum(purchase_price)*1.5;

-- 7
SELECT *
from product
order by regist_date desc, sale_price;






