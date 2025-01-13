-- 2356. Number of Unique Subjects Taught by Each Teacher
-- teacher(teacher_id, subject_id, dept_id)

-- Write a solution to calculate the number of unique subjects each teacher teaches in the university.

SELECT
    teacher_id,
    COUNT(DISTINCT subject_id) AS cnt
FROM teacher
GROUP BY teacher_id


-- 1141. User Activity for the Past 30 Days I
-- activity(user_id, session_id, activity_date, activity_type)
-- The activity_type column is an ENUM (category) of type ('open_session', 'end_session', 'scroll_down', 'send_message').

-- Write a solution to find the daily active user count for a period of 30 days ending 2019-07-27 inclusively.
-- A user was active on someday if they made at least one activity on that day.

SELECT
    activity_date AS day,
    COUNT(DISTINCT user_id) AS active_users
FROM activity
WHERE DATEDIFF('2019-07-27',activity_date) BETWEEN 0 AND 29
GROUP BY activity_date
ORDER BY activity_date

-- OR

SELECT
    activity_date AS day,
    COUNT(DISTINCT user_id) AS active_users
FROM activity
WHERE activity_date BETWEEN DATE_SUB('2019-07-27', INTERVAL 29 DAY) AND '2019-07-27'
GROUP BY activity_date
ORDER BY 1


-- 1070. Product Sales Analysis III
-- sales(sale_id, product_id, year, quantity, price)
-- product(product_id, product_name) 

-- Write a solution to select the product id, year, quantity, and price for the first year of every product sold.

SELECT
    product_id,
    year AS first_year,
    quantity,
    price
FROM sales
WHERE (product_id, year) IN (
                                SELECT product_id, MIN(year)
                                FROM sales
                                GROUP BY product_id
                            )


-- 596. Classes More Than 5 Students
-- courses(student, class)

-- Write a solution to find all the classes that have at least five students.

SELECT class
FROM courses
GROUP by class
HAVING COUNT(*) >= 5


-- 1729. Find Followers Count
-- followers(user_id, follower_id)

-- Write a solution that will, for each user, return the number of followers.
-- Return the result table ordered by user_id in ascending order.

SELECT
    user_id,
    COUNT(*) AS followers_count
FROM followers
GROUP BY user_id
ORDER BY user_id


-- 619. Biggest Single Number
-- mynumbers(num)

-- A single number is a number that appeared only once in the MyNumbers table.
-- Find the largest single number. If there is no single number, report null.

SELECT MAX(num) AS num
FROM(
    SELECT num
    FROM(
        SELECT
            num,
            ROW_NUMBER() OVER (PARTITION BY num ORDER BY num) AS rownum1
        FROM mynumbers
        ) t1
    GROUP BY num
    HAVING MAX(rownum1) = 1
) t2

-- OR

SELECT MAX(num) AS num
FROM (
        SELECT num
        FROM mynumbers
        GROUP BY num
        HAVING COUNT(num) = 1
     ) t


-- 1045. Customers Who Bought All Products
-- customer(customer_id, product_key)
-- product(product_key)

-- Write a solution to report the customer ids from the Customer table that bought all the products in the Product table.

SELECT customer_id
FROM customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(DISTINCT product_key) FROM product)