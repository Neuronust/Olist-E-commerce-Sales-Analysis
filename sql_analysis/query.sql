-- =========================================
-- FACT SALES
-- =========================================
DROP VIEW IF EXISTS fact_sales;
CREATE VIEW fact_sales AS
SELECT
    oi.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_state,
    oi.product_id,
    pt.product_category_name_english,
    oi.seller_id,
    o.order_purchase_timestamp::date AS order_date,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS gross_revenue
FROM olist.order_items oi
JOIN olist.orders o 
    ON oi.order_id = o.order_id
JOIN olist.customers c 
    ON o.customer_id = c.customer_id
JOIN products_translation pt
    ON oi.product_id = pt.product_id;

-- =========================================
-- FACT PAYMENT
-- =========================================
DROP VIEW IF EXISTS fact_payment;
CREATE VIEW fact_payment AS
SELECT
    op.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_state,
    o.order_purchase_timestamp::date AS order_date,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    INITCAP(TO_CHAR(o.order_purchase_timestamp, 'month')) AS month,
    
    MIN(o.order_purchase_timestamp::date) 
        OVER (PARTITION BY c.customer_unique_id) AS first_purchase_date,
        
    MAX(o.order_purchase_timestamp::date) 
        OVER (PARTITION BY c.customer_unique_id) AS last_purchase_date,

    op.payment_type,
    op.payment_installments,
    op.payment_value
FROM olist.order_payments op
JOIN olist.orders o 
    ON op.order_id = o.order_id
JOIN olist.customers c 
    ON o.customer_id = c.customer_id;

-- =========================================
-- PRODUCT TRANSLATION
-- =========================================
DROP VIEW IF EXISTS products_translation;
CREATE VIEW products_translation AS
SELECT
    p.product_id,
    p.product_category_name,
    pt.product_category_name_english,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g
FROM products p
LEFT JOIN product_category_name_translation pt
    ON p.product_category_name = pt.product_category_name;

-- =========================================
-- FACT REVIEW
-- =========================================
DROP VIEW IF EXISTS fact_review;

CREATE VIEW fact_review AS
SELECT
    r.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_state,
    c.customer_city,
    r.review_score,
    o.order_status,
    
    o.order_purchase_timestamp::date AS order_date,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    INITCAP(TO_CHAR(o.order_purchase_timestamp, 'month')) AS month,

    MIN(o.order_purchase_timestamp::date) 
        OVER (PARTITION BY c.customer_unique_id) AS first_purchase_date,

    MAX(o.order_purchase_timestamp::date) 
        OVER (PARTITION BY c.customer_unique_id) AS last_purchase_date,

    (o.order_delivered_customer_date::date - o.order_purchase_timestamp::date) AS delivery_duration,
    (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) AS delay_duration,

    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
FROM olist.order_reviews r
JOIN olist.orders o 
    ON r.order_id = o.order_id
JOIN olist.customers c 
    ON o.customer_id = c.customer_id;

---------------------------------------------
------------------ Sales --------------------
---------------------------------------------

--Total Revenue
SELECT
	SUM(payment_value) AS Total_revenue
FROM fact_payment;
-- Year over Year (YoY)
WITH revenue_yearly AS (
    SELECT
        year,
        SUM(payment_value) AS total_revenue
    FROM fact_payment
    GROUP BY year
)
SELECT
    year,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY year) AS last_year,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY year))
        / LAG(total_revenue) OVER (ORDER BY year) * 100,
        2
    ) AS growth_pct
FROM revenue_yearly;

-- Month over Month (MoM)
WITH revenue_monthly AS (
    SELECT
        EXTRACT(MONTH FROM order_date) AS month_num,
        month,
        SUM(payment_value) AS total_revenue
    FROM fact_payment
    GROUP BY month, month_num
)
SELECT
    month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month_num) AS last_month,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY month_num))
        / LAG(total_revenue) OVER (ORDER BY month_num) * 100,
        2
    ) AS growth_pct
FROM revenue_monthly;

--Top 7 product By Revenue
SELECT
	product_category_name_english,
	SUM(price) AS total_revenue
FROM fact_sales
GROUP BY product_category_name_english
ORDER BY total_revenue DESC
LIMIT 7;

--Revenue By State
SELECT
	c.customer_state,
	ROUND(
		SUM(payment_value)/COUNT(DISTINCT c.customer_unique_id)
		,2
		) AS average_revenue 
FROM fact_payment 
JOIN customers c
	ON fact_payment.customer_id=c.customer_id
GROUP BY c.customer_state
ORDER BY average_revenue DESC;

-- Residual revenue check
WITH order_gross AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS gross_revenue
    FROM fact_sales
    GROUP BY order_id
),

order_payment AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_revenue
    FROM fact_payment
    GROUP BY order_id
)

SELECT
    p.order_id,
    p.total_revenue,
    g.gross_revenue,
    (p.total_revenue - g.gross_revenue) AS other
FROM order_payment p
LEFT JOIN order_gross g
    ON p.order_id = g.order_id
WHERE p.total_revenue <> g.gross_revenue;

--order VS revenue
SELECT 
	year,
	COUNT(DISTINCT order_id) total_orders,
	SUM(payment_value) total_revenue
FROM fact_payment
GROUP BY year;

-------------------------------------------------
------------------ Customers --------------------
-------------------------------------------------

--Total Customer
SELECT
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM fact_payment;
--Cohort retention
WITH cohort_base AS (
    SELECT
        customer_unique_id,
        DATE_TRUNC('month', first_purchase_date) AS cohort_month,
        EXTRACT(YEAR FROM first_purchase_date) AS cohort_year,

        (
            EXTRACT(YEAR FROM AGE(order_date, first_purchase_date)) * 12
            + EXTRACT(MONTH FROM AGE(order_date, first_purchase_date))
        ) AS month_index

    FROM fact_payment
),

cohort_agg AS (
    SELECT
        cohort_month,
        cohort_year,
        month_index,
        COUNT(DISTINCT customer_unique_id) AS customer_active
    FROM cohort_base
    GROUP BY
        cohort_month,
        cohort_year,
        month_index
)

SELECT
    cohort_month,
    cohort_year,
    month_index,
    customer_active,

    ROUND(
        customer_active * 1.0
        / FIRST_VALUE(customer_active)
            OVER (PARTITION BY cohort_month ORDER BY month_index),
        4
    ) AS retention_rate

FROM cohort_agg
ORDER BY
    cohort_month,
    month_index;

-- Customer Segmentation
WITH customer_spending AS (
    SELECT
        customer_unique_id,
        SUM(payment_value) AS total_revenue
    FROM fact_payment
    GROUP BY customer_unique_id
),

percentile AS (
    SELECT
        PERCENTILE_CONT(0.25) 
            WITHIN GROUP (ORDER BY total_revenue) AS p25,
        PERCENTILE_CONT(0.75) 
            WITHIN GROUP (ORDER BY total_revenue) AS p75
    FROM customer_spending
),

segmentation AS (
    SELECT
        cs.customer_unique_id,
        cs.total_revenue,
        CASE
            WHEN cs.total_revenue <= p25 THEN 'Low Value'
            WHEN cs.total_revenue < p75 THEN 'Mid Value'
            ELSE 'High Value'
        END AS segment
    FROM customer_spending cs
    CROSS JOIN percentile
)

SELECT
    segment,
    COUNT(*) AS total_customer,
    SUM(total_revenue) AS total_revenue,
    ROUND(
        SUM(total_revenue) * 1.0 / SUM(SUM(total_revenue)) OVER (),
        2
    ) AS pct_revenue
FROM segmentation
GROUP BY segment;

--customers vs orders
SELECT
	COUNT(DISTINCT customer_unique_id) AS total_customer,
	COUNT(DISTINCT order_id) AS total_order,
	MONTH,
	EXTRACT(MONTH FROM order_date) AS month_num
FROM fact_payment
GROUP BY month_num,MONTH
ORDER BY EXTRACT(MONTH FROM order_date);

SELECT
	SUM(payment_value)/COUNT(DISTINCT customer_unique_id)
FROM fact_payment;


-----------------------------------------------------------
------------------ Shipment & Review ----------------------
-----------------------------------------------------------

--review by delivery duration
-- Delivery vs Review
WITH delivery_category AS (
    SELECT
        order_id,
        review_score,
        CASE
            WHEN delay_duration < 0 THEN 'Early'
            WHEN delay_duration = 0 THEN 'On Time'
            WHEN delay_duration BETWEEN 1 AND 3 THEN 'Late'
            ELSE 'Very Late'
        END AS delay_category
    FROM fact_review
)
SELECT
    delay_category,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(review_score), 2) AS avg_review
FROM delivery_category
GROUP BY delay_category;

--freight vs review
WITH total_freight AS(	
	SELECT
		order_id,
		SUM(freight_value) AS freight_value
	FROM fact_sales 
	GROUP BY order_id 
),
review AS( 
SELECT 
	AVG(review_score) AS avg_review_score,
	AVG(freight_value) AS avg_freight_value,
	MONTH,
	EXTRACT('month' FROM order_date) AS num_month
FROM fact_review
JOIN total_freight 
	ON fact_review.order_id=total_freight.order_id
GROUP BY 
	MONTH,
	EXTRACT('month' FROM order_date)
)
SELECT
	MONTH,
	avg_review_score,
	avg_freight_value
FROM review
ORDER BY num_month;
--Shipment Duration by Customer State
SELECT
	customer_state,
	ROUND (AVG(delivery_duration),0)||' days' AS average_duration
FROM fact_review
WHERE delivery_duration IS NOT NULL
GROUP BY customer_state
ORDER BY AVG(delivery_duration) DESC;

	SELECT
		order_id,
		count(order_id)
	FROM fact_review
	GROUP BY order_id
	HAVING COUNT(order_id)>1;

-------------------------------------------------
------------------ product ----------------------
-------------------------------------------------

-- Repeat Purchase Rate
WITH customer_product_order AS (
    SELECT
        customer_unique_id,
        product_category_name_english,
        COUNT(DISTINCT order_id) AS total_order
    FROM fact_sales
    GROUP BY customer_unique_id, product_category_name_english
)

SELECT
    product_category_name_english,
    COUNT(DISTINCT CASE WHEN total_order > 1 THEN customer_unique_id END) * 1.0
        / COUNT(DISTINCT customer_unique_id) AS repeat_rate,
    COUNT(DISTINCT customer_unique_id) AS total_customer
FROM customer_product_order
GROUP BY product_category_name_english
ORDER BY repeat_rate DESC
LIMIT 10;
	
--Top product By Quantity and Review
WITH review AS(
	SELECT
		AVG(review_score)review_score,
		order_id 
	FROM fact_review
	GROUP BY order_id
)
SELECT
	product_category_name_english,
	SUM(price) AS total_revenue,
	COUNT(product_id)AS quantity,
	ROUND(AVG(review_score),2) AS review_score
FROM fact_sales
JOIN review r ON fact_sales.order_id=r.order_id
GROUP BY product_category_name_english
ORDER BY quantity DESC;


	

