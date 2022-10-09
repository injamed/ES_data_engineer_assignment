# Report

## Queries and design decisions
> As hinted in the description, stream table includes multiple events with the
same event_id:

sqlite> select count(event_id) from stream;
237001
sqlite> select count(distinct event_id) from stream;
215358

-> 21643 repeating events.

For examample, by running
sqlite> select event_id, count(*) as cnt from stream group by 1 order by 2 desc limit 16;
we see that 3ec9a256-a08f-4f9c-9872-eac1af526188 appears 5 times
sqlite> select * from stream where event_id = "3ec9a256-a08f-4f9c-9872-eac1af526188"
with the same device_sent_ts and different collector received timestamps.

In the fact table I decided to keep unique events with the shortest time
between sending and reception (checked, just in case, that collection time
is always later than creation).

For this end I create an intermediary table stream_unique.


## Questions
> add your answers here