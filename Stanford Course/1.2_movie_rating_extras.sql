-- SQL Movie-Rating Query Exercises - Extras

--1. Find the names of all reviewers who rated Gone with the Wind
                
SELECT DISTINCT rev.name
FROM Reviewer rev
INNER JOIN Rating rat ON rev.rID = rat.rID
WHERE rat.mID IN 
        (
            SELECT mID 
            FROM Movie 
            WHERE title = 'Gone with the Wind'
        )
;
 
   
--2. For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars
    
SELECT
     rev.name,
     mov.title,
     rat.stars
FROM Reviewer rev
INNER JOIN Rating rat ON rev.rID = rat.rID
INNER JOIN Movie mov ON rat.mID = mov.mID
WHERE rev.name = mov.director;


--3. Return all reviewer names and movie names together in a single list, alphabetized
-- Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The"

SELECT name
FROM Reviewer
UNION
SELECT title
FROM Movie
ORDER BY name, title;


--4. Find the titles of all movies not reviewed by Chris Jackson

SELECT title
FROM Movie
WHERE mID NOT IN
         (
            SELECT mID
            FROM Rating
            INNER JOIN Reviewer ON Rating.rID = Reviewer.rID
            WHERE name = 'Chris Jackson'
         )
;
                    
                                        
--5. For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers
-- Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order            
                    
SELECT DISTINCT
     rev1.name,
     rev2.name
FROM Reviewer rev1, Reviewer rev2, Rating rat1, Rating rat2
WHERE
         rev1.rID = rat1.rID
    AND  rev2.rID = rat2.rID
    AND  rat1.mID = rat2.mID
    AND  rev1.name < rev2.name
ORDER BY rev1.name, rev2.name
;   
    
        
--6. For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars
    
SELECT
    name,
    title,
    stars
FROM Movie mov
INNER JOIN Rating rat ON mov.mID = rat.mID
INNER JOIN Reviewer rev ON rat.rID = rev.rID
WHERE rat.stars = 
                    (
                        SELECT MIN(stars)
                        FROM Rating
                    )
;


--7. List movie titles and average ratings, from highest-rated to lowest-rated.
-- If two or more movies have the same average rating, list them in alphabetical order

SELECT
    mov.title,
    AVG(rat.stars) AS avg
FROM Movie mov
INNER JOIN Rating rat ON mov.mID = rat.mID
GROUP BY mov.title
ORDER BY avg DESC, mov.title;


--8. Find the names of all reviewers who have contributed three or more ratings

SELECT rev.name
FROM Reviewer rev
INNER JOIN Rating rat ON rev.rID = rat.rID
GROUP BY rev.name
HAVING COUNT(*)>=3;


--9. Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name
-- Sort by director name, then movie title.

SELECT
     M1.title,
     M1.director
FROM Movie M1
INNER JOIN Movie M2 ON M1.director = M2.director
GROUP BY M1.title
HAVING COUNT(*)>1
ORDER BY M1.director, M1.title;

-- OR

SELECT
    title,
    director
FROM Movie
WHERE director IN
        (
            SELECT director
            FROM Movie
            GROUP BY director
            HAVING COUNT(*)>1
        )
ORDER BY director, title;
                              
                                 
--10. Find the movie(s) with the highest average rating. Return the movie title(s) and average rating
                                                                 
SELECT
    mov.title,
    AVG(rat.stars) AS avg
FROM Movie mov
INNER JOIN Rating rat ON mov.mID = rat.mID
GROUP BY mov.title
ORDER BY avg DESC
LIMIT 1;

--OR: what if multiple movies with same max avg? can't use LIMIT

SELECT *
FROM (
        SELECT title, AVG(stars) AS avg
        FROM Movie mov
        INNER JOIN Rating rat ON mov.mID = rat.mID
        GROUP BY mov.title
     )
WHERE avg = (
                SELECT MAX(avg)
                FROM (
                        SELECT 
                            mID,
                            AVG(stars) AS avg
                        FROM Rating
                        GROUP BY mID
                     )
            )
;
            
            
--11. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating
            
SELECT *
FROM (
        SELECT title, AVG(stars) AS avg
        FROM Movie mov
        INNER JOIN Rating rat ON mov.mID = rat.mID
        GROUP BY mov.title
     )
WHERE avg = (
               SELECT MIN(avg)
               FROM (
                       SELECT mID, AVG(stars) AS avg
                       FROM Rating
                       GROUP BY mID
                    )
            )
;
       
             
--12. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating.
--Ignore movies whose director is NULL
                       
SELECT
    director,
    title,
    MAX(stars)
FROM Movie mov
INNER JOIN Rating rat ON mov.mID = rat.mID
WHERE director IS NOT NULL
GROUP BY director;