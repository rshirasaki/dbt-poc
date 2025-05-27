-- models/staging/stg_customers.sql
with source as (
    select * from {{ source('ecommerce', 'customers') }}
),

renamed as (
    select
        customer_id,
        customer_name,
        customer_email,
        customer_created_at
    from source
)

select * from renamed