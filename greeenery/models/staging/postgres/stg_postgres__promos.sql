{{
  config(
    materialized = 'view'
    , unique_key = 'promo_desc'
  )
}}

with promos_source as (
  select * from {{ source('postgres', 'promos') }}
)

, renamed_recast as (
  select
    -- should probably consider a surrogate here for uniqueness/id
    promo_id as promo_desc
    , discount as promo_discount
    , status as promo_status
    , iff(status = 'active', true, false) as promo_is_active
  from promos_source
)

select * from renamed_recast