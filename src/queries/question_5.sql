-- 5) How long do we need to expect to wait until we have received 99% of a given set of stream events at the collector relative to when the events were created?

with diff as (

    select
        (julianday(collector_ts) - julianday(device_created_ts)) * 86400.0 as delay

    from fact_stream

),

percentiles as (

    select
        delay,
        ntile(100) over (order by delay) as perc

    from diff

)

select
    max(delay)

from percentiles
where perc = 99;