-- models/marts/agg/agg_daily_sales.sql
with orders as (
    select * from {{ ref('fact_orders') }}
),

daily_sales as (
    select
        order_date as sales_date,
        count(distinct order_id) as total_orders,
        sum(total_amount) as total_revenue
    from orders
    group by 1
)

select * from daily_sales
order by sales_date