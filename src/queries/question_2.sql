-- 2) Which song has been streamed for the most minutes, and how many people worked on it?

-- selecting the track with the most recent release date
with latest_release as (

    select
        track_id,
        max(release_date) as latest_release_date

    from track
    group by 1

),

-- filtering tracks on the most resent release
unique_track as (

    select
        track.*

    from track
    inner join latest_release
        on track.track_id = latest_release.track_id
        and track.release_date = latest_release.latest_release_date

),

-- finding the most played track (from streams)
most_played_track_id as (

    select
        track_id,
        sum(track_played_sec)/60 as track_played_min

    from fact_stream
    group by 1
    order by track_played_min desc
    limit 1

),

most_played_track as (

    select
        unique_track.track_id,
        unique_track.track_name,
        most_played_track_id.track_played_min

    from unique_track
    inner join most_played_track_id
        on unique_track.track_id = most_played_track_id.track_id

)

-- MOST PLAYED TRACK NAME:
select
    track_name,
    "" as artist_num

from most_played_track

union all

-- MOST PLAYED TRACK WAS WORKED ON BY:
select
    "" as track_name,
    count(distinct artist_id)

from trackartist
where track_id = (select track_id from most_played_track);
