-- tests/singular/test_customer_total_orders_positive.sql
-- total_lifetime_value が負の値になっていないかをテストする

select
    customer_id,
    total_lifetime_value
from {{ ref('dim_customers') }}
where total_lifetime_value < 0