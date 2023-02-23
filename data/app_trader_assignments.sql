-- ### App Trader

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

-----SELECT ALL FROM BOTH TABLES TO PREVIEW-----

SELECT * 
FROM app_store_apps;

SELECT *
FROM play_store_apps;

-----SELECT DISTINCT PRICE POINTS PER STORE-----

SELECT DISTINCT(CAST(price AS MONEY))
FROM play_store_apps;
--OUTPUT there are 92 distinct prices in the play_store

SELECT DISTINCT(CAST(price AS MONEY))
FROM app_store_apps;
--OUTPUT there are 36 distinct prices in the app_store
--Both of these outputs were needed to begin building a query piece by piece

-----SELECT HIGHEST/LOWEST/AVG PRICE POINTS PER STORES-----
SELECT MAX(DISTINCT(CAST(price AS MONEY)))
FROM play_store_apps;
--OUTPUT $400

SELECT MAX(DISTINCT(CAST(price AS MONEY)))
FROM app_store_apps;
--OUTPUT $299

SELECT MIN(DISTINCT(CAST(price AS numeric))) 
FROM play_store_apps
WHERE CAST(price AS numeric) > 0;
--OUTPUT (can't get this one to work due to invalid data type comparisons, but we can assume the lowest price above $0 is $.99)

SELECT MIN(DISTINCT(CAST(price AS MONEY)))
FROM app_store_apps
WHERE price > 0;
--OUTPUT $299


------UNION BOTH TABLES TO PREVIEW RESULTS-------
SELECT 
	name,
	CAST(price AS MONEY),
	rating,
	content_rating
FROM app_store_apps
WHERE rating IS NOT NULL
UNION 
SELECT 
	name,
	CAST(price AS MONEY),
	rating,
	content_rating
FROM play_store_apps
WHERE rating IS NOT NULL
--UNION OUTPUT--

-- "FK Dedinje BGD"					"$0.00"	5.0	"Everyone"
-- "Awake Dating"					"$0.00"	5.0	"Mature 17+"
-- "UP EB Bill Payment & Details"	"$0.00"	5.0	"Teen"
-- "BI News"						"$0.00"	5.0	"Everyone"
-- "Railroad Radio Vancouver BC"	"$0.00"	5.0	"Teen"

-----FIND TOP RATED CONTENT RATINGS PER STORE-----

SELECT 
	DISTINCT content_rating,
	rating
FROM app_store_apps
WHERE rating IS NOT NULL
ORDER BY rating DESC
LIMIT 10;

-----THE APP STORES TOP CONTENT RATING BY RATING BELOW, THIS SHOULD POINT TOWARD THE AGE GROUP AND TYPE OF APPS WE'D RECOMMEND-----
-- "12+" 5.0
-- "9+"	5.0
-- "17+" 5.0
-- "4+"	5.0
-- "9+"	4.5

SELECT
	DISTINCT content_rating,
	rating
FROM play_store_apps
WHERE rating IS NOT NULL
ORDER BY rating DESC
LIMIT 10;

-----THE PLAY STORES TOP CONTENT RATING BY RATING BELOW, THIS SHOULD POINT TOWARD THE AGE GROUP AND TYPE OF APPS WE'D RECOMMEND-----
-- "Everyone" 5.0
-- "Mature 17+"	5.0
-- "Teen"	5.0
-- "Everyone 10+" 5.0
-- "Everyone"	4.9

												----------CONCLUSIONS----------
-- Both app stores have top rating for games that are meant for a wide range of ages, though the playstore leans toward adult content

-----CTE TO DRILL DOWN ON GENRE -----
WITH one AS 
(
	SELECT
		name, 
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating IS NOT NULL
UNION
	SELECT
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating IS NOT NULL
)
SELECT  
	COUNT(name) as app_count,
	primary_genre
FROM one
GROUP BY primary_genre
ORDER BY app_count DESC

												----------CONCLUSIONS----------
-- The genres with the most apps are below, we can use these to filter down to the most abundant apps. With this information, I'm curious about the avg price per genre to narrow our search down further
-- 3861	"Games"
-- 1006	"Entertainment"
-- 883	"Education"
-- 720	"Tools"
-- 476	"Productivity"

WITH one AS 
(
	SELECT
		name, 
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating IS NOT NULL
UNION
	SELECT
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating IS NOT NULL
)
SELECT
	primary_genre,
	ROUND(AVG(CAST(price as numeric)),2) AS avg_app_price
FROM one
WHERE primary_genre IN 
	('Entertainment', 'Games', 'Education', 'Tools', 'Productivity')
GROUP BY primary_genre
ORDER BY avg_app_price DESC;

----------OUTPUT----------
-- "Education"		2.22
-- "Entertainment"	2.08
-- "Productivity"	1.77
-- "Games"			1.43
-- "Tools"			0.29

WITH one AS 
(
	SELECT
		name, 
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating IS NOT NULL
UNION
	SELECT
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating IS NOT NULL
)
SELECT
	primary_genre,
	ROUND(AVG(rating),1) AS avg_rating
FROM one
WHERE primary_genre IN 
	('Entertainment', 'Games', 'Education', 'Tools', 'Productivity')
GROUP BY primary_genre
ORDER BY avg_rating DESC;
----------OUTPUT---------
-- "Productivity"	4.1
-- "Tools"			4.0
-- "Education"		3.8
-- "Games"			3.7
-- "Entertainment"	3.6
-- THE BEST RATED APPS FALL INTO THE PRODUCTIVITY AND TOOLS GENRES

												----------CONCLUSIONS----------
-- Our top genres have a low price on avg. We should focus on purchasing apps within these genres because they are numerous, are well rated, and have a low price point.

-----LOOK AT TOP RATED GAMES WITH RATING >=4-----
WITH one AS 
(
	SELECT
		'app_store' as system,
		name, 
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating IS NOT NULL
UNION
	SELECT
		'play_store' as system,
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating IS NOT NULL
)
SELECT
	system,
	name,
	rating,
	price
FROM one
WHERE primary_genre IN 
	('Entertainment', 'Games', 'Education', 'Tools', 'Productivity')
AND rating >=4
ORDER BY rating DESC;
-----OUTPUT-----
--a list of 4,930 games between both stores that are rated 4 stars or more.

-----NOW BRINGING IN THE PRICE BETWEEN $0 - $1-----
WITH one AS 
(
	SELECT
		'app_store' as system,
		name, 
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating IS NOT NULL
UNION
	SELECT
		'play_store' as system,
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating IS NOT NULL
)
SELECT
	system,
	name,
	rating,
	price
FROM one
WHERE primary_genre IN 
	('Entertainment', 'Games', 'Education', 'Tools', 'Productivity')
	AND rating >=4
	AND price BETWEEN '$0.00' AND '$1.00'
ORDER BY rating DESC;
-----OUTPUT-----
--OUR PREVIOUS LIST 4,930 GAMES HAS SHORTENED TO 3603 GAMES, NARROWING DOWN ON GAMES TO RECOMMEND-----







-----CASE STATEMENT TO SHOW APP COST-----
CASE WHEN price <= '$1.00' THEN '$10,000.00'
ELSE (price * 10000) END AS cost


----------NEXT STEP IS TO TRY AND COMPARE PRICES BETWEEN APP STORES AND CALCULATE THE COST PER APP----------


-- #### 2. Assumptions

-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000.
    
-- - For example, an app that costs $2.00 will be purchased for $20,000.
    
-- - The cost of an app is not affected by how many app stores it is on. A $1.00 app on the Apple app store will cost the same as a $1.00 app on both stores. 
    
-- - If an app is on both stores, it's purchase price will be calculated based off of the highest app price between the two stores. 

-- b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app.
    
-- - An app that costs $200,000 will make the same per month as an app that costs $1.00. 

-- - An app that is on both app stores will make $10,000 per month. 

-- c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.
    
-- - An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

-- d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

SELECT 
	'appstore' as system,
	ROUND(AVG(rating),1)
FROM app_store_apps
WHERE rating IS NOT NULL
UNION 
SELECT 
	'playstore' as system,
	ROUND(AVG(rating),1)
FROM play_store_apps
WHERE rating IS NOT NULL;

--the avg ratings per stores are
-- "appstore"	3.5
-- "playstore"	4.2


-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.


-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.





-- updated 2/18/2023
