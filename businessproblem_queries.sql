-- -- Business Problems for Walmart Sales database


-- -- 1. Find different payment method and number of transaction, number of quantity sold

-- select payment_method,
-- count(*) as num_transactions,
-- sum(quantity) as num_quantity_sold
-- from walmart
-- group by payment_method;

-- -- 2. Identify the highest-rated category in each branch, displaying the branch, categry and avg rating
-- select * 
-- from (
-- select branch, 
-- category, 
-- avg(rating) as avg_rating,
-- rank() over (partition by branch order by avg(rating) desc) as `rank`
-- from walmart
-- group by branch, category) as ranked_category
-- where `rank` = 1;


-- -- 3. identify the busiest day for each branch based on the number of transactions 
-- SELECT *
-- FROM (
--     SELECT 
--         branch, 
--         day_name,
--         num_transactions,
--         RANK() OVER (PARTITION BY branch ORDER BY num_transactions DESC) AS `rank`
--     FROM (
--         SELECT 
--             branch, 
--             DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
--             COUNT(*) AS num_transactions
--         FROM walmart
--         GROUP BY branch, day_name
--     ) AS daily_counts
-- ) AS ranked_days
-- WHERE `rank` = 1;


-- -- 4.  Calculate the quantity of items sold per payment method. List payment_methos and total_quanity

-- select payment_method,
-- sum(quantity) as num_quantity_sold
-- from walmart
-- group by payment_method;

-- -- 5. Determine the average, minimum and maximum rating of category for each city.
-- -- List the city, average_rating, min_rating, and max_rating
-- select 
--     city,
--     category,
--     min(rating) as min_rating,
--     max(rating) as max_rating,
--     avg(rating) as average_rating
-- from walmart
-- group by city, category;

-- -- 6. calculate the total profit for each category by considerong total_profit as
-- -- (unit_price * quantity * profit_margin).
-- -- List category and total_profit, ordered from highest to lowest profile.
-- select category,
-- sum(total) as total_revenue,
-- sum(unit_price * quantity * profit_margin) as profit
-- from walmart
-- group by category
-- order by profit DESC;

-- -- 7. Determine the most common payment method for each Branch, Display Branch and the preferred_payment_method
-- SELECT 
--     branch,
--     payment_method,
--     total_transact,
--     `rank`
-- FROM (
--     SELECT 
--         branch,
--         payment_method,
--         COUNT(*) AS total_transact,
--         RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS `rank`
--     FROM walmart
--     GROUP BY branch, payment_method
-- ) AS ranked
-- WHERE `rank` = 1;


-- -- 8. categorize sales into 3 group morning, afternoon, evening
-- -- find out which of the shift and number of invoices
-- select 
-- branch,
-- case 
--     when hour(time) between 5 and 11 then 'Morning'
--     when hour(time) between 12 and 16 then 'Afternoon'
--     when hour(time) between 17 and 21 then 'Evening'
--     else 'Night'
-- end as time_of_day,
-- count(*) as num_invoices
-- from walmart
-- group by branch,time_of_day
-- order by branch,num_invoices desc;


-- 9. Indentify 5 branches with highest decrease ratio in
-- revenue compare to last year. Assume that the data is from 2022 and 2023
-- rdr == lastyear_rev - curyear_rev * 100

WITH rev_2022 AS (
    SELECT branch, SUM(total) AS revenue_2022
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),
rev_2023 AS (
    SELECT branch, SUM(total) AS revenue_2023
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)
select ls_sale.branch,
ls_sale.revenue_2022 as last_year_revenue,
cs_sale.revenue_2023 as current_year_revenue,
ROUND(
        (ls_sale.revenue_2022 - cs_sale.revenue_2023) / ls_sale.revenue_2022 * 100,
        2
    ) AS revenue_decrease_ratio
from rev_2022 as ls_sale
join rev_2023 as cs_sale on ls_sale.branch = cs_sale.branch
order by ls_sale.branch asc;