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

-- #### 2. Assumptions

-- Based on research completed prior to launching App Trader as a company, you can assume the following:

SELECT * 
FROM app_store_apps;

SELECT *
FROM play_store_apps;

SELECT DISTINCT(CAST(price AS MONEY))
FROM play_store_apps;
--OUTPUT there are 92 distinct prices in the play_store

SELECT DISTINCT(CAST(price AS MONEY))
FROM app_store_apps;\
--OUTPUT there are 36 distinct prices in the app_store
--Both of these outputs was needed to begin building a query piece by piece

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
ORDER BY price, rating DESC;
-- --output 
-- "FK Dedinje BGD"	"$0.00"	5.0	"Everyone"
-- "Awake Dating"	"$0.00"	5.0	"Mature 17+"
-- "UP EB Bill Payment & Details"	"$0.00"	5.0	"Teen"
-- "BI News"	"$0.00"	5.0	"Everyone"
-- "Railroad Radio Vancouver BC"	"$0.00"	5.0	"Teen"


	

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

-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.


-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.





-- updated 2/18/2023
