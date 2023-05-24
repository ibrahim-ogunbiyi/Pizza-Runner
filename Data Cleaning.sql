-- Data Cleaning

-- Customer Orders

SELECT *
FROM pizza_runner.customer_orders;

-- Exclusions

UPDATE pizza_runner.customer_orders
SET exclusions = 
CASE WHEN exclusions = 'null' THEN NULL
WHEN exclusions = '' THEN NULL
ELSE exclusions::VARCHAR(4) END;

-- Extras

UPDATE pizza_runner.customer_orders
SET extras = 
CASE WHEN extras = 'null' THEN NULL
WHEN extras = '' THEN NULL
ELSE extras::VARCHAR(4) END;

-- Runner Orders

SELECT *
FROM pizza_runner.runner_orders;


-- Cancellation
UPDATE pizza_runner.runner_orders
SET cancellation = 
CASE WHEN cancellation = 'null' THEN NULL
WHEN cancellation = '' THEN NULL
ELSE cancellation::VARCHAR(23) END;

-- Distance
UPDATE pizza_runner.runner_orders
SET distance = 
CASE WHEN distance = 'null' THEN NULL::NUMERIC
WHEN distance = '' THEN NULL
ELSE regexp_replace(distance, '[a-zA-Z]', '', 'g')::NUMERIC END;


-- Duration
UPDATE pizza_runner.runner_orders
SET duration = 
CASE WHEN duration = 'null' THEN NULL::NUMERIC
WHEN distance = '' THEN NULL
ELSE CAST(regexp_replace(duration, '[a-zA-Z]', '', 'g') AS NUMERIC)END;



-- Pickup time
UPDATE pizza_runner.runner_orders
SET pickup_time = 
CASE WHEN pickup_time = 'null' THEN NULL
WHEN pickup_time = ''THEN NULL
ELSE pickup_time END;


-- Runners
SELECT *
FROM pizza_runner.runners;

-- Pizza_names

SELECT *
FROM pizza_runner.pizza_names;

-- Pizza Recipes
SELECT *
FROM pizza_runner.pizza_recipes;

-- Pizza Toppings
SELECT *
FROM pizza_runner.pizza_toppings;
