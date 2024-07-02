CREATE TABLE restaurants (
    restaurant_id INT,
    restaurant_name VARCHAR(255),
    country_code INT,
    city VARCHAR(255),
    address TEXT,
    locality VARCHAR(255),
    locality_verbose TEXT,
    longitude FLOAT,
    latitude FLOAT,
    cuisines TEXT,
    average_cost_for_two INT,
    currency VARCHAR(50),
    has_table_booking VARCHAR(3),
    has_online_delivery VARCHAR(3),
    is_delivering_now VARCHAR(3),
    switch_to_order_menu VARCHAR(3),
    price_range INT,
    aggregate_rating FLOAT,
    rating_color VARCHAR(50),
    rating_text VARCHAR(50),
    votes INT
);

Drop table restaurants;

select * from restaurants;



--Level 1

--Task1: Top Cuisines

--Determine the top three most common cuisines in the dataset.

Select unnest(string_to_array(cuisines, ', ')), count(restaurant_id) as count_cuisines
from restaurants
group by unnest(string_to_array(cuisines, ', '))
order by count_cuisines desc
limit 3;

--Calculate the percentage of restaurants that serve each of the top cuisines.

WITH cuisine_counts AS (
    SELECT 
        unnest(string_to_array(cuisines, ', ')) AS cuisine,
        COUNT(restaurant_id) AS cuisine_count
    FROM 
        restaurants
    GROUP BY 
        cuisine
),
total_restaurants AS (
    SELECT COUNT(*) AS total_count FROM restaurants
)

SELECT 
    cc.cuisine,
    cc.cuisine_count,
    (cc.cuisine_count::float / tr.total_count::float) * 100 AS count_cuisines
FROM 
    cuisine_counts cc, total_restaurants tr
ORDER BY 
    cc.cuisine_count DESC
	
limit 4	;


--Task 2: City Analysis

-- Identify the city with the highest numberof restaurants in the dataset.

select city, count(restaurant_id) as count_city
from restaurants
group by city
order by count_city desc
limit 1;

-- Calculate the average rating for restaurants in each city.

select city, avg(aggregate_rating) as Avg_rating
from restaurants
group by city
order by city ;

-- Determine the city with the highest average rating.


select city, avg(aggregate_rating) as Avg_rating
from restaurants
group by city
order by Avg_rating desc
limit 1;


-- Task 3: Price Range Distribution

--Calculate the percentage of restaurants in each price range category.

with count_range as
	(select price_range, count(restaurant_id) as count_id
	from restaurants
	group by price_range),
total_count as (select count(*) as total_id_count from restaurants)	

select cr.price_range,
       cr.count_id,
	   (cr.count_id::float/tc.total_id_count::float)*100 as percantage
from count_range as cr,total_count as tc
order by cr.price_range;
	
	
--Task 4: Online Delivery

--Determine the percentage of restaurants that offer online delivery.


with count_online_delivery as
	(select has_online_delivery, count(*) as count_id
	from restaurants
	group by has_online_delivery),
total_count as (select count(*) as total_id_count from restaurants)	

select od.has_online_delivery,
       od.count_id,
	   concat(ROUND((CAST(od.count_id AS numeric) / CAST(tc.total_id_count AS numeric)) * 100, 2),'%') AS percentage
from count_online_delivery as od,total_count tc;


-- Compare the average ratings of restaurants with and without online delivery.

select has_online_delivery,  ROUND(cast(avg(aggregate_rating) as numeric), 2)as avg_rating
from restaurants
group by has_online_delivery;



-- level 2

--Task 1: Restaurant Ratings

--Analyze the distribution of aggregateratings and determine the most common rating range.


select aggregate_rating,
count(*) as count_rating
from restaurants
group by aggregate_rating
order by count_rating desc;

--Calculate the average number of votes received by restaurants.

select avg(votes) as avg_votes
from restaurants;

--Task 2: Cuisine Combination

-- Identify the most common combinations of cuisines in the dataset.

select unnest(string_to_array(cuisines, ', ')) as cuisiness , count(*) as count_cuisines
from restaurants
group by cuisiness
order by count_cuisines desc;

-- Determine if certain cuisine combinations tend to have higher ratings.

select cuisines ,count(aggregate_rating) as higher_rating
from restaurants
group by cuisines
order by higher_rating desc;


--Task 4: Restaurant Chains

--Identify if there are any restaurant chains present in the dataset.


select restaurant_name, count(restaurant_name) as count_restaurant
from restaurants
group by restaurant_name
having count(restaurant_name)>1
order by count_restaurant desc;

-- Analyze the ratings and popularity of different restaurant chains.

select restaurant_name, count(restaurant_name) as num_restaurant, avg(aggregate_rating) as Avg_rating,sum(votes) as total_votes
from restaurants
group by restaurant_name
having count(restaurant_name)>1
order by Avg_rating desc,total_votes desc;

   -- level 3

-- Task 1: Restaurant Reviews

-- Calculate the average length of reviews and explore if there is a relationship between review length and rating.

select aggregate_rating,avg(length(rating_text))
from restaurants
group by aggregate_rating
order by aggregate_rating desc;

--Task 2: Votes Analysis

-- Identify the restaurants with the highest and lowest number of votes.

(SELECT restaurant_name,votes,'highest' AS rank
FROM restaurants
ORDER BY votes DESC
LIMIT 1)
UNION ALL
(SELECT restaurant_name, votes,'lowest' AS rank
FROM restaurants
ORDER BY votes ASC
LIMIT 1);
											 

-- Analyze if there is a correlation between the number of votes and the rating of a restaurant.
											 
SELECT CORR(votes, aggregate_rating) AS correlation_coefficient
FROM restaurants;


-- Task 2: Price Range vs. Online Delivery and Table Booking


-- Analyze if there is a relationship between the price range and the availability of online delivery and table booking.


SELECT price_range, COUNT(*) AS total_restaurants,
    round(avg(CASE WHEN has_online_delivery = 'Yes' THEN 1 ELSE 0 END),3)AS delivery_available,
    round(avg(CASE WHEN has_table_booking = 'Yes' THEN 1 ELSE 0 END),3) AS booking_available
FROM restaurants
GROUP BY price_range;

-- Determine if higher-priced restaurants are more likely to offer these services.

--this is for online_delivery
select has_online_delivery, count(price_range) as higher_price_count
from restaurants
where price_range =4
GROUP BY has_online_delivery;

--this is for table_booking
select has_table_booking, count(price_range) as higher_price_count
from restaurants
where price_range =4
GROUP BY has_table_booking;


											 