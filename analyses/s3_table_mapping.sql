-- analyses/s3_table_mapping.sql
-- S3パスと出力先テーブル名の対応関係を明確化

/*
=== S3パスと出力先テーブル名の対応設定 ===

【設定箇所1】models/staging/schema_external.yml
- dbt_external_tablesパッケージ用の外部テーブル定義
- S3パスとソーステーブル名の対応

【設定箇所2】models/staging/stg_*.sql
- ステージングモデルでの参照
- 出力先テーブル名の決定

【設定箇所3】dbt_project.yml
- マテリアライゼーション設定
- 最終的な物理テーブル名
*/

with s3_source_mapping as (
    -- === 1. S3パス → ソーステーブル名 ===
    select
        's3://my-data-lake/ecommerce/customers/' as s3_path,
        'customers_parquet' as source_table_name,
        's3_data_lake' as source_schema_name,
        'external' as table_type,
        false as is_partitioned,
        'Parquet形式の顧客マスタデータ' as description
    
    union all
    
    select
        's3://my-data-lake/ecommerce/orders/' as s3_path,
        'orders_parquet' as source_table_name,
        's3_data_lake' as source_schema_name,
        'external' as table_type,
        true as is_partitioned,
        'パーティション化された注文トランザクションデータ' as description
    
    union all
    
    select
        's3://my-data-lake/ecommerce/products/' as s3_path,
        'products_parquet' as source_table_name,
        's3_data_lake' as source_schema_name,
        'external' as table_type,
        false as is_partitioned,
        'Parquet形式の商品マスタデータ' as description
),

staging_model_mapping as (
    -- === 2. ソーステーブル名 → ステージングモデル名 ===
    select
        'customers_parquet' as source_table_name,
        'stg_customers_s3' as staging_model_name,
        'models/staging/stg_customers_s3.sql' as model_file_path,
        'view' as materialization,
        'public' as target_schema
    
    union all
    
    select
        'orders_parquet' as source_table_name,
        'stg_orders_s3' as staging_model_name,
        'models/staging/stg_orders_s3.sql' as model_file_path,
        'view' as materialization,
        'public' as target_schema
    
    union all
    
    select
        'products_parquet' as source_table_name,
        'stg_products_s3' as staging_model_name,
        'models/staging/stg_products_s3.sql' as model_file_path,
        'view' as materialization,
        'public' as target_schema
),

final_output_mapping as (
    -- === 3. ステージングモデル名 → 最終出力テーブル名 ===
    select
        'stg_customers_s3' as staging_model_name,
        'stg_customers_s3' as final_table_name,
        'public.stg_customers_s3' as full_table_name,
        'PostgreSQL View' as physical_type,
        'S3データを標準化した顧客ビュー' as purpose
    
    union all
    
    select
        'stg_orders_s3' as staging_model_name,
        'stg_orders_s3' as final_table_name,
        'public.stg_orders_s3' as full_table_name,
        'PostgreSQL View' as physical_type,
        'S3データを標準化した注文ビュー' as purpose
    
    union all
    
    select
        'stg_products_s3' as staging_model_name,
        'stg_products_s3' as final_table_name,
        'public.stg_products_s3' as full_table_name,
        'PostgreSQL View' as physical_type,
        'S3データを標準化した商品ビュー' as purpose
)

-- === 完全な対応関係マッピング ===
select
    ssm.s3_path,
    ssm.source_table_name,
    ssm.source_schema_name,
    smm.staging_model_name,
    smm.model_file_path,
    fom.final_table_name,
    fom.full_table_name,
    fom.physical_type,
    ssm.is_partitioned,
    smm.materialization,
    fom.purpose,
    
    -- 参照方法の例
    'source(s3_data_lake, ' || ssm.source_table_name || ')' as dbt_source_reference,
    'ref(' || smm.staging_model_name || ')' as dbt_model_reference
    
from s3_source_mapping ssm
join staging_model_mapping smm on ssm.source_table_name = smm.source_table_name
join final_output_mapping fom on smm.staging_model_name = fom.staging_model_name
order by ssm.s3_path 