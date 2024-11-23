-- Revisiting Aggregations - The Count Function
-- Query a count of the number of cities in CITY having a Population larger than 100000.
-- city(ID, name, countrycode, district, population)


SELECT COUNT(id)
FROM city
WHERE population > 100000;


-- Revisiting Aggregations - The Sum Function
-- Query the total population of all cities in CITY where District is California.

SELECT SUM(population)
FROM city
WHERE district = 'California'


-- Revisiting Aggregations - Averages
-- Query the average population of all cities in CITY where District is California.

SELECT AVG(population)
FROM city
WHERE district = 'California';


-- Average Population
-- Query the average population for all cities in CITY, rounded down to the nearest integer.

SELECT ROUND(AVG(population))
FROM city;


-- Japan Population
-- Query the sum of the populations for all Japanese cities in CITY. The COUNTRYCODE for Japan is JPN.

SELECT SUM(population)
FROM city
WHERE countrycode = 'JPN';


-- Population Density Difference
-- Query the difference between the maximum and minimum populations in CITY.

SELECT MAX(population) - MIN(population)
FROM city;


--The Blunder
-- Samantha was tasked with calculating the average monthly salaries for all employees in the EMPLOYEES table, but did not realize her keyboard's  key was broken until after completing the calculation.
-- She wants your help finding the difference between her miscalculation (using salaries with any zeros removed), and the actual average salary.
-- Write a query calculating the amount of error (i.e.: actual - miscalculated average monthly salaries), and round it up to the next integer.
-- employees(id, name, salary)

SELECT
    CEILING(
            AVG(salary)
            -
            AVG(REPLACE(salary,0,""))
           )
FROM employees;


-- Top Earners
-- We define an employee's total earnings to be their monthly salary x months worked, and the maximum total earnings to be the maximum total earnings for any employee in the Employee table.
-- Write a query to find the maximum total earnings for all employees as well as the total number of employees who have maximum total earnings. Then print these values as 2 space-separated integers.
-- employee(employee_id, name, months, salary)

SELECT
     salary*months,
     COUNT(name)
FROM employee
WHERE salary*months = (
                        SELECT MAX(salary*months)
                        FROM employee
                      )  
GROUP BY salary*months;


-- Weather Observation Station 2
-- Query the following two values from the STATION table:
--The sum of all values in LAT_N rounded to a scale of  decimal places.
--The sum of all values in LONG_W rounded to a scale of  decimal places.
-- station(id, city, state, lat_n, long_w)

SELECT
        ROUND(SUM(lat_n),2) lat,
        ROUND(SUM(long_w),2) lon
FROM station;


-- Weather Observation Station 13
-- Query the sum of Northern Latitudes (LAT_N) from STATION having values greater than 38.7880 and less than 137.2345. Truncate your answer to  decimal places.

SELECT ROUND(SUM(lat_n),4)
FROM station
WHERE lat_n > 38.7880
  AND lat_n < 137.2345;


-- Weather Observation Station 14
-- Query the greatest value of the Northern Latitudes (LAT_N) from STATION that is less than . Truncate your answer to  decimal places.

SELECT ROUND(MAX(lat_n),4)
FROM station
WHERE lat_n < 137.2345;


-- Weather Observation Station 15
-- Query the Western Longitude (LONG_W) for the largest Northern Latitude (LAT_N) in STATION that is less than . Round your answer to  decimal places.

SELECT ROUND(long_w,4)
FROM station
WHERE lat_n IN (
                SELECT MAX(lat_n)
                FROM station
                WHERE lat_n < 137.2345
                )
;


-- Weather Observation Station 16
-- Query the smallest Northern Latitude (LAT_N) from STATION that is greater than . Round your answer to  decimal places.

SELECT ROUND(MIN(lat_n),4)
FROM station
WHERE lat_n > 38.7780;


-- Weather Observation Station 17
-- Query the Western Longitude (LONG_W)where the smallest Northern Latitude (LAT_N) in STATION is greater than . Round your answer to  decimal places.

SELECT ROUND(long_w,4)
FROM station
WHERE lat_n IN (
                SELECT MIN(lat_n)
                FROM station
                WHERE lat_n > 38.7880
               )
;


-- Weather Observation Station 18

--Consider P1(a,b) and P2(c,d)  to be two points on a 2D plane.
-- a happens to equal the minimum value in Northern Latitude (LAT_N in STATION).
-- b happens to equal the minimum value in Western Longitude (LONG_W in STATION).
-- c happens to equal the maximum value in Northern Latitude (LAT_N in STATION).
-- d happens to equal the maximum value in Western Longitude (LONG_W in STATION).
-- Query the Manhattan Distance between points  and  and round it to a scale of  decimal places.

SELECT ROUND(ABS(a-c)+ ABS(b-d),4)
FROM(
            SELECT
                    MIN(lat_n) a,
                    MIN(long_w) b,
                    MAX(lat_n) c,
                    MAX(long_w) d
            FROM station
          ) t
;


-- Weather Observation Station 19
-- Query the Euclidean Distance between points  and  and format your answer to display  decimal digits.

SELECT ROUND(SQRT(POWER(ABS(a-c),2)+ POWER(ABS(b-d),2)),4)
FROM(
            SELECT
                    MIN(lat_n) a,
                    MIN(long_w) b,
                    MAX(lat_n) c,
                    MAX(long_w) d
            FROM station
          ) t
          

-- Weather Observation Station 20
-- A median is defined as a number separating the higher half of a data set from the lower half. Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to  decimal places.

WITH t AS
( SELECT
            lat_n,
            ROW_NUMBER() OVER (PARTITION BY NULL ORDER BY lat_n) AS rn
  FROM station
)

SELECT
   CASE
        WHEN COUNT(*) % 2 <> 0
                THEN (
                        SELECT
                            CAST(ROUND(lat_n,4) AS DECIMAL(10,4))
                        FROM t
                        WHERE rn = ((SELECT COUNT(*) FROM station) + 1) / 2
                     )
        WHEN COUNT(*) % 2 = 0
                THEN (
                        SELECT
                            CAST(ROUND(AVG(lat_n),4) AS DECIMAL (10,4))
                        FROM t
                        WHERE rn = (SELECT COUNT(*) FROM station) / 2
                           OR rn = (SELECT COUNT(*) FROM station) / 2 + 1
                     )
   END
FROM t                  