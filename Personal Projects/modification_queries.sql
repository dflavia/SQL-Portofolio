-- Add a new column in resorts and convert the local prices into EUR, rounded at 2 decimals, based on FX conversion table (resort_fx_conversion)

-- Take for example the sample data for tables: resorts, resort_fx_conversion:


| resort_id | resort_name        | resort_rating | resort_country | duration_of_stay | resort_price | resort_currency | resort_city    | resort_payment_type |
| --------- | ------------------ | ------------- | -------------- | ---------------- | ------------ | --------------- | -------------- | ------------------- \
| 1         | Lazy Lagoon        | 2             | Chile          | 29               | 975490       | CLP             | Lautaro        | maestro             | 
| 2         | Sleepy Sands       | 1             | Colombia       | 2                | 4644360      | COP             | Pizarro        | jcb                 |
| 3         | Chillax Cove       | 5             | Colombia       | 29               | 18777500     | IDR             | Karangkedawung | jcb                 |
| 4         | Snoozeville Resort | 2             | France         | 27               | 2546.47      | BRL             | Formiga        | bankcard            |
| 5         | Lazy River Lodge   | 2             | Brazil         | 29               | 23245900     | IDR             | Jatinagara     | jcb                 |


| resort_currency | target_eur | eur_fx_conversion |
| --------------- | ---------- | ----------------- |
| EUR             | EUR        | 1                 |
| HRK             | EUR        | 0.1327            |
| USD             | EUR        | 0.94              |
| PHP             | EUR        | 0.016             |
| COP             | EUR        | 0.00024           |

	
ALTER TABLE resorts
ADD COLUMN resort_price_eur DECIMAL(8,2)

UPDATE resorts r
SET resort_price_eur = ROUND(r.resort_price * fx.eur_fx_conversion,2)
FROM resort_fx_conversion fx
WHERE r.resort_currency = fx.resort_currency


-- Result set sample:

| resort_id | resort_name        | resort_rating | resort_country | duration_of_stay | resort_price | resort_currency | resort_city    | resort_payment_type | resort_price_eur |
| --------- | ------------------ | ------------- | -------------- | ---------------- | ------------ | --------------- | -------------- | ------------------- | ---------------- |
| 1         | Lazy Lagoon        | 2             | Chile          | 29               | 975490       | CLP             | Lautaro        | maestro             | 955.98           |
| 2         | Sleepy Sands       | 1             | Colombia       | 2                | 4644360      | COP             | Pizarro        | jcb                 | 1114.65          |
| 3         | Chillax Cove       | 5             | Colombia       | 29               | 18777500     | IDR             | Karangkedawung | jcb                 | 1126.65          |
| 4         | Snoozeville Resort | 2             | France         | 27               | 2546.47      | BRL             | Formiga        | bankcard            | 458.36           |
| 5         | Lazy River Lodge   | 2             | Brazil         | 29               | 23245900     | IDR             | Jatinagara     | jcb                 | 1394.75          |



-- Create a new column random_resort_id in table user_flights and populate it with a random resort id that matches the arrival country of the flight

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


ALTER TABLE user_flights
ADD COLUMN random_resort_id INT 

UPDATE user_flights uf
SET random_resort_id = t.random_resort_id
FROM (
		SELECT
			*,
			(split_part( -- split string based on specified delimiter and find the nth position
						possible_resorts, -- string of possible resort ids from subquery below
						',', -- delimniter
						(random()*(LENGTH(possible_resorts)-LENGTH(REPLACE(possible_resorts, ',', '')))+1)::int -- generate a random position between 0 and total no of resorts, cast no as int
						))::int AS random_resort_id
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
	) t
WHERE
	uf.user_id = t.user_id
	AND uf.flight_id = t.flight_id


-- Result set sample:

| user_id | flight_id | random_resort_id |
| ------- | --------- | ---------------- |
| 104     | 64        | 98               |
| 170     | 126       | 37               |
| 145     | 117       | 46               |
| 142     | 26        | 32               |
| 7       | 14        | 77               |