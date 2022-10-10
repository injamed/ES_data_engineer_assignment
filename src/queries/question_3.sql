-- 3) Who are the 3 most played artists and how many plays do they have?

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

-- selecting alphabetically first artist name for
-- duplicated artist_ids

first_artist as (

    select
        artist_id,
        artist_name,
        min(artist_name) as first_artist_name

    from artist
    group by 1

),

unique_atrist as (

    select
        artist.*

    from artist
    inner join first_artist
        on artist.atrist_id = first_artist.artist_id
        and artist.artist_name = first_artist.artist_name

)

select
    first_artist.artist_name,
    count(fact_stream.event_id) as count_plays

from fact_stream
inner join unique_track
    on fact_stream.track_id = unique_track.track_id
inner join trackartist
    on unique_track.track_id = trackartist.track_id
inner join first_artist
    on trackartist.artist_id = first_artist.artist_id

group by 1
order by 2 desc
limit 3;