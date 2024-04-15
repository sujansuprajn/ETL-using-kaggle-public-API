SELECT * FROM new_schema.df_orders;
# find top 10 highest revenue generating products
select
	product_id,
	sum(sales_price) as revenue
from 
	df_orders
group by 
	product_id
order by 
	revenue desc limit 10
    
    # Top 5 highest selling products in each region
with top_5_products as 
	(select *,
	dense_rank() over (partition by region order by sum(sales_price) desc) as p_rank
from 
	df_orders
group by 
	region, product_id
    )

select 
	region, 
	product_id, 
    sum(sales_price) as revenue 
from top_5_products 
where p_rank <= 5 
group by region, product_id
	
    #find month over month growth comparison for 22 and 23 sales eg jan 22 vs jan 23
with pivot as (
select 
	month(order_date) as mon_th, 
	year(order_date) as yea_r, sum(sales_price) as revenue 
from df_orders 
group by mon_th, yea_r
order by mon_th, yea_r
)
select mon_th, 
	max(case when yea_r = 2022 then revenue else null end ) as "2022",
	max(case when yea_r = 2023 then revenue else null end )as "2023"
from pivot
group by mon_th

# for each category which month has highest sales
with cte as (
select 
	month(order_date) as mon_th,
    year(order_date) as yea_r,
    category,
    sum(sales_price) as revenue,
	dense_rank() over 
    (partition by category order by sum(sales_price) desc) as p_rank
from df_orders 
group by category, mon_th, yea_r)
select 
	* 
from cte 
where p_rank = 1

# which sub category had highest growth by profit in 23 compared to 22.
with pivot as (
select 
	sub_category,
	year(order_date) as yea_r, sum(profit) as profit 
from df_orders 
group by sub_category, yea_r
order by sub_category, yea_r
), cte2 as (
select sub_category, 
	max(case when yea_r = 2022 then profit else null end ) as profit_2022,
	max(case when yea_r = 2023 then profit else null end )as profit_2023
from pivot
group by sub_category) 
select *, (profit_2023 - profit_2022)/(profit_2022) * 100 as profit_growth_pct from cte2 order by profit_growth_pct desc limit 1

