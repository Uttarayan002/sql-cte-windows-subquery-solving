SELECT * FROM userss;
SELECT * FROM productss;
SELECT * FROM orderss;
SELECT * FROM order_itemss;

-- Q1. Monthly User Signups
-- Get the number of users who signed up each month in 2024.
-- Expected Output: Month | Year | Signups
SELECT EXTRACT (MONTH FROM SIGNUP_DATE) AS month_, 
EXTRACT(YEAR FROM SIGNUP_DATE) AS YEAR_, 
COUNT(*)
FROM userss 
WHERE EXTRACT (YEAR FROM signup_date) = 2024
GROUP BY EXTRACT (YEAR FROM signup_date), EXTRACT (MONTH FROM SIGNUP_DATE)
ORDER BY MONTH_;



-- User Order Count
-- Return a list of users and how many total orders they placed.
-- Bonus: Also show users with zero orders.
SELECT u.u_id,  u.signup_date, u.country,
	COUNT(O.O_ID) as total_orders
FROM USERSS u 
	LEFT JOIN orderss o ON O.U_ID = U.U_ID
	group by u.u_id, u.signup_date, u.country
	order by total_orders DESC;



-- Total Revenue by Category
-- Calculate the total revenue for each product category.
-- Revenue = SUM(quantity * price) from order_items joined with products.
SELECT P.CATEGORY, SUM(OI.QUANTITYSS * P.PRICE) AS REVENUE
FROM PRODUCTSS P 
JOIN order_itemss OI ON P.P_ID = OI.P_ID
GROUP BY P.CATEGORY;



--  Top 5 Most Ordered Products
-- Return the top 5 products by total quantity sold.
SELECT P.P_ID, P.CATEGORY, SUM(OI.QUANTITYSS) AS AMNT_QUAT
	FROM PRODUCTSS P 
	INNER JOIN order_itemss OI ON P.p_id = OI.p_id
	GROUP BY P.P_ID, P.CATEGORY
	ORDER BY AMNT_QUAT DESC
	LIMIT 5;



-- Daily Revenue Summary
-- For each day in which any order was placed, show the total revenue earned.
SELECT O.O_DATE, SUM(OI.QUANTITYSS * P.PRICE) AS DAILY_REVENUE 
	FROM ORDER_ITEMSS OI
	JOIN orderss o ON oi.o_id = o.o_id
    JOIN productss p ON oi.p_id = p.p_id 
GROUP BY o.o_date
ORDER BY o.o_date;


