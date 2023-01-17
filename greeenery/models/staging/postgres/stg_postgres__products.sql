{{
  config(
    materialized = 'view'
    , unique_key = 'product_guid'
  )
}}

with products_source as (
  select * from {{ source('postgres', 'products') }}
)

, renamed_recast as (
  select
    product_id as product_guid
    , name as product_name
    , price as product_price
    , inventory as product_inventory
  from products_source
)

select * from renamed_recast