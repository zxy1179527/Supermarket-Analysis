SELECT 
    `Region`,
    `Ship Mode`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(AVG(days_to_ship), 1) AS avg_days_to_ship,
    MAX(days_to_ship) AS max_days_to_ship
FROM t_cleaned_base
GROUP BY `Region`, `Ship Mode`
ORDER BY `Region`, avg_days_to_ship;