-- models/staging/stg_products.sql
with source as (
    select * from {{ source('ecommerce', 'products') }}
),

renamed as (
    select
        product_id,
        product_name,
        product_category,
        product_price,
        product_created_at
    from source
)

select * from renamed