-- macros/tenant_management.sql
-- テナント管理用マクロ

-- テナント名を取得（環境変数 > dbt vars > デフォルト）
{% macro get_tenant_name() %}
  {% set tenant_name = env_var('TENANT_NAME', var('tenant_name', 'tenant_a')) %}
  {{ return(tenant_name.strip() if tenant_name else 'tenant_a') }}
{% endmacro %}

-- テナント設定を取得（動的生成対応）
{% macro get_tenant_config(tenant_name=none) %}
  {% set tenant = tenant_name or get_tenant_name() %}
  {% set tenant_configs = var('tenants', {}) %}
  
  {% if tenant in tenant_configs %}
    {{ return(tenant_configs[tenant]) }}
  {% else %}
    {{ log("Info: Tenant '" ~ tenant ~ "' not found in predefined configuration. Generating dynamic config.", info=true) }}
    {{ return(generate_dynamic_tenant_config(tenant)) }}
  {% endif %}
{% endmacro %}

-- 動的テナント設定を生成
{% macro generate_dynamic_tenant_config(tenant_name) %}
  {% set config = {
    's3_bucket': tenant_name ~ '-data-lake',
    's3_prefix': 'ecommerce-data',
    'database': tenant_name ~ '_db'
  } %}
  {{ log("Generated dynamic config for tenant '" ~ tenant_name ~ "': " ~ config, info=true) }}
  {{ return(config) }}
{% endmacro %}

-- テナント名の妥当性チェック
{% macro validate_tenant_name(tenant_name) %}
  {% if not tenant_name %}
    {{ exceptions.raise_compiler_error("テナント名が指定されていません") }}
  {% endif %}
  
  {% if not tenant_name.replace('_', '').replace('-', '').isalnum() %}
    {{ exceptions.raise_compiler_error("テナント名は英数字、ハイフン、アンダースコアのみ使用可能です: " ~ tenant_name) }}
  {% endif %}
  
  {% if tenant_name|length > 50 %}
    {{ exceptions.raise_compiler_error("テナント名は50文字以内で指定してください: " ~ tenant_name) }}
  {% endif %}
  
  {{ log("Tenant name validation passed: " ~ tenant_name, info=true) }}
{% endmacro %}

-- テナント用S3バケット名を取得
{% macro get_tenant_s3_bucket(tenant_name=none) %}
  {% set config = get_tenant_config(tenant_name) %}
  {{ return(config.get('s3_bucket', 'default-bucket')) }}
{% endmacro %}

-- テナント用S3プレフィックスを取得
{% macro get_tenant_s3_prefix(tenant_name=none) %}
  {% set config = get_tenant_config(tenant_name) %}
  {{ return(config.get('s3_prefix', 'default-prefix')) }}
{% endmacro %}

-- テナント用データベース名を取得
{% macro get_tenant_database(tenant_name=none) %}
  {% set config = get_tenant_config(tenant_name) %}
  {{ return(config.get('database', 'default_db')) }}
{% endmacro %}

-- テナント用S3パスを生成
{% macro generate_tenant_s3_path(entity, tenant_name=none) %}
  {% set bucket = get_tenant_s3_bucket(tenant_name) %}
  {% set prefix = get_tenant_s3_prefix(tenant_name) %}
  {{ return('s3://' ~ bucket ~ '/' ~ prefix ~ '/' ~ entity ~ '/') }}
{% endmacro %}

-- 共通テーブル名を取得
{% macro get_table_name(entity) %}
  {% set table_names = var('table_names', {}) %}
  {{ return(table_names.get(entity, entity)) }}
{% endmacro %}

-- テナント情報をログ出力
{% macro log_tenant_info(tenant_name=none) %}
  {% set tenant = tenant_name or get_tenant_name() %}
  {% set config = get_tenant_config(tenant) %}
  
  {{ log("=== テナント情報 ===", info=true) }}
  {{ log("テナント名: " ~ tenant, info=true) }}
  {{ log("S3バケット: " ~ config.get('s3_bucket', 'N/A'), info=true) }}
  {{ log("S3プレフィックス: " ~ config.get('s3_prefix', 'N/A'), info=true) }}
  {{ log("データベース: " ~ config.get('database', 'N/A'), info=true) }}
  {{ log("==================", info=true) }}
{% endmacro %}

-- テナント別外部テーブル名を生成
{% macro generate_external_table_name(entity, tenant_name=none) %}
  {% set table_name = get_table_name(entity) %}
  {{ return(table_name ~ '_external') }}
{% endmacro %} 