{{
  config(
    materialized = 'view'
    , unique_key = 'user_guid'
  )
}}

with user_source as (
  select * from {{ source('postgres', 'users') }}
)

, renamed_recast as (
  select
    user_id as user_guid
    , first_name as user_first_name
    , last_name as user_last_name
    , email as user_email
    , phone_number as user_phone_number
    , created_at::timestampntz as user_created_at_utc
    , updated_at::timestampntz as user_updated_at_utc
    , address_id as address_guid
  from user_source
)

select * from renamed_recast