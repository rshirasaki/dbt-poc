-- analyses/customer_segmentation.sql
-- 顧客をライフタイムバリューに基づいてセグメント化する

with customers as (
    select * from {{ ref('dim_customers') }}
),

segmented_customers as (
    select
        customer_id,
        first_name,
        last_name,
        total_lifetime_value,
        case
            when total_lifetime_value >= 1000 then 'High Value'
            when total_lifetime_value >= 500 then 'Medium Value'
            else 'Low Value'
        end as customer_segment
    from customers
)

select * from segmented_customers
order by total_lifetime_value desc