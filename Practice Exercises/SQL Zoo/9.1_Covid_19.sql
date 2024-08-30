--Window LAG
--covid(name, whn, confirmed, deaths, recovered)
--The SQL Window functions include LAG, LEAD, RANK and NTILE. These functions operate over a "window" of rows - typically these are rows in the table that are in some sense adjacent.

--1. The example uses a WHERE clause to show the cases in 'Italy' in March 2020.
--Modify the query to show data from Spain

SELECT
     name,
     DAY(whn),
     confirmed,
     deaths,
     recovered
FROM covid
WHERE name = 'Spain'
  AND MONTH(whn) = 3
  AND YEAR(whn) = 2020
ORDER BY whn


--2. The LAG function is used to show data from the preceding row or the table
-- When lining up rows the data is partitioned by country name and ordered by the data whn. That means that only data from Italy is considered.
-- Modify the query to show confirmed for the day before

SELECT 
    name,
    DAY(whn),
    confirmed,
    LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
FROM covid
WHERE name = 'Italy'
  AND MONTH(whn) = 3
  AND YEAR(whn) = 2020
ORDER BY whn


--3. Show the number of new cases for each day, for Italy, for March

SELECT 
    name,
    DAY(whn),
    (confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)) as new
FROM covid
WHERE name = 'Italy'
  AND MONTH(whn) = 3
  AND YEAR(whn) = 2020
OR DER BY whn


--4. Show the number of new cases in Italy for each week in 2020 - show Monday only

SELECT
  name,
  DATE_FORMAT(whn,'%Y-%m-%d'),
  (confirmed - LAG(confirmed,1) OVER (PARTITION by name ORDER BY whn)) as new_cases
FROM covid
WHERE name = 'Italy'
  AND WEEKDAY(whn) = 0 
  AND YEAR(whn) = 2020
ORDER BY whn


--5. You can JOIN a table using DATE arithmetic
-- Show the number of new cases in Italy for each week - show Monday only

SELECT
     tw.name,
     DATE_FORMAT(tw.whn,'%Y-%m-%d') AS date, 
     tw.confirmed - lw.confirmed
 FROM covid tw
 LEFT JOIN covid lw ON DATE_ADD(lw.whn, INTERVAL 1 WEEK) = tw.whn
                    AND tw.name=lw.name
WHERE tw.name = 'Italy'
AND WEEKDAY(tw.whn) = 0
ORDER BY tw.whn


--6. This query shows the number of confirmed cases together with the world ranking for cases for the date '2020-04-20'. The number of COVID deaths is also shown
-- Add a column to show the ranking for the number of deaths due to COVID

SELECT 
   name,
   confirmed,
   RANK() OVER (ORDER BY confirmed DESC) rank_confirmed,
   deaths,
   RANK() OVER (ORDER BY deaths DESC) rank_deaths
  FROM covid
WHERE whn = '2020-04-20'
ORDER BY confirmed DESC


--7. Show the infection rate ranking for each country. Only include countries with a population of at least 10 million.

SELECT
   world.name,
   ROUND(100000*confirmed/population,2) infection_rate,
   RANK() OVER (ORDER BY 100000*confirmed/population) rank
FROM covid
INNER JOIN world ON covid.name = world.name
WHERE (whn = '2020-04-20')
  AND (population > 10000000)
ORDER BY population DESC


--8. For each country that has had at last 1000 new cases in a single day, show the date of the peak number of new cases.

WITH CTE1 AS
(SELECT 
    name,
    DATE_FORMAT(whn, "%Y-%m-%d") as date,
    confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY DATE(whn)) as increase
 FROM covid
 ORDER BY whn
 ),

CTE2 AS
(SELECT
     name,
     MAX(increase) as max_increase
 FROM CTE1
 WHERE increase >999
 GROUP BY name
 ORDER BY date)
 
SELECT
     c1.name,
     c1.date,
     c2.max_increase as peakNewCases
FROM CTE1 as c1
JOIN CTE2 as c2
ON c1.name=c2.name AND c1.increase=c2.max_increase