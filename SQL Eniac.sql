use magist;
-- What categories of tech products does Magist have? --
SELECT 
    product_category_name_english AS Product_Category
FROM
    product_category_name_translation
WHERE
    product_category_name_english IN ('audio' , 'home_appliances',
        'telephony',
        'home_appliances,2',
        'electronics',
        'small_appliances',
        'computer_accessories',
        'pc_gamer',
        'computers',
        'watches_gifts',
        'tablets_printing_image');

-- How many products of these tech categories have been sold? --
SELECT 
    COUNT(DISTINCT (p.product_id)) AS total_tech_products_sold
FROM
    order_items AS items
        LEFT JOIN
    products p ON items.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation AS Category ON p.product_category_name = Category.product_category_name
WHERE
    product_category_name_english = 'audio'
        OR product_category_name_english = 'electronics'
        OR product_category_name_english = 'computers_accessories'
        OR product_category_name_english = 'pc_gamer'
        OR product_category_name_english = 'computers'
        OR product_category_name_english = 'tablets_printing_image'
        OR product_category_name_english = 'telephony'
        OR product_category_name_english = 'home_appliances'
        OR product_category_name_english = 'home_appliances,2'
        OR product_category_name_english = 'watches_gifts'
        OR product_category_name_english = 'small appliances';
     
-- What percentage does that represent from the overall number of products sold? --
SELECT 
    COUNT(DISTINCT (product_id)) AS products_sold
FROM
    order_items;
SELECT 5089 / 32951; -- i.e. 15.4%

-- What’s the average price of the products being sold? --
SELECT 
    ROUND(AVG(price), 2) AS Average_Price
FROM
    products AS p
        LEFT JOIN
    product_category_name_translation AS pt ON p.product_category_name = pt.product_category_name
        LEFT JOIN
    order_items AS oi ON p.product_id = oi.product_id
WHERE
    product_category_name_english = 'audio'
        OR product_category_name_english = 'electronics'
        OR product_category_name_english = 'computers_accessories'
        OR product_category_name_english = 'pc_gamer'
        OR product_category_name_english = 'computers'
        OR product_category_name_english = 'tablets_printing_image'
        OR product_category_name_english = 'telephony'
        OR product_category_name_english = 'home_appliances'
        OR product_category_name_english = 'home_appliances,2'
        OR product_category_name_english = 'watches_gifts';

-- Are expensive tech products popular? --
SELECT 
    COUNT(o.product_id),
    o.product_id,
    CASE
        WHEN price > 1000 THEN 'Expensive'
        WHEN price > 100 THEN 'Mid-range'
        ELSE 'Cheap'
    END AS 'price_range'
FROM
    order_items o
        LEFT JOIN
    products p ON p.product_id = o.product_id
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ('audio' , 'telephony''home_appliances',
        'home_appliances,2',
        'electronics',
        'small_appliances',
        'computer_accessories',
        'pc_gamer',
        'computers',
        'watches_gifts',
        'tablets_printing_image')
GROUP BY price_range , product_id;

-- How many months of data is included in the Database? --
SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp)) AS Months
FROM
    orders;
    
-- How many sellers are there? --
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    Sellers;
    
-- How many Tech sellers are there? --
SELECT 
    COUNT(DISTINCT seller_id) AS Tech_Sellers
FROM
    sellers
        LEFT JOIN
    order_items USING (seller_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');

-- What percentage of overall sellers are Tech-sellers? --
SELECT (454 / 3095) * 100 AS Percent_Tech_Sellers;

-- What is the total amount earned by all sellers? --
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled');

-- What is the total amount earned by Tech-sellers? --
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled')
        AND pt.product_category_name_english IN ('audio' , 'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');

--  What is the average monthly income of Tech- sellers? --
SELECT 1666211.28 / 454 / 25;

--  Average monthly income of all sellers --
SELECT 13494400.74 / 454 / 25;

-- What’s the average time between the order being placed and the product being delivered? --
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date,
            order_purchase_timestamp)) AS duration_of_delivering
FROM
    orders;

-- How many orders are delivered on time vs orders delivered with a delay? --    
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE
		WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
        ELSE 0
        END) AS on_time_deliveries,
    SUM(CASE
		WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
        ELSE 0
        END) AS delayed_deliveries
FROM
    orders
WHERE
    order_delivered_customer_date IS NOT NULL;
    
-- Is there any pattern for delayed orders, e.g. big products being delayed more often? --
SELECT 
    CASE
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) >= 100
        THEN
            '> 100 day Delay'
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) >= 7
                AND DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) < 100
        THEN
            '1 week to 100 day delay'
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) > 3
                AND DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) < 7
        THEN
            '4-7 day delay'
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) >= 1
                AND DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) <= 3
        THEN
            '1-3 day delay'
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) > 0
                AND DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) < 1
        THEN
            'less than 1 day delay'
        WHEN
            DATEDIFF(order_estimated_delivery_date,
                    order_delivered_customer_date) <= 0
        THEN
            'On time'
    END AS 'delay_range',
    AVG(product_weight_g) AS weight_avg,
    MAX(product_weight_g) AS max_weight,
    MIN(product_weight_g) AS min_weight,
    SUM(product_weight_g) AS sum_weight,
    COUNT(DISTINCT a.order_id) AS orders_count
FROM
    orders a
        LEFT JOIN
    order_items b USING (order_id)
        LEFT JOIN
    products c USING (product_id)
WHERE
    order_estimated_delivery_date IS NOT NULL
        AND order_delivered_customer_date IS NOT NULL
        AND order_status = 'delivered'
GROUP BY delay_range;


    

    

    