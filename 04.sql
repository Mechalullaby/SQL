-- UNION
SELECT product_id, product_name
  FROM product
 UNION
SELECT product_id, product_name
  FROM product2;

-- 使用 OR 谓词
SELECT * 
  FROM product 
 WHERE sale_price / purchase_price < 1.3 
    OR sale_price / purchase_price IS NULL;
-- 使用 UNION
SELECT * 
  FROM product 
 WHERE sale_price / purchase_price < 1.3
 
 UNION
SELECT * 
  FROM product 
 WHERE sale_price / purchase_price IS NULL;

-- 保留重复行
SELECT product_id, product_name
  FROM product
 UNION ALL
SELECT product_id, product_name
  FROM product2;
  
SELECT *
FROM product
WHERE sale_price > 1.5 * purchase_price -- 利润低于50%
UNION ALL
SELECT *
FROM product
WHERE sale_price < 1000; 

-- 隐式类型转换
SELECT product_id, product_name, '1'
  FROM product
 UNION
SELECT product_id, product_name,sale_price
  FROM product2;

SELECT SYSDATE(), SYSDATE(), SYSDATE()
 UNION
SELECT 'chars', 123,  null;

-- MySQL 8.0 不支持交运算INTERSECT，不支持 EXCEPT 运算
-- 使用 IN 子句的实现方法
SELECT * 
  FROM product
 WHERE product_id NOT IN (SELECT product_id 
                            FROM product2);

-- 使用 NOT IN 实现两个表的差集
SELECT * 
  FROM product
 WHERE product_id NOT IN (SELECT product_id FROM product2)
UNION
SELECT * 
  FROM product2
 WHERE product_id NOT IN (SELECT product_id FROM product);
 
-- 内连接，join
SELECT SP.shop_id
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

-- 使用子查询
SELECT  SP.shop_id, SP.shop_name, SP.product_id
       ,P.product_name, P.product_type, P.purchase_price
  FROM shopproduct AS SP 
INNER JOIN -- 从 product 表找出衣服类商品的信息
  (SELECT product_id, product_name, product_type, purchase_price
     FROM product	
    WHERE product_type = '衣服') AS P 
   ON SP.product_id = P.product_id;

-- 找出东京商店里, 售价低于 2000 的商品信息
SELECT SP.*, P.*
FROM shop_product AS SP
INNER JOIN product as P
ON SP.product_id = P.product_id
WHERE shop_id = '000A' AND sale_price < 2000;
-- 使用子查询
SELECT SP.*, P.*
FROM (SELECT *
	  FROM shop_product 
      WHERE shop_id = '000A') AS SP
INNER JOIN product AS P
ON SP.product_id = P.product_id;

-- 每个商店中, 售价最高的商品
SELECT SP.shop_id
      ,SP.shop_name
      ,MAX(P.sale_price) AS max_price
      ,P.product_name
  FROM shop_product AS SP
 INNER JOIN product AS P
    ON SP.product_id = P.product_id
 GROUP BY SP.shop_id,SP.shop_name;

-- 找出每个商品种类当中售价高于该类商品的平均售价的商品
-- 使用子查询
SELECT product_type, product_name, sale_price
  FROM product AS P1
 WHERE sale_price > (SELECT AVG(sale_price)
                       FROM product AS P2
                      WHERE P1.product_type = P2.product_type
                      GROUP BY product_type);
-- 使用group by，更好理解
SELECT  P1.product_id
       ,P1.product_name
       ,P1.product_type
       ,P1.sale_price
       ,P2.avg_price
  FROM product AS P1
 INNER JOIN 
   (SELECT product_type,
           AVG(sale_price) AS avg_price 
      FROM product 
     GROUP BY product_type) AS P2 
    ON P1.product_type = P2.product_type
 WHERE P1.sale_price > P2.avg_price;

-- NATURAL JOIN
-- 按照两个表中都包含的列名来进行等值内连结
SELECT *  FROM shop_product NATURAL JOIN product;
-- 求出两张表或子查询的公共部分（完全一样的行）
SELECT * FROM product NATURAL JOIN product2;
-- 只让特定列相等
SELECT * 
  FROM (SELECT product_id, product_name
          FROM product ) AS A 
NATURAL JOIN 
   (SELECT product_id, product_name 
      FROM product2) AS B;
-- OR
SELECT P1.*
  FROM product AS P1
 INNER JOIN product2 AS P2
    ON (P1.product_id  = P2.product_id
   AND P1.product_name = P2.product_name
   AND P1.product_type = P2.product_type
   AND P1.sale_price   = P2.sale_price
   AND P1.regist_date  = P2.regist_date);-- NULL不能用等号比较，这里应该可以删掉

-- 外连接
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.sale_price
  FROM product AS P
  LEFT OUTER JOIN shop_product AS SP
    ON SP.product_id = P.product_id;

-- 某个商店库存少于50的商品及对应的商店，不包括无货的
SELECT P.product_id
       ,P.product_name
       ,P.sale_price
       ,SP.shop_id
       ,SP.shop_name
       ,SP.quantity
  FROM product AS P
  LEFT OUTER JOIN shop_product AS SP
    ON SP.product_id = P.product_id
 WHERE quantity< 50;
-- 某个商店库存少于50的商品及对应的商店，包括无货的（NULL）
SELECT P.product_id
      ,P.product_name
      ,P.sale_price
	  ,SP.shop_id
      ,SP.shop_name
      ,SP.quantity 
  FROM product AS P
  LEFT OUTER JOIN-- 先筛选quantity<50的商品
   (SELECT *
      FROM shop_product
     WHERE quantity < 50 ) AS SP
    ON SP.product_id = P.product_id;

CREATE TABLE Inventoryproduct
( inventory_id       CHAR(4) NOT NULL,
product_id         CHAR(4) NOT NULL,
inventory_quantity INTEGER NOT NULL,
PRIMARY KEY (inventory_id, product_id));
-- DML：插入数据
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

-- 三表连接，使用内连接找出每个商店都有那些商品, 每种商品的库存总量分别是多少，外连接同理
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.sale_price
       ,IP.inventory_quantity
  FROM shop_product AS SP
 INNER JOIN product AS P
    ON SP.product_id = P.product_id
 INNER JOIN Inventoryproduct AS IP
    ON SP.product_id = IP.product_id
 WHERE IP.inventory_id = 'P001';

-- 按照商品的售价从低到高,对售价进行累计求和！！！！！！！！！！！！！！
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

-- 笛卡尔积（没什么用）
-- 1.使用关键字 CROSS JOIN 显式地进行交叉连结
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.sale_price
  FROM shop_product AS SP
 CROSS JOIN product AS P;
-- 2.使用逗号分隔两个表,并省略 ON 子句
SELECT SP.shop_id
       ,SP.shop_name
       ,SP.product_id
       ,P.product_name
       ,P.sale_price
  FROM shop_product AS SP ,product AS P;

-- 4.1
SELECT *
FROM product
UNION SELECT * FROM product2 AS P
WHERE sale_price > 500;
-- 4.2
SELECT *
FROM product
WHERE product_id IN (SELECT product_id FROM product2);
-- 4.3 每类商品中售价最高的商品都在哪些商店有售
SELECT P.product_id
      ,P.product_name
      ,P.sale_price
	  ,SP.shop_id
      ,SP.shop_name
  FROM shop_product AS SP
  RIGHT OUTER JOIN (-- 先找出每类商品中售价最高的商品
  SELECT product_id,product_type, product_name, sale_price
  FROM product AS P1
 WHERE sale_price = (SELECT MAX(sale_price)
                       FROM product AS P2
                      WHERE P1.product_type = P2.product_type
                      GROUP BY product_type)) AS P
    ON SP.product_id = P.product_id;
-- 4.4
SELECT  P1.product_id
       ,P1.product_name
       ,P1.product_type
       ,P1.sale_price
       ,P2.max_price
  FROM product AS P1
 INNER JOIN 
   (SELECT product_type,
           MAX(sale_price) AS max_price 
      FROM product 
     GROUP BY product_type) AS P2 
    ON P1.product_type = P2.product_type
 WHERE P1.sale_price = P2.max_price;


