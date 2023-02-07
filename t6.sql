-- 1. 将三张表中的TICKER_SYMBOL为600383和600048的信息合并在一起

SELECT Ins.ticker_symbol,
	   Ins.end_date,
       Ins.t_revenue,
       Ins.cogs,
       Ins.n_income,
       MD.ticker_symbol,
       MD.end_date,
       MD.close_price,
       CO.ticker_symbol,
       CO.indic_name_en,
       CO.end_date,
       CO.value
  FROM (SELECT *
  FROM Market_Data
 WHERE ticker_symbol = 600383
    OR ticker_symbol = 600048) AS MD -- ticker_symbol in (600383,600383)
 INNER JOIN Income_Statement AS InS -- left join更符合题意，而且最好也先select一下
    ON InS.ticker_symbol = MD.ticker_symbol  
-- AND InS.end_date = MD.end_date
 INNER JOIN Company_Operating AS CO
    ON MD.ticker_symbol = CO.ticker_symbol;
-- ORDER BY ...

SELECT 
    SP.shop_id,
    SP.shop_name,
    P.product_id,
    P.product_name,
    P.sale_price,
    I.inventory_quantity
FROM
    (SELECT 
        product_name, sale_price, product_id
    FROM
        product
    WHERE
        product_id IN (0003 , 0005)) AS P
        LEFT JOIN
    (SELECT 
        shop_id, shop_name, product_id
    FROM
        shop_product
    WHERE
        product_id IN (0003 , 0005)) AS SP ON P.product_id = SP.product_id
        LEFT JOIN
    Inventoryproduct AS I ON P.product_id = I.product_id;

-- 2. 找出 pH=3.03的所有红葡萄酒，然后，对其 citric acid 进行中式排名
SELECT  product_name
       ,product_type
       ,sale_price
       ,DENSE_RANK() OVER (ORDER BY sale_price) AS dense_ranking
  FROM product
 WHERE product_name = '高压锅';

-- 3. 分别找出在2016年7月期间，发放优惠券总金额最多和发放优惠券张数最多的商家
-- 这里只考虑满减的金额，不考虑打几折的优惠券
SELECT  product_id
       ,product_name
       ,sale_price
       ,SUM(sale_price) AS discount_amount -- SUBSTRING_INDEX(`Discount_rate`,':',-1)
       -- 张数的话直接count
       -- COUNT(1) AS cnt
  FROM product
 WHERE product_id BETWEEN 0001 AND 0007
 GROUP BY product_id
 ORDER BY discount_amount DESC
 LIMIT 1;

-- 4. 全社会用电量:第一产业:当月值在2015年用电最高峰是发生在哪月？
SELECT regist_date
	  ,MAX(sale_price) price -- 省略AS
  FROM product
 WHERE product_type = '厨房用具'
 GROUP BY regist_date
 ORDER BY price DESC
 LIMIT 1; -- 只显示一个结果

-- 并且相比去年同期增长/减少了多少个百分比？
UPDATE product
   SET regist_date = '2009-04-28'
 WHERE product_id = 0007;

SELECT BaseData.*, (BaseData.price - YoY.price) / YoY.price result
  FROM (SELECT regist_date
	  ,MAX(sale_price) price -- 省略AS
  FROM product
 WHERE product_type = '厨房用具'
 GROUP BY regist_date
 ORDER BY price DESC
 LIMIT 1) BaseData 
 LEFT JOIN
(SELECT regist_date
	  ,MAX(sale_price) price -- 省略AS
  FROM product
 WHERE product_type = '厨房用具'
 GROUP BY regist_date
 ORDER BY price
 LIMIT 1) YoY
 ON YEAR(BaseData.regist_date) = YEAR(YoY.regist_date); -- 同期体现
    
-- 5. 在2016年6月期间，线上总体优惠券弃用率为多少？
-- 弃用率 = 被领券但未使用的优惠券张数 / 总的被领取优惠券张数
SELECT SUM(CASE WHEN Date='0000-00-00' AND Coupon_id IS NOT NULL
				THEN 1
                ELSE 0
                END) / SUM(CASE WHEN Coupon_id IS NOT NULL
				THEN 1
                ELSE 0
                END) AS discard_rate
FROM ccf_online_stage1_train
WHERE Date_received BETWEEN '2016-06-01' AND '2016-06-30';

-- 并找出优惠券弃用率最高的商家
SELECT SUM(CASE WHEN Date='0000-00-00' AND Coupon_id IS NOT NULL
				THEN 1
                ELSE 0
                END) / SUM(CASE WHEN Coupon_id IS NOT NULL
				THEN 1
                ELSE 0
                END) AS discard_rate
FROM ccf_online_stage1_train
WHERE Date_received BETWEEN '2016-06-01' AND '2016-06-30'
GROUP BY Merchant_id
ORDER BY discard_rate DESC
LIMIT 1;

-- 6. 找出 pH=3.63的所有白葡萄酒，并对其 residual sugar 量进行英式排名（非连续的排名）
SELECT  product_name
       ,product_type
       ,sale_price
       ,RANK() OVER (ORDER BY sale_price) AS dense_ranking
  FROM product
 WHERE product_name = '高压锅';

-- 7. 截止到2018年底，市值最大的三个行业是哪些？
SELECT con_name, sum(market_price)
from tablename
where end_date = '2018-12-31'
group by con_name
order by sum(market_price) desc
limit 3;

-- 这三个行业里市值最大的三个公司是哪些？（共9个）
SELECT BaseData.TYPE_NAME_CN,
BaseData.TICKER_SYMBOL
FROM (SELECT TYPE_NAME_CN,
TICKER_SYMBOL,
MARKET_VALUE,
ROW_NUMBER() OVER(PARTITION BY TYPE_NAME_CN ORDER BY MARKET_VALUE)
CompanyRanking
FROM `market data` ) BaseData
LEFT JOIN
( SELECT TYPE_NAME_CN,
SUM(MARKET_VALUE)
FROM `market data`
WHERE YEAR(END_DATE) = '2018-12-31'
GROUP BY TYPE_NAME_CN
ORDER BY SUM(MARKET_VALUE) DESC
LIMIT 3 ) top3Type
ON BaseData.TYPE_NAME_CN = top3Type.TYPE_NAME_CN
WHERE CompanyRanking <= 3
AND top3Type.TYPE_NAME_CN IS NOT NULL;

-- 8. 找出在2016年6月期间，线上线下累计优惠券使用次数最多的顾客

SELECT User_id,
SUM(couponCount) couponCount
FROM (

SELECT User_id,
count(*) couponCount
FROM `ccf_online_stage1_train`
WHERE (Date != 'null' AND Coupon_id != 'null')
AND (LEFT(DATE,4)=2016 )
GROUP BY User_id

UNION ALL

SELECT User_id,
COUNT(*) couponCount
FROM `ccf_offline_stage1_train`
WHERE (Date != 'null' AND Coupon_id != 'null')
AND (LEFT(DATE,4)=2016 )
GROUP BY User_id 
) BaseData

GROUP BY User_id
ORDER BY SUM(couponCount) DESC
LIMIT 1;

-- 9. 按季度统计，白云机场旅客吞吐量最高的那一季度对应的净利润
-- （注意，是单季度对应的净利润，非累计净利润。）
SELECT *
FROM (SELECT TICKER_SYMBOL,
YEAR(END_DATE) Year,
QUARTER(END_DATE) QUARTER,
SUM(VALUE) Amount
FROM `company operating`
WHERE INDIC_NAME_EN = 'Baiyun Airport:Passenger throughput'
GROUP BY TICKER_SYMBOL,YEAR(END_DATE),QUARTER(END_DATE)
ORDER BY SUM(VALUE) DESC
LIMIT 1 ) BaseData
LEFT JOIN -- income statement
(SELECT TICKER_SYMBOL,
YEAR(END_DATE) Year,
QUARTER(END_DATE) QUARTER,
SUM(N_INCOME) Amount
FROM `income statement`
GROUP BY TICKER_SYMBOL,YEAR(END_DATE),QUARTER(END_DATE) ) Income
ON BaseData.TICKER_SYMBOL = Income.TICKER_SYMBOL
AND BaseData.Year = Income.Year
AND BaseData.QUARTER = Income.QUARTER;

-- 10. 在2016年6月期间，线上线下累计被使用优惠券满减最多的前3名商家
-- 比如商家A，消费者A在其中使用了一张200减50的，消费者B使用了一张30减1的，那么商家A累计被使用优惠券满减51元
SELECT Merchant_id,
SUM(discount_amount) discount_amount
FROM (SELECT Merchant_id,
SUM(SUBSTRING_INDEX(`Discount_rate`,':',-1)) AS discount_amount
FROM `ccf_online_stage1_train`
WHERE (Date != 'null' AND Coupon_id != 'null')
AND (LEFT(DATE,4)=2016 )
AND MID(DATE,5,2) = '06'
GROUP BY Merchant_id
UNION ALL
SELECT Merchant_id,
SUM(SUBSTRING_INDEX(`Discount_rate`,':',-1)) AS discount_amount
FROM `ccf_offline_stage1_train`
WHERE (Date != 'null' AND Coupon_id != 'null')
AND (LEFT(DATE,4)=2016 )
AND MID(DATE,5,2) = '06'
GROUP BY Merchant_id ) BaseData
GROUP BY Merchant_id
ORDER BY SUM(discount_amount) DESC
LIMIT 1;


