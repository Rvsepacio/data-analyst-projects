--------------------------
--Change over time
--------------------------

--Change over time (YEARS)
Select
year(order_date) as order_year,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from dbo.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);

--Change over time (MONTHS)
Select
month(order_date) as order_year,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from dbo.fact_sales
where order_date is not null
group by month(order_date)
order by month(order_date);

--------------------------
--Cumulative Analysis
--------------------------

--Total Sales per month
select
datetrunc(month, order_date) as order_month,
sum(sales_amount) as total_sales
from dbo.fact_sales
where order_date is not null
group by datetrunc(month, order_date)
order by datetrunc(month, order_date);

--Running Total Sales over time
select
order_date,
total_sales,
sum(total_sales) over (partition by order_date order by order_date asc) as running_total_sales
from
(
select
datetrunc(month, order_date) as order_date,
sum(sales_amount) as total_sales
from dbo.fact_sales
where order_date is not null
group by datetrunc(month, order_date)
) t;

--------------------------
--Performance Analysis
--------------------------

--Yearly performance of the products by comparing sales to the average sales performance of the product

With yearly_product_sales as
(
select
year(a.order_date) as order_year,
b.product_name,
sum(a.sales_amount) as current_sales
from dbo.fact_sales as a
left join dbo.products as b
	on a.product_key=b.product_key
where a.order_date is not null
group by 
year(a.order_date),
b.product_name
)
select
order_year,
product_name,
current_sales,
avg(current_sales) over(partition by product_name) as avg_sales,
current_sales-avg(current_sales) over(partition by product_name) as diff_avg,
Case when current_sales-avg(current_sales) over(partition by product_name) > 0 then 'Above Avg'
	when current_sales-avg(current_sales) over(partition by product_name) < 0 then 'Below Avg'
	Else 'Avg'
End as Avg_change
from yearly_product_sales
order by product_name, order_year
;

--Yearly performance of the products by comparing sales to the previous year's sales performance of the product

With yearly_product_sales as
(
select
year(a.order_date) as order_year,
product_name,
sum(sales_amount) as current_sales
from dbo.fact_sales as a
left join dbo.products as b
	on a.product_key=b.product_key
where order_date is not null
group by year(a.order_date), product_name
)
select
order_year,
product_name,
current_sales,
coalesce(lag(current_sales) over(partition by product_name order by order_year), 0) as previous_sales, 
coalesce(current_sales-lag(current_sales) over(partition by product_name order by order_year), 0) as diff,
Case when coalesce(lag(current_sales) over(partition by product_name order by order_year), 0) > 0 then 'Increase'
	when coalesce(lag(current_sales) over(partition by product_name order by order_year), 0) < 0 then 'Decrease'
	Else 'No Change'
End as Change
from yearly_product_sales
order by product_name, order_year
;

--------------------------
--Part-to-whole Analysis
--------------------------

--Categories contribute the most to overall sales
with category_sales as
(
select
b.category,
sum(a.sales_amount) as total_sales
from dbo.fact_sales as a
left join dbo.products as b
	on a.product_key=b.product_key
group by b.category
)
select
category,
total_sales,
sum(total_sales) over() as overall_sales,
Concat(round((cast(total_sales as float)/sum(total_sales) over())*100,2),'%') as percent_contribution
from category_sales
order by total_sales desc
;

--------------------------
--Data Segmentation
--------------------------

--Product segmentation on cost ranges

with product_segments as
(
select
product_key,
product_name,
cost,
case when cost < 100 Then 'Below 100'
	when cost between 100 and 500 Then '100-500'
	when cost between 500 and 1000 Then '500-1000'
	else 'Above 1000'
end as cost_range
from dbo.products
)
select 
cost_range,
count(product_key) as total_products
from product_segments
group by cost_range
order by count(product_key) desc
;


--Customer segmentation on spending behaviour

with customer_segments as
(
select
a.customer_key,
sum(a.sales_amount) as total_spending,
min(order_date) as first_order,
max(order_date) as last_order,
datediff(MONTH,min(order_date),max(order_date)) as lifespan
from dbo.fact_sales as a
left join dbo.customers as b
	on a.customer_key=b.customer_key
group by a.customer_key
)
select
customer_key,
total_spending,
lifespan,
case when total_spending > 5000 and lifespan >= 12 then 'VIP'
	when total_spending <= 5000 and lifespan >= 12 then 'Regular'
	else 'New'
end as customer_type
from customer_segments
;

--No. of customer segmentation on spending behaviour

with customer_segments as
(
select
a.customer_key,
sum(a.sales_amount) as total_spending,
min(order_date) as first_order,
max(order_date) as last_order,
datediff(MONTH,min(order_date),max(order_date)) as lifespan
from dbo.fact_sales as a
left join dbo.customers as b
	on a.customer_key=b.customer_key
group by a.customer_key
)

select
customer_type,
count(customer_key) as total_customer
from(
select
customer_key,
case when total_spending > 5000 and lifespan >= 12 then 'VIP'
	when total_spending <= 5000 and lifespan >= 12 then 'Regular'
	else 'New'
end as customer_type
from customer_segments) t
group by customer_type
order by count(customer_key) desc
;


--------------------------
--Customer Report
--------------------------

