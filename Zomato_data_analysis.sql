-- DATABASE SETUP


-- Create a new database named 'zomato' and switch to it.
CREATE DATABASE zomato;
USE zomato;


-- Create 'customers' table to store customer details.
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    registration_date DATE
);

-- Create 'deliveries' table to track order delivery details.
CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY,
    order_id INT,
    delivery_status TEXT,
    delivery_time TIME,
    rider_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);

-- Create 'orders' table to record all food orders placed.
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_item TEXT,
    order_date DATE,
    order_time TIME,
    order_status TEXT,
    total_amount DOUBLE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Create 'restaurants' table to store restaurant information.
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    restaurant_name TEXT NOT NULL,
    city TEXT,
    opening_time TIME,
    closing_time TIME
);

-- Create 'riders' table to store delivery partner information.
CREATE TABLE riders (
    rider_id INT PRIMARY KEY,
    rider_name TEXT NOT NULL,
    signup_date DATE
);



-- EXPLORATORY DATA ANALYSIS (EDA)


-- View all table data for a quick check.
SELECT * FROM customers;
SELECT * FROM deliveries;
SELECT * FROM orders;
SELECT * FROM restaurants;
SELECT * FROM riders;


-- NULL VALUE CHECKS

-- Identify null values in customers table.
SELECT COUNT(*) FROM customers
WHERE customer_name IS NULL OR registration_date IS NULL;

-- Identify null values in riders table.
SELECT COUNT(*) FROM riders
WHERE rider_name IS NULL OR signup_date IS NULL;

-- Identify null values in restaurants table.
SELECT COUNT(*) FROM restaurants
WHERE restaurant_name IS NULL OR city IS NULL OR opening_time IS NULL OR closing_time IS NULL;

-- Identify null values in orders table.
SELECT COUNT(*) FROM orders
WHERE order_item IS NULL OR order_date IS NULL OR order_time IS NULL OR order_status IS NULL OR total_amount IS NULL;

-- Identify null values in deliveries table.
SELECT COUNT(*) FROM deliveries
WHERE delivery_status IS NULL OR delivery_time IS NULL OR rider_id IS NULL;



-- CUSTOMER ORDER ANALYSIS


-- Find top 3 most frequently ordered dishes by a specific customer in the last 2 years.
WITH customer_dish_rankings AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        o.order_item AS dish,
        COUNT(*) AS total_orders,
        DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS rank_number
    FROM orders o 
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE c.customer_name = 'Rayaan Nagarajan'
      AND o.order_date >= CURRENT_DATE - INTERVAL 2 YEAR
    GROUP BY c.customer_id, c.customer_name, o.order_item
)
SELECT 
    customer_id, customer_name, dish, total_orders, rank_number
FROM customer_dish_rankings
WHERE rank_number <= 3
ORDER BY rank_number;



-- TIME SLOT ORDER ANALYSIS

-- Bucket orders into 2-hour time slots and identify peak ordering periods in last 2 years.
WITH time_slots AS (
    SELECT 
        CONCAT(
            LPAD(HOUR(order_time) - (HOUR(order_time) % 2), 2, '0'),
            ':00 - ',
            LPAD(HOUR(order_time) - (HOUR(order_time) % 2) + 2, 2, '0'),
            ':00'
        ) AS two_hour_slot,
        COUNT(*) AS total_orders
    FROM orders
    WHERE order_date >= CURRENT_DATE - INTERVAL 2 YEAR
    GROUP BY two_hour_slot
)
SELECT two_hour_slot, total_orders
FROM time_slots
ORDER BY total_orders DESC
LIMIT 5;



-- AVERAGE ORDER VALUE (AOV) ANALYSIS

-- Calculate average order value (AOV), total orders, and total spent per customer.
SELECT 
    c.customer_name,
    COUNT(order_id) AS total_orders,
    AVG(total_amount) AS AOV,
    SUM(total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_name, c.customer_id
ORDER BY total_orders DESC;

-- Compute overall AOV across all customers.
SELECT 
    AVG(total_amount) AS overall_AOV,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers
FROM orders;



-- ORDER RANGE ANALYSIS

-- Group orders into price bands and compute count and average order value per range.
SELECT 
	CASE 
       WHEN total_amount < 200 THEN 'Under 200'
       WHEN total_amount BETWEEN 200 AND 500 THEN '200 - 500'
       WHEN total_amount BETWEEN 501 AND 1000 THEN '501 - 1000'
       ELSE 'ABOVE 1000'
	END AS order_range,
    COUNT(*) AS order_count,
    AVG(total_amount) AS avg_value_in_range
FROM orders
GROUP BY 
    CASE 
       WHEN total_amount < 200 THEN 'Under 200'
       WHEN total_amount BETWEEN 200 AND 500 THEN '200 - 500'
       WHEN total_amount BETWEEN 501 AND 1000 THEN '501 - 1000'
       ELSE 'ABOVE 1000'
	END
ORDER BY avg_value_in_range;


-- RESTAURANT PERFORMANCE ANALYSIS

-- Analyze restaurant performance based on AOV, order count, and highest order value.
SELECT 
  r.restaurant_name,
  COUNT(*) AS total_count,
  AVG(o.total_amount) AS restaurant_aov,
  MAX(total_amount) AS highest_order
FROM orders o 
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY restaurant_aov DESC;


-- TIME-BASED ORDER VALUE ANALYSIS

-- Evaluate day-of-week trends for average order value and order count.
SELECT 
   DAYNAME(order_date) AS day_of_week,
   AVG(total_amount) AS avg_order_value,
   COUNT(*) AS total_orders
FROM orders
GROUP BY DAYNAME(order_date)
ORDER BY AVG(total_amount) DESC;



-- CUSTOMER SPENDING AND LTV ANALYSIS


-- Rank customers based on total spend to identify top spenders.
SELECT 
  c.customer_id,
  c.customer_name,
  COUNT(*) AS total_orders,
  SUM(o.total_amount) AS total_spent,
  RANK() OVER(ORDER BY SUM(total_amount) DESC) AS spend_rank
FROM orders o 
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY SUM(total_amount) DESC; 


-- Compute customer lifetime value (LTV), tenure, and rank by LTV.
SELECT 
  c.customer_id,
  c.customer_name,
  COUNT(*) AS total_orders,
  SUM(o.total_amount) AS lifetime_value,
  AVG(o.total_amount) AS avg_order_value,
  DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS Tenure_days,
  RANK() OVER(ORDER BY SUM(o.total_amount) DESC) AS ltv_rank
FROM orders o 
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_value DESC;



-- PRICE BAND AND ORDER VOLUME ANALYSIS

-- Classify orders into Low, Medium, High price bands and rank based on popularity.
WITH orders_band AS (
    SELECT
        o.*,
        CASE
          WHEN total_amount < 200 THEN 'Low'
          WHEN total_amount BETWEEN 200 AND 500 THEN 'Medium'
          ELSE 'High'
	    END AS price_band
    FROM orders o
)
SELECT 
   price_band,
   COUNT(*) AS order_count,
   AVG(total_amount) AS avg_band_value,
   RANK() OVER (ORDER BY COUNT(*) DESC) AS band_popularity_rank
FROM orders_band
GROUP BY price_band
ORDER BY band_popularity_rank;



-- YEARLY GROWTH ANALYSIS

-- Track year-over-year (YoY) growth in total orders and total order value.
WITH yearly_stats AS (
    SELECT
        YEAR(order_date) AS order_year,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_order_value
    FROM orders
    GROUP BY YEAR(order_date)
)
SELECT
    order_year,
    total_orders,
    total_order_value,
    LAG(total_orders) OVER (ORDER BY order_year) AS last_year_orders,
    LAG(total_order_value) OVER (ORDER BY order_year) AS last_year_value,
    ROUND(
        (total_orders - LAG(total_orders) OVER (ORDER BY order_year)) * 100.0 /
        LAG(total_orders) OVER (ORDER BY order_year), 2
    ) AS orders_yoy_growth_percent,
    ROUND(
        (total_order_value - LAG(total_order_value) OVER (ORDER BY order_year)) * 100.0 /
        LAG(total_order_value) OVER (ORDER BY order_year), 2
    ) AS value_yoy_growth_percent
FROM yearly_stats
ORDER BY order_year;


-- MONTHLY GROWTH ANALYSIS

-- Analyze month-over-month (MoM) trends in total orders and order values.
WITH monthly_stats AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_order_value
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    CONCAT(order_year, '-', LPAD(order_month, 2, '0')) AS year__month,
    total_orders,
    total_order_value,
    LAG(total_orders) OVER (ORDER BY order_year, order_month) AS last_month_orders,
    LAG(total_order_value) OVER (ORDER BY order_year, order_month) AS last_month_value,
    ROUND(
        (total_orders - LAG(total_orders) OVER (ORDER BY order_year, order_month)) * 100.0 /
        LAG(total_orders) OVER (ORDER BY order_year, order_month), 2
    ) AS orders_mom_growth_percent,
    ROUND(
        (total_order_value - LAG(total_order_value) OVER (ORDER BY order_year, order_month)) * 100.0 /
        LAG(total_order_value) OVER (ORDER BY order_year, order_month), 2
    ) AS value_mom_growth_percent
FROM monthly_stats
ORDER BY order_year, order_month;
