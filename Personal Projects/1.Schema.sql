-- CREATE DATABASE

CREATE DATABASE travel
    WITH
    OWNER = flaff
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;


-- CREATE TABLES

-- I. Primary Tables:

-- 1. users - list of people taking various flights to different travel destinations; one user may board multiple flights

CREATE TABLE users(
	user_id SMALLSERIAL PRIMARY KEY, -- autoincrement
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(50),
	phone_number VARCHAR(50) NOT NULL,
	gender VARCHAR(50) NOT NULL,
	country_of_origin VARCHAR(50) NOT NULL,
	date_of_birth DATE NOT NULL,
	profession VARCHAR(50)
);


-- 2. flights - list of flights between 2018 - 2020; one flight may accomodate multiple users

CREATE TABLE flights (
	flight_id SMALLSERIAL PRIMARY KEY, -- autoincrement						
	departure_country VARCHAR(50) NOT NULL, 		
	arrival_country VARCHAR(50) NOT NULL,	
	airline VARCHAR(50) NOT NULL,			
	flight_class VARCHAR(50) NOT NULL,		
	flight_date DATE NOT NULL,				
	time_hours DECIMAL(4,2) NOT NULL,			
	distance_km DECIMAL(6,2) NOT NULL,			
	flight_price VARCHAR(50) NOT NULL,			
	flight_payment_type VARCHAR(50) NOT NULL,
);


-- 3. resorts - list of possible resorts that users can book for their vacation, based on the countries that they are flying to; one user may book stays in multiple resorts

CREATE TABLE resorts (
	resort_id SMALLSERIAL PRIMARY KEY, -- -- autoincrement, unique, not null, range 1 - 100
	resort_name VARCHAR(50) UNIQUE NOT NULL,
	resort_rating INT NOT NULL,
	resort_country VARCHAR(50) NOT NULL,
	duration_of_stay INT NOT NULL,
	resort_price DECIMAL(7,2) NOT NULL,
	resort_currency CHAR(3) NOT NULL,
	resort_city VARCHAR(50) NOT NULL,
	resort_payment_type VARCHAR(50) NOT NULL
);


-- 4. facilities - list of various facilities that resorts may offer to their guests; one resort may offer multiple facilities

CREATE TABLE facilities (
	facilities_id SMALLSERIAL PRIMARY KEY,
	facilities_options VARCHAR(50) NOT NULL
);


-- II. Junction Tables

-- 1. user_flights - used in order to indicate what flights each user boarded

CREATE TABLE user_flights (
	user_id INT REFERENCES users(user_id),
	flight_id INT REFERENCES flights(flight_id),
);


-- 2. resort_facilities - used in order to indicate what facilities each resort offers

CREATE TABLE resort_facilities (
	resort_id INT REFERENCES resorts(resort_id),
	facilities_id INT REFERENCES facilities(facilities_id)
);


-- 3. resort_facilities - used in order to convert the resort prices from local currency (as is the source data in resorts table) to EUR figures

CREATE TABLE resort_fx_conversion (
	resort_currency CHAR(3) PRIMARY KEY,
	target_EUR CHAR(3) CHECK (target_EUR = 'EUR'),
	EUR_fx_conversion DECIMAL(6,5)
);


-- CHECK CONSTRAINTS

-- Default code to list full constraint list for a specific table

SELECT con.*
       FROM pg_catalog.pg_constraint con
            INNER JOIN pg_catalog.pg_class rel
                       ON rel.oid = con.conrelid
            INNER JOIN pg_catalog.pg_namespace nsp
                       ON nsp.oid = connamespace
       WHERE nsp.nspname = '<schema name>'
             AND rel.relname = '<table name>';