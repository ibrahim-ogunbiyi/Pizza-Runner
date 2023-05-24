/* Pizza Metrics Challenge -- Geek */

-- 1. How many pizzas were ordered.
SELECT COUNT(order_id) AS total_pizza_ordered
FROM pizza_runner.customer_orders;

--2. How many unique customer orders were made?
SELECT COUNT(DISTINCT customer_id) AS unique_customer_orders
FROM pizza_runner.customer_orders;

--3. How many successful orders were delivered by each runner?

SELECT COUNT(order_id) AS successfull_orders
FROM pizza_runner.runner_orders
WHERE cancellation IS NULL;

-- 4. How many of each type of pizza was delivered?
SELECT pizza_name, numbers_delivered
FROM pizza_runner.pizza_names
INNER JOIN
(SELECT pizza_id, COUNT(*) AS numbers_delivered
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
USING(order_id)
WHERE cancellation IS NULL
GROUP BY pizza_id) AS result
USING(pizza_id);

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT *
FROM pizza_runner.pizza_names;

SELECT 
	customer_id,
	SUM(CASE WHEN pizza_id = 1  THEN 1 ELSE 0 END) AS Meatlovers, 
	SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END ) AS Vegetarian
FROM pizza_runner.customer_orders
GROUP BY customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT COUNT(pizza_id) AS no_of_pizzas
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
USING(order_id)
WHERE cancellation IS NULL
GROUP BY pizza_runner.customer_orders.order_id
ORDER BY no_of_pizzas DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
	customer_id,
	SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS had_change,
	SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS no_change
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders
USING(order_id)
WHERE cancellation IS NULL
GROUP BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
COUNT(order_id) AS no_of_pizza
FROM pizza_runner.customer_orders
INNER JOIN pizza_runner.runner_orders 
USING(order_id)
WHERE cancellation IS NULL AND (exclusions IS NOT NULL AND extras IS NOT NULL)

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
	EXTRACT(HOUR FROM order_time) AS hour_of_the_day,
	COUNT(order_id) AS total_volume_of_pizzas 
FROM pizza_runner.customer_orders
GROUP BY EXTRACT(HOUR FROM order_time);

-- 10. What was the volume of orders for each day of the week?
SELECT 
	to_char(order_time, 'Day') AS dow,
	COUNT(DISTINCT order_id) AS volume_order
FROM pizza_runner.customer_orders
GROUP BY to_char(order_time, 'Day');

