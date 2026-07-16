select * from swiggy_orders;

--Data Validation and cleaning 
-- Null Check
SELECT
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,
    SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating
FROM swiggy_orders;

--Blank or empty strings
SELECT *
FROM swiggy_orders
WHERE TRIM(State) = ''
   OR TRIM(City) = ''
   OR TRIM(Restaurant_Name) = ''
   OR TRIM(Location) = ''
   OR TRIM(Category) = ''
   OR TRIM(Dish_Name) = '';

-- Duplicate detection
SELECT
    State, City, order_date, restaurant_name, location, category, dish_name, price_INR, rating,
    COUNT(*) AS CNT
FROM swiggy_orders
GROUP BY
    State, City, order_date, restaurant_name, location, category, dish_name, price_INR, rating
HAVING COUNT(*) > 1;

-- Delete duplication
WITH cte AS (
    SELECT ctid,
           ROW_NUMBER() OVER (
               PARTITION BY State, City, order_date, restaurant_name,
                            location, category, dish_name,
                            price_inr, rating
               ORDER BY ctid
           ) AS rn
    FROM swiggy_orders
)
DELETE FROM swiggy_orders
WHERE ctid IN (
    SELECT ctid
    FROM cte
    WHERE rn > 1
);


-- Creating Schema
-- Dimensions table
-- Date Table
CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    day INT,
    week INT
);

-- Location table
CREATE TABLE dim_location (
    location_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    state VARCHAR(100),
    city VARCHAR(100),
    location VARCHAR(200)
);

-- Restaurant Table
CREATE TABLE dim_restaurant (
    restaurant_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_name VARCHAR(200)
);

-- Category Table
CREATE TABLE dim_category (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category VARCHAR(200)
);

--Dish table
CREATE TABLE dim_dish (
    dish_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dish_name VARCHAR(200)
);

-- Fact table
CREATE TABLE fact_swiggy_orders (
    order_id SERIAL PRIMARY KEY,

    date_id INT,
    price_inr DECIMAL(10,2),
    rating DECIMAL(4,2),
    

    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,

    CONSTRAINT fk_date
        FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id),

    CONSTRAINT fk_location
        FOREIGN KEY (location_id)
        REFERENCES dim_location(location_id),

    CONSTRAINT fk_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES dim_restaurant(restaurant_id),

    CONSTRAINT fk_category
        FOREIGN KEY (category_id)
        REFERENCES dim_category(category_id),

    CONSTRAINT fk_dish
        FOREIGN KEY (dish_id)
        REFERENCES dim_dish(dish_id)
);

-- Inserting data into Date table
INSERT INTO dim_date (
    full_date,
    year,
    month,
    month_name,
    quarter,
    day,
    week
)
SELECT DISTINCT
    order_date,
    EXTRACT(YEAR FROM order_date)::INT,
    EXTRACT(MONTH FROM order_date)::INT,
    TRIM(TO_CHAR(order_date, 'Month')),
    EXTRACT(QUARTER FROM order_date)::INT,
    EXTRACT(DAY FROM order_date)::INT,
    EXTRACT(WEEK FROM order_date)::INT
FROM swiggy_orders 
WHERE order_date IS NOT NULL;

-- Inserting data into Location table
INSERT INTO dim_location (state, city, location)
SELECT DISTINCT
    state,
    city,
    location
FROM swiggy_orders;

-- Inserting data into Restaurant table
INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT
    restaurant_name
FROM swiggy_orders;

-- Inserting data into Category table
INSERT INTO dim_category (category)
SELECT DISTINCT
    category
FROM swiggy_orders;

-- Inserting data into Dish table
INSERT INTO dim_dish (dish_name)
SELECT DISTINCT
    dish_name
FROM swiggy_orders;

-- Inserting data into Fact table
INSERT INTO fact_swiggy_orders
(
    date_id,
    price_inr,
    rating,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)

SELECT
    dd.date_id,
    s.price_inr,
    s.rating,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id

FROM swiggy_orders s

JOIN dim_date dd
    ON dd.full_date = s.order_date

JOIN dim_location dl
    ON dl.state = s.state
   AND dl.city = s.city
   AND dl.location = s.location

JOIN dim_restaurant dr
    ON dr.restaurant_name = s.restaurant_name

JOIN dim_category dc
    ON dc.category = s.category

JOIN dim_dish dsh
    ON dsh.dish_name = s.dish_name;


SELECT *
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_location l ON f.location_id = l.location_id
JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
JOIN dim_category c ON f.category_id = c.category_id
JOIN dim_dish di ON f.dish_id = di.dish_id;

SELECT * FROM fact_swiggy_orders;

--KPIs
-- Total Orders
SELECT COUNT(*) as Total_orders from fact_swiggy_orders;

-- Total Revenue (INR Millions)
SELECT 
    CONCAT(ROUND(SUM(price_inr) / 1000000, 2), ' Million Rupees') AS Total_Revenue FROM fact_swiggy_orders;

-- Average Dish Price
SELECT 
    ROUND(Avg(price_inr) ,2) AS Avg_Price FROM fact_swiggy_orders;

-- Average Rating
SELECT 
    ROUND(Avg(rating) ,2) AS Avg_rating FROM fact_swiggy_orders;

-- GRANULAR REQUIREMENTS
-- Monthly Order Trends

-- Total Orders month wise
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(*) AS Total_Monthly_Orders
FROM fact_swiggy_orders f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY Total_Monthly_Orders DESC;

-- Total Revenue month wise
SELECT
    d.year,
    d.month,
    d.month_name,
    CONCAT(ROUND(SUM(price_inr) / 1000000, 2), ' Million Rupees') AS Total_Monthly_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY Total_Monthly_Revenue DESC;

-- Quarterly Trend

-- Total Orders Quarter wise
SELECT
    d.year,
    d.quarter,
    COUNT(*) AS Total_Quarterly_Orders
FROM fact_swiggy_orders f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    d.year,
    d.quarter
ORDER BY Total_Quarterly_Orders DESC;

-- Total Revenue Quarter wise
SELECT
    d.year,
    d.quarter,
    CONCAT(ROUND(SUM(price_inr) / 1000000, 2), ' Million Rupees') AS Total_Quarterly_Revenue
FROM fact_swiggy_orders f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    d.year,
    d.quarter
ORDER BY Total_Quarterly_Revenue DESC;

-- Orders by Day of Week (Mon-Sun)
SELECT
    TO_CHAR(d.full_date, 'Day') AS day_name,
    COUNT(*) AS total_day_orders
FROM fact_swiggy_orders f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    EXTRACT(DOW FROM d.full_date),
    TO_CHAR(d.full_date, 'Day')
ORDER BY
    EXTRACT(DOW FROM d.full_date);

-- Top 10 Cities by Order Volume
SELECT
    l.city,
    COUNT(*) AS Total_City_Orders
FROM fact_swiggy_orders f
JOIN dim_location l
    ON l.location_id = f.location_id
GROUP BY
    l.city
ORDER BY Total_City_Orders DESC
LIMIT 10;

-- Top 10 Cities by Total Revenue
SELECT
    l.city,
    CONCAT(ROUND(SUM(price_inr) / 1000000, 2), ' Million Rupees') AS Total_City_Revenue
FROM fact_swiggy_orders f
JOIN dim_location l
    ON l.location_id = f.location_id
GROUP BY
    l.city
ORDER BY
    Total_City_Revenue DESC
LIMIT 10;

-- Revenue Contribution by States
SELECT
    l.state,
    CONCAT(ROUND(SUM(price_inr) / 1000000, 2), ' Million Rupees') AS Total_State_Revenue
FROM fact_swiggy_orders f
JOIN dim_location l
    ON l.location_id = f.location_id
GROUP BY
    l.state
ORDER BY
    Total_State_Revenue DESC;

--Top 10 Restaurants by Orders Volume
SELECT
    r.restaurant_name,
    COUNT(*) AS Total_Restaurant_Orders
FROM fact_swiggy_orders f
JOIN dim_restaurant r
    ON r.restaurant_id = f.restaurant_id
GROUP BY
    r.restaurant_name
ORDER BY
    Total_Restaurant_Orders DESC
LIMIT 10;

-- Top Restaurant Performance
SELECT
    r.restaurant_name,
    COUNT(*) AS Total_Orders,
    CONCAT(ROUND(SUM(price_inr) / 1000000, 2), ' Million Rupees')  AS Total_Restaurant_Revenue,
    ROUND(AVG(f.rating),2) AS Average_Rating
FROM fact_swiggy_orders f
JOIN dim_restaurant r
ON r.restaurant_id=f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY Total_Restaurant_Revenue DESC
LIMIT 10;

--Top 10 Categories by Orders Volume
SELECT
    c.category,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_category c
    ON f.category_id = c.category_id
GROUP BY
    c.category
ORDER BY
    total_orders DESC LIMIT 10;

-- TOP 10 Highest Revenue Categories 
SELECT
    c.category,
    COUNT(*) AS total_orders,
    ROUND(SUM(f.price_inr),2) AS total_revenue
FROM fact_swiggy_orders f
JOIN dim_category c
ON f.category_id=c.category_id
GROUP BY c.category
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 20 Most ordered Dishes
SELECT
    d.dish_name,
    COUNT(*) AS order_count
FROM fact_swiggy_orders f
JOIN dim_dish d
    ON f.dish_id = d.dish_id
GROUP BY
    d.dish_name
ORDER BY
    order_count DESC
	LIMIT 20;

-- Cuisine Performance (Orders + Avg rating)
SELECT
    c.category,
    COUNT(*) AS total_orders,
    ROUND(AVG(f.rating), 2) AS avg_rating
FROM fact_swiggy_orders f
JOIN dim_category c
    ON f.category_id = c.category_id
GROUP BY
    c.category
ORDER BY
    total_orders DESC, avg_rating DESC ;

-- Order Value Distribution (Total Orders by Price Range)
SELECT
    price_range,
    COUNT(*) AS total_orders
FROM (
    SELECT
        CASE
            WHEN price_inr < 100 THEN 'Under 100'
            WHEN price_inr BETWEEN 100 AND 199 THEN '100 - 199'
            WHEN price_inr BETWEEN 200 AND 299 THEN '200 - 299'
            WHEN price_inr BETWEEN 300 AND 499 THEN '300 - 499'
            ELSE '500+'
        END AS price_range
    FROM fact_swiggy_orders
) t
GROUP BY
    price_range
ORDER BY
    total_orders DESC;

-- Top 10 Highest Rated Restaurants

SELECT
    r.restaurant_name,
    COUNT(*) AS Total_Orders,
    ROUND(AVG(f.rating), 2) AS Average_Rating
FROM fact_swiggy_orders f
JOIN dim_restaurant r
    ON r.restaurant_id = f.restaurant_id
GROUP BY
    r.restaurant_name
ORDER BY
    Average_Rating DESC,
    Total_Orders DESC
LIMIT 10;




	