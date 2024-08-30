-- SQL Social-Network Query Exercises - Core

--1. Find the names of all students who are friends with someone named Gabriel

SELECT name
FROM Friend
INNER JOIN Highschooler ON ID = ID2
WHERE ID1 IN (
             SELECT ID
             FROM Highschooler
             WHERE name = 'Gabriel'
             )
             

--2. For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.

SELECT
    H1.name,
    H1.grade,
    H2.name,
    H2.grade
FROM Highschooler H1
INNER JOIN Likes L ON H1.ID = L.ID1
INNER JOIN Highschooler H2 ON L.ID2 = H2.ID
WHERE H1.grade - H2.grade >= 2


--3. For every pair of students who both like each other, return the name and grade of both students. 
-- Include each pair only once, with the two names in alphabetical order.

SELECT
    H1.name,
    H1.grade,
    H2.name,
    H2.grade
FROM Highschooler H1, Highschooler H2, Likes L1, Likes L2
WHERE L1.ID1 = H1.ID
  AND L1.ID2 = H2.ID
  AND L2.ID1 = H2.ID
  AND L2.ID2 = H1.ID
  AND H1.name < H2.name
ORDER BY H1.name, H2.name


--4. Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades.
-- Sort by grade, then by name within each grade.

SELECT
    name,
    grade
FROM Highschooler
WHERE ID NOT IN (
                    SELECT ID1 FROM Likes
                    UNION
                    SELECT ID2 FROM Likes
                )
ORDER BY grade, name


--5. For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.

SELECT
    H1.name,
    H1.grade,
    H2.name,
    H2.grade
FROM Highschooler H1
INNER JOIN Likes L ON H1.ID = L.ID1
INNER JOIN Highschooler H2 ON L.ID2 = H2.ID
WHERE H1.ID = L.ID1
  AND H2.ID = L.ID2
  AND H2.ID NOT IN (SELECT ID1 FROM Likes)


--6. Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.

SELECT
    H1.name,
    H1.grade
FROM Highschooler H1
WHERE H1.ID NOT IN (
                        SELECT F.ID1
                        FROM Friend F, Highschooler H2
                        WHERE H1.ID = F.ID1
                          AND H2.ID = F.ID2
                          AND H1.grade <> H2.grade
                    )
ORDER BY H1.grade, H1.name;


--7. For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!).
-- For all such trios, return the name and grade of A, B, and C.

SELECT
    H1.name,
    H1.grade,
    H2.name,
    H2.grade,
    H3.name,
    H3.grade
FROM Highschooler H1, Highschooler H2, Highschooler H3, Likes L, Friend F1, Friend F2
  WHERE 1=1
    AND H1.ID = L.ID1
    AND H2.ID = L.ID2
    AND H2.ID NOT IN (SELECT ID2 FROM Friend WHERE H1.ID = ID1)
    AND (H1.ID = F1.ID1 AND H3.ID = F1.ID2)
    AND (H2.ID = F2.ID1 AND H3.ID = F2.ID2)
    

--8. Find the difference between the number of students in the school and the number of different first names.

SELECT COUNT(Highschooler.ID) - COUNT(DISTINCT Highschooler.name)
FROM Highschooler


--9. Find the name and grade of all students who are liked by more than one other student.

SELECT
    name,
    grade
FROM Highschooler H
INNER JOIN Likes L ON H.ID = L.ID2
GROUP BY name, grade
HAVING COUNT(*)>1