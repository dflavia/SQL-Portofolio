-- Active User Retention [Facebook SQL Interview Question]
-- user_actions(user_id, event_id, event_type, event_date)

-- Assume you're given a table containing information on Facebook user actions. Write a query to obtain number of monthly active users (MAUs) in July 2022, including the month in numerical format "1, 2, 3".
-- An active user is defined as a user who has performed actions such as 'sign-in', 'like', or 'comment' in both the current month and the previous month.


SELECT
    month,
    COUNT(DISTINCT user_id) AS monthly_active_users
FROM (
      SELECT
          user_id,
          EXTRACT(MONTH FROM event_date) AS month,
          DENSE_RANK() OVER (PARTITION BY user_id ORDER BY EXTRACT(MONTH FROM event_date)) AS r1 -- assign a rank to the users active in Jul and Jun
      FROM user_actions
      WHERE
          (EXTRACT(MONTH FROM event_date) = 6 OR EXTRACT(MONTH FROM event_date) = 7) -- isolate users active in Jul 22 and previous month
          AND EXTRACT(YEAR FROM event_date) = 2022
     ) t
WHERE r1 = 2 -- filter for users active in both Jul and Jun
GROUP BY month;

-- OR

SELECT
    EXTRACT(MONTH FROM curr_month.event_date) AS month,
    COUNT(DISTINCT curr_month.user_id) AS monthly_active_users
FROM user_actions AS curr_month

WHERE EXISTS (
               SELECT last_month.user_id
               FROM user_actions AS last_month
               WHERE last_month.user_id = curr_month.user_id
               AND EXTRACT(MONTH FROM last_month.event_date) = EXTRACT(MONTH FROM curr_month.event_date - INTERVAL '1 MONTH')
             )
  AND EXTRACT(MONTH FROM curr_month.event_date) = 7
  AND EXTRACT (YEAR FROM curr_month.event_date) = 2022
  
GROUP BY EXTRACT(MONTH FROM curr_month.event_date)


-- Y-on-Y Growth Rate [Wayfair SQL Interview Question]
-- user_transactions(transaction_id, product_id, spend, transaction_date)

-- Write a query to calculate the year-on-year growth rate for the total spend of each product, grouping the results by product ID.
-- The output should include the year in ascending order, product ID, current year's spend, previous year's spend and year-on-year growth percentage, rounded to 2 decimal places.

SELECT
    *,
    ROUND(100.0* (curr_year_spend - prev_year_spend) / prev_year_spend,2) AS yoy_rate
FROM (
      SELECT
          EXTRACT(YEAR FROM transaction_date) AS year,
          product_id,
          spend AS curr_year_spend,
          LAG(spend) OVER (PARTITION BY product_id ORDER BY EXTRACT(YEAR FROM transaction_date)) AS prev_year_spend
      FROM user_transactions
      ) t
      

-- Advertiser Status [Facebook SQL Interview Question]
-- advertiser(user_id, status)
-- daily_pay(user_id, paid)

-- You're provided with two tables: the advertiser table contains information about advertisers and their respective payment status
-- The daily_pay table contains the current payment information for advertisers, and it only includes advertisers who have made payments.
-- Write a query to update the payment status of Facebook advertisers based on the information in the daily_pay table.
-- The output should include the user ID and their current payment status, sorted by the user id.

-- The payment status of advertisers can be classified into the following categories:

-- New: Advertisers who are newly registered and have made their first payment.
-- Existing: Advertisers who have made payments in the past and have recently made a current payment.
-- Churn: Advertisers who have made payments in the past but have not made any recent payment.
-- Resurrect: Advertisers who have not made a recent payment but may have made a previous payment and have made a payment again recently.

SELECT 
    COALESCE(a.user_id,d.user_id) AS user_id,
    CASE
        WHEN paid IS NULL THEN 'CHURN'
        WHEN paid IS NOT NULL AND a.status = 'CHURN' THEN 'RESURRECT'
        WHEN  paid IS NOT NULL and a.status IS NULL THEN 'NEW'
        WHEN paid IS NOT NULL AND a.status IN ('NEW', 'EXISTING', 'RESURRECT') THEN 'EXISTING'
    END AS new_status
FROM advertiser a
FULL OUTER JOIN daily_pay d ON a.user_id = d.user_id
ORDER BY user_id;


-- 3-Topping Pizzas [McKinsey SQL Interview Question]
-- pizza_toppings(topping_name, ingredient_cost)

-- Given a list of pizza toppings, consider all the possible 3-topping pizzas, and print out the total cost of those 3 toppings.
-- Sort the results with the highest total cost on the top followed by pizza toppings in ascending order.
-- Break ties by listing the ingredients in alphabetical order, starting from the first ingredient, followed by the second and third.
-- Do not display pizzas where a topping is repeated. For example, ‘Pepperoni,Pepperoni,Onion Pizza’.
-- Ingredients must be listed in alphabetical order. For example, 'Chicken,Onions,Sausage'. 'Onion,Sausage,Chicken' is not acceptable.

SELECT 
    CONCAT(n1, ',', n2, ',', n3) AS pizza,
    c1 + c2 + c3 AS total_cost

FROM (
      SELECT 
          p1.topping_name AS n1,
          p1.ingredient_cost AS c1,
          p2.topping_name AS n2,
          p2.ingredient_cost AS c2,
          p3.topping_name AS n3,
          p3.ingredient_cost AS c3
      FROM pizza_toppings p1
      INNER JOIN pizza_toppings p2 ON p1.topping_name < p2.topping_name
      INNER JOIN pizza_toppings p3 ON p2.topping_name < p3.topping_name
     ) t
ORDER BY total_cost DESC, pizza;

-- OR

WITH RECURSIVE all_toppings AS
(-- write non-recursive query or anchor
  SELECT
    topping_name::VARCHAR, -- PSQL limitation, need to explicitly CAST as VARCHAR
    ingredient_cost::DECIMAL, -- PSQL limitation, need to explicitly CAST as VARCHAR
    1 AS topping_number
  FROM pizza_toppings
  
  UNION ALL
  
  -- write recursive query; will iterate until termination condition
  SELECT
    CONCAT(addon.topping_name, ',', anchor.topping_name) AS topping_name, -- CONCAT to combine 2 or more toppings
    addon.ingredient_cost + anchor.ingredient_cost AS total_cost, -- sum up cost of all used toppings
    topping_number + 1 -- increment topping number used in pizza
  FROM
    pizza_toppings AS addon,
    all_toppings AS anchor
  WHERE anchor.topping_name < addon.topping_name -- termination condition, prevents the same topping names from showing up multiple times in the combination
)

SELECT
  STRING_AGG(single_topping,',' ORDER BY single_topping) AS pizza, -- use STRING_AGG to order single_toppings alphabetically and join into one string
  ingredient_cost
FROM 
  all_toppings,
  REGEXP_SPLIT_TO_TABLE(topping_name, ',') AS single_topping -- split ',' separated string into multiple rows that will be ordered by STRING_AGG
WHERE topping_number = 3 -- filter only for 3-ingredient pizza
GROUP BY topping_name, ingredient_cost -- GROUP BY due to aggregate function STRING_AGG
ORDER BY ingredient_cost DESC, pizza


-- Repeated Payments [Stripe SQL Interview Question]
-- transactions(transaction_id, merchant_id, credit_card_id, amount, transaction_timestamp)

-- Using the transactions table, identify any payments made at the same merchant with the same credit card for the same amount within 10 minutes of each other. Count such repeated payments.
-- The first transaction of such payments should not be counted as a repeated payment.
-- This means, if there are two transactions performed by a merchant with the same credit card and for the same amount within 10 minutes, there will only be 1 repeated payment.

SELECT COUNT(merchant_id)
FROM (
      SELECT
          *,
          EXTRACT
            (EPOCH FROM
                    transaction_timestamp - LAG(transaction_timestamp) OVER (PARTITION BY merchant_id, credit_card_id, amount ORDER BY transaction_timestamp)
            )/60 AS diff -- calculate difference between transactions in seconds with EPOCH; divide by 60 to find minutes
      FROM transactions
) t
WHERE diff <= 10 -- filter for 10 minutes max


-- Server Utilization Time [Amazon SQL Interview Question]
-- server_utilization(server_id, status_time, session_status)

-- Write a query that calculates the total time that the fleet of servers was running. The output should be in units of full days.
-- Each server might start and stop several times.
-- The total time in which the server fleet is running can be calculated as the sum of each server's uptime.

SELECT FLOOR(SUM(seconds) / (60*60*24)) -- /60 convert sec to min, again /60 convert min to hours
FROM (
      SELECT
          *,
          LEAD(status_time) OVER (PARTITION BY server_id ORDER BY status_time),
          EXTRACT
            (EPOCH FROM
                 LEAD(status_time) OVER (PARTITION BY server_id ORDER BY status_time) - status_time
            ) AS seconds
      FROM server_utilization
     ) t
WHERE session_status = 'start'

-- OR

SELECT
    DATE_PART('DAYS',JUSTIFY_HOURS(SUM(time_diff))) -- JUSTIFY_HOURS to convert any value above 24 hours into units of full days; then extract days number with DATE_PART
FROM (
      SELECT
          *,
          LEAD(status_time) OVER (PARTITION BY server_id ORDER BY status_time) - status_time AS time_diff
            
      FROM server_utilization
      ) t
WHERE session_status = 'start'


-- Department vs. Company Salary [FAANG SQL Interview Question]
-- employee(employee_id, name, salary, department_id, manager_id)
-- salary(salary_id, employee_id, amount, payment_date)

-- Write a query to compare the average salary of employees in each department to the company's average salary for March 2024. Return the comparison result as 'higher', 'lower', or 'same' for each department.
-- Display the department ID, payment month (in MM-YYYY format), and the comparison result.  

WITH comp AS
(SELECT
    AVG(amount) AS avg_comp, -- avg per company
    TO_CHAR(payment_date, 'MM-YYYY') AS payment_date -- change format from 03/31/2024 00:00:00 to 03-2024
 FROM salary
 WHERE EXTRACT(YEAR FROM payment_date) = 2024
 AND EXTRACT(MONTH FROM payment_date) = 3 -- filter avg only for Mar 24
 GROUP BY payment_date
),
 
dep AS
(SELECT
    department_id,
    AVG(amount) AS avg_dep -- avg per dep
 FROM employee e
 INNER JOIN salary s ON e.employee_id = s.employee_id
 WHERE EXTRACT(YEAR FROM payment_date) = 2024
 AND EXTRACT(MONTH FROM payment_date) = 3 -- filter avg only for Mar 24
 GROUP BY department_id
)
 
SELECT
    dep.department_id,
    comp.payment_date,
    CASE
        WHEN avg_dep = avg_comp THEN 'same'
        WHEN avg_dep < avg_comp THEN 'lower'
        WHEN avg_dep > avg_comp THEN 'higher'
    END AS comparison    
FROM dep, comp


-- Median Google Search Frequency [Google SQL Interview Question]
-- search_frequency(searches, num_users)

-- You have access to a summary table which tells you the number of searches made last year and how many Google users fall into that bucket.
-- Write a query to report the median of searches made by a user. Round the median to one decimal point.

WITH t AS
(SELECT
    searches AS num, -- after cross join, obtain repeated searches rows based on num_users values
    ROW_NUMBER() OVER (ORDER BY searches) AS r1 -- order numbers before median calculation
 FROM search_frequency, GENERATE_SERIES(1, num_users) -- generate series, cross join with initial table
 ORDER BY num)
 
SELECT
  CASE
      WHEN MOD(COUNT(*),2) <> 0 -- for odd series, median is middle number
          THEN (SELECT num
                FROM t
                WHERE r1 = ((SELECT COUNT(*) FROM t) + 1) / 2 -- calculate middle number of series = (n+1)/2
               )
      ELSE (SELECT ROUND(AVG(num),1) -- for even series, median is middle numbers divided by two
            FROM t
            WHERE
                 r1 = (SELECT COUNT(*) FROM t) / 2 -- -- calculate middle numbers of series = n/2
              OR r1 = (SELECT COUNT(*) FROM t) / 2 + 1 -- -- calculate middle numbers of series = n/2 + 1
           )  
  END AS median          
FROM t


-- Maximize Prime Item Inventory [Amazon SQL Interview Question]
-- inventory(item_id, item_type, item_category, square_footage)

-- Amazon wants to maximize the storage capacity of its 500,000 square-foot warehouse by prioritizing a specific batch of prime items.
-- The specific prime product batch detailed in the inventory table must be maintained.
-- After prioritizing the maximum number of prime batches, any remaining square footage will be utilized to stock non-prime batches, which also come in batch sets and cannot be separated into individual items.
-- Write a query to find the maximum number of prime and non-prime batches that can be stored in the 500,000 square feet warehouse based on the following criteria:

-- Prioritize stocking prime batches
-- After accommodating prime items, allocate any remaining space to non-prime batches
-- Output the item_type with prime_eligible first followed by not_prime, along with the maximum number of batches that can be stocked.

-- Assumptions:

-- Again, products must be stocked in batches, so we want to find the largest available quantity of prime batches, and then the largest available quantity of non-prime batches
-- Non-prime items must always be available in stock to meet customer demand, so the non-prime item count should never be zero.
-- Item count should be whole numbers (integers).

WITH summary AS
(
  SELECT
      item_type,
      SUM(square_footage) AS ft_per_batch, -- find sq ft necessary for prime batch vs not_prime batch
      COUNT(item_id) AS item_per_batch, -- find how many items are in a prime batch vs not_prime batch
      FLOOR(500000/SUM(square_footage)) AS possible_max_batch, -- find max possible batches no for prime vs not_prime
      FLOOR(500000/SUM(square_footage)) * SUM(square_footage) AS possible_max_ft, -- find max possible ft no for prime vs not_prime
      FLOOR(500000/SUM(square_footage)) * COUNT(item_id) AS possible_max_item -- find max possible no of items for prime vs not_prime    
  FROM inventory
  GROUP BY item_type -- group all based on prime vs not_prime
),

prime AS
(
  SELECT
      item_type,
      possible_max_ft AS prime_ft,
      possible_max_item AS prime_item
  FROM summary
  WHERE item_type = 'prime_eligible'
),

not_prime AS
(
  SELECT
      item_type,
      500000 - (SELECT prime_ft FROM prime) AS not_prime_ft, -- priotitize ft for prime, find residual ft and allocate to not_prime
      FLOOR((500000 - (SELECT prime_ft FROM prime)) / ft_per_batch) AS not_prime_batch, -- find no of not_prime batches that can fit the residual ft
      FLOOR((500000 - (SELECT prime_ft FROM prime)) / ft_per_batch) * item_per_batch AS not_prime_item -- find no of not_prime items that can fit the residual ft
  FROM summary
  WHERE item_type = 'not_prime'
  )
  
SELECT
    item_type,
    prime_item
FROM prime
UNION
SELECT
    item_type,
    not_prime_item
FROM not_prime
ORDER BY item_type DESC -- Output the item_type with prime_eligible first followed by not_prime