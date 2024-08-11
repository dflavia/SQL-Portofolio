-- Type of Triangle
-- Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table:
-- Equilateral: It's a triangle with  sides of equal length.
-- Isosceles: It's a triangle with  sides of equal length.
-- Scalene: It's a triangle with  sides of differing lengths.
-- Not A Triangle: The given values of A, B, and C don't form a triangle.

--triangles(A, B, C)

SELECT
        CASE
                WHEN A+B <= C OR A+C <= B OR B+C <=A
                            THEN 'Not A Triangle'
                WHEN A = B AND A = C
                            THEN 'Equilateral'
                WHEN A=B OR A=C OR B=C
                            THEN 'Isosceles'
                ELSE  'Scalene'
        END
FROM triangles


-- The PADS
-- Query an alphabetically ordered list of all names in OCCUPATIONS, immediately followed by the first letter of each profession as a parenthetical (i.e.: enclosed in parentheses).
-- Query the number of ocurrences of each occupation in OCCUPATIONS. Sort the occurrences in ascending order, and output them in the following format: "There are a total of [occupation_count] [occupation]s."
-- where [occupation_count] is the number of occurrences of an occupation in OCCUPATIONS and [occupation] is the lowercase occupation name
-- If more than one Occupation has the same [occupation_count], they should be ordered alphabetically.

--occupations(name, occupation)

SELECT
    CONCAT(name, "(", SUBSTR(occupation,1,1), ")" ) AS x1
FROM occupations
UNION
SELECT
    CONCAT("There are a total of ", count1, " ", LOWER(occupation),"s.")
FROM(
     SELECT COUNT(occupation) AS count1, occupation
     FROM occupations
     GROUP BY occupation
     ORDER BY count1
    ) t
ORDER BY x1 ;


-- Occupations
-- Pivot the Occupation column in OCCUPATIONS so that each Name is sorted alphabetically and displayed underneath its corresponding Occupation.
-- The output column headers should be Doctor, Professor, Singer, and Actor, respectively.
-- Note: Print NULL when there are no more names corresponding to an occupation.

SELECT Doctor, Professor, Singer, Actor -- works in SQL Server
FROM (
       SELECT
            name,
            occupation,
            ROW_NUMBER() OVER (PARTITION BY occupation ORDER BY name) AS rownum1
       FROM occupations
     ) st
PIVOT(
        MAX(name)
        FOR occupation
        IN (Doctor, Professor, Singer, Actor)
     ) pt;
     
-- OR

SELECT -- works in MySql
    MIN(IF(occupation='Doctor', name, NULL)),
    MIN(IF(occupation='Professor', name, NULL)),
    MIN(IF(occupation='Singer', name, NULL)),
    MIN(IF(occupation='Actor', name, NULL))
FROM (
        SELECT
            name,
            occupation,
            ROW_NUMBER() OVER (PARTITION BY occupation ORDER BY name) AS rownum1
        FROM occupations
     ) t
GROUP BY rownum1;


-- Binary Tree Nodes
-- You are given a table, BST, containing two columns: N and P, where N represents the value of a node in Binary Tree, and P is the parent of N.
-- Write a query to find the node type of Binary Tree ordered by the value of the node. Output one of the following for each node:
-- Root: If node is root node.
-- Leaf: If node is leaf node.
-- Inner: If node is neither root nor leaf node.

SELECT
    N,
    CASE
        WHEN P IS NULL
            THEN "Root"
        WHEN N IN (SELECT  P FROM BST WHERE P IS NOT NULL)
             THEN "Inner"
        ELSE
            "Leaf"
    END AS output
FROM BST
ORDER BY N;


-- New Companies
-- Given the table schemas below, write a query to print the company_code, founder name, total number of lead managers, total number of senior managers, total number of managers, and total number of employees.
-- Order your output by ascending company_code.

--company(company_code, founder)
--lead_manager(lead_manager_code, company_code)
--senior_manager(senior_manager_code, lead_manager_code, company_code)
--manager(manager_code, senior_manager_code, lead_manager_code, company_code)
--employee(employee_code,manager_code, senior_manager_code, lead_manager_code, company_code) 

SELECT
     C.company_code,
     C.founder,
     COUNT(DISTINCT LM.lead_manager_code),
     COUNT(DISTINCT SM.senior_manager_code),
     COUNT(DISTINCT M.manager_code),
     COUNT(DISTINCT E.employee_code)
FROM company C
INNER JOIN lead_manager LM ON C.company_code = LM.company_code
INNER JOIN senior_manager SM ON LM.lead_manager_code = SM.lead_manager_code
INNER JOIN manager M ON SM.senior_manager_code = M.senior_manager_code
INNER JOIN employee E ON M.manager_code = E.manager_code
GROUP BY C.company_code, C.founder
ORDER BY C.company_code