-- 620. Not Boring Movies
-- cinema(id, movie, description, rating)

-- Write a solution to report the movies with an odd-numbered ID and a description that is not "boring".
-- Return the result table ordered by rating in descending order.

SELECT *
FROM cinema
WHERE MOD(id,2) <> 0
AND description <> 'boring'
ORDER BY rating DESC;


-- 1251. Average Selling Price
-- prices(product_id, start_date, end_date, price)
-- For each product_id there will be no two overlapping periods.
-- unitssold(product_id, purchase_date, units)

-- Write a solution to find the average selling price for each product. average_price should be rounded to 2 decimal places.

SELECT
     p.product_id,
     COALESCE(ROUND(SUM(price * units) / SUM(units),2),0) AS average_price
FROM prices p
LEFT JOIN unitssold u ON p.product_id = u.product_id
AND purchase_date BETWEEN start_date AND end_date
GROUP BY p.product_id


-- 1075. Project Employees I
-- project(project_id, employee_id)
-- employee(employee_id, name, experience_years)
-- It's guaranteed that experience_years is not NULL.

-- Write an SQL query that reports the average experience years of all the employees for each project, rounded to 2 digits.

SELECT
     p.project_id,
     ROUND(SUM(experience_years) / COUNT(experience_years),2) AS average_years
FROM project p
LEFT JOIN employee e ON p.employee_id = e.employee_id
GROUP BY p.project_id


-- 1633. Percentage of Users Attended a Contest
-- users(user_id, user_name)
-- register(contest_id, user_id)

-- Write a solution to find the percentage of the users registered in each contest rounded to two decimals.
-- Return the result table ordered by percentage in descending order. In case of a tie, order it by contest_id in ascending order.

SELECT
     contest_id,
     ROUND((COUNT(user_id) / (SELECT COUNT(user_id) FROM users))*100,2) AS percentage
FROM register
GROUP BY contest_id
ORDER  BY percentage DESC, contest_id;


-- 1211. Queries Quality and Percentage
-- queries(query_name, result, position, rating)
-- We define query quality as: The average of the ratio between query rating and its position.
-- We also define poor query percentage as: The percentage of all queries with rating less than 3.

-- Write a solution to find each query_name, the quality and poor_query_percentage.
-- Both quality and poor_query_percentage should be rounded to 2 decimal places.

SELECT
    query_name,
    ROUND(AVG(rating/position),2) AS quality,
    ROUND(100.0 * AVG(CASE WHEN rating <3 THEN 1 ELSE 0 END),2) AS poor_query_percentage
FROM queries
WHERE query_name IS NOT NULL
GROUP BY query_name


-- 1193. Monthly Transactions I
-- transactions(id, country, state, amount, trans_date)
-- The state column is an enum of type ["approved", "declined"].

-- Write an SQL query to find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount.

SELECT
    DATE_FORMAT(trans_date, '%Y-%m') AS month,
    country,
    COUNT(*) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM transactions
GROUP BY month, country


-- 1174. Immediate Food Delivery II
-- delivery(delivery_id, customer_id, order_date, customer_pref_delivery_date)
-- If the customer's preferred delivery date is the same as the order date, then the order is called immediate; otherwise, it is called scheduled.

-- Write a solution to find the percentage of immediate orders in the first orders of all customers, rounded to 2 decimal places.

SELECT ROUND(AVG(order_date = customer_pref_delivery_date) * 100,2) AS immediate_percentage
FROM(
    SELECT
        customer_id,
        RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rank1,
        order_date,
        customer_pref_delivery_date
    FROM delivery
    ) t1
WHERE rank1 = 1

-- OR

SELECT ROUND(AVG(order_date = customer_pref_delivery_date) * 100,2) AS immediate_percentage
FROM delivery
WHERE (customer_id, order_date) IN (
                                    SELECT customer_id, MIN(order_date)
                                    FROM delivery
                                    GROUP BY customer_id
                                    )

-- OR

WITH T1 AS
(SELECT
    *,
    RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS r1,
    CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END AS type
FROM delivery
)

SELECT
    ROUND(100 * AVG(type),2) AS immediate_percentage
FROM T1
WHERE r1 = 1
                                    

-- 550. Game Play Analysis IV
-- activity(player_id, device_id, event_date, games_played)

-- Write a solution to report the fraction of players that logged in again on the day after the day they first logged in, rounded to 2 decimal places.
-- In other words, you need to count the number of players that logged in for at least two consecutive days starting from their first login date,
-- then divide that number by the total number of players.

SELECT ROUND(COUNT(DISTINCT player_id) / (SELECT COUNT(DISTINCT player_id) FROM activity),2) AS fraction
FROM(
SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY event_date) AS day2, 
    DATEDIFF(event_date, LAG(event_date) OVER (PARTITION BY player_id ORDER BY event_date)) AS consec 
FROM activity
) t
WHERE day2 = 2 -- 1 would be the first login ever
AND consec = 1 -- -- ensure that days are consecutive