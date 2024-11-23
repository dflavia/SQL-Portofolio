-- 1978. Employees Whose Manager Left the Company
-- employees(employee_id, name, manager_id, salary)

-- Find the IDs of the employees whose salary is strictly less than $30000 and whose manager left the company.
-- When a manager leaves the company, their information is deleted from the Employees table, but the reports still have their manager_id set to the manager that left.
-- Return the result table ordered by employee_id.

SELECT employee_id
FROM employees
WHERE salary < 30000
AND manager_id NOT IN (SELECT employee_id FROM employees)
ORDER BY employee_id


-- 626. Exchange Seats
-- seat(id, student)

-- Write a solution to swap the seat id of every two consecutive students. If the number of students is odd, the id of the last student is not swapped.
-- Return the result table ordered by id in ascending order.

SELECT 
    CASE
        WHEN id = (SELECT MAX(id) FROM seat) AND MOD(id,2) <> 0 -- keep last odd id the same
            THEN id
        WHEN MOD(id,2) <> 0 
            THEN id + 1 -- swap ids
        WHEN MOD(id,2) = 0
            THEN id - 1 -- swap ids
        END AS id,
    student
FROM seat
ORDER BY id


-- 1341. Movie Rating
-- movies(movie_id, title)
-- users(user_id, name)
-- movierating(movie_id, user_id, rating, created_at)

-- Find the name of the user who has rated the greatest number of movies. In case of a tie, return the lexicographically smaller user name.
-- Find the movie name with the highest average rating in February 2020. In case of a tie, return the lexicographically smaller movie name.

SELECT name AS results
FROM(
SELECT u.user_id, name, COUNT(mr.user_id) AS reviews_count
FROM movierating mr
INNER JOIN users u ON mr.user_id = u.user_id
GROUP BY u.user_id
ORDER BY reviews_count DESC, name
LIMIT 1) t1

UNION ALL -- to cover also Rebecca test cases where user name = movie title

SELECT title AS results
FROM (
SELECT m.movie_id, title, AVG(rating) as rating
FROM movierating mr
INNER JOIN movies m ON mr.movie_id = m.movie_id
WHERE DATE_FORMAT(created_at, '%Y-%M') = '2020-February'
GROUP BY movie_id
ORDER BY rating DESC, title
LIMIT 1) t2


-- 1321. Restaurant Growth
-- customer(customer_id, name, visited_on, amount)

-- Compute the moving average of how much the customer paid in a seven days window (i.e., current day + 6 days before). average_amount should be rounded to two decimal places.
-- Return the result table ordered by visited_on in ascending order.

SELECT
     visited_on,
     amount,
     average_amount
FROM (
        SELECT
            DATE_ADD(original_date, INTERVAL 6 DAY) AS visited_on,
            SUM(total_amount_per_day) OVER(ORDER BY original_date ROWS BETWEEN CURRENT ROW AND 6 FOLLOWING) AS amount,
            ROUND(AVG(total_amount_per_day) OVER(ORDER BY original_date ROWS BETWEEN CURRENT ROW AND 6 FOLLOWING),2) AS average_amount
        FROM (
                SELECT
                    visited_on AS original_date,
                    SUM(amount) AS total_amount_per_day
                FROM customer
                GROUP BY visited_on
             ) t1 -- aggregate amounts in case of duplicate days, needed for window functions above
     ) t2
WHERE visited_on <= (SELECT MAX(visited_on) FROM customer) -- ensure only 7 days window calculations, not lower than 7


-- 602. Friend Requests II: Who Has the Most Friends
-- requestaccepted(requester_id, accepter_id, accept_date)

-- Write a solution to find the people who have the most friends and the most friends number.
-- The test cases are generated so that only one person has the most friends.

SELECT
    requester_id AS id,
    COUNT(requester_id) AS num
FROM(
    SELECT requester_id
    FROM requestaccepted
    
    UNION ALL
    
    SELECT accepter_id
    FROM requestaccepted
    ) t
GROUP BY requester_id
ORDER BY COUNT(requester_id) DESC
LIMIT 1


-- 585. Investments in 2016
-- insurance(pid, tiv_2015, tiv_2016, lat, lon)

-- Write a solution to report the sum of all total investment values in 2016 tiv_2016, for all policyholders who:
-- have the same tiv_2015 value as one or more other policyholders, and
-- are not located in the same city as any other policyholder (i.e., the (lat, lon) attribute pairs must be unique).
-- Round tiv_2016 to two decimal places.

SELECT ROUND(SUM(tiv_2016),2) AS tiv_2016
FROM insurance
WHERE tiv_2015 IN (
                    SELECT tiv_2015
                    FROM insurance
                    GROUP BY tiv_2015
                    HAVING COUNT(tiv_2015) > 1)
AND (lat, lon) IN (SELECT lat, lon
                   FROM insurance
                   GROUP BY lat, lon
                   HAVING COUNT(*) = 1)


-- 185. Department Top Three Salaries
-- employee(id, name, salary, departmentid)
-- department(id, name)

-- A company's executives are interested in seeing who earns the most money in each of the company's departments.
-- A high earner in a department is an employee who has a salary in the top three unique salaries for that department.
-- Write a solution to find the employees who are high earners in each of the departments.

SELECT Department, Employee, Salary
FROM(
        SELECT
             d.name AS Department,
             e.name AS Employee,
             e.salary AS Salary,
             DENSE_RANK() OVER (PARTITION BY d.name ORDER BY e.salary DESC) AS rank1
        FROM employee e
        INNER JOIN department d ON e.departmentid = d.id
    ) t1
WHERE rank1 <= 3