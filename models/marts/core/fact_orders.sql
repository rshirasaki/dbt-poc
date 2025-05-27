-- models/marts/core/fact_orders.sql
with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.product_id,
        customers.customer_name,
        orders.order_date,
        orders.quantity,
        orders.total_amount
    from orders
    left join customers on orders.customer_id = customers.customer_id
)

select * from final