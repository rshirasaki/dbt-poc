-- models/staging/stg_orders.sql
with source as (
    select * from {{ source('ecommerce', 'orders') }}
),

renamed as (
    select
        order_id,
        customer_id,
        product_id,
        order_date,
        quantity,
        total_amount
    from source
)

select * from renamed