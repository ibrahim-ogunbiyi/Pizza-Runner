-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)


SELECT 
	FLOOR((registration_date - '2021-01-01'::date) / 7) + 1 AS week,
	COUNT(runner_id) AS no_of_registration
FROM pizza_runner.runners
GROUP BY week
ORDER BY week;

-- 2. What was the average time in minutes it took for each runner 
--    to arrive at the Pizza Runner HQ to pickup the order?

SELECT
	runner_id,
	EXTRACT(EPOCH FROM AVG(pickup_time::time)) / 60 AS average_time
FROM pizza_runner.runner_orders
GROUP BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH result AS
(SELECT 
	order_id,
	COUNT(pizza_id) AS no_of_pizza,
	AVG(pickup_time::timestamp - order_time::timestamp) AS avg_time
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
USING(order_id)
GROUP BY order_id
ORDER BY no_of_pizza)

SELECT CORR(no_of_pizza, EXTRACT(EPOCH FROM avg_time)) AS relationship
FROM result;

-- 4. What was the average distance travelled for each customer?
SELECT 
	customer_id,
	ROUND(AVG(distance::NUMERIC), 2) AS average_distance
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
USING(order_id)
GROUP BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT 
	MAX(duration::INT) - MIN(duration::INT) AS times_difference
FROM pizza_runner.runner_orders;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
	runner_id,
	order_id,
	ROUND(AVG((distance::NUMERIC / 1000.0)/ (duration::INT /60.0)), 2) AS speed
FROM pizza_runner.runner_orders
INNER JOIN pizza_runner.customer_orders
USING(order_id)
GROUP BY runner_id, order_id;

-- 7. What is the successful delivery percentage for each runner?
SELECT 
	runner_id,
	ROUND(COUNT(*)FILTER (WHERE cancellation IS NULL) / COUNT(*)::NUMERIC * 100) AS delivery_percentage
FROM pizza_runner.runner_orders
GROUP BY runner_id;
