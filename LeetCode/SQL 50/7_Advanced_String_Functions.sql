-- 1667. Fix Names in a Table
-- users(user_id, name)

-- Write a solution to fix the names so that only the first character is uppercase and the rest are lowercase.
-- Return the result table ordered by user_id.

SELECT
    user_id,
    CONCAT(UPPER(LEFT(name,1)), LOWER(SUBSTRING(name,2))) AS name
FROM users
ORDER BY user_id


-- 1527. Patients With a Condition
-- patients(petient_id, patient_name, conditions)

-- Write a solution to find the patient_id, patient_name, and conditions of the patients who have Type I Diabetes. Type I Diabetes always starts with DIAB1 prefix.

SELECT *
FROM patients
WHERE conditions LIKE '% DIAB1%' -- to cover all test cases
   OR conditions LIKE 'DIAB1%'
   

-- 196. Delete Duplicate Emails
-- person(id, email)

-- Write a solution to delete all duplicate emails, keeping only one unique email with the smallest id.

DELETE FROM person
WHERE id NOT IN(
                SELECT id
                FROM(
                    SELECT
                        *,
                        ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS rownum1
                    FROM person
                    ) t
                WHERE rownum1 = 1
               )


-- 176. Second Highest Salary
-- employee(id, salary)

-- Write a solution to find the second highest salary from the Employee table. If there is no second highest salary, return null (return None in Pandas).

SELECT
    CASE
        WHEN COUNT(*) >= 2
            THEN (
                  SELECT DISTINCT salary
                  FROM(
                      SELECT
                          *,
                          DENSE_RANK() OVER (PARTITION BY NULL ORDER BY salary DESC) AS rank1
                      FROM employee
                      ) t
                  WHERE rank1 = 2)
        ELSE NULL
    END AS SecondHighestSalary
FROM employee


-- 1484. Group Sold Products By The Date
-- activities(sell_date, product)

-- Write a solution to find for each date the number of different products sold and their names.
-- The sold products names for each date should be sorted lexicographically.
-- Return the result table ordered by sell_date.

SELECT
    sell_date,
    COUNT(DISTINCT product) AS num_sold,
    GROUP_CONCAT(DISTINCT product) AS products
FROM activities
GROUP BY sell_date


-- 1327. List the Products Ordered in a Period
-- products(product_id, product_name, product_category)
-- orders(product_id, order_date, unit)

-- Write a solution to get the names of products that have at least 100 units ordered in February 2020 and their amount.

SELECT
    product_name,
    SUM(unit) AS unit
FROM products p
INNER JOIN orders o ON p.product_id = o.product_id
WHERE DATE_FORMAT(order_date, '%Y-%M') = '2020-February'
GROUP BY product_name
HAVING SUM(unit) >= 100


-- 1517. Find Users With Valid E-Mails
-- users(user_id, name, mail)

-- Write a solution to find the users who have valid emails.
--A valid e-mail has a prefix name and a domain where:
-- The prefix name is a string that may contain letters (upper or lower case), digits, underscore '_', period '.', and/or dash '-'. The prefix name must start with a letter.
-- The domain is '@leetcode.com'.

SELECT user_id, name, mail
FROM users
WHERE mail REGEXP '^[a-zA-Z][a-zA-Z0-9_.-]*@leetcode\\.com$';

-- ^ start of string
-- [a-zA-Z] first character must be letter
-- [a-zA-Z0-9_.-] following allowed characters
-- * zero or more of the preceding characters will be allowed; pattern can match zero/ more combinations of specified characters [a-zA-Z0-9_.-]
-- \\ needed next to . because period is a wildcard character that matches any single character; to match a literal period, need to escape with backslash \ or \\
-- $ end of string