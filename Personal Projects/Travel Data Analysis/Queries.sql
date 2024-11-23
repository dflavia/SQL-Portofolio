-- Find possible resorts based on flight destinations.
-- Also include in the result a column with a count of all possible resorts.
-- Only include resorts rated with 4 stars or more.

-- Take for example the sample data for tables: user_flights, flights, resorts:

| user_id | flight_id |
| ------- | --------- |
| 124     | 54        |
| 9       | 94        |
| 85      | 2         |
| 97      | 94        |
| 5       | 2         |


| flight_id | departure_country | arrival_country | airline           | flight_class | flight_date | time_hours | distance_km | flight_price | flight_payment_type       |
| --------- | ----------------- | --------------- | ----------------- | ------------ | ----------- | ---------- | ----------- | ------------ | ------------------------- |
| 1         | Norway            | Indonesia       | Koelpin Group     | economy      | 11-05-19    | 1.3        | 1433.25     | â‚¬2426,02   | diners-club-carte-blanche |
| 2         | Brazil            | Costa Rica      | Collins-Keeling   | first class  | 27-01-21    | 7.68       | 2305.95     | â‚¬1232,81   | americanexpress           |
| 3         | China             | Indonesia       | Bashirian-Grimes  | first class  | 22-04-18    | 4.58       | 2787.33     | â‚¬1754,81   | diners-club-enroute       |
| 4         | Indonesia         | Philippines     | Bartoletti Inc    | economy      | 03-09-18    | 9.41       | 689.55      | â‚¬1632,44   | diners-club-enroute       |
| 5         | China             | United States   | Prosacco-Medhurst | premium      | 26-11-22    | 5.11       | 1980.54     | â‚¬942,87    | visa                      |


| resort_id | resort_name        | resort_rating | resort_country | duration_of_stay | resort_price | resort_currency | resort_city    | resort_payment_type |
| --------- | ------------------ | ------------- | -------------- | ---------------- | ------------ | --------------- | -------------- | ------------------- \
| 1         | Lazy Lagoon        | 2             | Chile          | 29               | 975490       | CLP             | Lautaro        | maestro             | 
| 2         | Sleepy Sands       | 1             | Colombia       | 2                | 4644360      | COP             | Pizarro        | jcb                 |
| 3         | Chillax Cove       | 5             | Colombia       | 29               | 18777500     | IDR             | Karangkedawung | jcb                 |
| 4         | Snoozeville Resort | 2             | France         | 27               | 2546.47      | BRL             | Formiga        | bankcard            |
| 5         | Lazy River Lodge   | 2             | Brazil         | 29               | 23245900     | IDR             | Jatinagara     | jcb                 |


SELECT
	f.arrival_country,
	LENGTH(STRING_AGG(DISTINCT r.resort_name, ',')) - LENGTH(REPLACE(STRING_AGG(DISTINCT r.resort_name, ','), ',', '')) + 1 AS possible_resorts_no,
	STRING_AGG(DISTINCT r.resort_name, ', ') AS possible_resorts
FROM user_flights uf
INNER JOIN flights f ON uf.flight_id = f.flight_id
INNER JOIN resorts r ON f.arrival_country = r.resort_country
WHERE r.resort_rating >= 4 
GROUP BY 1


-- Result set sample:

| arrival_country | possible_resorts_no | possible_resorts                                                                      |
| --------------- | ------------------- | ------------------------------------------------------------------------------------- |
| Brazil          | 3                   | Power Nap Place, Sleepyhead Shores, The Rest & Relax                                  |
| Colombia        | 2                   | Chillax Cove, Do Nothing Dome                                                         |
| France          | 5                   | Chillaxation Station, Slackers Paradise, Snuggle Sands, Unwind Utopia, Unwind Waters  |
| Greece          | 2                   | The Lazy Lobster, The Slack Shack                                                     |



-- Based on the flights that users  have boarded and countries where they landed:
-- generate a new column with a comma separated list of all possible resorts that they may book their stays in
-- pick a random resort from that list

-- Take for example the sample data for tables: user_flights, flights, resorts:

| user_id | flight_id |
| ------- | --------- |
| 124     | 54        |
| 9       | 94        |
| 85      | 2         |
| 97      | 94        |
| 5       | 2         |


| flight_id | departure_country | arrival_country | airline           | flight_class | flight_date | time_hours | distance_km | flight_price | flight_payment_type       |
| --------- | ----------------- | --------------- | ----------------- | ------------ | ----------- | ---------- | ----------- | ------------ | ------------------------- |
| 1         | Norway            | Indonesia       | Koelpin Group     | economy      | 11-05-19    | 1.3        | 1433.25     | â‚¬2426,02   | diners-club-carte-blanche |
| 2         | Brazil            | Costa Rica      | Collins-Keeling   | first class  | 27-01-21    | 7.68       | 2305.95     | â‚¬1232,81   | americanexpress           |
| 3         | China             | Indonesia       | Bashirian-Grimes  | first class  | 22-04-18    | 4.58       | 2787.33     | â‚¬1754,81   | diners-club-enroute       |
| 4         | Indonesia         | Philippines     | Bartoletti Inc    | economy      | 03-09-18    | 9.41       | 689.55      | â‚¬1632,44   | diners-club-enroute       |
| 5         | China             | United States   | Prosacco-Medhurst | premium      | 26-11-22    | 5.11       | 1980.54     | â‚¬942,87    | visa                      |


| resort_id | resort_name        | resort_rating | resort_country | duration_of_stay | resort_price | resort_currency | resort_city    | resort_payment_type |
| --------- | ------------------ | ------------- | -------------- | ---------------- | ------------ | --------------- | -------------- | ------------------- \
| 1         | Lazy Lagoon        | 2             | Chile          | 29               | 975490       | CLP             | Lautaro        | maestro             | 
| 2         | Sleepy Sands       | 1             | Colombia       | 2                | 4644360      | COP             | Pizarro        | jcb                 |
| 3         | Chillax Cove       | 5             | Colombia       | 29               | 18777500     | IDR             | Karangkedawung | jcb                 |
| 4         | Snoozeville Resort | 2             | France         | 27               | 2546.47      | BRL             | Formiga        | bankcard            |
| 5         | Lazy River Lodge   | 2             | Brazil         | 29               | 23245900     | IDR             | Jatinagara     | jcb                 |


SELECT
	*,
	(split_part( -- split string based on specified delimiter ',' and find nth position
				possible_resorts, -- string of possible resort ids
				',', -- delimniter
				(random()*(LENGTH(possible_resorts)-LENGTH(REPLACE(possible_resorts, ',', '')))+1)::int -- generate a random position between 0 and total no of resorts, cast no as int
				))::int AS random_resort
FROM(
		SELECT
			uf.user_id,
			uf.flight_id,
			f.arrival_country,	
			STRING_AGG(r.resort_id::text,',' ORDER BY resort_id) AS possible_resorts -- generate a comma separated list of all possible resorts based on country
		FROM user_flights uf
		INNER JOIN flights f ON uf.flight_id = f.flight_id
		INNER JOIN resorts r ON f.arrival_country = r.resort_country
		GROUP BY 1,2,3
	)

-- Result set sample:

| user_id | flight_id | arrival_country | possible_resorts                            | random_resort |
| ------- | --------- | --------------- | ------------------------------------------- | ------------- |
| 1       | 47        | Philippines     | 8,11,13,15,17,19,21,25,29,37,47,48,61,65,81 | 13            |
| 1       | 64        | Brazil          | 5,10,14,27,32,50,88,90,98                   | 50            |
| 1       | 123       | Brazil          | 5,10,14,27,32,50,88,90,98                   | 32            |
| 2       | 35        | Cuba            | 68,80                                       | 68            |
| 2       | 38        | France          | 4,6,12,31,35,36,43,64,83,86                 | 43            |



-- List all facilities for each resort that offers airport transfers or beach access among its services.
-- The facilities list should be a new column ordered alphabethically and comma-separated.
-- Also include in the result a column with a count of all facilities offered by each resort.
-- List first the resorts with the highest number of facilities in their portofolio, then order by resort name.

-- Take for example the sample data for tables: resorts, facilities, resort_facilities:

| resort_id | resort_name        | resort_rating | resort_country | duration_of_stay | resort_price | resort_currency | resort_city    | resort_payment_type |
| --------- | ------------------ | ------------- | -------------- | ---------------- | ------------ | --------------- | -------------- | ------------------- \
| 1         | Lazy Lagoon        | 2             | Chile          | 29               | 975490       | CLP             | Lautaro        | maestro             | 
| 2         | Sleepy Sands       | 1             | Colombia       | 2                | 4644360      | COP             | Pizarro        | jcb                 |
| 3         | Chillax Cove       | 5             | Colombia       | 29               | 18777500     | IDR             | Karangkedawung | jcb                 |
| 4         | Snoozeville Resort | 2             | France         | 27               | 2546.47      | BRL             | Formiga        | bankcard            |
| 5         | Lazy River Lodge   | 2             | Brazil         | 29               | 23245900     | IDR             | Jatinagara     | jcb                 |


| facilities_id | facilities_options          |
| ------------- | --------------------------- |
| 1             | spa and wellness facilities |
| 2             | swimming pool               |
| 3             | beach access                |
| 4             | parking                     |
| 5             | room service                |


| resort_id | facilities_id |
| --------- | ------------- |
| 19        | 12            |
| 1         | 1             |
| 80        | 18            |
| 23        | 12            |
| 59        | 19            |


SELECT
	r.resort_name AS resort,
	LENGTH(STRING_AGG (f.facilities_options,',')) - LENGTH(REPLACE(STRING_AGG(f.facilities_options,','),',','')) + 1 AS facilities_no,
	STRING_AGG(f.facilities_options,', ' ORDER BY facilities_options) AS facilities_list
FROM resorts r
INNER JOIN resort_facilities AS rf USING (resort_id)
INNER JOIN facilities AS f USING (facilities_id)
GROUP BY r.resort_name
HAVING
	(STRING_AGG(f.facilities_options,', ' ORDER BY facilities_options) LIKE '%airport%'
	OR STRING_AGG(f.facilities_options,', ' ORDER BY facilities_options) LIKE '%beach%')
ORDER BY facilities_no DESC, resort_name;


-- Result set sample:

| resort          | facilities_no | facilities_list                                                                  |
| --------------- | ------------- | -------------------------------------------------------------------------------- |
| Slacker Sands   | 4             | airport transfer, beach access, indoor games, room service                       |
| Unwind Waters   | 4             | beach access, fitness center, luxury accommodations, spa and wellness facilities |
| Kicked-Back Key | 3             | airport transfer, room service, water sports                                     |
| Nap Nest        | 3             | beach access, business and conference facilities, parking                        |
| Nappy Valley    | 3             | beach access, complimentary items, parking                                       |



-- List the percentage of internal flights (departure country being the same as the destination country)
-- Round the result to 2 decimals and display it as percentage(%)
-- Don't include years with no internal flights

-- Take for example the sample data for table flights:

| flight_id | departure_country | arrival_country | airline           | flight_class | flight_date | time_hours | distance_km | flight_price | flight_payment_type       |
| --------- | ----------------- | --------------- | ----------------- | ------------ | ----------- | ---------- | ----------- | ------------ | ------------------------- |
| 1         | Norway            | Indonesia       | Koelpin Group     | economy      | 11-05-19    | 1.3        | 1433.25     | â‚¬2426,02   | diners-club-carte-blanche |
| 2         | Brazil            | Costa Rica      | Collins-Keeling   | first class  | 27-01-21    | 7.68       | 2305.95     | â‚¬1232,81   | americanexpress           |
| 3         | China             | Indonesia       | Bashirian-Grimes  | first class  | 22-04-18    | 4.58       | 2787.33     | â‚¬1754,81   | diners-club-enroute       |
| 4         | Indonesia         | Philippines     | Bartoletti Inc    | economy      | 03-09-18    | 9.41       | 689.55      | â‚¬1632,44   | diners-club-enroute       |
| 5         | China             | United States   | Prosacco-Medhurst | premium      | 26-11-22    | 5.11       | 1980.54     | â‚¬942,87    | visa                      |


SELECT
	flight_yr,
	CONCAT(internal_flights_no,'%') AS internal_flights_percentage
FROM (
		SELECT
			EXTRACT(YEAR FROM flight_date) AS flight_yr,
			ROUND(100.0 *
						COUNT(CASE WHEN departure_country = arrival_country THEN 1 ELSE NULL END)
						/ COUNT(*)
			,2) AS internal_flights_no 
		FROM flights
		GROUP BY EXTRACT(YEAR FROM flight_date)
	) t
WHERE internal_flights_no <> 0
ORDER BY 1


-- Result set sample:

| flight_yr | internal_flights_percentage |
| --------- | --------------------------- |
| 2019      | 3.33%                       |
| 2020      | 6.90%                       |
| 2022      | 3.13%                       |

----------------------------------


SELECT
	t1.airline,
	t1.year,
	t1.total_revenue_eur,
	t1.rank_revenue,
	CONCAT(
			COALESCE(
					ROUND(
							100.00 * (
										t1.total_revenue_eur - LAG(t1.total_revenue_eur) OVER (PARTITION BY t1.airline ORDER BY t1.year)
									 )
										/ LAG(t1.total_revenue_eur) OVER (PARTITION BY t1.airline ORDER BY t1.year)
						,2)
				,0)
			,'%') AS growth_percentage,
	t1.flights_per_airline_per_year,
	CONCAT(ROUND(100.00 * t1.flights_per_airline_per_year / t2.flights_per_year,2),'%') AS flights_percentage
FROM (
		SELECT
			airline,
			EXTRACT(YEAR FROM flight_date) AS year,
			SUM(f.flight_amount_eur) AS total_revenue_eur,
			DENSE_RANK() OVER (PARTITION BY EXTRACT(YEAR FROM flight_date) ORDER BY SUM(flight_amount_eur) DESC) AS rank_revenue,
			COUNT(flight_id) AS flights_per_airline_per_year
		FROM flights f
		--INNER JOIN user_flights uf ON f.flight_id = uf.flight_id
		GROUP BY airline, EXTRACT(YEAR FROM flight_date)
		ORDER BY year
	) t1

INNER JOIN (SELECT
				EXTRACT(YEAR FROM flight_date) AS year,
				COUNT(*) AS flights_per_year
			FROM flights
			GROUP BY EXTRACT(YEAR FROM flight_date)
			) t2 ON t1.year = t2.year