-- SQL Project Planning
-- You are given a table, Projects, containing three columns: Task_ID, Start_Date and End_Date.
-- It is guaranteed that the difference between the End_Date and the Start_Date is equal to 1 day for each row in the table.
-- If the End_Date of the tasks are consecutive, then they are part of the same project. Samantha is interested in finding the total number of different projects completed.
-- Write a query to output the start and end dates of projects listed by the number of days it took to complete the project in ascending order.
-- If there is more than one project that have the same number of completion days, then order by the start date of the project.

WITH t1 AS
(SELECT
     start_date,
     ROW_NUMBER() OVER (ORDER BY start_date) AS rownum1
 FROM projects
 WHERE start_date NOT IN (SELECT end_date FROM projects)
 ORDER BY start_date),

t2 AS
(SELECT
     end_date,
     ROW_NUMBER() OVER (ORDER BY end_date) AS rownum2
 FROM projects
 WHERE end_date NOT IN (SELECT start_date FROM projects)
 ORDER BY end_date)

SELECT start_date, end_date
FROM t1
INNER JOIN t2 ON t1.rownum1 = t2.rownum2
ORDER BY end_date - start_date, start_date


-- Placements
-- Students(ID, Name)
-- Friends(ID, Friend_ID) (ID of the ONLY best friend).
-- Packages(ID,Salary) (offered salary in $ thousands per month).

-- Write a query to output the names of those students whose best friends got offered a higher salary than them. Names must be ordered by the salary amount offered to the best friends.
-- It is guaranteed that no two students got same salary offer.

SELECT
s.name
FROM students s
INNER JOIN packages p1 ON s.id = p1.id
INNER JOIN friends f ON s.id = f.id
INNER JOIN packages p2 ON f.friend_id = p2.id
WHERE p2.salary > p1.salary
ORDER BY p2.salary


-- Symmetric Pairs
-- Functions(x,y)
-- Two pairs (X1, Y1) and (X2, Y2) are said to be symmetric pairs if X1 = Y2 and X2 = Y1.

-- Write a query to output all such symmetric pairs in ascending order by the value of X. List the rows such that X1 ≤ Y1.

SELECT x, y
FROM functions
GROUP BY x,y
HAVING COUNT(*) >1
UNION
SELECT f1.x, f1.y
FROM functions f1
INNER JOIN functions f2 ON f1.x = f2.y AND f1.y = f2.x
AND f1.x < f1.y  
ORDER BY x


-- Interviews
-- contest(contest_id, hacker_id, name)
-- colleges(college_id, contest_id)
-- challenges(challenge_id, college_id)
-- view_stats(challenge_id, total_views, total_unique_views)
-- submission_stats(challenge_id, total_submissions, total_accepted_submissions)

-- Print the contest_id, hacker_id, name, sums of total_submissions, total_accepted_submissions, total_views, and total_unique_views for each contest sorted by contest_id.
-- Exclude the contest from the result if all four sums are .
-- Note: A specific contest can be used to screen candidates at more than one college, but each college only holds  screening contest.

SELECT
    c1.contest_id,
    c1.hacker_id,
    c1.name,
    SUM(ss.ts),    --AGGREGATE challenge_id numbers again at contest_id level
    SUM(ss.tas),   --AGGREGATE challenge_id numbers at again contest_id level
    SUM(vs.tv),    --AGGREGATE challenge_id numbers at again contest_id level
    SUM(vs.tuv)    --AGGREGATE challenge_id numbers at again contest_id level
FROM contests c1
INNER JOIN colleges c2 ON c1.contest_id = c2.contest_id
INNER JOIN challenges c3 ON c2.college_id = c3.college_id
LEFT JOIN (                                            -- LEFT not INNER for not matching records
            SELECT                                     -- JOIN on AGGREGATE numbers at challenge_id level to retrieve correct figures
                challenge_id,
                SUM(total_views AS tv,
                SUM(total_unique_views) AS tuv 
            FROM view_stats
            GROUP BY challenge_id
          ) vs
       ON vs.challenge_id = c3.challenge_id
LEFT JOIN (                                        -- LEFT not INNER for not matching records
            SELECT                                 -- JOIN on AGGREGATE numbers at challenge_id level to retrieve correct figures
                challenge_id,
                SUM(total_submissions) AS ts,
                SUM(total_accepted_submissions) AS tas
            FROM submission_stats
            GROUP BY challenge_id
          ) ss
       ON ss.challenge_id = c3.challenge_id
GROUP BY c1.contest_id, c1.hacker_id, c1.name
ORDER BY c1.contest_id


-- 15 Days of Learning SQL
-- hackers(hacker_id, name)
-- submissions(submission_date, submission_id, hacker_id, score)

-- Write a query to:
-- print total number of unique hackers who made at least 1 submission each day (starting on the first day of the contest)
-- find the hacker_id and name of the hacker who made maximum number of submissions each day.
-- If more than one such hacker has a maximum number of submissions, print the lowest hacker_id.
-- The query should print this information for each day of the contest, sorted by the date.

WITH CTE1 AS
(SELECT
    submission_date,
    hacker_id
 FROM(
         SELECT
             submission_date,
             hacker_id,
             DENSE_RANK() OVER (PARTITION BY submission_date ORDER BY count_submission DESC, hacker_id) AS rank_submission 
         FROM (
                 SELECT
                     submission_date,
                     hacker_id,
                     COUNT(submission_id) AS count_submission -- count submission per hacker and day
                 FROM submissions
                 GROUP BY submission_date, hacker_id
              ) t1
     ) t2
 WHERE rank_submission = 1 -- rank by highest no of submissions and ascending hacker_id; select hacker_id with max submissions for each day
),

CTE2 AS
(SELECT
    submission_date,
    COUNT(DISTINCT hacker_id) AS daily_submission
 FROM(
        SELECT
            hacker_id,
            submission_date,
            DENSE_RANK() OVER (ORDER BY submission_date) AS day_check, -- assign numbers to each day
            DENSE_RANK() OVER (PARTITION BY hacker_id ORDER BY submission_date) AS hacker_check -- assign numbers to each hacker for each day
        FROM submissions
    ) t
 WHERE day_check = hacker_check -- check hackers that  submitted each day
 GROUP BY submission_date)

SELECT
    cte2.submission_date,
    cte2.daily_submission,
    cte1.hacker_id,
    h.name    
FROM CTE1
INNER JOIN CTE2 ON cte1.submission_date = cte2.submission_date
INNER JOIN hackers h ON cte1.hacker_id = h.hacker_id