--SQL Social-Network Modification Exercises

--1. It's time for the seniors to graduate. Remove all 12th graders from Highschooler.

DELETE FROM Highschooler
WHERE grade = 12


--2. If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.

DELETE FROM Likes
WHERE ID1 IN (SELECT H1.ID
               FROM Highschooler H1, Highschooler H2, Friend F, Likes L
               WHERE H1.ID = F.ID1
                 AND H2.ID = F.ID2
                 AND H1.ID = L.ID1
                 AND H2.ID = L.ID2
			  
                 AND H2.ID NOT IN (
                                    SELECT H3.ID
                                    FROM Highschooler H3, Highschooler H4, Likes L
                                     WHERE H3.ID = H2.ID
                                       AND H4.ID = H1.ID
                                       AND H3.ID = L.ID1
                                       AND H4.ID = L.ID2
                                 
                                  )
             )


--3. For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C.
-- Do not add duplicate friendships, friendships that already exist, or friendships with oneself.

INSERT INTO Friend
SELECT DISTINCT
         F1.ID1,
         F2.ID2
FROM Friend F1, Friend F2
WHERE F1.ID2 = F2.ID1
  AND F1.ID1 <> F2.ID2 -- don't add friendships with oneself
  AND F1.ID1 NOT IN (
                      SELECT F3.ID1
                      FROM Friend F3
                      WHERE F3.ID2 = F2.ID2
                    ) -- don't add already existing friendships
                     

--OR

INSERT INTO Friend
SELECT DISTINCT F1.ID1, F2.ID2
FROM Friend F1, Friend F2
WHERE F1.ID2 = F2.ID1
AND F1.ID1 <> F2.ID2 -- don't add friendships with oneself
EXCEPT
SELECT * FROM Friend -- don't add already existing friendships