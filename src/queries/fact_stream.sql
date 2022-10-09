-- Insert a query that will populate fact_stream
-- number of seconds between device send and 
-- collector receive events is used
-- https://stackoverflow.com/questions/17708167/difference-in-seconds-between-timestamps-in-sqlite3

with min_delay as (

    select distinct
        *,
        min(julianday(collector_ts) - 
            julianday(device_created_ts) * 86400.0) as min_diff
    
    from stream
    group by event_id

)

select
    stream.*

from stream
inner join min_delay
    on stream.event_id = min_delay.event_id
    and (julianday(stream.collector_ts) - 
        julianday(stream.device_created_ts) * 86400.0 ) = min_delay.min_diff;