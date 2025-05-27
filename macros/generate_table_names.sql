-- macros/generate_table_names.sql
-- 変数を使った動的テーブル名・S3パス生成マクロ

{% macro generate_s3_path(entity_name) %}
  {%- set s3_bucket = var('s3_bucket') -%}
  {%- set s3_prefix = var('s3_prefix') -%}
  {%- set entity = var('data_sources')[entity_name] -%}
  
  s3://{{ s3_bucket }}/{{ s3_prefix }}/{{ entity }}/
{% endmacro %}

{% macro generate_source_table_name(entity_name) %}
  {%- set entity = var('data_sources')[entity_name] -%}
  {%- set suffix = var('source_suffix') -%}
  
  {{ entity }}_{{ suffix }}
{% endmacro %}

{% macro generate_staging_table_name(entity_name) %}
  {%- set prefix = var('staging_prefix') -%}
  {%- set entity = var('data_sources')[entity_name] -%}
  {%- set environment = var('environment') -%}
  
  {{ prefix }}_{{ entity }}_s3{% if environment != 'prod' %}_{{ environment }}{% endif %}
{% endmacro %}

{% macro get_environment_config(config_key) %}
  {%- set environment = var('environment') -%}
  {%- set env_config = var(environment, {}) -%}
  
  {% if config_key in env_config %}
    {{ env_config[config_key] }}
  {% else %}
    {{ var(config_key) }}
  {% endif %}
{% endmacro %}

{% macro generate_full_s3_path(entity_name) %}
  {%- set bucket = get_environment_config('s3_bucket') -%}
  {%- set prefix = var('s3_prefix') -%}
  {%- set entity = var('data_sources')[entity_name] -%}
  
  s3://{{ bucket }}/{{ prefix }}/{{ entity }}/
{% endmacro %}

{% macro list_all_entities() %}
  {%- set entities = var('data_sources').keys() -%}
  {{ return(entities | list) }}
{% endmacro %}

{% macro generate_entity_mapping() %}
  {%- set entities = var('data_sources').keys() -%}
  {%- set mapping = {} -%}
  
  {%- for entity in entities -%}
    {%- set entity_info = {
        'source_table': generate_source_table_name(entity),
        'staging_table': generate_staging_table_name(entity),
        's3_path': generate_full_s3_path(entity),
        'entity_name': var('data_sources')[entity]
    } -%}
    {%- do mapping.update({entity: entity_info}) -%}
  {%- endfor -%}
  
  {{ return(mapping) }}
{% endmacro %} 