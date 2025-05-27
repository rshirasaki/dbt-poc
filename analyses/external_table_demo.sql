-- analyses/external_table_demo.sql
-- dbt_external_tables vs Glue Crawler 機能比較デモ

/*
=== Glue Crawler vs dbt_external_tables 比較 ===

【Glue Crawlerの場合】
1. AWSコンソールでCrawlerを設定
2. S3パスを指定
3. スケジュール実行でスキーマ自動検出
4. Data Catalogに結果を保存
5. 手動でのスキーマ管理が困難

【dbt_external_tablesの場合】
1. YAMLファイルでスキーマ定義
2. Gitでバージョン管理
3. dbtコマンドで外部テーブル作成
4. コードレビュー可能
5. 環境間での一貫性保証
*/

-- === 1. 外部テーブル定義の確認 ===
{{ log("=== 外部テーブル定義情報 ===", info=true) }}

{% set external_tables = [
    {
        'name': 'customers_parquet',
        'location': 's3://my-data-lake/ecommerce/customers/',
        'format': 'parquet',
        'partitioned': false,
        'columns': 6
    },
    {
        'name': 'orders_parquet', 
        'location': 's3://my-data-lake/ecommerce/orders/',
        'format': 'parquet',
        'partitioned': true,
        'columns': 10
    },
    {
        'name': 'products_parquet',
        'location': 's3://my-data-lake/ecommerce/products/',
        'format': 'parquet', 
        'partitioned': false,
        'columns': 9
    }
] %}

-- === 2. スキーマ管理の自動化デモ ===
with schema_management as (
    select
        '{{ external_tables[0].name }}' as table_name,
        '{{ external_tables[0].location }}' as s3_location,
        '{{ external_tables[0].format }}' as file_format,
        {{ external_tables[0].partitioned }} as is_partitioned,
        {{ external_tables[0].columns }} as column_count,
        'dbt_external_tables managed' as management_type
    
    union all
    
    select
        '{{ external_tables[1].name }}' as table_name,
        '{{ external_tables[1].location }}' as s3_location,
        '{{ external_tables[1].format }}' as file_format,
        {{ external_tables[1].partitioned }} as is_partitioned,
        {{ external_tables[1].columns }} as column_count,
        'dbt_external_tables managed' as management_type
    
    union all
    
    select
        '{{ external_tables[2].name }}' as table_name,
        '{{ external_tables[2].location }}' as s3_location,
        '{{ external_tables[2].format }}' as file_format,
        {{ external_tables[2].partitioned }} as is_partitioned,
        {{ external_tables[2].columns }} as column_count,
        'dbt_external_tables managed' as management_type
),

-- === 3. データ品質チェック（Glue Crawlerでは困難） ===
data_quality_checks as (
    select
        table_name,
        s3_location,
        case 
            when s3_location like 's3://%' then 'valid_s3_path'
            else 'invalid_s3_path'
        end as path_validation,
        
        case 
            when file_format = 'parquet' then 'optimized_format'
            else 'suboptimal_format'
        end as format_validation,
        
        case 
            when is_partitioned and table_name like '%orders%' then 'properly_partitioned'
            when not is_partitioned and table_name not like '%orders%' then 'appropriately_unpartitioned'
            else 'partition_review_needed'
        end as partition_validation,
        
        current_timestamp as validated_at
        
    from schema_management
),

-- === 4. 外部テーブル利用統計（dbt独自機能） ===
usage_statistics as (
    select
        table_name,
        column_count,
        case 
            when table_name = 'customers_parquet' then 'dimension'
            when table_name = 'orders_parquet' then 'fact'
            when table_name = 'products_parquet' then 'dimension'
        end as table_type,
        
        case 
            when table_name = 'orders_parquet' then 'high'
            when table_name = 'customers_parquet' then 'medium'
            when table_name = 'products_parquet' then 'low'
        end as expected_query_frequency,
        
        management_type
        
    from schema_management
)

-- === 最終結果：外部テーブル管理サマリー ===
select
    sm.table_name,
    sm.s3_location,
    sm.file_format,
    sm.is_partitioned,
    sm.column_count,
    dqc.path_validation,
    dqc.format_validation,
    dqc.partition_validation,
    us.table_type,
    us.expected_query_frequency,
    sm.management_type,
    
    -- dbt_external_tablesの利点
    'Git versioned, Code reviewed, Environment consistent' as dbt_advantages
    
from schema_management sm
join data_quality_checks dqc on sm.table_name = dqc.table_name
join usage_statistics us on sm.table_name = us.table_name
order by us.expected_query_frequency desc 