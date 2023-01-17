{{
  config(
    materialized = 'view'
    , unique_key = 'address_guid'
  )
}}

with addresses_source as (
  select * from {{ source('postgres', 'addresses') }}
)

, renamed_recast as (
  select
    address_id as address_guid
    , address as address_street_address
    , lpad(zipcode::varchar, 5, '0') as address_zip_code
    , state as address_state
    , country as address_country
  from addresses_source
)

select * from renamed_recast