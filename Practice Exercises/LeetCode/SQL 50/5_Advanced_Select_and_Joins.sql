-- 1731. The Number of Employees Which Report to Each Employee
-- employees(employee_id, name, reports_to, age)

-- Write a solution to report the ids and the names of all managers, the number of employees who report directly to them, and the average age of the reports rounded to the nearest integer.
-- Return the result table ordered by employee_id.

SELECT 
    e1.reports_to AS employee_id,
    e2.name,
    COUNT(e1.reports_to) AS reports_count,
    ROUND(AVG(e1.age)) AS average_age
FROM employees e1
INNER JOIN employees e2 ON e1.reports_to = e2.employee_id
WHERE e1.reports_to IS NOT NULL
GROUP BY e1.reports_to
ORDER BY e1.reports_to

-- OR

SELECT
    e.employee_id,
    e.name,
    T.reports_count,
    T.average_age
FROM employees e
INNER JOIN 

        (SELECT
            reports_to,
            COUNT(reports_to) AS reports_count,
            ROUND(AVG(age)) AS average_age
        FROM employees
        WHERE reports_to IS NOT NULL
        GROUP BY reports_to) AS T

        ON e.employee_id = T.reports_to

ORDER BY employee_id



-- 1789. Primary Department for Each Employee
-- employee(employee_id, department_id, primary_flag)
-- primary_flag is an ENUM (category) of type ('Y', 'N').
-- If the flag is 'Y', the department is the primary department for the employee.
-- If the flag is 'N', the department is not the primary.
-- Employees can belong to multiple departments. When the employee joins other departments, they need to decide which department is their primary department.
-- Note that when an employee belongs to only one department, their primary column is 'N'.

-- Write a solution to report all the employees with their primary department. For employees who belong to one department, report their only department.

SELECT employee_id, department_id
FROM employee
WHERE
        primary_flag = 'Y'
    OR  employee_id IN (
                        SELECT employee_id
                        FROM employee
                        GROUP BY employee_id
                        HAVING COUNT(employee_id) = 1
                        )


-- 610. Triangle Judgement
-- triangle(x, y, z)
-- Report for every three line segments whether they can form a triangle.

SELECT
    x,
    y,
    z,
    CASE
        WHEN x + y <= z
          OR x + z <= y
          OR y + z <= x
        THEN 'No'
        ELSE 'Yes'
    END AS 'triangle'
FROM triangle


-- 180. Consecutive Numbers
-- logs(id, num)
-- Find all numbers that appear at least three times consecutively.

SELECT DISTINCT num AS consecutivenums
FROM(
SELECT
    *,
    LAG(num) OVER (PARTITION BY NULL ORDER BY id) AS prevnum,
    LEAD(num) OVER (PARTITION BY NULL ORDER BY id) AS nextnum,
    (id - LAG(id) OVER (PARTITION BY NULL ORDER BY id)) AS previd,
    (LEAD(id) OVER (PARTITION BY NULL ORDER BY id) - id) AS nextid
FROM logs
) t
WHERE num = prevnum
AND num = nextnum -- ensure the number is the same on at least 3 rows
AND previd = nextid -- ensure that the ids are also consecutive, to cover all test cases


-- 1164. Product Price at a Given Date
-- products(product_id, new_price, change_date)

-- Write a solution to find the prices of all products on 2019-08-16. Assume the price of all products before any change is 10.

SELECT product_id, new_price AS price
FROM products
WHERE (product_id, change_date) IN (SELECT product_id, MAX(change_date)
                                  FROM products
                                  WHERE change_date <= '2019-08-16'
                                  GROUP BY product_id)
UNION
SELECT product_id, 10
FROM products
GROUP BY product_id
HAVING MIN(change_date) > '2019-08-16'
ORDER BY product_id


-- 1204. Last Person to Fit in the Bus
-- queue(person_id, person_name, weight, turn)
-- turn determines the order of which the people will board the bus, where turn=1 denotes the first person to board and turn=n denotes the last person to board.
-- There is a queue of people waiting to board a bus. However, the bus has a weight limit of 1000 kilograms, so there may be some people who cannot board.

-- Write a solution to find the person_name of the last person that can fit on the bus without exceeding the weight limit.
-- The test cases are generated such that the first person does not exceed the weight limit.

SELECT person_name
FROM queue
WHERE turn IN (SELECT MAX(turn)
               FROM (
                        SELECT
                             person_name,
                             turn,
                             SUM(weight) OVER (PARTITION BY NULL ORDER BY turn) AS total_weight
                        FROM queue
                     ) t1
               WHERE total_weight <= 1000)


-- 1907. Count Salary Categories
-- accounts(account_id, income)

-- Write a solution to calculate the number of bank accounts for each salary category. The salary categories are:
-- "Low Salary": All the salaries strictly less than $20000.
-- "Average Salary": All the salaries in the inclusive range [$20000, $50000].
-- "High Salary": All the salaries strictly greater than $50000.
-- The result table must contain all three categories. If there are no accounts in a category, return 0.

SELECT
    'Low Salary' AS category,
    COUNT(account_id) AS accounts_count
FROM accounts
WHERE income < 20000
UNION
SELECT
    'Average Salary' AS category,
    COUNT(account_id) AS accounts_count
FROM accounts
WHERE income BETWEEN 20000 AND 50000
UNION
SELECT
    'High Salary' AS category,
    COUNT(account_id) AS accounts_count
FROM accounts
WHERE income > 50000