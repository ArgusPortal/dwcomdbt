-- import

with source as (
    select
        "date",
        "Close",
        "simbolo"
    from 
        {{ source ('database_rq2i', 'commodities') }}
),

renamed as (

    select
        cast("date" as date) as data,
        "Close" as valor_fechamento,
        simbolo
    from
        source
)

select * from renamed