-- User's Third Transaction [Uber SQL Interview Question]
-- transactions(user_id, spend, transaction_date)

-- Write a query to obtain the third transaction of every user. Output the user id, spend and transaction date.

SELECT
    user_id,
    spend,
    transaction_date
FROM (
        SELECT
            *,
            DENSE_RANK() OVER (PARTITION BY user_id ORDER BY transaction_date) AS r1
        FROM transactions
     ) t
WHERE r1 = 3;


-- Second Highest Salary [FAANG SQL Interview Question]
-- employee(employee_id, name, salary, department_id, manager_id)

-- Determine the second highest salary among all employees.
-- It's possible that multiple employees may share the same second highest salary. In case of duplicate, display the salary only once.

SELECT
    DISTINCT salary
FROM employee
ORDER BY salary DESC
LIMIT 1
OFFSET 1


-- Sending vs. Opening Snaps [Snapchat SQL Interview Question]
-- activities(activity_id, user_id, activity_type, time_spent, activity_date)
-- age_breakdown(user_id, age_bucket)

-- Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of total time spent on these activities grouped by age group.
-- Round the percentage to 2 decimal places in the output.
-- Notes:
-- Calculate the following percentages:
-- time spent sending / (Time spent sending + Time spent opening)
-- Time spent opening / (Time spent sending + Time spent opening)
-- To avoid integer division in percentages, multiply by 100.0 and not 100.

SELECT
    age_bucket,
    ROUND(100.0 *
             SUM(CASE WHEN activity_type = 'send' THEN time_spent ELSE NULL END)
           / SUM(CASE WHEN activity_type = 'send' OR activity_type = 'open' THEN time_spent ELSE NULL END)
             ,2)  AS send_perc,
    ROUND(100.0 *
             SUM(CASE WHEN activity_type = 'open' THEN time_spent ELSE NULL END)
           / SUM(CASE WHEN activity_type = 'send' OR activity_type = 'open' THEN time_spent ELSE NULL END)
             ,2) AS open_perc
FROM activities a1
INNER JOIN age_breakdown a2 ON a1.user_id = a2.user_id
GROUP BY age_bucket


-- Tweets' Rolling Averages [Twitter SQL Interview Question]
-- tweets(user_id, tweet_date, tweet_count)

-- Calculate the 3-day rolling average of tweets for each user. Output the user ID, tweet date, and rolling averages rounded to 2 decimal places.
-- Notes:
-- A rolling average, also known as a moving average or running mean is a time-series technique that examines trends in data over a specified period of time.
-- In this case, we want to determine how the tweet count for each user changes over a 3-day period.

SELECT
    user_id,
    tweet_date,
    ROUND(AVG(tweet_count) OVER (PARTITION BY user_id
                ORDER BY tweet_date
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
          ,2) AS rolling_avg_3d

FROM tweets
GROUP BY user_id, tweet_date, tweet_count; 



-- Highest-Grossing Items [Amazon SQL Interview Question]
-- product_spend(category, product, user_id, spend, transaction_date)

-- Write a query to identify the top two highest-grossing products within each category in the year 2022. The output should include the category, product, and total spend.


SELECT
    category,
    product,
    total_spend
FROM (
      SELECT
          *,
          DENSE_RANK() OVER (PARTITION BY category ORDER BY total_spend DESC) AS r1
      FROM (SELECT 
                category,
                product,
                SUM(spend) AS total_spend
            FROM product_spend
            GROUP BY category, product
           )t1
     ) t2
WHERE r1 < 3;


-- Top Three Salaries [FAANG SQL Interview Question]
-- employee(employee_id, name, salary, department_id, manager_id)

-- You're tasked with identifying high earners across all departments. Write a query to display the employee's name along with their department name and salary.
-- In case of duplicates, sort the results of department name in ascending order, then by salary in descending order. If multiple employees have the same salary, then order them alphabetically.
-- A 'high earner' within a department is defined as an employee with a salary ranking among the top three salaries within that department.

WITH t1 AS
(SELECT 
    *,
    DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY salary DESC) AS r1
FROM employee e
INNER JOIN department d ON e.department_id = d.department_id
)

SELECT
    department_name,
    name,
    salary
FROM t1
WHERE r1 <=3
ORDER BY department_name, salary DESC, name


-- Top 5 Artists [Spotify SQL Interview Question]
-- artists(artist_id, artist_name, label_owner)
-- songs(song_id, artist_id, name)
-- global_song_rank(day, song_id, rank)

-- Write a query to find the top 5 artists whose songs appear most frequently in the Top 10 of the global_song_rank table.
-- Display the top 5 artist names in ascending order, along with their song appearance ranking.
-- If two or more artists have the same number of song appearances, they should be assigned the same ranking, and the rank numbers should be continuous (i.e. 1, 2, 2, 3, 4, 5)

SELECT
  artist_name,
  r1
FROM (
      SELECT
        *,
        DENSE_RANK() OVER (ORDER BY c1 DESC) AS r1
      FROM (
            SELECT
                a.artist_name,
                COUNT(g.song_id) AS c1
            FROM global_song_rank AS g
            INNER JOIN songs s ON g.song_id = s.song_id
            INNER JOIN artists a ON s. artist_id = a.artist_id
            WHERE g.rank < 11
            GROUP BY a.artist_name
            ) t1
      ) t2
WHERE r1 < 6
ORDER BY r1


-- Signup Activation Rate [TikTok SQL Interview Question]
-- emails(email_id, user_id, signup_date)
-- texts(text_id, email_id, signup_action)
-- emails table contain the information of user signup details.
-- texts table contains the users' activation information.

-- New TikTok users sign up with their emails. They confirmed their signup by replying to the text confirmation to activate their accounts.
-- Users may receive multiple text messages for account confirmation until they have confirmed their new account.
-- A senior analyst is interested to know the activation rate of specified users in the emails table, which may not include all users that could potentially be found in the texts table.
-- Write a query to find the activation rate. Round the percentage to 2 decimal places.

SELECT 
    ROUND(1.0* COUNT(CASE WHEN signup_action = 'Confirmed' THEN 1 ELSE NULL END) / COUNT(signup_action),2)
FROM emails e
LEFT JOIN texts t ON e.email_id = t.email_id


-- Supercloud Customer [Microsoft SQL Interview Question]
-- customer_contracts(customer_id, product_id, amount)
-- products(product_id, product_category, product_name)

-- A Microsoft Azure Supercloud customer is defined as a customer who has purchased at least one product from every product category listed in the products table.
-- Write a query that identifies the customer IDs of these Supercloud customers.

SELECT customer_id
FROM (
        SELECT 
            *,
            DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY product_category) AS r1
        FROM products p
        INNER JOIN customer_contracts c ON p.product_id = c.product_id
     ) t1
WHERE r1 = (
            SELECT COUNT(DISTINCT product_category)  -- count how many categories there are in products table
            FROM products                            -- then filter only customers that bought products from all categories ie. rank = count of categories   
           ) 


-- Odd and Even Measurements [Google SQL Interview Question]
-- measurements(measurement_id, measurement_value, measurement_time)
-- Within a day, measurements taken at 1st, 3rd, and 5th times are considered odd-numbered measurements, and measurements taken at 2nd, 4th, and 6th times are considered even-numbered measurements.

-- Write a query to calculate the sum of odd-numbered and even-numbered measurements separately for a particular day and display the results in two different columns.

SELECT
    measurement_day,
    SUM(CASE WHEN MOD(r1,2) <> 0 THEN measurement_value ELSE NULL END) AS odd_sum,
    SUM(CASE WHEN MOD(r1,2) = 0 THEN measurement_value ELSE NULL END) AS even_sum
FROM(
      SELECT
          CAST(measurement_time AS DATE) AS measurement_day,
          measurement_time,
          measurement_value,
          DENSE_RANK() OVER (PARTITION BY CAST(measurement_time AS DATE) ORDER BY measurement_time) AS r1
      FROM measurements
    ) t
GROUP BY measurement_day;


-- Histogram of Users and Purchases [Walmart SQL Interview Question]
-- user_transactions(product_id, user_id, spend, transaction_date)

-- Assume you're given a table on Walmart user transactions. Based on their most recent transaction date, write a query that retrieves the users along with the number of products they bought.
-- Output the user's most recent transaction date, user ID, and the number of products, sorted in chronological order by the transaction date.

SELECT
  transaction_date,
  user_id,
  COUNT(product_id)
FROM (
      SELECT
          *,
          DENSE_RANK() OVER (PARTITION BY user_id ORDER BY transaction_date DESC) AS r1
      FROM user_transactions
     ) t1
WHERE r1 = 1
GROUP BY transaction_date, user_id
ORDER BY transaction_date


-- Card Launch Success [JPMorgan Chase SQL Interview Question]
-- monthly_cards_issued(issue_month, issue_year, card_name, issued_amount)

-- Write a query that outputs the name of the credit card, and how many cards were issued in its launch month.
-- The launch month is the earliest record in the monthly_cards_issued table for a given card. Order the results starting from the biggest issued amount.

SELECT
  card_name,
  issued_amount
FROM (
      SELECT
          *,
          ROW_NUMBER() OVER (PARTITION BY card_name ORDER BY issue_year, issue_month) AS r1
      FROM monthly_cards_issued
      ) t
WHERE r1 = 1
ORDER BY issued_amount DESC

-- OR

SELECT
  card_name,
  issued_amount
FROM (
      SELECT
          card_name,
          issued_amount,
          MAKE_DATE(issue_year, issue_month,1) AS issue_date,
          MIN(MAKE_DATE(issue_year, issue_month,1)) OVER (PARTITION BY card_name) AS first_date
      FROM monthly_cards_issued
      ) t
WHERE issue_date = first_date
ORDER BY issued_amount DESC


-- International Call Percentage [Verizon SQL Interview Question]
-- phone_calls(caller_id, receiver_id, call_time)
-- phone_info(caller_id, country_id, network, phone_number)

-- What percentage of phone calls are international? Round the result to 1 decimal.

SELECT 
    ROUND(100.0 * COUNT(CASE WHEN country1 <> country2 THEN 1 ELSE NULL END) / COUNT(*),1)
FROM (
      SELECT
          c.caller_id,
          i1. country_id AS country1,
          c.receiver_id,
          i2.country_id AS country2
      FROM phone_calls c
      INNER JOIN phone_info i1 ON c.caller_id = i1.caller_id
      INNER JOIN phone_info i2 ON c.receiver_id = i2.caller_id
      ) t


-- Patient Support Analysis (Part 2) [UnitedHealth SQL Interview Question]
-- callers(policy_holder_id, case_id, call_category, call_date, call_duration_secs)

-- Calls to the Advocate4Me call centre are classified into various categories, but some calls cannot be neatly categorised.
-- These uncategorised calls are labeled as “n/a”, or are left empty when the support agent does not enter anything into the call category field.
-- Write a query to calculate the percentage of calls that cannot be categorised. Round your answer to 1 decimal place.

SELECT
  ROUND(100.0 * COUNT(CASE WHEN call_category IS NULL OR call_category = 'n/a' THEN 1 ELSE NULL END) / COUNT(*),1)
FROM callers


-- Swapped Food Delivery [Zomato SQL Interview Question]
-- orders(order_id, item)

-- Due to an error in the delivery driver instructions, each item's order was swapped with the item in the subsequent row.
-- As a data analyst, you're asked to correct this swapping error and return the proper pairing of order ID and item.
-- If the last item has an odd order ID, it should remain as the last item in the corrected data.
-- For example, if the last item is Order ID 7 Tandoori Chicken, then it should remain as Order ID 7 in the corrected data.
-- In the results, return the correct pairs of order IDs and items.

SELECT
  CASE
      WHEN LEAD(order_id) OVER (ORDER BY order_id) IS NULL AND MOD(order_id,2) <> 0 THEN order_id -- If the last item has an odd order ID, it should remain as the last item in the corrected data
      WHEN MOD(order_id,2) <> 0 THEN order_id + 1
      WHEN MOD(order_id,2) = 0 THEN order_id - 1
  END AS corrected_order_id	,
  item
FROM orders
ORDER BY corrected_order_id


-- FAANG Stock Min-Max (Part 1) [Bloomberg SQL Interview Question]
-- stock_prices(date, ticker, open, high, low, close)

-- For each FAANG stock, display the ticker symbol, the month and year ('Mon-YYYY') with the corresponding highest and lowest open prices. Ensure that the results are sorted by ticker symbol.


WITH t1 AS -- highest prices
(SELECT
    ticker,
    TO_CHAR(date, 'Mon-YYYY') AS month,
    open,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open DESC) AS r1
FROM stock_prices
),

t2 AS -- lowest prices
(SELECT
    ticker,
    TO_CHAR(date, 'Mon-YYYY') AS month,
    open,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY open) AS r2
FROM stock_prices
)

SELECT
     t1.ticker,
     t1.month AS highest_mth,
     t1.open AS highest_open,
     t2.month AS lowest_mth,
     t2.open AS lowest_open
FROM t1
INNER JOIN t2 ON t1.ticker = t2.ticker
WHERE r1 = r2 AND r1 = 1
ORDER BY t1.ticker


-- Compressed Mode [Alibaba SQL Interview Question]
-- items_per_order(item_count, order_occurrences)
-- item_count: Represents the number of items sold in each order.
-- order_occurrences: Represents the frequency of orders with the corresponding number of items sold per order.
-- For example, if there are 800 orders with 3 items sold in each order, the record would have an item_count of 3 and an order_occurrences of 800.


-- You're given a table containing the item count for each order on Alibaba, along with the frequency of orders that have the same item count.
-- Write a query to retrieve the mode of the order occurrences. Additionally, if there are multiple item counts with the same mode, the results should be sorted in ascending order.


SELECT item_count
FROM items_per_order
WHERE order_occurrences = (
                            SELECT MAX(order_occurrences)
                            FROM items_per_order
                          )