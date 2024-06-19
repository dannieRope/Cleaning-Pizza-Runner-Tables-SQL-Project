# Data cleaning - SQL Project 

Data cleaning is one of the most important aspects of data analysis. One could ask why data analysts spend most of their time trying to identify and remove errors and inconsistencies.
Inaccurate conclusions and poor decision-making can result from incomplete or inconsistent data.

Data quality is increased through cleaning. Reliable decision-making is facilitated by accurate analysis of data that is free of errors, such as typos, duplicates, missing values, and incorrect data types.

# The Dataset 

This data cleaning project is a part of 8 week SQL Challenge - Case Study #2(PIZZA RUNNER)

All datasets provided exist within the [pizza_runner](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65) database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

The Entit Releationship Diagram can be seen below. 


Table 1: runners

The runners table shows the `registration_date` for each new runner

Table 2: customer_orders

Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order.

The `pizza_id` relates to the type of pizza which was ordered whilst the `exclusions` are the ingredient_id values which should be removed from the pizza and the `extras` are the ingredient_id values which need to be added to the pizza.

Note that customers can order multiple pizzas in a single order with varying exclusions and extras values even if the pizza is the same type!

The `exclusions` and `extras` columns will need to be cleaned up before using them in your queries.

Table 3: runner_orders
After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.

The `pickup_time` is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The `distance` and `duration` fields are related to how far and long the runner had to travel to deliver the order to the respective customer.


Table 4: pizza_names
At the moment - Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!

Table 5: pizza_recipes
Each `pizza_id` has a standard set of toppings which are used as part of the pizza recipe.

Table 6: pizza_toppings
This table contains all of the `topping_name` values with their corresponding `topping_id` value

# Data Cleaning
Before we start the cleaning process, it is best practice to go through the data to discover the data quality issues and abnormalities in the data.

``sql
  SELECT *
  FROM [pizza_runner].[customer_orders];
  SELECT * FROM pizza_names;
  SELECT * FROM pizza_recipes;
  SELECT * FROM pizza_toppings;
  SELECT * FROM runner_orders;
  SELECT * FROM runners;
``
## The `customer_orders` Table

Data Quality issues observed are

-In the exclusions column, the presense of ‘null’ and ‘ ‘ instead of NULL
-In the extras column, the presence of ‘null’ and ‘ ‘ instead of NULL
-The exclusions & extras column contains comma separated values. It may require us to each value on seperate rows so we need to fix that as well. 

``sql
--Retrieve all records from the customer_orders table
SELECT *
FROM [pizza_runner].[customer_orders];
``

Clearning Script 

``sql
--Replacing the null and blank values with NULL in both exclusions and extras columns

UPDATE [pizza_runner].[customer_orders]
SET exclusions = CASE 
                      WHEN LTRIM(RTRIM(exclusions))= '' THEN REPLACE(exclusions,' ',NULL)
                      WHEN exclusions= 'null' THEN NULL ELSE exclusions 
			     END,
     extras =   CASE 
                       WHEN extras = 'null' THEN NULL 
					   WHEN TRIM(extras) = '' THEN NULL ELSE extras 
                 END;
``
OUTPUT

``sql 
--Dealing with comma seperated values in both exclusions and extras column and
--Storing the data in a temporary table 
INSERT INTO #customer_orders_clean
SELECT order_id,
       customer_id,
	   pizza_id,
	   TRIM(c1.value) AS exclusions,
	   TRIM(c2.value) AS extras,
	   order_time
FROM [pizza_runner].[customer_orders]
outer APPLY string_split(TRIM(exclusions),',') AS c1
outer APPLY string_split(TRIM(extras),',') AS c2
``
OUTPUT

## The `runner_orders` Table

Data Quality issues observed are

-the pickup_time column has ‘null’ values
-the distance column has the appearance of ‘km’, ‘null’ values and ‘ km’
-the duration column has the appearance of ‘minutes’, ‘null’, ‘mins’, ‘minute’
-the cancellation column has the appearance of ‘null’ and ‘ ‘
-Change the data types of the corrected columns

``sql
--Retrieve all records from the runner_orders table
SELECT *
FROM [pizza_runner].[runner_orders];
``

Cleaning Script

``sql
UPDATE [pizza_runner].[runner_orders]
SET distance = CASE WHEN distance = 'null' THEN NULL
                    WHEN distance like '%Km%' THEN TRIM(SUBSTRING(distance,CHARINDEX('K',duration),2)) ELSE distance    
			   END,
    pickup_time = CASE WHEN pickup_time = 'null' THEN NULL ELSE pickup_time END,
	duration =    CASE WHEN duration  LIKE '%min%' THEN SUBSTRING(duration,1,CHARINDEX('m',duration)-1)
	                   WHEN duration = 'null' THEN NULL ELSE duration 
	              END,
	cancellation = CASE WHEN TRIM(cancellation) = '' THEN NULL
	                    WHEN cancellation = 'null' THEN NULL ELSE cancellation
				   END;
``

``sql
--Change distance and duration column datatype to numeric
ALTER  TABLE [pizza_runner].[runner_orders]
ALTER COLUMN distance NUMERIC;

ALTER  TABLE [pizza_runner].[runner_orders]
ALTER COLUMN duration NUMERIC;
``

OUTPUT

## The `pizza_recipes` Table


Data Quality issues observed:
-the toppings column contains comma separated values which needs to be separated into each rows of its own.

``sql
SELECT *
FROM [pizza_runner].[pizza_recipes]
``

Cleaning Script 

``sql
-- Create a temporary table to store the clean pizza recipes
CREATE TABLE #pizza_recipes_clean (
    pizza_id INT,
    toppings VARCHAR(255)
);

-- Insert data into the temporary table
INSERT INTO #pizza_recipes_clean (pizza_id, toppings)
SELECT 
    p.pizza_id,
   TRIM(value) AS toppings
FROM 
   [pizza_runner].[pizza_recipes] p
   CROSS APPLY STRING_SPLIT(CAST(p.toppings AS VARCHAR(MAX)), ',')

```
OUTPUT

Thanks For reading and Feel free to comment, share and correct the codes in case of an error. I would also love feedbacks.

## License
[MIT License](LICENSE)











