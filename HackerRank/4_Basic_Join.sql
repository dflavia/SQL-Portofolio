-- city(ID, name, countrycode, district, population)
-- country(code, name, continent,region, surfacearea, indepyear, population, lifeexpectancy, gnp, gnpold, localname, governmentform, headofstate, capital, code2)

-- Population Census
-- Given the CITY and COUNTRY tables, query the sum of the populations of all cities where the CONTINENT is 'Asia'.

SELECT SUM(population)
FROM city
WHERE countrycode IN (
                       SELECT code
                       FROM country
                       WHERE continent = 'Asia'
                     )
;


-- African Cities
-- Given the CITY and COUNTRY tables, query the names of all cities where the CONTINENT is 'Africa'.

SELECT name
FROM city
WHERE countrycode IN (
                        SELECT code
                        FROM country
                        WHERE continent = 'Africa'
                     )
;


-- Average Population of Each Continent
--Given the CITY and COUNTRY tables, query the names of all the continents (COUNTRY.Continent) and their respective average city populations (CITY.Population) rounded down to the nearest integer.

SELECT
    country.continent,
    FLOOR(AVG(city.population))
FROM country
INNER JOIN city ON country.code = city.countrycode
GROUP BY continent


-- The Report
-- Ketty gives Eve a task to generate a report containing three columns: Name, Grade and Mark. Ketty doesn't want the NAMES of those students who received a grade lower than 8.
-- The report must be in descending order by grade -- i.e. higher grades are entered first.
-- If there is more than one student with the same grade (8-10) assigned to them, order those particular students by their name alphabetically.
-- Finally, if the grade is lower than 8, use "NULL" as their name and list them by their grades in descending order.
-- If there is more than one student with the same grade (1-7) assigned to them, order those particular students by their marks in ascending order.

--students(ID, name, marks)
--grades(grade, min_mark, max_mark)

SELECT 
    CASE
        WHEN grade < 8 
            THEN name = NULL
        ELSE
            name
    END AS name,
    grade,
    marks
FROM students s
INNER JOIN grades g ON s.marks >= g.min_mark AND s.marks <= g.max_mark
ORDER BY grade DESC, name, marks


-- Top Competitors
-- Write a query to print the respective hacker_id and name of hackers who achieved full scores for more than one challenge.
-- Order your output in descending order by the total number of challenges in which the hacker earned a full score.
-- If more than one hacker received full scores in same number of challenges, then sort them by ascending hacker_id.
-- hackers(hacker_id, name)
-- difficulty(difficulty_level, score)
-- challenges(challenge_id, hacker_id, difficulty_level)
-- submissions(submission_id, hacker_id, challenge_id, score)

SELECT h.hacker_id, h.name
FROM hackers h
INNER JOIN submissions s ON h.hacker_id = s.hacker_id
INNER JOIN challenges c ON c.challenge_id = s.challenge_id
INNER JOIN difficulty d ON c.difficulty_level = d.difficulty_level
WHERE d.score = s.score
GROUP BY h.hacker_id, h.name
HAVING COUNT(submission_id)>1
ORDER BY COUNT(submission_id) DESC, h.hacker_id ASC


-- Ollivander's Inventory
-- Harry Potter and his friends are at Ollivander's with Ron, finally replacing Charlie's old broken wand.
-- Hermione decides the best way to choose is by determining the minimum number of gold galleons needed to buy each non-evil wand of high power and age.
-- Write a query to print the id, age, coins_needed, and power of the wands that Ron's interested in, sorted in order of descending power.
-- If more than one wand has same power, sort the result in order of descending age.

-- wands(id, code, coins_needed, power)
-- wands_property(code, age, is_evil)

SELECT 
    id,
    age,
    coins_needed,
    power
FROM(
        SELECT
            id,
            age,
            coins_needed,
            power,
            ROW_NUMBER() OVER (PARTITION BY power, age ORDER BY coins_needed) AS rownum1
        FROM wands w
        INNER JOIN wands_property wp ON w.code = wp.code
        WHERE is_evil = 0
    ) t
WHERE rownum1 = 1
ORDER BY power DESC, age DESC


-- Challenges
-- Write a query to print the hacker_id, name, and the total number of challenges created by each student.
-- Sort your results by the total number of challenges in descending order. If more than one student created the same number of challenges, then sort the result by hacker_id.
-- If more than one student created the same number of challenges and the count is less than the maximum number of challenges created, then exclude those students from the result.
-- hackers(hacker_id, name)
-- challenges(challenge_id, hacker_id)

WITH temp AS
(SELECT
    hacker_id AS hid,
    COUNT(*) AS count1,
    COUNT(COUNT(*)) OVER (PARTITION BY COUNT(*)) AS partcount
    FROM challenges
    GROUP BY hacker_id
    ) 
SELECT hid, name, count1
FROM temp
INNER JOIN hackers h ON temp.hid = h.hacker_id
WHERE count1 = (SELECT MAX(count1) FROM temp) OR partcount = 1
ORDER BY count1 DESC, hid


-- Contest Leaderboard
-- The total score of a hacker is the sum of their maximum scores for all of the challenges.
-- Write a query to print the hacker_id, name, and total score of the hackers ordered by the descending score. If more than one hacker achieved the same total score, then sort the result by ascending hacker_id.
-- Exclude all hackers with a total score of  from your result.
-- hackers(hacker_id, name)
-- submissions(submission_id, hacker_id, challenge_id, score)

SELECT h.hacker_id, h.name, SUM(maxscore) AS totalscore
FROM(
SELECT hacker_id,  challenge_id, MAX(score) AS maxscore
FROM submissions
GROUP BY hacker_id, challenge_id
ORDER BY hacker_id,  challenge_id
) t1
INNER JOIN hackers h ON t1.hacker_id = h.hacker_id
GROUP BY h.hacker_id, h.name
HAVING SUM(maxscore) > 0
ORDER BY SUM(maxscore) DESC, h.hacker_id