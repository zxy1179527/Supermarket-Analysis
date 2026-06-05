    -- 1. 计算每个区域每个月的总销售额
DROP TEMPORARY TABLE IF EXISTS t_monthly_sales;
CREATE TEMPORARY TABLE t_monthly_sales AS
SELECT 
    `Region`,
    STR_TO_DATE(DATE_FORMAT(order_date, '%Y-%m-01'), '%Y-%m-%d') AS order_month,
    SUM(sales) AS total_sales
FROM t_cleaned_base
GROUP BY `Region`, order_month;

-- 2：计算上月和去年同月销售额
DROP TEMPORARY TABLE IF EXISTS t_sales_with_lags;
CREATE TEMPORARY TABLE t_sales_with_lags AS
SELECT `Region`, order_month, total_sales,
    LAG(total_sales, 1) OVER(PARTITION BY `Region` ORDER BY order_month) AS last_month_sales,
    LAG(total_sales, 12) OVER(PARTITION BY `Region` ORDER BY order_month) AS last_year_sales
FROM t_monthly_sales;

-- 3：计算环比和同比
SELECT `Region`, 
       DATE_FORMAT(order_month, '%Y-%m') AS month_label,
       ROUND(total_sales, 2) AS current_sales,
       ROUND(((total_sales - last_month_sales) / last_month_sales) * 100, 2) AS mom_growth_rate_pct,
       ROUND(((total_sales - last_year_sales) / last_year_sales) * 100, 2) AS yoy_growth_rate_pct
FROM t_sales_with_lags
ORDER BY `Region`, order_month;