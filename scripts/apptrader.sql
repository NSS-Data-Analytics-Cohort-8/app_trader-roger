-- Your team has been hired by a new company called App Trader to help them explore and gain insights from apps that are made available through the Apple App Store and Android Play Store. App Trader is a broker that purchases the rights to apps from developers in order to market the apps and offer in-app purchase. 

-- Unfortunately, the data for Apple App Store apps and Android Play Store Apps is located in separate tables with no referential integrity.

-- #### 1. Loading the data
-- a. Launch PgAdmin and create a new database called app_trader.  

-- b. Right-click on the app_trader database and choose `Restore...`  

-- c. Use the default values under the `Restore Options` tab. 

-- d. In the `Filename` section, browse to the backup file `app_store_backup.backup` in the data folder of this repository.  

-- e. Click `Restore` to load the database.  

-- f. Verify that you have two tables:  
--     - `app_store_apps` with 7197 rows  
--     - `play_store_apps` with 10840 rows

SELECT COUNT(*)
FROM play_store_apps;

-- #### 2. Assumptions

-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000.
    
-- - For example, an app that costs $2.00 will be purchased for $20,000.
    
-- - The cost of an app is not affected by how many app stores it is on. A $1.00 app on the Apple app store will cost the same as a $1.00 app on both stores. 
    
-- - If an app is on both stores, it's purchase price will be calculated based off of the highest app price between the two stores. 

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, 
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, 
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT appname, MAX(purchase_price) AS max_cost
FROM appunion
GROUP BY appname
ORDER BY max_cost DESC; 

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, 
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, 
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT appname, MAX(purchase_price) AS max_cost
FROM appunion
GROUP BY appname
ORDER BY appname; 
			   


-- b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app.
    
-- - An app that costs $200,000 will make the same per month as an app that costs $1.00. 

-- - An app that is on both app stores will make $10,000 per month. 

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, 
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, 
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT appname,  
	MAX(purchase_price) AS max_cost, 
	CAST(COUNT(appname)*5000 AS MONEY) AS monthly_income
FROM appunion
GROUP BY appname
ORDER BY appname;


-- c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.
    
-- - An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, 
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, 
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
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
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, 
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT appname,  
	MAX(purchase_price) AS max_cost, 
	CAST(COUNT(appname)*5000 AS MONEY) AS monthly_income,
	CAST (1000 AS MONEY) AS monthly_cost,
	(CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY)) AS net
FROM appunion
GROUP BY appname
ORDER BY appname;

-- d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, rating,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, rating,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT appname,  
	MAX(purchase_price) AS max_cost, 
	CAST(COUNT(appname)*5000 AS MONEY) AS monthly_income,
	CAST (1000 AS MONEY) AS monthly_cost,
	(CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY)) AS net,
	(MAX(rating * 2)+1) AS app_rating_life
FROM appunion
GROUP BY appname
ORDER BY appname;

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, rating,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, rating,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT appname, 
	MAX(purchase_price) AS max_cost, 
	CAST(COUNT(appname)*5000 AS MONEY) AS monthly_income,
	CAST (1000 AS MONEY) AS monthly_cost,
	(CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY)) AS net,
	MAX(rating) AS best_rating,
	(MAX(rating * 2)+1)*12 AS app_rating_mo_life,
	((CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY))) * ((MAX(rating * 2)+1)*12) AS lifetime_gross_profit,
	(((CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY))) * ((MAX(rating * 2)+1)*12)) - MAX(purchase_price) AS lifetime_net_profit
FROM appunion
WHERE rating IS NOT NULL
GROUP BY appname
ORDER BY lifetime_net_profit DESC, appname;


-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.


WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, rating,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, rating,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT appname, 
	MAX(purchase_price) AS max_cost, 
	CAST(COUNT(appname)*5000 AS MONEY) AS monthly_income,
	CAST (1000 AS MONEY) AS monthly_cost,
	(CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY)) AS net,
	MAX(rating) AS best_rating,
	(MAX(rating * 2)+1)*12 AS app_rating_mo_life,
	((CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY))) * ((MAX(rating * 2)+1)*12) AS lifetime_gross_profit,
	(((CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY))) * ((MAX(rating * 2)+1)*12)) - MAX(purchase_price) AS lifetime_net_profit
FROM appunion
WHERE rating IS NOT NULL
GROUP BY appname
ORDER BY lifetime_net_profit DESC, appname;

-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, rating, content_rating, primary_genre AS genre,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, rating, content_rating, genres AS genre,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT genre, ROUND(AVG(rating),5) AS avg_rating
FROM appunion
WHERE rating IS NOT NULL
GROUP BY genre
ORDER BY avg_rating DESC;


-- There are many free games, and if the prices are $, then they can be purchased for $10,000.
--

-- b. Develop a Top 10 List of the apps that App Trader should buy.

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, rating, content_rating, primary_genre AS genre,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, rating, content_rating, genres AS genre,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT appname, 
	MAX(purchase_price) AS max_cost, 
	CAST(COUNT(appname)*5000 AS MONEY) AS monthly_income,
	CAST (1000 AS MONEY) AS monthly_cost,
	(CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY)) AS net,
	ROUND(ROUND(AVG(rating)/5,1)*5,1) AS avg_rating,
	(ROUND(ROUND((AVG(rating * 2)+1)*12)/5,1)*5) AS app_rating_mo_life,
	((CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY))) * ((AVG(rating * 2)+1)*12) AS lifetime_gross_profit,
	(((CAST(COUNT(appname)*5000 AS MONEY)) - (CAST (1000 AS MONEY))) * ((AVG(rating * 2)+1)*12)) - MAX(purchase_price) AS lifetime_net_profit
FROM appunion
WHERE rating IS NOT NULL
GROUP BY appname
ORDER BY lifetime_net_profit DESC, appname
LIMIT 20;

-- "Solitaire"--1
-- "Bubble Shooter" (only playstore)
-- "PewDiePie's Tuber Simulator"--2
-- "ASOS"--3
-- "Domino's Pizza USA" (Probably not for sale)
-- "Egg, Inc."--4
-- "The Guardian" (Probably not for sale)
-- "Cytus"--5
-- "Geometry Dash Lite"--6
-- "English Grammar Test" (only playstore)
-- "Period Tracker" (only playstore)
-- "H*nest Meditation"--7
-- "Fernanfloo"--8
-- "Bible" (Probably not for sale)
-- "Flashlight" (only playstore)
-- "Narcos: Cartel Wars"--9
-- "Ruler" (only playstore)
-- "Toy Blast"--10
-- "Zombie Catchers"--11
-- "The EO Bar"--12

-- APP REVIEW, appname, system, rating, and genre.

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, rating, content_rating, primary_genre AS genre,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, rating, content_rating, genres AS genre,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT appname, system, rating, genre
FROM appunion
WHERE appname = 'Bubble Shooter';

WITH appunion AS
(SELECT 'appstore' AS system, TRIM(name) AS appname, rating, content_rating, primary_genre AS genre,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM app_store_apps
UNION 
SELECT 'playstore' AS system, TRIM(name) AS appname, rating, content_rating, genres AS genre,
CASE WHEN CAST(price AS MONEY) <= '$1.00' THEN '$10,000.00'
	ELSE (CAST (price AS MONEY) * 10000) END AS purchase_price
FROM play_store_apps)
SELECT count(appname)
FROM appunion
WHERE appname = 'Bubble Shooter';