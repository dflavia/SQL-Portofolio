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



-- Replace the trailing roman numerals from the professions in users table

-- Take for example the sample data for table users:

| user_id | first_name | last_name   | email                         | phone_number | gender | country_of_origin | date_of_birth | profession                |
| ------- | ---------- | ----------- | ----------------------------- | ------------ | ------ | ----------------- | ------------- | ------------------------- |
| 193     | Giffy      | Ionnidis    | gionnidis5c@cocolog-nifty.com | 349-278-2607 | Male   | Bulgaria          | 27-10-80      | Programmer II             |
| 194     | Garrard    | McCarron    | gmccarron5d@i2i.jp            | 434-603-7331 | Male   | Argentina         | 16-06-51      | Developer II              |
| 195     | Raimund    | Cuttell     | NULL                          | 628-138-5750 | Male   | Russia            | 19-01-63      | Environmental Specialist  |
| 196     | Rozella    | Banaszewski | rbanaszewski5f@mapquest.com   | 598-170-4817 | Female | Poland            | 12-08-76      | NULL                      |
| 197     | Roslyn     | Cleft       | rcleft5g@booking.com          | 453-503-3339 | Female | Guatemala         | 20-12-80      | Account Representative II |


UPDATE users u
SET profession = t.updated_profession
FROM (
		SELECT
			user_id,
			REGEXP_REPLACE(profession, '\s[IV]+$','') AS updated_profession -- \s ensure that roman numerals are preceded by a space, +$ ensure that roman numerals are at the end of the value
		FROM users
	) t
WHERE u.user_id = t.user_id


-- Result set sample:

| user_id | first_name | last_name   | email                         | phone_number | gender | country_of_origin | date_of_birth | profession               |
| ------- | ---------- | ----------- | ----------------------------- | ------------ | ------ | ----------------- | ------------- | ------------------------ |
| 193     | Giffy      | Ionnidis    | gionnidis5c@cocolog-nifty.com | 349-278-2607 | Male   | Bulgaria          | 27-10-80      | Programmer               |
| 194     | Garrard    | McCarron    | gmccarron5d@i2i.jp            | 434-603-7331 | Male   | Argentina         | 16-06-51      | Developer                |
| 195     | Raimund    | Cuttell     | NULL                          | 628-138-5750 | Male   | Russia            | 19-01-63      | Environmental Specialist |
| 196     | Rozella    | Banaszewski | rbanaszewski5f@mapquest.com   | 598-170-4817 | Female | Poland            | 12-08-76      | NULL                     |
| 197     | Roslyn     | Cleft       | rcleft5g@booking.com          | 453-503-3339 | Female | Guatemala         | 20-12-80      | Account Representative   |



-- Create a view for users table that will display:
-- full name as 'last_name, first_name' instead of first_name and last_name
-- gender as either M or F (instead of 'Male' or 'Female')
-- age instead of date_of_birth

-- Take for example the sample data for table users:

| user_id | first_name | last_name | email                        | phone_number | gender | country_of_origin        | date_of_birth | profession            |
| ------- | ---------- | --------- | ---------------------------- | ------------ | ------ | ------------------------ | ------------- | --------------------- |
| 1       | Curr       | Mushawe   | cmushawe0@newyorker.com      | 245-524-7170 | Male   | Poland                   | 22-10-86      | NULL                  |
| 2       | Fredericka | Hickisson | fhickisson1@flavors.me       | 358-686-3248 | Female | China                    | 02-11-06      | NULL                  |
| 3       | Verena     | Gonsalvez | vgonsalvez2@reverbnation.com | 305-632-9817 | Female | Kazakhstan               | 15-06-56      | Systems Administrator |
| 4       | Estell     | Tivers    | etivers3@imdb.com            | 906-642-7546 | Female | Argentina                | 01-01-12      | NULL                  |
| 5       | Bordy      | Vitler    | bvitler4@nydailynews.com     | 848-962-8647 | Male   | Central African Republic | 05-03-00      | NULL                  |


CREATE VIEW users_view AS
	
SELECT
	user_id,
	CONCAT(last_name,', ',first_name) AS full_name,
	email,
	phone_number,
	CASE
		WHEN gender = 'Male' THEN 'M'
		WHEN gender = 'Female' THEN 'F'
	END AS gender,
	country_of_origin,
	EXTRACT(YEAR FROM AGE(current_date, date_of_birth)) AS age,
	profession
FROM users
ORDER BY user_id


-- Result set sample:

| user_id | full_name             | email                        | phone_number | gender | country_of_origin        | age | profession            |
| ------- | --------------------- | ---------------------------- | ------------ | ------ | ------------------------ | --- | --------------------- |
| 1       | Mushawe, Curr         | cmushawe0@newyorker.com      | 245-524-7170 | M      | Poland                   | 37  | NULL                  |
| 2       | Hickisson, Fredericka | fhickisson1@flavors.me       | 358-686-3248 | F      | China                    | 17  | NULL                  |
| 3       | Gonsalvez, Verena     | vgonsalvez2@reverbnation.com | 305-632-9817 | F      | Kazakhstan               | 68  | Systems Administrator |
| 4       | Tivers, Estell        | etivers3@imdb.com            | 906-642-7546 | F      | Argentina                | 12  | NULL                  |
| 5       | Vitler, Bordy         | bvitler4@nydailynews.com     | 848-962-8647 | M      | Central African Republic | 24  | NULL                  |