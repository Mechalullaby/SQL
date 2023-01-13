-- 窗口函数等

-- 窗口函数也称为OLAP函数, OnLine AnalyticalProcessing 的简称

/*
<窗口函数> OVER ([PARTITION BY <列名>]
                     ORDER BY <排序用列名>)
*/

-- PARTITON BY是用来分组，即选择要看哪个窗口，类似于GROUP BY 子句的分组功能，
-- 但是PARTITION BY 子句并不具备GROUP BY 子句的汇总功能，并不会改变原始表中记录的行数。

-- ORDER BY是用来排序，即决定窗口内，是按那种规则(字段)来排序的

SELECT product_name
       ,product_type
       ,sale_price
       ,RANK() OVER (PARTITION BY product_type
                         ORDER BY sale_price) AS ranking
  FROM product;
-- ASC/DESC来指定升序/降序。省略该关键字时会默认按照ASC

-- 大致来说，窗口函数可以分为两类。
-- 一是 将SUM、MAX、MIN等聚合函数用在窗口函数中
-- 二是 RANK、DENSE_RANK等排序用的专用窗口函数

-- RANK函数**（英式排序）**
-- 计算排序时，如果存在相同位次的记录，则会跳过之后的位次
-- 例）有 3 条记录排在第 1 位时：1 位、1 位、1 位、4 位……

-- DENSE_RANK函数**（中式排序）**
-- 同样是计算排序，即使存在相同位次的记录，也不会跳过之后的位次
-- 例）有 3 条记录排在第 1 位时：1 位、1 位、1 位、2 位……

-- ROW_NUMBER函数
-- 赋予唯一的连续位次
-- 例）有 3 条记录排在第 1 位时：1 位、2 位、3 位、4 位
SELECT  product_name
       ,product_type
       ,sale_price
       ,RANK() OVER (ORDER BY sale_price) AS ranking
       ,DENSE_RANK() OVER (ORDER BY sale_price) AS dense_ranking
       ,ROW_NUMBER() OVER (ORDER BY sale_price) AS row_num
  FROM product;

-- 聚合函数在开窗函数中的使用方法和之前的专用窗口函数一样，
-- 只是出来的结果是一个累计的聚合函数值
SELECT  product_id
       ,product_name
       ,sale_price
       ,SUM(sale_price) OVER (ORDER BY sale_price) AS current_sum
       ,AVG(sale_price) OVER (ORDER BY product_id) AS current_avg  
  FROM product;

/*
聚合函数在窗口函数使用时，计算的是累积到当前行的所有的数据的聚合
实际上，还可以指定更加详细的汇总范围。该汇总范围成为框架(frame)
<窗口函数> OVER (ORDER BY <排序用列名>
                 ROWS n PRECEDING )  
                 
<窗口函数> OVER (ORDER BY <排序用列名>
                 ROWS BETWEEN n PRECEDING AND n FOLLOWING)

PRECEDING（“之前”）， 将框架指定为 “截止到之前 n 行”，加上自身行
FOLLOWING（“之后”）， 将框架指定为 “截止到之后 n 行”，加上自身行
BETWEEN 1 PRECEDING AND 1 FOLLOWING，将框架指定为 “之前1行” + “之后1行” + “自身”
*/
SELECT  product_id
       ,product_name
       ,sale_price
       ,AVG(sale_price) OVER (ORDER BY product_id
                               ROWS 2 PRECEDING) AS moving_avg
		-- 即每三行取平均，因为是自身加上前两行
       ,AVG(sale_price) OVER (ORDER BY product_id
                               ROWS BETWEEN 1 PRECEDING 
                                        AND 1 FOLLOWING) AS moving_avg  
		-- 也是三行，不过是前一行和自己和下一行
  FROM product;

-- 原则上，窗口函数只能在SELECT子句中使用
-- 窗口函数OVER 中的ORDER BY 子句并不会影响最终结果的排序, 只决定窗口函数按何种顺序计算


-- GROUPING运算符

-- 常规的GROUP BY 只能得到每个分类的小计，计算分类的合计，可以用 ROLLUP关键字
SELECT  product_type
       ,regist_date
       ,SUM(sale_price) AS sum_price
  FROM product
 GROUP BY product_type, regist_date WITH ROLLUP;

-- 5.1 当前最贵商品价格
SELECT  product_id
       ,product_name
       ,sale_price
       ,MAX(sale_price) OVER (ORDER BY product_id) AS Current_max_price
  FROM product;

/*计算出按照登记日期（regist_date）升序进行排列的各日期的销售单价（sale_price）的总额
排序是需要将登记日期为NULL 的“运动 T 恤”记录排在第 1 位（也就是将其看作比其他日期都早）*/
SELECT  product_name
       ,sale_price
       ,regist_date
       ,SUM(sale_price) OVER (ORDER BY regist_date) AS current_sum
  FROM product
 GROUP BY regist_date;

-- 5.3
-- 窗口函数不指定partition的话，效果与正常的order差不多
















