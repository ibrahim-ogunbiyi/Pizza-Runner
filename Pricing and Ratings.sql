/* Pricing and Ratings */

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges
-- for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT 
	SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS total_revenue
FROM pizza_runner.customer_orders;


-- 2. What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

SELECT
	SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) + 
	(ARRAY_LENGTH(string_to_array((string_agg(extras, ',')), ','), 1)) *1 AS total_revenue
FROM pizza_runner.customer_orders;

-- 3. The Pizza Runner team now wants to add an additional ratings system that 
-- allows customers to rate their runner, how would you design an additional table for 
-- this new dataset - generate a schema for this new table and insert your own data for ratings for 
-- each successful customer order between 1 to 5.

SELECT
	*
FROM pizza_runner.customer_orders;

DROP TABLE IF EXISTS pizza_runner.customer_ratings; 
CREATE TABLE pizza_runner.customer_ratings(
	
	order_id INTEGER PRIMARY KEY,
	customer_id INTEGER,
	runner_id INTEGER,
	ratings INTEGER
);

INSERT INTO pizza_runner.customer_ratings(order_id, customer_id, runner_id)
SELECT DISTINCT r.order_id, customer_id, runner_id
	FROM pizza_runner.customer_orders
	INNER JOIN pizza_runner.runner_orders AS r
	USING(order_id); 

UPDATE pizza_runner.customer_ratings
SET ratings = 
CASE WHEN order_id = 1 THEN 1
WHEN order_id = 2 THEN 5
WHEN order_id = 3 THEN 4
WHEN order_id = 4 THEN 4
WHEN order_id = 5 THEN 2
WHEN order_id = 6 THEN 3
WHEN order_id = 7 THEN 5
WHEN order_id = 8 THEN 3
WHEN order_id = 9 THEN 5
WHEN order_id = 10 THEN 2
END
WHERE ratings IS NULL;

SELECT *
FROM pizza_runner.customer_ratings;

-- 4. 

SELECT 
	c.customer_id,
	c.order_id,
	r.runner_id,
	ratings,
	order_time,
	pickup_time,
	pickup_time::timestamp - order_time::timestamp AS time_difference,
	duration,
	AVG((distance::NUMERIC * 1000) / (duration::INT *60)) 
	OVER(PARTITION BY r.runner_id, order_id) AS average_speed,
	COUNT(pizza_id)OVER(PARTITION BY order_id) AS total_no_of_pizzas
FROM pizza_runner.customer_orders AS c
INNER JOIN pizza_runner.runner_orders AS r
USING(order_id)
INNER JOIN pizza_runner.customer_ratings
USING(order_id);

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost
-- for extras and each runner is paid $0.30 per kilometre traveled - 
 -- how much money does Pizza Runner have left over after these deliveries?
 
SELECT SUM(pizza_cost) -  SUM(duration_cost) As total_profit
FROM(
SELECT
	order_id, 
	SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) As pizza_cost,
	SUM(DISTINCT r.duration::NUMERIC) * 0.30 AS duration_cost
FROM pizza_runner.customer_orders AS c
INNER JOIN pizza_runner.runner_orders AS r
USING(order_id)
WHERE cancellation IS NULL
GROUP BY order_id
) AS result;

