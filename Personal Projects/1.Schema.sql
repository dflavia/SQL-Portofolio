CREATE DATABASE travel
    WITH
    OWNER = flaff
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;


CREATE TABLE demographic(
	user_id SMALLSERIAL PRIMARY KEY, -- autoincrement, unique, not null, range 1 - 200
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(50),
	phone_number VARCHAR(50) NOT NULL,
	gender VARCHAR(50) NOT NULL,
	country_of_origin VARCHAR(50) NOT NULL,
	date_of_birth DATE NOT NULL,
	profession VARCHAR(50)
);

CREATE TABLE flights (
	flight_id SMALLSERIAL PRIMARY KEY, -- autoincrement, unique, not null, range 1 - 150 						
	departure_country VARCHAR(50) NOT NULL, 		
	arrival_country VARCHAR(50) NOT NULL,	
	airline VARCHAR(50) NOT NULL,			
	flight_class VARCHAR(50) NOT NULL,		
	flight_date DATE NOT NULL,				
	time_hours DECIMAL(4,2) NOT NULL,			-- range 0 to 00 w/ 2 decimals
	distance_km DECIMAL(6,2) NOT NULL,			-- range 000 to 0000 w/ 2 decimals
	flight_price VARCHAR(50) NOT NULL,			
	flight_payment_type VARCHAR(50) NOT NULL,
	flight_amount_eur DECIMAL(6,2) NOT NULL
);

CREATE TABLE resorts (
	resort_id SMALLSERIAL PRIMARY KEY, -- -- autoincrement, unique, not null, range 1 - 100
	resort_name VARCHAR(50) NOT NULL,
	resort_rating INT NOT NULL,
	resort_country VARCHAR(50) NOT NULL,
	duration_of_stay INT NOT NULL,
	resort_price DECIMAL(7,2) NOT NULL,
	resort_currency CHAR(3) NOT NULL,
	resort_city VARCHAR(50) NOT NULL,
	resort_payment_type VARCHAR(50) NOT NULL
);

CREATE TABLE facilities (
	facilities_id SMALLSERIAL PRIMARY KEY,
	facilities_options VARCHAR(50) NOT NULL
);

CREATE TABLE resort_facilities (
	resort_id INT REFERENCES resorts(resort_id),
	facilities_id INT REFERENCES facilities(facilities_id)
);

CREATE TABLE itinerary (
	user_id INT REFERENCES demographic(user_id),
	flight_id INT REFERENCES flights(flight_id),
);