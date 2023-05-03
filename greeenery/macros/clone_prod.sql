{% macro clone_prod(
    db_to_clone = "DBT_PROD"
    , developer_db = "DEV_TEST"
    , developer_schema = target.schema
  )
%}
{# 
  clones production directly into your individual development schema, simply `dbt run-operation clone_prod`
#}
  {% set time_start = run_query("select current_timestamp") %}
  {{ log("beginning clone operation at " ~ time_start.rows[0][0], true) }}
  {% set create_schema_sql %}
    create schema if not exists {{ developer_db }}.{{ developer_schema }};
    {{ log("...rebuilding schema " ~ developer_db ~ "." ~ developer_schema ~ " ...", info=True) }}
  {% endset %}
  {% do run_query(create_schema_sql) %}
  {{ log("... " ~ developer_db ~ "." ~ developer_schema ~ " recreated ... moving to clone production", info=True) }}
  {% set schemas_to_clone_query %}
    show schemas in database dbt_prod;
  {% endset %}
  {% set schema_results = run_query(schemas_to_clone_query) %}
  {% set schemas_to_clone = schema_results.columns[1].values() %}
  {% for schema in schemas_to_clone %}
      {% set table_names_query %}
        select table_name
        from dbt_prod.information_schema.tables
        where upper(table_schema) = upper('{{schema}}')
          and table_type = 'BASE TABLE'
      {% endset %}
      {% set tables_results = run_query(table_names_query) %}
      {% set table_names = tables_results.columns[0].values() %}
      {% for t_name in table_names %}
        {% set t_ref = schema ~ "." ~ t_name %}
        {% set clone_ref = developer_schema ~ "." ~ t_name %}
        {% set create_table_sql %}
          create or replace transient table {{ developer_db }}.{{ clone_ref }} clone {{ db_to_clone }}.{{ t_ref }};
          {{ log("...cloning table " ~ db_to_clone ~ "." ~ t_ref ~ " ... into " ~ developer_db ~ "." ~ developer_schema, info=True) }}
        {% endset %}
        {% do run_query(create_table_sql) %}
      {% endfor %}
  {% endfor %}
  {{ log("...Finished cloning... your tables should now match prod!", info=True) }}
  {% set time_end = run_query("select current_timestamp") %}
  {% set total_minutes = run_query("select datediff('seconds', '" ~ time_start.rows[0][0] ~ "', '" ~ time_end.rows[0][0] ~ "')/60") %}
  {{ log("Total elapsed time: " ~ total_minutes[0][0] ~ " minutes", true) }}
{% endmacro %}