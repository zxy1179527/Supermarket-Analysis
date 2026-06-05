DROP TEMPORARY TABLE IF EXISTS t_postal_frequency;
CREATE TEMPORARY TABLE t_postal_frequency AS
SELECT `State`, `City`, `Postal Code`, COUNT(*) AS cnt
FROM supermarket_raw
WHERE `Postal Code` IS NOT NULL AND `Postal Code` <> ''
GROUP BY `State`, `City`, `Postal Code`;

DROP TEMPORARY TABLE IF EXISTS t_postal_best;
CREATE TEMPORARY TABLE t_postal_best AS
SELECT `State`, `City`, `Postal Code`,
       ROW_NUMBER() OVER (PARTITION BY `State`, `City` ORDER BY cnt DESC) AS rn
FROM t_postal_frequency;

DROP TABLE IF EXISTS t_cleaned_base;
CREATE TABLE t_cleaned_base AS
SELECT 
    r.`Row ID`, 
    r.`Order ID`, 
    r.`Ship Mode`, 
    r.`Segment`, 
    r.`Region`, 
    r.`State`,   
    r.`City`,    
    r.`Product ID`, 
    r.`Category`, 
    r.`Sub-Category`, 
    r.`Product Name`,
    -- 1. 文本转标准日期
    STR_TO_DATE(r.`Order Date`, '%d/%m/%Y') AS order_date,
    STR_TO_DATE(r.`Ship Date`, '%d/%m/%Y') AS ship_date,
    -- 2. 计算发货时效
    DATEDIFF(STR_TO_DATE(r.`Ship Date`, '%d/%m/%Y'), STR_TO_DATE(r.`Order Date`, '%d/%m/%Y')) AS days_to_ship,
    -- 3. 确保销售额为精确的小数类型
    CAST(r.`Sales` AS DECIMAL(10, 2)) AS sales,
    -- 4. 补齐邮编
    COALESCE(NULLIF(r.`Postal Code`, ''), p.`Postal Code`, 'Unknown') AS postal_code
FROM supermarket_raw r
LEFT JOIN t_postal_best p 
    ON r.`State` = p.`State` 
   AND r.`City` = p.`City` 
   AND p.rn = 1;