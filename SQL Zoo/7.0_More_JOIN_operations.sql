 --More JOIN operations
--movie(id, title, yr, director, budget, gross)
--actor(id, name)
--casting(movieid, actorid, ord)

--1. List the films where the yr is 1962 [Show id, title]

SELECT id, title
FROM movie
WHERE yr = 1962


--2. Give year of 'Citizen Kane'

SELECT yr
FROM movie
WHERE title = 'Citizen Kane'


--3. List all of the Star Trek movies, include the id, title and yr (all of these movies include the words Star Trek in the title)
-- Order results by year

SELECT id, title, yr
FROM movie
WHERE title LIKE '%Star Trek%'
ORDER BY yr


--4. What id number does the actor 'Glenn Close' have?

SELECT id
FROM actor
WHERE name = 'Glenn Close'


--5. What is the id of the film 'Casablanca'

SELECT id
FROM movie
WHERE title = 'Casablanca'


--6. Obtain the cast list for 'Casablanca'

SELECT actor.name
FROM actor
INNER JOIN casting ON actor.id = casting.actorid
INNER JOIN movie ON casting.movieid = movie.id
WHERE movie.title = 'Casablanca'


--7. Obtain the cast list for the film 'Alien'

SELECT actor.name
FROM actor
INNER JOIN casting ON actor.id = casting.actorid
INNER JOIN movie ON casting.movieid = movie.id
WHERE movie.title = 'Alien'


--8. List the films in which 'Harrison Ford' has appeared

SELECT mov.title
FROM movie mov
INNER JOIN casting cast ON mov.id = cast.movieid
INNER JOIN actor act ON cast.actorid = act.id
WHERE act.name = 'Harrison Ford'


--9. List the films where 'Harrison Ford' has appeared - but not in the starring role
-- [Note: the ord field of casting gives the position of the actor. If ord=1 then this actor is in the starring role]

SELECT mov.title
FROM movie mov
INNER JOIN casting cast ON mov.id = cast.movieid
INNER JOIN actor act ON cast.actorid = act.id
WHERE act.name = 'Harrison Ford'
AND cast.ord <>1


--10. List the films together with the leading star for all 1962 films

SELECT mov.title, act.name
FROM movie mov
INNER JOIN casting cast ON mov.id = cast.movieid
INNER JOIN actor act ON cast.actorid = act.id
WHERE yr = 1962 AND cast.ord = 1


--11. Which were the busiest years for 'Rock Hudson'
-- show the year and the number of movies he made each year for any year in which he made more than 2 movies

SELECT yr, COUNT(title)
FROM movie mov
INNER JOIN casting cast ON mov.id = cast.movieid
INNER JOIN actor act ON cast.actorid = act.id
WHERE act.name = 'Rock Hudson'
GROUP BY yr
HAVING COUNT(title)>2


--12. List the film title and the leading actor for all of the films 'Julie Andrews' played in

SELECT title, name
FROM movie mov
     INNER JOIN casting cast ON mov.id = cast.movieid
     INNER JOIN actor act ON cast.actorid = act.id
WHERE movieid IN 
               (
                   SELECT movieid
                    FROM casting
                    WHERE actorid IN
                                   (
                                       SELECT id
                                        FROM actor
                                        WHERE name = 'Julie Andrews'
                                   )
               )
AND ord = 1


--13. Obtain a list, in alphabetical order, of actors who've had at least 15 starring roles

SELECT act.name
FROM actor act
JOIN casting cast ON act.id = cast.actorid
WHERE ord = 1
GROUP BY act.name
HAVING COUNT(act.name)>=15
ORDER BY act.name


--14. List the films released in the year 1978 ordered by the number of actors in the cast, then by title

SELECT mov.title, COUNT(cast.actorid)
FROM movie mov
INNER JOIN casting cast ON mov.id = cast.movieid
WHERE yr = 1978
GROUP BY mov.title
ORDER BY COUNT(cast.actorid) DESC, mov.title


--15. List all the people who have worked with 'Art Garfunkel'

SELECT act.name
FROM actor act
INNER JOIN casting cast ON act.id = cast.actorid
WHERE movieid IN
               (
                   SELECT movieid
                   FROM casting
                   WHERE actorid IN 
                                   (
                                       SELECT id 
                                       FROM actor 
                                       WHERE name = 'Art Garfunkel'
                                   )
               )
AND act.name <> 'Art Garfunkel'