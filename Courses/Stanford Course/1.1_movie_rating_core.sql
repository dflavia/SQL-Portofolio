-- SQL Social-Network Query Exercises - Core

--1. Find the titles of all movies directed by Steven Spielberg

SELECT title
FROM Movie
WHERE director = 'Steven Spielberg';


--2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order

SELECT year
FROM Movie
WHERE mID IN 
    (
        SELECT mID 
        FROM Rating 
        WHERE stars IN (4,5)
    )
ORDER BY year;
             
            
--3. Find the titles of all movies that have no ratings
             
SELECT title
FROM Movie
WHERE mID NOT IN 
    (
        SELECT mID 
        FROM Rating 
    )
;
             
             
--4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date
              
SELECT name
FROM Reviewer
WHERE rID IN 
    (
        SELECT rID
        FROM Rating
        WHERE ratingDate IS NULL
    )
;
               
               
--5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate
-- Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars
               
SELECT
     rev.name,
     mov.title,
     rat.stars,
     rat.ratingDate
FROM Movie mov
INNER JOIN Rating rat ON mov.mID = rat.mID
INNER JOIN Reviewer rev ON rat.rID = rev.rID
ORDER BY rev.name, mov.title, rat.stars;


--6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie

SELECT *
FROM 
    (
        SELECT
             rev.name,
             mov.title
        FROM Movie mov 
        INNER JOIN Rating rat1 ON mov.mID = rat1.mID
        INNER JOIN Reviewer rev ON rat1.rID = rev.rID
        INNER JOIN Rating rat2 ON rat1.rID = rat2.rID
        WHERE
                rat1.mID = rat2.mID
            AND rat1.ratingDate > rat2.ratingDate
            AND rat1.stars > rat2.stars
    )
;
      
    
--7. For each movie that has at least one rating, find the highest number of stars that movie received
-- Return the movie title and number of stars. Sort by movie title
  
SELECT 
     mov.title,
     rat.'highest number of stars'
FROM
    (
       SELECT rat1.mID, MAX(rat1.stars) AS 'highest number of stars'
       FROM Rating rat1 JOIN Rating rat2 ON rat1.mID = rat2.mID
       GROUP BY rat1.mID
       HAVING COUNT (*)>1
     ) rat
JOIN Movie mov ON rat.mID = mov.mID
ORDER BY mov.title;


--8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie
-- Sort by rating spread from highest to lowest, then by movie title

SELECT 
    mov.title,
    rat_temp.rat_spread
  FROM(
        SELECT 
            rat.mID,
            MAX(rat.stars),
            MIN(rat.stars),
            MAX(rat.stars) - MIN(rat.stars) AS rat_spread
        FROM Rating rat
        GROUP BY rat.mID
      ) AS rat_temp
INNER JOIN Movie mov ON rat_temp.mID = mov.mID
ORDER BY rat_spread DESC, mov.title;


--9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980
-- Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after
-- Don't just calculate the overall average rating before and after 1980
   
SELECT AVG(avgBefore) - AVG(avgAfter)
FROM
    (    
      SELECT
         mov.mID, 
         mov.year,
         AVG(rat.stars) AS avgBefore
      FROM Rating rat JOIN Movie mov ON rat.mID = mov.mID
      WHERE year <1980
      GROUP BY mov.mID
    ) TableBefore, 
                  
    (
      SELECT
         mov.mID, 
         mov.year,
         AVG(rat.stars) AS avgAfter
      FROM Rating rat JOIN Movie mov ON rat.mID = mov.mID
      WHERE year >1980
      GROUP BY mov.mID
    ) TableAfter