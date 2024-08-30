--SQL Social-Network Query Exercises Extras

--1. For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.

SELECT
    H1.name,
    H1.grade,
    H2.name,
    H2.grade,
    H3.name,
    H3.grade
FROM Highschooler H1, Highschooler H2, Highschooler H3, Likes L1, Likes L2
WHERE
    H1.ID = L1.ID1
AND H2.ID = L1.ID2
AND H2.ID = L2.ID1
AND H3.ID = L2.ID2
AND H1.name <> H2.name
AND H2.name <> H3.name
AND H1.name <> H3.name


--2. Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.

SELECT H1.name, H1.grade
FROM Highschooler H1
WHERE H1.ID NOT IN (
                    SELECT F.ID1
                    FROM Friend F, Highschooler H2
                    WHERE H1.ID = F.ID1
                    AND H2.ID = F.ID2
                    AND H1.grade = H2.grade
                    )


--3. What is the average number of friends per student? (Your result should be just one number.)

SELECT AVG(count)
FROM (
       SELECT
            ID1,
            COUNT(ID2) count
       FROM Friend
       GROUP BY ID1
     )


--4. Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra.
-- Do not count Cassandra, even though technically she is a friend of a friend.

SELECT friends + friends_of_friends
FROM (
        SELECT H1.ID,
               COUNT(DISTINCT H2.ID) friends,
               COUNT(DISTINCT H3.ID) friends_of_friends
        FROM Highschooler H1, Highschooler H2, Highschooler H3, Friend F1, Friend F2
        WHERE H1.ID IN (SELECT ID FROM Highschooler WHERE name = 'Cassandra')
        AND (H1.ID = F1.ID1 AND H2.ID = F1.ID2)
        AND (H2.ID = F2.ID1 AND H3.ID = F2.ID2)
        AND H3.ID <> H1.ID
        )


--5. Find the name and grade of the student(s) with the greatest number of friends.

SELECT name, grade
FROM Highschooler H
INNER JOIN Friend F ON H.ID = F.ID1
GROUP BY F.ID1
HAVING COUNT (*) = (SELECT MAX(count)
                   FROM (
                           SELECT ID1, COUNT(DISTINCT ID2) count
                           FROM Friend
                           GROUP BY ID1
                           )
                           )