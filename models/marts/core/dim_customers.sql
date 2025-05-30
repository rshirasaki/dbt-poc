-- models/marts/core/dim_customers.sql
with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders,
        sum(total_amount) as total_lifetime_value
    from orders
    group by 1
),

final as (
    select
        customers.customer_id,
        customers.customer_name,
        customers.customer_email,
        customers.customer_created_at,
        coalesce(customer_orders.first_order_date, customers.customer_created_at) as first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
        coalesce(customer_orders.total_lifetime_value, 0) as total_lifetime_value
    from customers
    left join customer_orders using (customer_id)
)

select * from final