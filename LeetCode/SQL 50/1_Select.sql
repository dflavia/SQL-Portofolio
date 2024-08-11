-- 1757. Recyclable and Low Fat Products
-- products(product_id, low_fats, recyclable)

-- Write a solution to find the ids of products that are both low fat and recyclable.

SELECT product_id
FROM products
WHERE low_fats = 'Y'
AND recyclable = 'Y';


-- 584. Find Customer Referee
-- customer(id, name, referee_id)

-- Find the names of the customer that are not referred by the customer with id = 2.

SELECT name
FROM customer
WHERE COALESCE(referee_id,0) <> 2;


-- 595. Big Countries
-- world(name, continent, area, population, gdp)
-- A country is big if:
-- it has an area of at least three million (i.e., 3000000 km2), or
-- it has a population of at least twenty-five million (i.e., 25000000).

-- Write a solution to find the name, population, and area of the big countries.

SELECT name, population, area
FROM world
WHERE area >= 3000000
OR population >= 25000000;


-- 1148. Article Views I
-- views(article_id, author_id, viewer_id, view_date)

-- Write a solution to find all the authors that viewed at least one of their own articles.
-- Return the result table sorted by id in ascending order.

SELECT DISTINCT author_id AS id
FROM views
WHERE author_id = viewer_id
ORDER BY id;


-- 1683. Invalid Tweets
-- tweets(tweet_id, content)

-- Write a solution to find the IDs of the invalid tweets. The tweet is invalid if the number of characters used in the content of the tweet is strictly greater than 15

SELECT tweet_id
FROM tweets
WHERE LENGTH(content) > 15;