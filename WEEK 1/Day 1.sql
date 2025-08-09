select * from patrons;
select * from demands;
select * from order_items;

-- Subqueries (3)
-- Find customers who have placed more than one order.
select 
p.name, 
count(d.d_id) as order_count 
from patrons p 
join demands d on p.p_id = d.p_id
group by p.name
having count(d.d_id) >1
order by order_count desc;

-- Find the most expensive item (by price) across all orders.
select 
	product_name,
	price from order_items 
where price = (select max(price) from order_items);

-- Find customers who placed an order whose total amount is above the average order total.
select 
    p.p_id, 
	p.name,
	d.total_amount
from patrons p 
join demands d on p.p_id = d.p_id
group by p.p_id, p.name, d.total_amount
having d.total_amount > (select avg(total_amount) from demands);
--------------------------------------------------------------------------------------------------------------------------------------------
-- CTEs (3)
-- Using a CTE, calculate the total amount spent by each customer.
with  ttl_amnt_patrons as(
	select p.name, sum(d.total_amount) as total_amnt
    from patrons p 
    join demands d on p.p_id = d.p_id
    group by p.name)

select * from ttl_amnt_patrons;

-- Using a CTE, find the average item price per order and filter orders with average price > 200.
with avg_per_order as (
	select oi.d_id, avg(oi.price) as avg_price, 
	count(oi.item_id) as item_count  
	from order_items oi 
    group by oi.d_id)

select
	apo.d_id, 
	round(apo.avg_price, 2) as avg_price,
	apo.item_count
FROM avg_per_order apo
JOIN demands d ON apo.d_id = d.d_id
WHERE apo.avg_price > 200
ORDER BY apo.avg_price DESC;


-- Use a recursive CTE to generate numbers from 1 to 5 (just for syntax practice).
WITH RECURSIVE number_sequence AS (
    -- Base case (anchor): Start with 1
    SELECT 1 as num
    UNION ALL
    -- Recursive case: Add 1 to the previous number
    SELECT num + 1
    FROM number_sequence
    WHERE num < 5  -- Stop condition
)
SELECT num
FROM number_sequence;
---------------------------------------------------------------------------------------------------------------------------------------------
-- Window Functions (3)
-- Assign a rank to each order based on total amount (highest first).
select *,
rank() over(order by total_amount desc) as rank_by_acc
from demands 
order by rank_by_acc;

-- Calculate the running total of order amounts for each customer.

select 
d.d_id,
	p.p_id, 
	d.total_amount, 
	sum(d.total_amount) over(
	partition by p.p_id order by d.demand_date
	) as running_total
	from demands d
	join patrons p on d.p_id = p.p_id; --running total by order date	

-- For each customer, show their latest order using ROW_NUMBER.
WITH ranked_orders AS (
    SELECT 
        d.d_id,
        d.p_id,
        ROW_NUMBER() OVER (
            PARTITION BY d.p_id 
            ORDER BY d.demand_date DESC
        ) as row_num
    FROM demands d
    JOIN patrons p ON d.p_id = p.p_id
)
SELECT *
FROM ranked_orders
WHERE row_num = 1
ORDER BY p_id;
-----------------------------------------------------------------------------------------------------------------------------------------
-- Bonus Hybrid Challenge (1)
-- Find the top 2 most expensive items per customer using a CTE + ROW_NUMBER window function.

