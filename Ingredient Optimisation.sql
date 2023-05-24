
/* Ingredient Optimization */

-- 1. What are the standard ingredients for each pizza?

SELECT pizza_id, topping_name
FROM pizza_runner.pizza_recipes, unnest(string_to_array(toppings, ',')) AS id
INNER JOIN pizza_runner.pizza_toppings
ON id::INTEGER = topping_id
ORDER BY pizza_id, topping_id;

-- 2. What was the most commonly added extra?
SELECT topping_name
FROM pizza_runner.pizza_toppings
WHERE topping_id = 
(SELECT
	MODE()
	WITHIN GROUP (ORDER BY extra::INTEGER)
FROM pizza_runner.customer_orders, 
unnest(string_to_array(extras, ',')) AS extra);

-- 3. What was the most common exclusion?

SELECT topping_name
FROM pizza_runner.pizza_toppings
WHERE topping_id = 
(SELECT
	MODE()
	WITHIN GROUP (ORDER BY exclusion::INTEGER)
FROM pizza_runner.customer_orders, 
unnest(string_to_array(exclusions, ',')) AS exclusion);

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:

SELECT	
	CONCAT(
		CASE WHEN pizza_id = 1 THEN 'Meat Lovers' END,
		CASE WHEN exclusions = '3' THEN ' - Exclude Beef' END,
		CASE WHEN extras = '1' THEN ' - Extra Bacon' END,
		CASE WHEN exclusions = '4, 1' AND extras = '6, 9' THEN
		' - Exclude Cheese, Bacon - Extra Mushroom, Peppers' END
	) AS order_item
FROM pizza_runner.customer_orders;

-- 5. Generate an alphabetically ordered comma separated ingredient list for 
--	each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

WITH meatlovers_ingredient AS
(
	SELECT string_agg(topping_name, ', ')
		FROM pizza_runner.pizza_toppings	
		WHERE topping_id IN(
			SELECT unnest(string_to_array(toppings, ','))::INTEGER
			FROM pizza_runner.pizza_recipes
			INNER JOIN pizza_runner.pizza_names
			USING(pizza_id)
			WHERE pizza_id = 1)
),
vegetarian_ingredient AS
(	
	SELECT string_agg(topping_name, ', ')
		FROM pizza_runner.pizza_toppings	
		WHERE topping_id IN(
			SELECT unnest(string_to_array(toppings, ','))::INT
			FROM pizza_runner.pizza_recipes
			INNER JOIN pizza_runner.pizza_names
			USING(pizza_id)
			WHERE pizza_id = 2)
)
SELECT
	order_id,
	CASE WHEN pizza_id = 1 THEN
	CONCAT('Meat Lovers: 2x',(SELECT * FROM meatlovers_ingredient))
	WHEN pizza_id = 2 THEN
	CONCAT('Vegeterian: 2x', (SELECT * FROM vegetarian_ingredient))
	END AS "order ingredient"
	
FROM pizza_runner.customer_orders;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

WITH ingredient AS
(SELECT
	unnest(string_to_array(toppings, ','))::INTEGER AS ingredient,
	COUNT(*) - COUNT(exclusions) + COUNT(extras) AS frequency
FROM pizza_runner.customer_orders AS c
INNER JOIN pizza_runner.runner_orders AS r
ON (c.order_id = r.order_id) 
INNER JOIN pizza_runner.pizza_recipes AS p
ON (c.pizza_id =  p.pizza_id)
GROUP BY ingredient)

SELECT 
	topping_name,
	frequency
FROM ingredient AS i
INNER JOIN pizza_runner.pizza_toppings AS p
ON i.ingredient = p.topping_id
ORDER BY frequency DESC;