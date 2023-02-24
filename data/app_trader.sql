Based on research completed prior to launching App Trader as a company, you can assume the following:
select *
From app_store_apps;
a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000.

- For example, an app that costs $2.00 will be purchased for $20,000.
    
- The cost of an app is not affected by how many app stores it is on. A $1.00 app on the Apple app store will cost the same as a $1.00 app on both stores. 
    
- If an app is on both stores, it's purchase price will be calculated based off of the highest app price between the two stores. 
2A)


SELECT 
  play_store_apps.name, 
  (CAST(play_store_apps.price AS MONEY) * 10000) AS purchase_price 
FROM play_store_apps 
INNER JOIN app_store_apps 
USING (name) 
ORDER BY purchase_price DESC;

2B)

SELECT 
  play_store_apps.name, 
  (CAST(play_store_apps.price AS MONEY) * 10000) AS purchase_price,
  COALESCE(earnings, 0) AS total_earnings,
  COALESCE(earnings, 0) * COUNT(*) OVER (PARTITION BY play_store_apps.name) AS total_monthly_earnings
FROM play_store_apps 
INNER JOIN app_store_apps 
USING (name) 
LEFT JOIN (
  SELECT 
    name, 
    SUM(5000) AS earnings 
  FROM (
    SELECT name FROM play_store_apps
    UNION
    SELECT name FROM app_store_apps
  ) AS apps 
  GROUP BY name
) AS app_earnings 
ON play_store_apps.name = app_earnings.name 
ORDER BY total_monthly_earnings DESC;







b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app.
    
- An app that costs $200,000 will make the same per month as an app that costs $1.00. 

- An app that is on both app stores will make $10,000 per month. 

c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.
    
- An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
    
- App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.


#### 3. Deliverables

a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

b. Develop a Top 10 List of the apps that App Trader should buy.



updated 2/18/2023
