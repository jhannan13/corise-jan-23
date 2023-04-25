{{
  config(
    materialized = 'view'
    , unique_key = 'order_guid'
  )
}}

with orders_source as (
  select * from {{ source('postgres', 'orders') }}
)

, renamed_recast as (
  select
    order_id as order_guid
    , user_id as order_user_guid
    , order_cost
    , shipping_cost as order_shipping_cost
    , order_total as order_total_cost
    , status as order_status
    , promo_id::string as order_promo_desc
    , created_at::timestampntz as order_created_at_utc
    , estimated_delivery_at::timestampntz as order_estimated_delivery_at_utc
    , delivered_at::timestampntz as order_delivered_at_utc
  from orders_source
  union all
  select
    '8329a65b-7ddf-4250-aeee-bd625f8a401a' as order_guid
    , null as order_user_guid
    , null as order_cost
    , null as order_shipping_cost
    , null as order_total_cost
    , null as order_status
    , null as order_promo_desc
    , null as order_created_at_utc
    , null as order_estimated_delivery_at_utc
    , null as order_delivered_at_utc
  from orders_source
)

select * from renamed_recast