-- analyses/basic_data_analysis.sql
-- dbtを使った基本的なデータ分析例

-- 1. 顧客別売上分析
with customer_sales as (
    select 
        c.customer_id,
        c.customer_name,
        c.customer_email,
        count(o.order_id) as total_orders,
        sum(o.total_amount) as total_sales,
        avg(o.total_amount) as avg_order_value,
        min(o.order_date) as first_order_date,
        max(o.order_date) as last_order_date
    from {{ ref('customers') }} c
    left join {{ ref('orders') }} o on c.customer_id = o.customer_id
    group by c.customer_id, c.customer_name, c.customer_email
),

-- 2. 商品別売上分析
product_sales as (
    select 
        p.product_id,
        p.product_name,
        p.product_category,
        p.product_price,
        count(o.order_id) as times_ordered,
        sum(o.quantity) as total_quantity_sold,
        sum(o.total_amount) as total_revenue,
        avg(o.quantity) as avg_quantity_per_order
    from {{ ref('products') }} p
    left join {{ ref('orders') }} o on p.product_id = o.product_id
    group by p.product_id, p.product_name, p.product_category, p.product_price
),

-- 3. 月別売上トレンド
monthly_trends as (
    select 
        date_trunc('month', order_date) as order_month,
        count(distinct customer_id) as unique_customers,
        count(order_id) as total_orders,
        sum(total_amount) as monthly_revenue,
        avg(total_amount) as avg_order_value
    from {{ ref('orders') }}
    group by date_trunc('month', order_date)
    order by order_month
),

-- 4. 顧客セグメンテーション
customer_segments as (
    select 
        customer_id,
        customer_name,
        total_sales,
        total_orders,
        case 
            when total_sales >= 1000 then 'VIP'
            when total_sales >= 500 then 'Premium'
            when total_sales >= 100 then 'Regular'
            else 'New'
        end as customer_segment,
        case 
            when total_orders >= 3 then 'Frequent'
            when total_orders >= 2 then 'Occasional'
            else 'One-time'
        end as purchase_frequency
    from customer_sales
)

-- 最終結果: 分析サマリー
select 
    '=== 顧客分析サマリー ===' as analysis_type,
    null as metric_name,
    null as metric_value,
    null as details
    
union all

select 
    '顧客数',
    'total_customers',
    count(*)::text,
    'アクティブ顧客数'
from customer_sales
where total_orders > 0

union all

select 
    '売上',
    'total_revenue', 
    sum(total_sales)::text,
    '全体売上'
from customer_sales

union all

select 
    '平均注文額',
    'avg_order_value',
    round(avg(avg_order_value), 2)::text,
    '顧客平均注文額'
from customer_sales
where total_orders > 0

union all

select 
    '=== 商品分析サマリー ===',
    null,
    null,
    null

union all

select 
    '商品数',
    'total_products',
    count(*)::text,
    '販売商品数'
from product_sales
where times_ordered > 0

union all

select 
    '最も売れた商品',
    'top_product',
    product_name,
    '売上: ' || total_revenue::text || '円'
from product_sales
where times_ordered > 0
order by total_revenue desc
limit 1

union all

select 
    '=== 顧客セグメント分布 ===',
    null,
    null,
    null

union all

select 
    'セグメント',
    customer_segment,
    count(*)::text,
    '顧客数'
from customer_segments
group by customer_segment
order by 
    case customer_segment
        when 'VIP' then 1
        when 'Premium' then 2
        when 'Regular' then 3
        when 'New' then 4
    end 