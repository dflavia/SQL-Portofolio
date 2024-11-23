-- 1378. Replace Employee ID With The Unique Identifier
-- employees(id, name)
-- employeeuni(id, unique_id)

-- Write a solution to show the unique ID of each user, If a user does not have a unique ID replace just show null.

SELECT unique_id, name
FROM employees
LEFT JOIN employeeuni ON employees.id = employeeuni.id;


-- 1068. Product Sales Analysis I
-- sales(sale_id, product_id, year, quantity, price)
-- product(product_id, product_name) 

-- Write a solution to report the product_name, year, and price for each sale_id in the Sales table.

SELECT product_name, year, price
FROM sales
INNER JOIN product ON sales.product_id = product.product_id


--1581. Customer Who Visited but Did Not Make Any Transactions
-- visits(visit_id, customer_id)
-- transactions(transaction_id, visit_id, amount)

-- Write a solution to find the IDs of the users who visited without making any transactions and the number of times they made these types of visits.

SELECT
    customer_id, COUNT(visit_id) AS count_no_trans
FROM visits
WHERE visit_id NOT IN (
                        SELECT visit_id
                        FROM transactions
                      )
GROUP BY customer_id;


-- 197. Rising Temperature
-- weather(id, record_date, temperature)

-- Write a solution to find all dates' Id with higher temperatures compared to its previous dates (yesterday).

SELECT id
FROM(
    SELECT 
        id,
        recorddate,
        LAG(recorddate,1) OVER (order by recorddate) prevday,
        temperature,
        LAG(temperature,1) OVER (ORDER BY recorddate) prevtemp
    FROM weather
    ) t
WHERE prevtemp < temperature
AND DATEDIFF(recorddate, prevday) = 1
;


-- 1661. Average Time of Process per Machine
-- activity(machine_id, process_id, activity_type, timestamp)

-- There is a factory website that has several machines each running the same number of processes.
-- Write a solution to find the average time each machine takes to complete a process.
-- The time to complete a process is the 'end' timestamp minus the 'start' timestamp.
-- The average time is calculated by the total time to complete every process on the machine divided by the number of processes that were run.
-- The resulting table should have the machine_id along with the average time as processing_time, which should be rounded to 3 decimal

SELECT
    machine_id,
    ROUND(AVG(timestamp - prevtime),3) AS processing_time
FROM (
        SELECT
            *,
            LAG(timestamp) OVER (PARTITION BY machine_id, process_id ORDER BY activity_type) AS prevtime
        FROM activity
) t1
GROUP BY machine_id


-- 577. Employee Bonus
-- employee(empid, name, supervisor, salary)
-- bonus(empid, bonus)

-- Write a solution to report the name and bonus amount of each employee with a bonus less than 1000.

SELECT name, bonus
FROM employee e
LEFT JOIN bonus b ON e.empid = b.empid
WHERE IFNULL(bonus,0) < 1000


-- 1280. Students and Examinations
-- students( student_id, student_name)
-- subjects(subject_name)
-- examinations(student_id, subject_name)
-- Each student from the Students table takes every course from the Subjects table.

-- Write a solution to find the number of times each student attended each exam.

SELECT
    s.student_id,
    s.student_name,
    sub.subject_name,
    COUNT(e.subject_name) AS attended_exams
FROM students AS s
CROSS JOIN subjects AS sub -- cartesian product, matches every student with every subject
LEFT JOIN examinations AS e ON s.student_id = e.student_id AND e.subject_name = sub.subject_name
GROUP BY s.student_id, s.student_name, sub.subject_name
ORDER BY s.student_id, sub.subject_name


-- 570. Managers with at Least 5 Direct Reports
-- employee(id, name, department, managerid)
-- If managerId is null, then the employee does not have a manager.
-- No employee will be the manager of themself.

-- Write a solution to find managers with at least five direct reports.

SELECT name
FROM employee
WHERE id IN (
             SELECT managerid
             FROM employee
             GROUP BY managerid
             HAVING COUNT(managerid)>=5
            )

-- OR

SELECT
    e1.name
FROM employee e1
INNER JOIN employee e2
    ON e1.id = e2.managerid
GROUP BY e2.managerid
HAVING COUNT(e2.managerid) >= 5
            


-- 1934. Confirmation Rate
-- signups(user_id, time_stamp)
-- confirmations(user_id, time_stamp, action)
-- action is an ENUM (category) of the type ('confirmed', 'timeout')

-- The confirmation rate of a user is the number of 'confirmed' messages divided by the total number of requested confirmation messages.
-- The confirmation rate of a user that did not request any confirmation messages is 0. Round the confirmation rate to two decimal places.
-- Write a solution to find the confirmation rate of each user.

SELECT s.user_id,
 COALESCE(ROUND(SUM(CASE WHEN action = 'timeout' THEN 0 ELSE 1 END)/ COUNT(action),2),0) AS confirmation_rate
FROM signups s
LEFT JOIN confirmations c ON s.user_id = c.user_id
GROUP BY user_id