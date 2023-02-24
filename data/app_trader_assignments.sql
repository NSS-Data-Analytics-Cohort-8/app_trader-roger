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
		'appstore' as system,
		name, 
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
UNION ALL
	SELECT
		'playstore' as system,
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
)
SELECT  
	COUNT(name) as app_count,
	primary_genre
FROM one
GROUP BY primary_genre
ORDER BY app_count DESC
-----OUTPUT-----
--The output includes 122 distinct genres across both stores. The output includes the genres that are rated >=4 and we also see the count of apps in these genres
-- 3861	"Games"
-- 1006	"Entertainment"
-- 883	"Education"
-- 720	"Tools"
-- 476	"Productivity"



-----LOOK AT TOP RATED APPS WITH RATING >=4-----
WITH one AS 
(
	SELECT
		'appstore' as system,
		name, 
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
UNION ALL
	SELECT
		'playstore' as system,
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
)
SELECT
	system,
	name,
	rating,
	price
FROM one
WHERE primary_genre IN 
	('Entertainment', 'Games', 'Education', 'Tools', 'Productivity')
ORDER BY rating DESC;
-----OUTPUT-----
--a list of 5,075 games between both stores that are rated 4+ stars.

WITH one AS 
(
	SELECT
		'appstore' as system,
		name, 
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
UNION ALL
	SELECT
		'playstore' as system,
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
)
SELECT
	system,
	COUNT(name) as app_count
FROM one
WHERE primary_genre IN 
	('Entertainment', 'Games', 'Education', 'Tools', 'Productivity')
GROUP BY system;
-----OUTPUT-----
--Of the 5,075 apps between both stores, 3538 live on the app store and 1537 live in the playstore. Next step is to see which of these 5,075 live in both stores. 

WITH one AS 
(
	SELECT
		'appstore' as system,
		name,
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
UNION ALL
	SELECT
		'playstore' as system,
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
)
SELECT
	name,
	price::MONEY
FROM one
WHERE primary_genre IN 
	('Entertainment', 'Games', 'Education', 'Tools', 'Productivity')
	AND name IN
		(SELECT a.name
		FROM app_store_apps as a
		JOIN play_store_apps as p
		ON a.name = p.name
		)
;
-----OUTPUT-----
--Of the 5,075 apps that are rated >=4 and are in genres with the biggest pool of apps to choose from, there are 269 that live in both app stores.

-----NOW BRINGING IN THE APPS THAT COST BETWEEN $0 - $1-----
WITH one AS 
(
	SELECT
		'appstore' as system,
		name,
		CAST(price AS MONEY) as price,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
UNION ALL
	SELECT
		'playstore' as system,
		name,
		CAST(price AS MONEY) as price,
		genres,
		rating
	FROM play_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
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
	AND name IN
	(SELECT a.name
		FROM app_store_apps as a
		JOIN play_store_apps as p
		ON a.name = p.name
		)
;
-----OUTPUT-----
--Looking at the apps that are in $10,000 price range, we see the list go from 269 to 223


-----BRING IN THE PURCHASING PRICE FOR APP TRADER-----
WITH one AS 
(
	SELECT
		'app_store' as system,
		name, 
		CASE WHEN price <= 1 THEN 10000
		ELSE (price * 10000) END AS cost,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
UNION ALL
	SELECT
		'play_store' as system,
		name,
		CASE WHEN price::MONEY::NUMERIC <= 1 THEN 10000
		ELSE (price::MONEY::NUMERIC * 10000) END AS cost,
		genres,
		rating
	FROM play_store_apps
	WHERE rating >=4 
	AND rating IS NOT NULL
)
SELECT
	system,
	name,
	rating,
	cost::MONEY
FROM one
WHERE primary_genre IN 
	('Entertainment', 'Games', 'Education', 'Tools', 'Productivity')
	AND rating >=4
	AND cost::NUMERIC <=10000
	AND name IN
	(SELECT a.name
		FROM app_store_apps as a
		JOIN play_store_apps as p
		ON a.name = p.name
		)
ORDER BY rating DESC;
		
-----OUTPUT-----
--Computed the purchase price for apps that fit in our prefiltered list of 4+ stars, popular genre, app that's in both stores, and price less than or equal to 10,000


WITH one AS 
(
	SELECT
		'app_store' as system,
		name, 
		CASE WHEN price <= 1 THEN 10000
		ELSE (price * 10000) END AS cost,
		price::NUMERIC,
		primary_genre,
		rating
	FROM app_store_apps
	WHERE rating IS NOT NULL
UNION ALL
	SELECT
		'play_store' as system,
		name,
		CASE WHEN price::MONEY::NUMERIC <= 1 THEN 10000
		ELSE (price::MONEY::NUMERIC * 10000) END AS cost,
		price::NUMERIC,
		genres,
		rating
	FROM play_store_apps
	WHERE rating IS NOT NULL
)
SELECT
	system,
	name,
	rating,
	cost::MONEY as cost_of_app,
	((cost::MONEY::NUMERIC *10000)-1000)::MONEY as monthly_revenue,
	(((cost::MONEY::NUMERIC *10000)*12)-12000)::MONEY as annual_revenue,
	((((cost::MONEY::NUMERIC *10000)*12)-12000)*4)::MONEY as lifetime_revenue
FROM one
WHERE rating >=4 
	AND name IN
		(SELECT a.name
		FROM app_store_apps as a
		JOIN play_store_apps as p
		ON a.name = p.name
		)
		AND cost::MONEY::NUMERIC < 11000
		AND primary_genre IN 
		('Entertainment', 'Games', 'Education', 'Tools', 'Productivity')
ORDER BY rating DESC;
-----OUTPUT-----
--These results shows apps that are in both app stores, their purchase price for App Trader, the monthly revenue, the annual revenue, and the lifetime revenue. The life time of these apps is 11 years since they're all rated 5 stars, so the annual cost is multiplied by 11 to get the lifetime revenue. This list is less than 10 so it will require additional computing to bring in another 4 apps to supply a top 10 recommendation list.

---playing around with a table expression to filter---
AND two AS (
SELECT
	a.name,
	a.price::MONEY as app_price,
	p.price::MONEY as play_price,
	CASE WHEN a.price::MONEY > p.price::MONEY THEN a.price::MONEY
	ELSE p.price::MONEY END as highest_price
FROM app_store_apps as a
JOIN play_store_apps as p
ON a.name = p.name
)


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

Recommendations for App Trader:
There are ~500 apps that live in both app stores. Of those ~500, 

-- b. Develop a Top 10 List of the apps that App Trader should buy.





-- updated 2/18/2023
