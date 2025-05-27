-- macros/create_external_tables.sql
-- S3外部テーブル作成・管理用のマクロ

{% macro create_s3_external_table(table_name, s3_location, file_format='parquet', partitions=none) %}
  
  {% set create_table_sql %}
    CREATE EXTERNAL TABLE IF NOT EXISTS {{ table_name }} (
      {% for column in var('external_table_columns')[table_name] %}
        {{ column.name }} {{ column.data_type }}
        {%- if not loop.last -%},{%- endif %}
      {% endfor %}
    )
    {% if partitions %}
    PARTITIONED BY (
      {% for partition in partitions %}
        {{ partition.name }} {{ partition.data_type }}
        {%- if not loop.last -%},{%- endif %}
      {% endfor %}
    )
    {% endif %}
    STORED AS {{ file_format.upper() }}
    LOCATION '{{ s3_location }}'
    {% if file_format == 'parquet' %}
    TBLPROPERTIES (
      'has_encrypted_data'='false',
      'projection.enabled'='true'
    )
    {% endif %}
  {% endset %}

  {{ return(create_table_sql) }}

{% endmacro %}

{% macro refresh_external_table_partitions(table_name) %}
  
  {% set refresh_sql %}
    MSCK REPAIR TABLE {{ table_name }}
  {% endset %}

  {{ return(refresh_sql) }}

{% endmacro %}

{% macro get_external_table_info(source_name, table_name) %}
  
  {% set table_info = source(source_name, table_name) %}
  {% set external_config = table_info.external %}
  
  {% set info = {
    'location': external_config.location,
    'file_format': external_config.file_format,
    'partitions': external_config.get('partitioned_by', [])
  } %}

  {{ return(info) }}

{% endmacro %} 