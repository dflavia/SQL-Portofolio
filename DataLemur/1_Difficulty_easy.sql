-- Histogram of Tweets [Twitter SQL Interview Question]
-- tweets(tweet_id, user_id, msg, tweet_date)

-- Assume you're given a table Twitter tweet data, write a query to obtain a histogram of tweets posted per user in 2022.
-- Output the tweet count per user as the bucket and the number of Twitter users who fall into that bucket.
-- In other words, group the users by the number of tweets they posted in 2022 and count the number of users in each group.

SELECT
  tweet_count AS tweet_bucket,
  COUNT(user_id) AS users_num
FROM (
        SELECT
            user_id,
            COUNT(tweet_id) AS tweet_count
        FROM tweets
        WHERE DATE_PART('year', tweet_date) = '2022'
        GROUP BY user_id
     ) t
GROUP BY tweet_count


-- Data Science Skills [LinkedIn SQL Interview Question]
-- candidates(candidate_id, skill)

-- Given a table of candidates and their skills, you're tasked with finding the candidates best suited for an open Data Science job. You want to find candidates who are proficient in Python, Tableau, and PostgreSQL.
-- Write a query to list the candidates who possess all of the required skills for the job. Sort the output by candidate ID in ascending order.

SELECT
  candidate_id
FROM candidates
WHERE skill IN ('Python','Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(*) = 3
ORDER BY candidate_id;


-- Page With No Likes [Facebook SQL Interview Question]
-- pages(page_id, page_name)
-- page_likes(user_id, page_id, liked_date)

-- Assume you're given two tables containing data about Facebook Pages and their respective likes (as in "Like a Facebook Page").
-- Write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.

SELECT page_id
FROM pages
WHERE page_id NOT IN (SELECT page_id FROM page_likes);


-- Unfinished Parts [Tesla SQL Interview Question]
-- parts_assembly(part, finish_date, assembly_step)
-- Assumptions:
-- parts_assembly table contains all parts currently in production, each at varying stages of the assembly process.
-- An unfinished part is one that lacks a finish_date.

-- Tesla is investigating production bottlenecks and they need your help to extract the relevant data. Write a query to determine which parts have begun the assembly process but are not yet finished.

SELECT part, assembly_step
FROM parts_assembly
WHERE finish_date IS NULL;


-- Laptop vs. Mobile Viewership [New York Times SQL Interview Question]
-- viewership(user_id, device_type, view_time)

-- Assume you're given the table on user viewership categorised by device type where the three types are laptop, tablet, and phone.
-- Write a query that calculates the total viewership for laptops and mobile devices where mobile is defined as the sum of tablet and phone viewership.
-- Output the total viewership for laptops as laptop_views and the total viewership for mobile devices as mobile_views.

SELECT
  COUNT(CASE WHEN device_type = 'laptop' THEN 1 ELSE NULL END) AS laptop_views,
  COUNT(CASE WHEN device_type IN ('tablet','phone') THEN 1 ELSE NULL END) AS mobile_views
FROM viewership


-- Average Post Hiatus (Part 1) [Facebook SQL Interview Question]
-- posts(user_id, post_id, post_content, post_date)

-- Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query to find the number of days between each user’s first post of the year and last post of the year in the year 2021.
-- Output the user and number of the days between each user's first and last post.

SELECT
  user_id,
  maxday - minday AS days_between
FROM (
        SELECT
            user_id,
            CAST(MIN(post_date) AS date) AS minday,
            CAST(MAX(post_date) AS date) AS maxday
        FROM posts
        WHERE DATE_PART('year',post_date) = '2021'
        GROUP BY user_id
        HAVING COUNT(post_id) > 1
     ) t


-- Teams Power Users [Microsoft SQL Interview Question]
-- messages(message_id, sender_id, receiver_id, content, sent_date)

-- Write a query to identify the top 2 Power Users who sent the highest number of messages on Microsoft Teams in August 2022. Display the IDs of these 2 users along with the total number of messages they sent.
-- Output the results in descending order based on the count of the messages.
-- Assumption: No two users have sent the same number of messages in August 2022.

SELECT
  sender_id,
  COUNT(message_id)
FROM messages
WHERE
     EXTRACT(MONTH FROM sent_date) = 8
 AND EXTRACT(YEAR FROM sent_date) = 2022
GROUP BY sender_id
ORDER BY COUNT(message_id) DESC
LIMIT 2


-- Duplicate Job Listings [Linkedin SQL Interview Question]
-- job_listings(job_id, company_id, title, description)

-- Write a query to retrieve the count of companies that have posted duplicate job listings.
-- Definition:-- Duplicate job listings are defined as two job listings within the same company that share identical titles and descriptions.

SELECT COUNT(company_id)
FROM(
        SELECT
             *,
             DENSE_RANK() OVER (PARTITION BY company_id, title, description ORDER BY job_id) AS rank1
         FROM job_listings
    ) t
WHERE rank1 > 1

-- OR

SELECT COUNT(company_id)
FROM(
        SELECT
             company_id,
             title,
             description
         FROM job_listings
         GROUP BY company_id, title, description
         HAVING COUNT(*) > 1
    ) t
    

-- Cities With Completed Trades [Robinhood SQL Interview Question]
-- trades(order_id, user_id, quantity, status, date, price)
-- users(user_id, city, email, signup_date)

-- Write a query to retrieve the top three cities that have the highest number of completed trade orders listed in descending order.
-- Output the city name and the corresponding number of completed trade orders.

SELECT
  city,
  COUNT(order_id) AS total_orders
FROM users u
INNER JOIN trades t ON u.user_id = t.user_id
WHERE status = 'Completed'
GROUP BY city
ORDER BY total_orders DESC
LIMIT 3


-- Average Review Ratings [Amazon SQL Interview Question]
-- reviews(review_id, user_id, submit_date, product_id, stars)

-- Write a query to retrieve the average star rating for each product, grouped by month.
-- The output should display the month as a numerical value, product ID, and average star rating rounded to two decimal places. 
-- Sort the output first by month and then by product ID.


SELECT
  EXTRACT(MONTH FROM submit_date) AS mth,
  product_id AS product,
  ROUND(AVG(stars),2) AS avg_stars
FROM reviews
GROUP BY EXTRACT(MONTH FROM submit_date), product
ORDER BY mth, product


-- App Click-through Rate (CTR) [Facebook SQL Interview Question]
-- events(app_id, event_type, timestamp)

-- Write a query to calculate the click-through rate (CTR) for the app in 2022 and round the results to 2 decimal places.
-- Definition and note: Percentage of click-through rate (CTR) = 100.0 * Number of clicks / Number of impressions
-- To avoid integer division, multiply the CTR by 100.0, not 100.

SELECT
  app_id,
  ROUND( 100.0*
         COUNT(CASE WHEN event_type = 'click' THEN 1 ELSE NULL END) / 
         COUNT(CASE WHEN event_type = 'impression' THEN 1 ELSE NULL END)
      ,2) AS ctr
FROM events
WHERE EXTRACT(YEAR FROM timestamp) = 2022
GROUP BY app_id


-- Second Day Confirmation [TikTok SQL Interview Question]
-- emails(email_id, user_id, signup_date)
-- text(text_id, email_id, signup_action, action_date)
-- Assume you're given tables with information about TikTok user sign-ups and confirmations through email and text.
-- New users on TikTok sign up using their email addresses, and upon sign-up, each user receives a text message confirmation to activate their account.

-- Write a query to display the user IDs of those who did not confirm their sign-up on the first day, but confirmed on the second day.

SELECT user_id
FROM(
    SELECT
      e.user_id,
      e.email_id,
      e.signup_date,
      t.text_id,
      t.signup_action,
      t.action_date,
      DENSE_RANK() OVER (PARTITION BY user_id ORDER BY action_date) AS rank1
    FROM emails e
    INNER JOIN texts t ON e.email_id = t.email_id
    ORDER BY user_id, email_id, signup_date, action_date
    ) t
WHERE rank1 = 2 AND signup_action = 'Confirmed'


-- IBM db2 Product Analytics [IBM SQL Interview Question]
-- queries(employee_id, query_id, query_start_time, execution_time)
-- employees(employee_id, full_name, gender)

-- IBM is analyzing how their employees are utilizing the Db2 database by tracking the SQL queries executed by their employees.
-- The objective is to generate data to populate a histogram that shows the number of unique queries run by employees during the third quarter of 2023 (July to September).
-- Additionally, it should count the number of employees who did not run any queries during this period.

-- Display the number of unique queries as histogram categories, along with the count of employees who executed that number of unique queries.

SELECT
  count_queries AS unique_queries,
  COUNT(employee_id) AS employee_count
FROM(
    SELECT
      e.employee_id,
      COUNT(DISTINCT query_id) AS count_queries -- counting on RIGHT table when doing LEFT JOIN will also count NULLS and display zero
    FROM employees e
    LEFT JOIN queries q ON e.employee_id = q.employee_id
    AND EXTRACT(MONTH FROM query_starttime) BETWEEN 7 and 9 -- apply time filter in ON, not WHERE, to keep NULLS and count them
    AND EXTRACT(YEAR FROM query_starttime) = 2023
    GROUP BY e.employee_id
    ) t
GROUP BY count_queries
ORDER BY unique_queries


-- Cards Issued Difference [JPMorgan Chase SQL Interview Question]
-- monthly_cards_issued(card_name, issued_amount, issue_month, issue_year)

-- Write a query that outputs:
-- the name of each credit card
-- the difference in the number of issued cards between the month with the highest issuance cards and the lowest issuance.
-- Arrange the results based on the largest disparity.

SELECT
  card_name,
  MAX(issued_amount) - MIN(issued_amount) AS difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC;


-- Compressed Mean [Alibaba SQL Interview Question]
-- items_per_order(item_count, order_occurrences)

-- Find the mean number of items per order on Alibaba
-- rounded to 1 decimal place 
-- using tables which includes information on the count of items in each order (item_count table) and the corresponding number of orders for each item count (order_occurrences table).

SELECT 
  ROUND(CAST(SUM(item_count * order_occurrences) / SUM(order_occurrences) AS DECIMAL),1) AS mean
FROM items_per_order;


-- Pharmacy Analytics (Part 1) [CVS Health SQL Interview Question]
-- pharmacy_sales(product_id, units_sold, total_sales, cogs, manufacturer, drug)

-- CVS Health is trying to better understand its pharmacy sales, and how well different products are selling. Each drug can only be produced by one manufacturer.
-- Definition:
-- cogs stands for Cost of Goods Sold which is the direct cost associated with producing the drug.
-- Total Profit = Total Sales - Cost of Goods Sold

-- Write a query to find the top 3 most profitable drugs sold, and how much profit they made. Assume that there are no ties in the profits. Display the result from the highest to the lowest total profit.

SELECT
  drug,
  SUM(total_sales - cogs) AS total_profit
FROM pharmacy_sales
GROUP BY drug
ORDER BY total_profit DESC
LIMIT 3;


-- Pharmacy Analytics (Part 2) [CVS Health SQL Interview Question]
-- Write a query to identify the manufacturers associated with the drugs that resulted in losses for CVS Health and calculate the total amount of losses incurred.
-- Output the manufacturer's name, the number of drugs associated with losses, and the total losses in absolute value. Display the results sorted in descending order with the highest losses displayed at the top.

SELECT
  manufacturer,
  COUNT(drug) AS drug_count,
  SUM(total_profit)* -1 AS total_loss
FROM(
        SELECT 
          manufacturer,
          drug,
          SUM(total_sales - cogs) AS total_profit
        FROM pharmacy_sales
        GROUP BY manufacturer, drug
        HAVING SUM(total_sales - cogs) < 0
    ) t
GROUP BY manufacturer
ORDER BY total_loss DESC;


-- Pharmacy Analytics (Part 3) [CVS Health SQL Interview Question]
-- Write a query to calculate the total drug sales for each manufacturer. Round the answer to the nearest million and report your results in descending order of total sales.
-- In case of any duplicates, sort them alphabetically by the manufacturer name.
-- Since this data will be displayed on a dashboard viewed by business stakeholders, please format your results as follows: "$36 million".

SELECT
  manufacturer,
  CONCAT('$',sales,' million') AS sales_mil
FROM (
        SELECT 
            manufacturer,
            ROUND(SUM(total_sales)/1000000) AS sales
        FROM pharmacy_sales
        GROUP BY manufacturer
        ORDER BY sales DESC, manufacturer DESC -- request is incorrect, does not accept ASC; needs DESC manufacturer
     )t;


-- Patient Support Analysis (Part 1) [UnitedHealth SQL Interview Question]
-- callers(policy_holder_id, case_id, call_category, call_date, call_duration_secs)

-- Write a query to find how many UHG policy holders made three, or more calls, assuming each call is identified by the case_id column.

SELECT
    COUNT(id) AS policy_holder_count
FROM (
        SELECT
            policy_holder_id AS id
        FROM callers
        GROUP BY policy_holder_id
        HAVING COUNT(case_id) >= 3
     ) t;
     

-- Who Made Quota? [Oracle SQL Interview Question]
-- deals(employee_id, deal_size)
-- sales_quotas(employee_id, quota)

-- Write a query that outputs each employee id and whether they hit the quota or not ('yes' or 'no'). Order the results by employee id in ascending order.
-- Definitions:
-- deal_size: Deals acquired by a salesperson in the year. Each salesperson may have more than 1 deal.
-- quota: Total annual quota for each salesperson.

SELECT
  employee_id,
  CASE
      WHEN sumdeal >= quota THEN 'yes'
      ELSE 'no'
  END AS made_quota
FROM (
        SELECT
          d.employee_id,
          d.sumdeal,
          s.quota
        FROM (
                SELECT
                  employee_id,
                  SUM(deal_size) AS sumdeal
                FROM deals
                GROUP BY employee_id
             ) d
        INNER JOIN sales_quotas s ON d.employee_id = s.employee_id
     ) t
ORDER BY employee_id

-- Simplified:

SELECT
  d.employee_id,
  CASE
      WHEN SUM(d.deal_size) >= s.quota THEN 'yes'
      ELSE 'no'
  END AS made_quota
FROM deals d
INNER JOIN sales_quotas s ON d.employee_id = s.employee_id
GROUP BY d.employee_id, s.quota
ORDER BY d.employee_id


-- Well Paid Employees [FAANG SQL Interview Question]
-- employee(employee_id, name, salary, department_id, manager_id)

-- Identify all employees who earn more than their direct managers. The result should include the employee's ID and name.

SELECT
    e1.employee_id,
    e1.name AS employee_name
FROM employee e1
LEFT JOIN employee e2 ON e1.manager_id = e2.employee_id
WHERE e1.salary > e2.salary