Based on research completed prior to launching App Trader as a company, you can assume the following:
select *
From app_store_apps;
a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000.
Select name
from app_store_apps
Intersect
select name
from play_store_apps;
- For example, an app that costs $2.00 will be purchased for $20,000.
    
- The cost of an app is not affected by how many app stores it is on. A $1.00 app on the Apple app store will cost the same as a $1.00 app on both stores. 
    
- If an app is on both stores, it's purchase price will be calculated based off of the highest app price between the two stores. 

b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app.
- An app that costs $200,000 will make the same per month as an app that costs $1.00.
- An app that is on both app stores will make $10,000 per month. 

SELECT app.name, 'app_store' AS app_store, 5000 AS monthly_earnings
FROM app_store_apps AS app
UNION
SELECT app.name, 'play_store' AS app_store, 5000 AS monthly_earnings
FROM play_store_apps AS app; ----this only gave me 500 as the monthly_earnings aka monthly income decided a different approach......


With appunion AS 
	(Select 'appstore' AS system, TRIM(name) AS appname, (CAST (price AS MONEY) * 10000) AS purchase_price
	From app_store_apps
	Where (CAST (Price AS MONEY)*10000) >'0' 
	UNION ALL 
	SELECT 'playstore' AS system, TRIM(name) AS appname, (CAST (price AS MONEY) *10000) AS purchase_price
	From play_store_apps 
	where (cAST (price AS MONEY) *10000) > '0')
Select *
from appunion
Order By appname, purchase_price DESC


WITH appunion AS 
	(SELECT 'appstore' AS system, TRIM(name) AS appname, 
	CASE
	WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) *10000) 
	END AS purchase_price
	FROM app_store_apps
	UNION
	SELECT 'playstore' AS system, TRIM(name) AS appname,
	CASE
	WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST(price AS MONEY) *10000)
	END AS purchase_price 
	FROM play_store_apps)
SELECT appname, (COUNT(appname) * 5000) AS monthly_income,
MAX(purchase_price) AS max_cost
FROM appunion
GROUP BY appname
ORDER BY appname;


WITH appunion AS 
	(SELECT 'appstore' AS system, TRIM(name) AS appname, 
	CASE
	WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) *10000) 
	END AS purchase_price
	FROM app_store_apps
	UNION
	SELECT 'playstore' AS system, TRIM(name) AS appname,
	CASE
	WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST(price AS MONEY) *10000)
	END AS purchase_price 
	FROM play_store_apps)
SELECT appname, 
MAX(purchase_price) AS max_cost,
CAST(COUNT(appname)*5000 AS MONEY) AS monthly_income,
CAST (1000 AS MONEY) AS monthly_cost
FROM appunion
GROUP BY appname
ORDER BY appname;

WITH appunion AS 
	(SELECT 'appstore' AS system, TRIM(name) AS appname, 
	CASE
		WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
		ELSE (CAST(price AS MONEY) * 10000) 
	END AS purchase_price,
	rating
	FROM app_store_apps
	UNION
	SELECT 'playstore' AS system, TRIM(name) AS appname,
	CASE
		WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
		ELSE (CAST(price AS MONEY) * 10000)
	END AS purchase_price,
	rating
	FROM play_store_apps)
SELECT appname, 
	MAX(purchase_price) AS max_cost,
	CAST(COUNT(appname) * 5000 AS MONEY) AS monthly_income,
	CAST(1000 AS MONEY) AS monthly_cost,
	MAX(rating) AS best_rating
FROM appunion
GROUP BY appname
ORDER BY appname;

WITH appunion AS 
(
    SELECT 'appstore' AS system, TRIM(name) AS appname, 
        CASE
            WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
            ELSE (CAST (price AS MONEY) *10000) 
        END AS purchase_price,
        rating,
        primary_genre AS genres
    FROM app_store_apps
    UNION
    SELECT 'playstore' AS system, TRIM(name) AS appname,
        CASE
            WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
            ELSE (CAST(price AS MONEY) *10000)
        END AS purchase_price,
        rating,
        genres
    FROM play_store_apps
)
SELECT appname, 
    MAX(purchase_price) AS max_cost,
    CAST(COUNT(appname)*5000 AS MONEY) AS monthly_income,
    CAST (1000 AS MONEY) AS monthly_cost,
    MAX(rating) AS best_rating,
    genres
FROM appunion
GROUP BY appname, genres
ORDER BY appname


WITH appunion AS 
(
    SELECT 'appstore' AS system, TRIM(name) AS appname, 
        CASE
            WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
            ELSE (CAST (price AS MONEY) *10000) 
        END AS purchase_price,
        rating,
        primary_genre AS genres
    FROM app_store_apps
    UNION
    SELECT 'playstore' AS system, TRIM(name) AS appname,
        CASE
            WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
            ELSE (CAST(price AS MONEY) *10000)
        END AS purchase_price,
        rating,
        genres
    FROM play_store_apps
)
SELECT appname, 
    MAX(purchase_price) AS max_cost,
    CAST(COUNT(appname)*5000 AS MONEY) AS monthly_income,
    CAST(1000 AS MONEY) AS monthly_cost,
    ROUND(AVG(rating), 1) AS average_rating,
    genres,
    CASE
        WHEN ROUND(AVG(rating), 1) <= 0.5 THEN 1
        WHEN ROUND(AVG(rating), 1) >= 4.0 THEN 9
        ELSE ROUND((ROUND(AVG(rating), 1) - 0.5) * 2) + 1
    END AS projected_lifespan
FROM appunion
WHERE system IN ('appstore', 'playstore')
GROUP BY appname, genres
HAVING COUNT(DISTINCT system) = 2
ORDER BY max_cost DESC




I decided to figure out my top ten apps by looking at the best rating apps between both app stores. 


c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.
    
- An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
    
- App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.





#### 3. Deliverables

a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

b. Develop a Top 10 List of the apps that App Trader should buy.



updated 2/18/2023
