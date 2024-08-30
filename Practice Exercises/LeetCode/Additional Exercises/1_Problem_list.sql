-- https://leetcode.com/problem-list/e97a9e5m/

-- 1407. Top Travellers
-- users(id, name)
-- rides(id, user_id, distance)

-- Write a solution to report the distance traveled by each user.
-- Return the result table ordered by travelled_distance in descending order, if two or more users traveled the same distance, order them by their name in ascending order.

SELECT
    name,
    COALESCE(SUM(distance),0) AS travelled_distance
FROM users u
LEFT JOIN rides r ON u.id = r.user_id
GROUP BY u.id, name -- GROUP BY Id too to cover test cases with different people but same name
ORDER BY travelled_distance DESC, name


-- 1084. Sales Analysis III
-- product)propduct_id, product_name, unit_price)
-- sales(seller_id, product_id, buyer_id, sale_date, quantity, price)

-- Write a solution to report the products that were only sold in the first quarter of 2019. That is, between 2019-01-01 and 2019-03-31 inclusive.

SELECT
    DISTINCT s.product_id,
    p.product_name
FROM product p
INNER JOIN sales s ON p.product_id = s.product_id
WHERE s.product_id NOT IN (
                           SELECT product_id
                           FROM sales
                           WHERE sale_date NOT BETWEEN '2019-01-01' AND '2019-03-31'
                          )

-- sale_date NOT BETWEEN finds period that we are not interested in
-- product_id NOT IN takes out products sold in that unwanted period; query will return only products sold BETWEEN '2019-01-01' AND '2019-03-31'


-- 1179. Reformat Department Table
-- Department(id, revenue, month)
-- The table has information about the revenue of each department per month.
-- The month has values in ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"].

-- Reformat the table such that there is a department id column and a revenue column for each month.

SELECT
    id,
    SUM(CASE WHEN month = 'Jan' THEN revenue END) AS 'Jan_Revenue',
    SUM(CASE WHEN month = 'Feb' THEN revenue END) AS 'Feb_Revenue',
    SUM(CASE WHEN month = 'Mar' THEN revenue END) AS 'Mar_Revenue',
    SUM(CASE WHEN month = 'Apr' THEN revenue END) AS 'Apr_Revenue',
    SUM(CASE WHEN month = 'May' THEN revenue END) AS 'May_Revenue',
    SUM(CASE WHEN month = 'Jun' THEN revenue END) AS 'Jun_Revenue',
    SUM(CASE WHEN month = 'Jul' THEN revenue END) AS 'Jul_Revenue',
    SUM(CASE WHEN month = 'Aug' THEN revenue END) AS 'Aug_Revenue',
    SUM(CASE WHEN month = 'Sep' THEN revenue END) AS 'Sep_Revenue',
    SUM(CASE WHEN month = 'Oct' THEN revenue END) AS 'Oct_Revenue',
    SUM(CASE WHEN month = 'Nov' THEN revenue END) AS 'Nov_Revenue',
    SUM(CASE WHEN month = 'Dec' THEN revenue END) AS 'Dec_Revenue'
FROM department
GROUP BY id


-- 511. Game Play Analysis I
-- activity(player_id, device_id, event_date, games_played)
-- Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on someday using some device.

-- Write a solution to find the first login date for each player.

SELECT
    player_id,
    MIN(event_date) AS first_login
FROM activity
GROUP BY player_id


-- 1795. Rearrange Products Table
-- products(product_id, store1, store2, store3)

-- Each row in this table indicates the product's price in 3 different stores: store1, store2, and store3.
-- If the product is not available in a store, the price will be null in that store's column.

SELECT *
FROM (

        SELECT
            product_id,
            'store1' AS store,
            store1 AS price
        FROM products
        
        UNION
        
        SELECT
            product_id,
            'store2' AS store,
            store2 AS price
        FROM products
        
        UNION
        
        SELECT
            product_id,
            'store3' AS store,
            store3 AS price
        FROM products
     ) t
WHERE price IS NOT NULL -- If a product is not available in a store, do not include the row


-- 1693. Daily Leads and Partners
-- dailysales(date_id, make_name, lead_id, partner_id)

-- For each date_id and make_name, find the number of distinct lead_id's and distinct partner_id's.

SELECT
    date_id,
    make_name,
    COUNT(DISTINCT lead_id) AS unique_leads,
    COUNT(DISTINCT partner_id) AS unique_partners
FROM dailysales
GROUP BY date_id, make_name


-- 175. Combine Two Tables
-- person(personid, lastname, firstname)
-- address(addressid, personid, city, state)

-- Write a solution to report the first name, last name, city, and state of each person in the Person table.
-- If the address of a personId is not present in the Address table, report null instead.

SELECT
    firstname,
    lastname,
    city,
    state
FROM person p
LEFT JOIN address a ON p.personid = a.personid


-- 178. Rank Scores
-- scores(id, score)

-- Write a solution to find the rank of the scores. The ranking should be calculated according to the following rules:
-- The scores should be ranked from the highest to the lowest.
-- If there is a tie between two scores, both should have the same ranking.
-- After a tie, the next ranking number should be the next consecutive integer value. In other words, there should be no holes between ranks.
-- Return the result table ordered by score in descending order.

SELECT
    score,
    DENSE_RANK() OVER (ORDER BY score DESC) AS 'rank'
FROM scores


-- 181. Employees Earning More Than Their Managers
-- employee(id, name, salary, managerid)

-- Write a solution to find the employees who earn more than their managers.

SELECT
    e.name AS employee
FROM employee e
INNER JOIN employee m ON e.managerid = m.id
WHERE e.salary > m.salary


-- 182. Duplicate Emails
-- person(id, email)

-- Write a solution to report all the duplicate emails. Note that it's guaranteed that the email field is not NULL.

SELECT
    email
FROM person
GROUP BY email
HAVING COUNT(email) >1


-- 183. Customers Who Never Order
-- customers(id, name)
-- orders(id, customerid)

-- Write a solution to find all customers who never order anything.

SELECT name AS customers
FROM customers
WHERE id NOT IN (
                    SELECT customerid
                    FROM orders
                )


-- 184. Department Highest Salary
-- employee(id, name, salary, departmentid)
-- department(id, name)

-- Write a solution to find employees who have the highest salary in each of the departments.

SELECT
    d.name AS department,
    e.name AS employee,
    e.salary
FROM department d
INNER JOIN employee e ON d.id = e.departmentid
WHERE (departmentid, salary) IN
                                (
                                    SELECT
                                        departmentid,
                                        MAX(salary)
                                    FROM employee
                                    GROUP BY departmentid
                                )


-- 1965. Employees With Missing Information
-- employees(employee_id, name)
-- salaries(employee_id, salary

-- Write a solution to report the IDs of all the employees with missing information. The information of an employee is missing if:
-- The employee's name is missing, or
-- The employee's salary is missing.
-- Return the result table ordered by employee_id in ascending order.

SELECT employee_id
FROM(
        
            SELECT e.employee_id
            FROM employees e
            LEFT JOIN salaries s ON e.employee_id = s.employee_id
            WHERE salary IS NULL
            
            UNION
        
            SELECT s.employee_id
            FROM salaries s
            LEFT JOIN employees e ON e.employee_id = s.employee_id
            WHERE name IS NULL
        
    ) t
ORDER BY employee_id


-- 1587. Bank Account Summary II
-- users(account, name)
-- transactions(trans_id, account, amount, transacted_on)

-- Write a solution to report the name and balance of users with a balance higher than 10000.
-- The balance of an account is equal to the sum of the amounts of all transactions involving that account.

SELECT
    name,
    SUM(amount) AS balance
FROM users u
INNER JOIN transactions t ON u.account = t.account
GROUP BY name
HAVING SUM(amount) >  10000


-- 601. Human Traffic of Stadium
-- stadium(id, visit_date, people)

-- Write a solution to display the records with three or more rows with consecutive id's, and the number of people is greater than or equal to 100 for each.
-- Return the result table ordered by visit_date in ascending order.

SELECT
    id,
    visit_date,
    people
FROM (
    SELECT
        *,
        COUNT(rowdiff1) OVER (PARTITION BY rowdiff1) AS count1 -- count consecutive rows
    FROM (
         SELECT
            id,
            visit_date,
            people,
            ROW_NUMBER() OVER(ORDER BY visit_date) AS rownum1,
            id - ROW_NUMBER() OVER(ORDER BY visit_date) AS rowdiff1 -- check if consecutive rows
         FROM Stadium
         WHERE people >= 100
         ) t1
    ORDER BY id
     ) t2
WHERE count1 >= 3


-- 607. Sales Person
-- salesperson(sales_id, name, salary, commision_rate, hire_date)
-- company(com_id, name, city)
-- orders(order_id, order_date, com_id, sales_id, amount)

-- Write a solution to find the names of all the salespersons who did not have any orders related to the company with the name "RED".

SELECT name
FROM salesperson s
WHERE sales_id NOT IN (
                        SELECT sales_id
                        FROM orders
                        WHERE com_id IN (SELECT com_id FROM company WHERE name = 'RED')
                      )


-- 586. Customer Placing the Largest Number of Orders
-- orders(order_number, customer_number)

-- Write a solution to find the customer_number for the customer who has placed the largest number of orders.
-- The test cases are generated so that exactly one customer will have placed more orders than any other customer.

SELECT customer_number
FROM orders
GROUP BY customer_number
HAVING COUNT(order_number) =
                        (
                            SELECT MAX(count1)
                            FROM (
                                    SELECT customer_number, COUNT(order_number) AS count1
                                    FROM orders
                                    GROUP BY customer_number
                                 ) t
                        ) 


-- 608. Tree Node
-- tree(id, p_id)

-- Each node in the tree can be one of three types:
-- "Leaf": if the node is a leaf node.
-- "Root": if the node is the root of the tree.
-- "Inner": If the node is neither a leaf node nor a root node.
-- Write a solution to report the type of each node in the tree.

SELECT
    id,
    CASE
        WHEN p_id IS NULL THEN 'Root'
        WHEN id IN (SELECT p_id FROM tree) THEN 'Inner'
        ELSE 'Leaf'
        END AS type
FROM tree

-- OR

SELECT
    id,
    CASE
        WHEN p_id IS NULL THEN 'Root'
        WHEN id NOT IN (SELECT p_id FROM tree WHERE p_id IS NOT NULL) THEN 'Leaf'
        ELSE 'Inner'
        END AS type
FROM tree


-- 1741. Find Total Time Spent by Each Employee
-- employees(emp_id, event_day, in_time, out_time)
-- The table shows the employees' entries and exits in an office.
-- event_day is the day at which this event happened
-- in_time is the minute at which the employee entered the office
-- out_time is the minute at which they left the office.
-- in_time and out_time are between 1 and 1440.
-- It is guaranteed that no two events on the same day intersect in time, and in_time < out_time.

-- Write a solution to calculate the total time in minutes spent by each employee on each day at the office.
-- Note that within one day, an employee can enter and leave more than once. The time spent in the office for a single entry is out_time - in_time.

SELECT
    event_day AS day,
    emp_id,
    SUM(out_time - in_time) AS total_time
FROM employees
GROUP BY day, emp_id


-- 1873. Calculate Special Bonus
-- employees(employee_id, name, salary)

-- Write a solution to calculate the bonus of each employee.
-- The bonus of an employee is 100% of their salary if the ID of the employee is an odd number and the employee's name does not start with the character 'M'.
-- The bonus of an employee is 0 otherwise.
-- Return the result table ordered by employee_id.

SELECT
    employee_id,
    CASE
        WHEN MOD(employee_id,2) <> 0 AND LEFT(name,1) <> 'M'
            THEN salary
        ELSE 0
    END AS bonus
FROM employees
ORDER BY employee_id


-- 1050. Actors and Directors Who Cooperated At Least Three Times
-- actordirector(actor_id, director_id, timestamp)

-- Write a solution to find all the pairs (actor_id, director_id) where the actor has cooperated with the director at least three times.

SELECT actor_id, director_id
FROM actordirector
GROUP BY actor_id, director_id
HAVING COUNT(*) > 2


-- 627. Swap Salary
-- salary(id, name, sex, salary)

-- Write a solution to swap all 'f' and 'm' values (i.e., change all 'f' values to 'm' and vice versa) with a single update statement and no intermediate temporary tables.
-- Note that you must write a single update statement, do not write any select statement for this problem.

UPDATE salary
SET sex = CASE
                WHEN sex = 'f' THEN 'm'
                WHEN sex ='m' THEN 'f'
          END


-- 1158. Market Analysis I
-- users(user_id, join_date, favorite_brand)
-- orders(order_id, order_date, item_id, buyer_id, seller_id)
-- items(item_id, item_brand)
-- buyer_id and seller_id are foreign keys to the Users table.

-- Write a solution to find for each user, the join date and the number of orders they made as a buyer in 2019.

SELECT
    user_id AS buyer_id,
    join_date,
    COUNT(buyer_id) AS orders_in_2019
FROM users u
LEFT JOIN orders o ON u.user_id = o.buyer_id AND YEAR(order_date) = '2019' -- records not matching 2019 will return '0', as requested
GROUP BY user_id, join_date


-- 1393. Capital Gain/Loss
-- stocks(stock_name, operation, operation_day
-- The operation column is an ENUM (category) of type ('Sell', 'Buy')
-- Each row of this table indicates that the stock which has stock_name had an operation on the day operation_day with the price.
-- It is guaranteed that each 'Sell' operation for a stock has a corresponding 'Buy' operation in a previous day.
-- It is also guaranteed that each 'Buy' operation for a stock has a corresponding 'Sell' operation in an upcoming day.

-- Write a solution to report the Capital gain/loss for each stock.
-- The Capital gain/loss of a stock is the total gain or loss after buying and selling the stock one or many times.

SELECT
    stock_name,
    SUM(CASE WHEN operation = 'Sell' THEN price ELSE - price END) AS capital_gain_loss
FROM stocks
GROUP BY stock_name


-- 1890. The Latest Login in 2020
-- logins(user_id, time_stamp)

-- Write a solution to report the latest login for all users in the year 2020. Do not include the users who did not login in 2020.

SELECT
    user_id,
    MAX(time_stamp) AS last_stamp
FROM logins
WHERE YEAR(time_stamp) = '2020'
GROUP BY user_id


-- 262. Trips and Users
-- trips(id, client_id, driver_id, city_id, status, request_at)
-- The table holds all taxi trips. Each trip has a unique id, while client_id and driver_id are foreign keys to the users_id at the Users table.
-- Status is an ENUM (category) type of ('completed', 'cancelled_by_driver', 'cancelled_by_client').

-- users(user_id, banned, role)
-- The table holds all users. Each user has a unique users_id, and role is an ENUM type of ('client', 'driver', 'partner').
-- banned is an ENUM (category) type of ('Yes', 'No').

-- The cancellation rate = dividing the number of canceled (by client or driver) requests with unbanned users by the total number of requests with unbanned users on that day.
-- Write a solution to find the cancellation rate of requests with unbanned users (both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03".
-- Round Cancellation Rate to two decimal points.

SELECT
    request_at AS day,
    ROUND(COUNT(CASE WHEN status <> 'completed' THEN 1 ELSE NULL END) / COUNT(*),2) AS 'cancellation rate'
FROM trips
WHERE client_id NOT IN (SELECT users_id
                        FROM users
                        WHERE banned = 'Yes')
  AND driver_id NOT IN (SELECT users_id
                        FROM users
                        WHERE banned = 'Yes')
  AND request_at BETWEEN '2013-10-01' AND '2013-10-03'
GROUP BY request_at