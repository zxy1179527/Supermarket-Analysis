WITH product_perf AS (
    -- 1：计算每个商品在各自子品类下的总销售额
    SELECT 
        `Category`,
        `Sub-Category`,
        `Product Name`,
        SUM(sales) AS total_product_sales
    FROM t_cleaned_base
    GROUP BY `Category`, `Sub-Category`, `Product Name`
),
ranked_products AS (
    -- 2：在品类内部进行排名
    SELECT 
        `Category`,
        `Sub-Category`,
        `Product Name`,
        total_product_sales,
        -- 使用 DENSE_RANK() 应对销售额并列的
        DENSE_RANK() OVER (
            PARTITION BY `Category`, `Sub-Category` 
            ORDER BY total_product_sales DESC
        ) AS sales_rank
    FROM product_perf
)
-- 3：筛选出前5名
SELECT * FROM ranked_products
WHERE sales_rank <= 5
ORDER BY `Category`, `Sub-Category`, sales_rank;