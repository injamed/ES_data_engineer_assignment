-- 1) How many tracks do we have in our catalog?

select
    count(distinct track_id)

from track;