SqlEventsDelta

Given a table events with the following structure:

  create table events (
      event_type integer not null,
      value integer not null,
      time timestamp not null,
      unique(event_type, time)
  );

Write an SQL query that, for each event_type that has been registered more than once, returns the difference between the latest (i.e. the most recent in terms of time) and the second latest value.
The table should be ordered by event_type (in ascending order).

For example, given the following data:

   event_type | value      | time
  ------------+------------+--------------------
   2          | 5          | 2015-05-09 12:42:00
   4          | -42        | 2015-05-09 13:19:57
   2          | 2          | 2015-05-09 14:48:30
   2          | 7          | 2015-05-09 12:54:39
   3          | 16         | 2015-05-09 13:19:57
   3          | 20         | 2015-05-09 15:01:09

your query should return the following rowset:

   event_type | value
  ------------+-----------
   2          | -5
   3          | 4

For the event_type 2, the latest value is 2 and the second latest value is 7, so the difference between them is −5.

The names of the columns in the rowset don't matter, but their order does.


Solution:

SELECT 
    event_type,
    new_value AS value
FROM (
        SELECT
            event_type,
            value - LEAD(value) OVER (PARTITION BY event_type ORDER BY rn2) AS new_value
        FROM (
                SELECT
                    event_type,
                    value,
                    time,
                    ROW_NUMBER() OVER(PARTITION BY event_type ORDER BY time DESC) AS rn2 
                FROM events
                WHERE event_type IN (
                                        SELECT DISTINCT event_type
                                        FROM (
                                                SELECT
                                                    event_type,
                                                    ROW_NUMBER() OVER (PARTITION BY event_type ORDER BY NULL) AS rn1
                                                FROM events
                                            ) t1
                                        WHERE rn1 > 1  
                                    )
            ) t2
        WHERE rn2 <= 2
    ) t3
WHERE new_value IS NOT NULL
