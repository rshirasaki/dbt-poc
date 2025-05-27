-- snapshots/snp_products.sql
{% snapshot snp_products %}

{{
    config(
      target_schema='analytics',
      unique_key='product_id',
      strategy='check',
      check_cols=['product_price', 'product_category'],
      invalidate_hard_deletes=True
    )
}}

select
    product_id,
    product_name,
    product_category,
    product_price,
    product_created_at
from {{ source('ecommerce', 'products') }}

{% endsnapshot %}