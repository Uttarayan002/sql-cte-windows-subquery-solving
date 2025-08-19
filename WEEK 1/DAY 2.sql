-- Day 2 — Structured Challenge
SELECT * FROM patrons;
SELECT * FROM DEMANDS;
SELECT * FROM ORDER_ITEMS;

-- Subqueries (3)--------------------------------------------------------------------------------------------
-- Find the top 3 customers by total spending.
SELECT p.p_id, p.name, 
	(SELECT SUM(total_amount) FROM demands d WHERE d.p_id = p.p_id) as total_spending FROM patrons p
	WHERE p.p_id IN ( SELECT p_id FROM demands )
	ORDER BY total_spending DESC LIMIT 3;

-- List all orders whose total amount is greater than the average total amount.
SELECT 
	D.D_ID,
D.TOTAL_AMOUNT
FROM DEMANDS D
WHERE D.total_amount > (SELECT AVG(TOTAL_AMOUNT) AS AVG_AMNT FROM DEMANDS);

-- Find the most expensive item for each order (use correlated subquery).
SELECT 
OI.ITEM_ID, 
OI.D_ID, 
OI.PRODUCT_NAME,
	OI.PRICE
FROM ORDER_ITEMS OI
WHERE OI.price = (
	SELECT MAX(OI2.PRICE) FROM ORDER_ITEMS OI2
WHERE OI2.ITEM_ID = OI.ITEM_ID)
ORDER BY OI.d_id;

-- CTEs (3)--------------------------------------------------------------------------------------------------
-- Using a CTE, show each customer’s total orders and their average order value.
WITH CUST_PERFORMANCE AS (
SELECT P.P_ID, 
	P.NAME,
COUNT(D.D_ID) AS NUM_OF_ORDERS,
ROUND(AVG(D.TOTAL_AMOUNT), 2) AS AVG_TOTAL_AMOUNT
FROM DEMANDS D
JOIN PATRONS P ON D.p_id = P.p_id
GROUP BY  P.P_ID, P.NAME )

SELECT * FROM CUST_PERFORMANCE;

-- Create a CTE that calculates the total revenue per day, then select only the days where revenue > 1000.
WITH REVENUE_CHECKIN AS(
SELECT 
	DATE(D.DEMAND_DATE) AS ORDER_DATE, 
    SUM(OI.QUANTITY * OI.PRICE) AS TOTAL_REVENUE
FROM ORDER_ITEMS OI
JOIN DEMANDS D ON OI.D_ID = D.d_id
GROUP BY DATE(D.DEMAND_DATE)
)
SELECT ORDER_DATE, TOTAL_REVENUE FROM REVENUE_CHECKIN
WHERE TOTAL_REVENUE > 300 --(Returning no values because most of the revenue is under 1000 So I change it to 300)
	ORDER BY ORDER_DATE DESC;

-- Use a recursive CTE to generate dates from Jan 1, 2025, to Jan 10, 2025.


-- Window Functions (3)-----------------------------------------------------------------------------------------------
-- For each customer, list their orders with a running total of spending.
SELECT 
	P.P_ID, 
	P.NAME, 
D.D_ID, 
D.DEMAND_DATE, 
	OI.PRODUCT_NAME,
SUM(D.TOTAL_AMOUNT) OVER(
	PARTITION BY P.P_ID
	ORDER BY D.DEMAND_DATE, D.D_ID) AS RUNNING_TOTAL
	FROM DEMANDS D 
	JOIN PATRONS P ON D.P_ID = P.p_id
	JOIN ORDER_ITEMS OI ON D.D_ID = OI.d_id;
	-- GROUP BY P.P_ID, P.NAME, D.D_ID, OI.PRODUCT_NAME;

-- For each customer, show previous order amount (using LAG).
SELECT P.P_ID, P.NAME, D.D_ID, D.DEMAND_DATE, LAG(D.TOTAL_AMOUNT) OVER(PARTITION BY P.p_id ORDER BY D.D_ID )
FROM PATRONS P
JOIN DEMANDS D ON P.P_ID = D.p_id;

-- For each customer, assign a rank to each order based on total_amount (highest first).
SELECT P.P_ID, P.NAME, 
	D.D_ID, D.TOTAL_AMOUNT, 
	RANK() OVER(PARTITION BY P.P_ID ORDER BY D.TOTAL_AMOUNT DESC) AS RANK_AMOUNT
FROM PATRONS P
JOIN DEMANDS D ON P.P_ID = D.p_id;

