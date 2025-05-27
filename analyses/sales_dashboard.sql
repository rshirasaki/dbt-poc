-- analyses/sales_dashboard.sql
-- 売上ダッシュボード用分析クエリ

-- KPI指標の計算
with kpi_metrics as (
    select 
        count(distinct customer_id) as total_customers,
        count(order_id) as total_orders,
        sum(total_amount) as total_revenue,
        avg(total_amount) as avg_order_value,
        sum(quantity) as total_items_sold
    from {{ ref('orders') }}
),

-- 日別売上トレンド
daily_sales as (
    select 
        order_date,
        count(order_id) as daily_orders,
        sum(total_amount) as daily_revenue,
        count(distinct customer_id) as daily_customers
    from {{ ref('orders') }}
    group by order_date
    order by order_date
),

-- カテゴリ別売上
category_performance as (
    select 
        p.product_category,
        count(o.order_id) as orders_count,
        sum(o.total_amount) as category_revenue,
        sum(o.quantity) as items_sold,
        round(avg(o.total_amount), 2) as avg_order_value
    from {{ ref('orders') }} o
    join {{ ref('products') }} p on o.product_id = p.product_id
    group by p.product_category
),

-- 顧客購買行動分析
customer_behavior as (
    select 
        customer_id,
        count(order_id) as order_frequency,
        sum(total_amount) as customer_ltv,
        avg(total_amount) as avg_spend_per_order,
        max(order_date) - min(order_date) as customer_lifespan_days
    from {{ ref('orders') }}
    group by customer_id
),

-- 商品ランキング
product_ranking as (
    select 
        p.product_name,
        p.product_category,
        p.product_price,
        count(o.order_id) as times_ordered,
        sum(o.quantity) as total_sold,
        sum(o.total_amount) as product_revenue,
        rank() over (order by sum(o.total_amount) desc) as revenue_rank
    from {{ ref('products') }} p
    left join {{ ref('orders') }} o on p.product_id = o.product_id
    group by p.product_id, p.product_name, p.product_category, p.product_price
)

-- ダッシュボード用統合ビュー
select 
    'KPI' as section,
    'total_customers' as metric,
    total_customers::text as value,
    '総顧客数' as description
from kpi_metrics

union all

select 
    'KPI',
    'total_orders',
    total_orders::text,
    '総注文数'
from kpi_metrics

union all

select 
    'KPI',
    'total_revenue',
    total_revenue::text || '円',
    '総売上'
from kpi_metrics

union all

select 
    'KPI',
    'avg_order_value',
    round(avg_order_value, 2)::text || '円',
    '平均注文額'
from kpi_metrics

union all

select 
    'DAILY_TREND',
    order_date::text,
    daily_revenue::text,
    '日別売上'
from daily_sales

union all

select 
    'CATEGORY',
    product_category,
    category_revenue::text || '円',
    'カテゴリ別売上'
from category_performance
order by category_revenue desc

union all

select 
    'TOP_PRODUCTS',
    product_name,
    product_revenue::text || '円',
    'ランキング: ' || revenue_rank::text
from product_ranking
where revenue_rank <= 5

order by 
    case section
        when 'KPI' then 1
        when 'DAILY_TREND' then 2
        when 'CATEGORY' then 3
        when 'TOP_PRODUCTS' then 4
    end,
    value desc 