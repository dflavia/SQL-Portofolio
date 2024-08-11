--The JOIN operation
--game(id, mdate, stadium, team1, team2)
--goal(matchid, teamid, player, gtime)
--eteam(id, teamname, coach)


--1. Show the matchid and player name for all goals scored by Germany

SELECT matchid, player
FROM goal 
WHERE teamid = 'GER'


--2. Show id, stadium, team1, team2 for just game 1012

SELECT id,stadium,team1,team2
FROM game
WHERE id = 1012


--3. Show the player, teamid, stadium and mdate for every German goal

SELECT player, teamid, stadium, mdate
FROM game
INNER JOIN goal ON game.id = goal.matchid
WHERE goal.teamid = 'GER'


--4. Show the team1, team2 and player for every goal scored by a player called Mario player LIKE 'Mario%'

SELECT team1, team2, player
FROM game
INNER JOIN goal ON game.id = goal.matchid
WHERE player LIKE 'Mario%'


--5. Show player, teamid, coach, gtime for all goals scored in the first 10 minutes gtime<=10

SELECT player, teamid, coach, gtime
FROM goal
INNER JOIN eteam ON goal.teamid = eteam.id
WHERE gtime <= 10


--6. List the dates of the matches and the name of the team in which 'Fernando Santos' was the team1 coach

SELECT game.mdate, eteam.teamname
FROM game
INNER JOIN eteam ON game.team1 = eteam.id
WHERE coach = 'Fernando Santos'


--7. List the player for every goal scored in a game where the stadium was 'National Stadium, Warsaw'

SELECT goal.player
FROM goal
INNER JOIN game ON goal.matchid = game.id
WHERE stadium = 'National Stadium, Warsaw'


--8. show the name of all players who scored a goal against Germany

SELECT DISTINCT player
FROM goal
INNER JOIN game ON goal.matchid = game.id
WHERE teamid <> 'GER'
AND (team1 = 'GER' OR team2 = 'GER')


--9. Show teamname and the total number of goals scored

SELECT eteam.teamname, COUNT(*)
FROM eteam
INNER JOIN goal ON eteam.id = goal.teamid
GROUP BY teamname


--10. how the stadium and the number of goals scored in each stadium

SELECT stadium, COUNT(*)
FROM game
INNER JOIN goal ON game.id = goal.matchid
GROUP BY stadium


--11. For every match involving 'POL', show the matchid, date and the number of goals scored

SELECT matchid, mdate, COUNT(*)
FROM goal JOIN game ON goal.matchid = game.id
WHERE team1 ='POL' OR team2 = 'POL'
GROUP BY matchid


--12. For every match where 'GER' scored, show matchid, match date and the number of goals scored by 'GER'

SELECT matchid, mdate, COUNT(*)
FROM goal
INNER JOIN game ON goal.matchid = game.id
WHERE teamid='GER'
GROUP BY matchid


--13. List every match with the goals scored by each team as shown
--Sort your result by mdate, matchid, team1 and team2

SELECT
   mdate,
   team1,
   SUM(CASE WHEN teamid=team1 THEN 1 ELSE 0 END) AS score1,
   team2,
   SUM(CASE WHEN teamid=team2 THEN 1 ELSE 0 END) AS score2
FROM game
LEFT JOIN goal ON game.id = goal.matchid -- LEFT JOIN, NOT INNER, to also return games with no match in goals, see 27 June POR vs ESP, 0-0
GROUP BY mdate, team1, team2
ORDER BY mdate, matchid, team1, team2