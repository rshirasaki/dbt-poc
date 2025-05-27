-- models/staging/stg_customers_tenant.sql
-- テナント対応顧客ステージングモデル

{{ config(
    materialized='view',
    tags=['staging', 'tenant', 'customers']
) }}

-- テナント情報をログ出力
{{ log_tenant_info() }}

with source_data as (
    select
        customer_id,
        customer_name,
        customer_email,
        customer_created_at,
        
        -- テナント情報を追加
        '{{ get_tenant_name() }}' as tenant_name,
        '{{ get_tenant_s3_bucket() }}' as source_s3_bucket,
        '{{ get_tenant_s3_prefix() }}' as source_s3_prefix,
        current_timestamp as processed_at
        
    from {{ ref('customers') }}
),

cleaned_data as (
    select
        customer_id,
        trim(customer_name) as customer_name,
        lower(trim(customer_email)) as customer_email,
        customer_created_at,
        tenant_name,
        source_s3_bucket,
        source_s3_prefix,
        processed_at,
        
        -- データ品質チェック
        case 
            when customer_email like '%@%' then 'valid'
            else 'invalid'
        end as email_validation,
        
        case 
            when customer_name is not null and length(trim(customer_name)) > 0 then 'valid'
            else 'invalid'
        end as name_validation
        
    from source_data
)

select * from cleaned_data 