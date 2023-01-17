{{
  config(
    materialized = 'view'
    , unique_key = 'order_items_unique_id'
  )
}}

with source as (
  select * from {{ source('postgres', 'order_items') }}
)

, renamed_recast as (
  select
    order_id as order_item_order_guid
    , product_id as order_item_product_guid
    , {{ dbt_utils.surrogate_key([
        'order_item_order_guid'
        , 'order_item_product_guid'
        ])
      }} as order_items_unique_id
    , quantity as order_item_quantity
  from source
)

select * from renamed_recast