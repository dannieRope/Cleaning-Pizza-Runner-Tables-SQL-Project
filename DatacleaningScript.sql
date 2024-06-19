
--Data cleaning and preparation
--Cleaning the customer_orders table
SELECT *
FROM [pizza_runner].[customer_orders];


UPDATE [pizza_runner].[customer_orders]
SET exclusions = CASE 
                      WHEN LTRIM(RTRIM(exclusions))= '' THEN REPLACE(exclusions,' ',NULL)
                      WHEN exclusions= 'null' THEN NULL ELSE exclusions 
			     END,
     extras =   CASE 
                       WHEN extras = 'null' THEN NULL 
					   WHEN TRIM(extras) = '' THEN NULL ELSE extras 
                 END;

--Dealing with comma seperated columns
--create a temporary table, insert data and clean 
CREATE TABLE #customer_orders_clean(
order_id INT,
customer_id INT,
pizza_id INT,
exclusions INT,
extras INT,
order_time DATETIME
)

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

SELECT *
FROM #customer_orders_clean


--Cleaning the runner_orders table
SELECT *
FROM [pizza_runner].[runner_orders];

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

--Change distance and duration column datatype to numeric
ALTER  TABLE [pizza_runner].[runner_orders]
ALTER COLUMN distance NUMERIC;

ALTER  TABLE [pizza_runner].[runner_orders]
ALTER COLUMN duration NUMERIC;


--Cleaning Pizza_recipes table
SELECT *
FROM [pizza_runner].[pizza_recipes]
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

SELECT * FROM #pizza_recipes_clean;
