-- 集合运算-表的加减法和join等

-- 表的加法–UNION，并集
SELECT product_id, product_name
  FROM product
 UNION
SELECT product_id, product_name
  FROM product2;

-- 增加毛利率超过 50%或者售价低于 800 的货物的存货量
SELECT  product_id,product_name,product_type
       ,sale_price,purchase_price
  FROM product 
 WHERE sale_price<800
  
 UNION
 
SELECT  product_id,product_name,product_type
       ,sale_price,purchase_price
  FROM product 
 WHERE sale_price>1.5*purchase_price;
 
-- 仅用于演示，实际上用OR更方便
SELECT  product_id,product_name,product_type
       ,sale_price,purchase_price
  FROM product 
 WHERE sale_price < 800 
    OR sale_price > 1.5 * purchase_price; -- 毛利率超过50%

-- 分别使用 UNION 或者 OR 谓词,找出毛利率不足 30%或毛利率未知的商品
-- or
select product_id,product_name,product_type -- or use *
       ,sale_price,purchase_price
  FROM product 
 where sale_price < 1.3 * purchase_price -- sale_price / purchase_price < 1.3
    or sale_price / purchase_price is null;

-- union
select product_id,product_name,product_type
       ,sale_price,purchase_price
  FROM product 
 where sale_price < 1.3 * purchase_price

 union

select product_id,product_name,product_type
       ,sale_price,purchase_price
  FROM product 
 where sale_price / purchase_price is null;

/*UNION 会对两个查询的结果集进行合并和去重, 这种去重不仅会去掉两个结果集相互重复的, 
还会去掉一个结果集中的重复行. 
有时候需要需要不去重的并集, 则在UNION 后面添加 ALL 关键字*/
-- 保留重复行
SELECT product_id, product_name
  FROM product
 UNION ALL
SELECT product_id, product_name
  FROM product2;

-- 对product表中利润低于50%和售价低于1000的商品提价
SELECT *
  FROM product
 WHERE sale_price / purchase_price < 1.5
 UNION ALL
SELECT *
  FROM product
 WHERE sale_price < 1000;

/*bag 允许元素重复出现, 对于两个 bag, 他们的并运算会按照: 
1.该元素是否至少在一个 bag 里出现过, 
2.该元素在两个 bag 中的最大出现次数
因此对于 A = {1,1,1,2,3,5,7}, B = {1,1,2,2,4,6,8} 两个 bag, 
它们的并就等于 {1,1,1,2,2,3,4,5,6,7,8}.*/

-- 隐式类型转换
SELECT product_id, product_name, '1'
  FROM product
 UNION
SELECT product_id, product_name,sale_price
  FROM product2;

-- SYSDATE()函数可以返回当前日期时间, 是一个日期时间类型的数据
-- 以下代码可以正确执行, 说明时间日期类型和字符串,数值以及缺失值均能兼容
SELECT SYSDATE(), SYSDATE(), SYSDATE()
 UNION
SELECT 'chars', 123,  null;

-- MySQL 8.0 不支持交运算INTERSECT

/*对于两个 bag, 他们的交运算会按照: 
1.该元素是否同时属于两个 bag, 
2.该元素在两个 bag 中的最小出现次数这两个方面来进行计算
对于 A = {1,1,1,2,3,5,7}, B = {1,1,2,2,4,6,8} 两个 bag, 
它们的交运算结果就等于 {1,1,2}*/

-- MySQL 8.0 还不支持 EXCEPT 运算
-- 不过, 借助第六章学过的NOT IN 谓词, 我们同样可以实现表的减法
-- 只存在于product表但不存在于product2表的商品
SELECT *
  FROM product
 where product_id not in (SELECT product_id
						    FROM product2);

-- 售价高于2000,但利润低于30%的商品，仅示范功能，不要学
SELECT * 
  FROM product
 WHERE sale_price > 2000 
   AND product_id NOT IN (SELECT product_id 
                            FROM product 
                           WHERE sale_price<1.3*purchase_price)

/*EXCEPT ALL 也是按出现次数进行减法, 也是使用bag模型进行运算.
1.该元素是否属于作为被减数的 bag,
2.该元素在两个 bag 中的出现次数;
这两个方面来进行计算. 只有属于被减数的bag的元素才参与EXCEP ALL运算, 
并且差bag中的次数,等于该元素在两个bag的出现次数之差(差为零或负数则不出现). 
因此对于 A = {1,1,1,2,3,5,7}, B = {1,1,2,2,4,6,8} 两个 bag, 
它们的差就等于 {1,3,5,7}.*/

-- 对称差
-- 两个集合A,B的对称差是指那些仅属于A或仅属于B的元素构成的集合

-- 两个集合的对称差等于 A-B并上B-A, 因此实践中可以用这个思路来求对称差

-- 使用product表和product2表的对称差来查询哪些商品只在其中一张表
select product_id
from product
where product_id not in (select product_id
						   from product2)
union
select product_id
from product2
where product_id not in (select product_id
						   from product1);

-- INTERSECT, 两个集合的交可以看作是两个集合的并去掉两个集合的对称差
-- 直接in不就可以了吗？


-- 内连结(INNER JOIN)
-- 内连结
-- FROM <tb_1> INNER JOIN <tb_2> ON <condition(s)>;
-- FROM 子句中使用 INNER JOIN 将两张表连接起来
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.product_type
       ,P.sale_price
       ,SP.quantity
  FROM shopproduct AS SP
 INNER JOIN product AS P
    ON SP.product_id = P.product_id;

/*内连结,需要注意以下三点
一: 进行连结时需要在 FROM 子句中使用多张表
FROM shopproduct AS SP INNER JOIN product AS P
二:必须使用 ON 子句来指定连结条件
能起到与 WHERE 相同的筛选作用
三: SELECT 子句中的列最好按照 表名.列名 的格式来使用
当两张表的列除了用于关联的列之外, 没有名称相同的列的时候, 也可以不写表名, 
但表名使得我们能够在今后读查询代码的时候, 都能马上看出每一列来自于哪张表
*/

-- 使用内连结的时候同时使用 WHERE , 把 WHERE 子句写在 ON 子句的后边

-- 第一种增加 WEHRE 子句的方式, 就是把上述查询作为子查询, 用括号封装起来
SELECT *
  FROM (-- 第一步查询的结果
        SELECT SP.shop_id
               ,SP.shop_name
               ,SP.product_id
               ,P.product_name
               ,P.product_type
               ,P.sale_price
               ,SP.quantity
          FROM shopproduct AS SP
         INNER JOIN product AS P
            ON SP.product_id = P.product_id) AS STEP1
 WHERE shop_name = '东京'
   AND product_type = '衣服' ;

-- 标准写法
-- 做完 INNER JOIN … ON 得到一个新表后, 才会执行 WHERE 子句
SELECT  SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.product_type
       ,P.sale_price
       ,SP.quantity
  FROM shopproduct AS SP
 INNER JOIN product AS P
    ON SP.product_id = P.product_id
 WHERE SP.shop_name = '东京'
   AND P.product_type = '衣服' ;

-- 不是很常见的做法是,还可以将 WHERE 子句中的条件直接添加在 ON 子句中
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.product_type
       ,P.sale_price
       ,SP.quantity
  FROM shopproduct AS SP
 INNER JOIN product AS P
    ON (SP.product_id = P.product_id
   AND SP.shop_name = '东京'
   AND P.product_type = '衣服') ; -- 不建议大家使用

/*先连结再筛选的标准写法的执行顺序是, 两张完整的表做了连结之后再做筛选,
如果要连结多张表, 或者需要做的筛选比较复杂时, 在写 SQL 查询时会感觉比较吃力. 
在结合 WHERE 子句使用内连结的时候, 我们也可以更改任务顺序, 并采用任务分解的方法,
先分别在两个表使用 WHERE 进行筛选,然后把上述两个子查询连结起来*/
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.product_type
       ,P.sale_price
       ,SP.quantity
  FROM (-- 子查询 1:从shopproduct 表筛选出东京商店的信息
        SELECT *
          FROM shopproduct
         WHERE shop_name = '东京' ) AS SP
 INNER JOIN -- 子查询 2:从 product 表筛选出衣服类商品的信息
   (SELECT *
      FROM product
     WHERE product_type = '衣服') AS P
    ON SP.product_id = P.product_id;

-- 看似复杂的写法, 实际上整体的逻辑反而非常清晰

-- 找出每个商店里的衣服类商品的名称及价格等信息
-- 不使用子查询
SELECT  SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.product_type
       ,P.sale_price
       ,SP.quantity
  FROM shopproduct AS SP
 INNER JOIN product AS P
    ON SP.product_id = P.product_id
 WHERE P.product_type = '衣服' ;

-- 使用where
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.product_type
       ,P.sale_price
       ,SP.quantity
  FROM shopproduct AS SP
 INNER JOIN
   (SELECT *
      FROM product
     WHERE product_type = '衣服') AS P
    ON SP.product_id = P.product_id;

-- 找出东京商店里, 售价低于 2000 的商品信息
-- 不使用子查询
SELECT SP.*, P.*
  FROM shopproduct AS SP
 INNER JOIN product AS P
    ON SP.product_id = P.product_id
 WHERE SP.shop_name = '东京' -- shop_id = '000A'
   AND P.sale_price < 2000 ;

-- 使用where
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.product_type
       ,P.sale_price
       ,SP.quantity
  FROM (SELECT *
      FROM shopproduct
     WHERE shop_name = '东京') AS SP
 INNER JOIN
   (SELECT *
      FROM product
     WHERE sale_price < 2000) AS P
    ON SP.product_id = P.product_id;

-- GROUP BY 子句使用内连结, 需要根据分组列位于哪个表区别对待.
-- 最简单的情形, 是在内连结之前就使用 GROUP BY 子句
-- 如果分组列和被聚合的列不在同一张表, 且二者都未被用于连结两张表, 则只能先连结, 再聚合
-- 每个商店中, 售价最高的商品的售价分别是多少
SELECT SP.shop_id
      ,SP.shop_name
      ,MAX(P.sale_price) AS max_price
  FROM shopproduct AS SP
 INNER JOIN product AS P
    ON SP.product_id = P.product_id
 GROUP BY SP.shop_id,SP.shop_name;
 
-- 获取每个商店里售价最高的商品的名称和售价
-- 在找出每个商店售价最高商品的价格后, 使用这个价格再与product 列进行连结, 
-- 这种做法在价格不唯一时会出现问题
select smax.*,
	   P.product_name
  FROM (SELECT SP.shop_id
      ,SP.shop_name
      ,MAX(P.sale_price) AS max_price
  FROM shopproduct AS SP
 INNER JOIN product AS P
    ON SP.product_id = P.product_id
 GROUP BY SP.shop_id,SP.shop_name) as smax
 inner join product AS P
 on smax.max_price = P.sale_price;
       
/*自连结(SELF JOIN)
一张表也可以与自身作连结, 这种连接称之为自连结. 
需要注意, 自连结并不是区分于内连结和外连结的第三种连结, 
自连结可以是外连结也可以是内连结, 它是不同于内连结外连结的另一个连结的分类方法*/

-- 内连结与关联子查询
-- 找出每个商品种类当中售价高于该类商品的平均售价的商品
SELECT  P1.product_id
       ,P1.product_name
       ,P1.product_type
       ,P1.sale_price
       ,P2.avg_price
  FROM product AS P1
 INNER JOIN 
   (SELECT product_type,AVG(sale_price) AS avg_price 
      FROM product 
     GROUP BY product_type) AS P2 
    ON P1.product_type = P2.product_type
 WHERE P1.sale_price > P2.avg_price;

-- 更屌但是不好理解的代码
SELECT  P1.product_id
       ,P1.product_name
       ,P1.product_type
       ,P1.sale_price
       ,AVG(P2.sale_price) AS avg_price
  FROM product AS P1
 INNER JOIN product AS P2
    ON P1.product_type = P2.product_type
 WHERE P1.sale_price > P2.sale_price
 GROUP BY P1.product_id,P1.product_name,P1.product_type,P1.sale_price,P2.product_type;


-- 自然连结(NATURAL JOIN)
-- 内连结的一种特例–当两个表进行自然连结时, 
-- 按照两个表中都包含的列名来进行等值内连结, 此时无需使用 ON 来指定连接条件.
SELECT *  FROM shopproduct NATURAL JOIN product;

-- 与上述自然连结等价的内连结
SELECT SP.*,P.product_name,P.product_type,P.sale_price
       ,P.purchase_price,P.regist_date
  FROM shopproduct AS SP 
 INNER JOIN product AS P
    ON SP.product_id = P.product_id;

-- 使用自然连结还可以求出两张表或子查询的公共部分
SELECT * FROM product NATURAL JOIN product2; 
-- 有null的情况，即使一样也不会被选上

SELECT * 
  FROM (SELECT product_id, product_name
          FROM product ) AS A 
NATURAL JOIN 
   (SELECT product_id, product_name 
      FROM product2) AS B;

-- 使用内连结求product 表和product2 表的交集
SELECT P1.*
  FROM product AS P1
 INNER JOIN product2 AS P2
    ON (P1.product_id  = P2.product_id
   AND P1.product_name = P2.product_name
   AND P1.product_type = P2.product_type
   AND P1.sale_price   = P2.sale_price
   AND P1.regist_date  = P2.regist_date);
-- 可以只on P1.product_id = P2.product_id


-- 外连结(OUTER JOIN)
/*按照保留的行位于哪张表,外连结有三种形式: 左连结, 右连结和全外连结
左连结会保存左表中无法按照 ON 子句匹配到的行, 此时对应右表的行均为缺失值，
结果与inner不一样因为两表可能没有包含关系；
右连结则会保存右表中无法按照 ON 子句匹配到的行, 此时对应左表的行均为缺失值; 
全外连结则会同时保存两个表中无法按照 ON子句匹配到的行, 相应的另一张表中的行用缺失值填充*/

-- 左连结
-- 每种商品分别在哪些商店有售, 需要包括那些在每个商店都没货的商品
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.sale_price
  FROM product AS P
  LEFT OUTER JOIN shopproduct AS SP
    ON SP.product_id = P.product_id;
-- 这两种商品并未在任何商店有售(这通常意味着比较重要的业务信息

-- 外连结要点 1: 选取出单张表中全部的信息
-- 	只要数据存在于某一张表当中,就能够读取出来.在实际的业务中,
-- 	例如想要生成固定行数的单据时,就需要使用外连结
-- 外连结要点 2:使用 LEFT、RIGHT 来指定主表
-- 它们的功能没有任何区别,使用哪一个都可以.通常使用 LEFT 的情况会多一些

-- 从shopproduct表和product表中找出那些在某个商店库存少于50的商品及对应的商店
SELECT P.product_id
       ,P.product_name
       ,P.sale_price
       ,SP.shop_id
       ,SP.shop_name
       ,SP.quantity
  FROM product AS P
  LEFT OUTER JOIN shopproduct AS SP
    ON SP.product_id = P.product_id
 WHERE SP.quantity < 50
    OR SP.quantity IS NULL;

-- 在实际环境中，我们并不能容易地意识到缺失值等问题数据的存在
-- 可以试着把WHERE子句挪到外连结之前进行
SELECT P.product_id
       ,P.product_name
       ,P.sale_price
       ,SP.shop_id
       ,SP.shop_name
       ,SP.quantity
  FROM product AS P
  LEFT OUTER JOIN (SELECT *
					 FROM shopproduct
					WHERE quantity < 50) AS SP
    ON SP.product_id = P.product_id;
    
/*全外连结本质上就是对左表和右表的所有行都予以保留, 
遗憾的是, MySQL8.0 目前还不支持全外连结, 
不过我们可以对左连结和右连结的结果进行 UNION 来实现全外连结*/


-- 多表连结

-- DDL：创建表
CREATE TABLE Inventoryproduct
( inventory_id       CHAR(4) NOT NULL,
product_id         CHAR(4) NOT NULL,
inventory_quantity INTEGER NOT NULL,
PRIMARY KEY (inventory_id, product_id));
--- DML：插入数据
START TRANSACTION;
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0001', 0);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0002', 120);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0003', 200);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0004', 3);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0005', 0);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0006', 99);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0007', 999);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P001', '0008', 200);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0001', 10);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0002', 25);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0003', 34);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0004', 19);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0005', 99);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0006', 0);
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0007', 0 );
INSERT INTO Inventoryproduct (inventory_id, product_id, inventory_quantity)
VALUES ('P002', '0008', 18);
COMMIT;

-- 使用内连接找出每个商店都有那些商品, 每种商品的库存总量分别是多少
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.sale_price,
	   I.inventory_quantity
  FROM product AS P 
 INNER JOIN shopproduct AS SP
    ON P.product_id = SP.product_id  
 INNER JOIN Inventoryproduct AS I
    ON P.product_id = I.product_id
 WHERE I.inventory_id = 'P001';

-- 外连结
SELECT P.product_id
       ,P.product_name
       ,P.sale_price
       ,SP.shop_id
       ,SP.shop_name
       ,IP.inventory_quantity
  FROM product AS P
  LEFT OUTER JOIN shopproduct AS SP
    ON SP.product_id = P.product_id
  LEFT OUTER JOIN Inventoryproduct AS IP
	ON SP.product_id = IP.product_id;

-- ON 子句进阶–非等值连结
-- 包括比较运算符(<,<=,>,>=, BETWEEN)和谓词运算(LIKE, IN, NOT 等等)
-- 在内的所有的逻辑运算都可以放在 ON 子句内作为连结条件

-- 非等值自左连结(SELF JOIN)
-- 使用非等值自左连结实现排名
-- 对 product 表中的商品按照售价赋予排名
-- 对每一种商品,找出售价不低于它的所有商品, 
-- 然后对售价不低于它的商品使用 COUNT 函数计数. 
-- 例如, 对于价格最高的商品
SELECT  product_id
       ,product_name
       ,sale_price
       ,COUNT(p2_id) AS rank_id
  FROM (-- 使用自左连结对每种商品找出价格不低于它的商品
        SELECT P1.product_id
               ,P1.product_name
               ,P1.sale_price
               ,P2.product_id AS P2_id
               ,P2.product_name AS P2_name
               ,P2.sale_price AS P2_price 
          FROM product AS P1 
          LEFT OUTER JOIN product AS P2 
            ON ((P1.sale_price > P2.sale_price)
             OR (P1.sale_price = P2.sale_price 
            AND P1.product_id<=P2.product_id))
	      ORDER BY P1.sale_price,P1.product_id 
        ) AS X
 GROUP BY product_id
 ORDER BY rank_id; 
-- COUNT 函数的参数是列名时, 会忽略该列中的缺失值, 参数为 * 时则不忽略缺失值

-- 按照商品的售价从低到高,对售价进行累计求和(没有实际意义)
-- 首先, 按照题意, 对每种商品使用自左连结, 找出比该商品售价价格更低或相等的商品
SELECT  P1.product_id
       ,P1.product_name
       ,P1.sale_price
       ,P2.product_id AS P2_id
       ,P2.product_name AS P2_name
       ,P2.sale_price AS P2_price 
  FROM product AS P1 
  LEFT OUTER JOIN product AS P2 
    ON P1.sale_price >= P2.sale_price
 ORDER BY P1.sale_price,P1.product_id;
 
-- 下一步, 按照 P1.product_id 分组,对 P2_price 求和
SELECT  product_id
       ,product_name
       ,sale_price
       ,SUM(P2_price) AS cum_price 
  FROM (SELECT  P1.product_id
               ,P1.product_name
               ,P1.sale_price
               ,P2.product_id AS P2_id
               ,P2.product_name AS P2_name
               ,P2.sale_price AS P2_price 
          FROM product AS P1 
          LEFT OUTER JOIN product AS P2 
            ON P1.sale_price >= P2.sale_price
         ORDER BY P1.sale_price,P1.product_id ) AS X
 GROUP BY product_id, product_name, sale_price
 ORDER BY sale_price,product_id;
 
-- 累计求和错误, 这是由于这两种商品售价相同导致的
-- 利用 ID 的有序性, 进一步将上述查询改写为
SELECT	product_id, product_name, sale_price
       ,SUM(P2_price) AS cum_price 
  FROM
        (SELECT  P1.product_id, P1.product_name, P1.sale_price
                ,P2.product_id AS P2_id
                ,P2.product_name AS P2_name
                ,P2.sale_price AS P2_price 
           FROM product AS P1 
           LEFT OUTER JOIN product AS P2 
             ON ((P1.sale_price > P2.sale_price)
             OR (P1.sale_price = P2.sale_price 
            AND P1.product_id<=P2.product_id))
	      ORDER BY P1.sale_price,P1.product_id) AS X
 GROUP BY product_id, product_name, sale_price
 ORDER BY sale_price,cum_price;

-- 交叉连结—— CROSS JOIN(笛卡尔积)，没什么用，不用学
-- 对两张表中的全部记录进行交叉组合,因此结果中的记录数通常是两张表中行数的乘积

-- 使用过时语法的内连结
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.sale_price
  FROM shopproduct SP,product P
 WHERE SP.product_id = P.product_id
   AND SP.shop_id = '000A';





