-- 4) What were the titles of the top 3 most streamed songs during each year, and how many streams did they get?

with num_streams_yearly as (

    select
        strftime('%Y', device_created_ts) as year,
        track_id,
        count(event_id) as num_streams

    from fact_stream
    group by 1, 2

),

ranked_years as (

    select
        year,
        track_id,
        rank () over (partition by year order by num_streams desc) as rank_pos,
        num_streams

    from num_streams_yearly

),

-- Tracks with equal number of streams receive equal rank,
-- therefore number of top tracks may increase 3.
-- My personal choise would be to display all tracks in the above table as
-- "top tracks" in the sense that they receive 1, 2, and 3rd ranked amount of
-- playes.
-- Below is a crude approach of cut the top to exactly 3 positions.
-- row_number could have been used in above calculation directly.

cut_ranking_raw as (

    select
        year,
        track_id,
        row_number () over (partition by year order by rank_pos) as top_position,
        num_streams

    from ranked_years
    where rank_pos <=3
    order by year, top_position

),

-- selecting the "newest" track name for the year

recent_names as (

    select
        cut_ranking_raw.year,
        cut_ranking_raw.track_id,
        cut_ranking_raw.top_position,
        cut_ranking_raw.num_streams,
        max(track.release_date) as recent_release_date

    from cut_ranking_raw
    inner join track
        on cut_ranking_raw.track_id = track.track_id
    where top_position <= 3
    group by 1, 2, 3, 4

)

select distinct
    cut_ranking_raw.year,
    cut_ranking_raw.top_position,
    track.track_name,
    cut_ranking_raw.num_streams

from cut_ranking_raw
inner join recent_names
    on cut_ranking_raw.year = recent_names.year
    and cut_ranking_raw.track_id = recent_names.track_id
    and cut_ranking_raw.top_position = recent_names.top_position
    and cut_ranking_raw.num_streams = recent_names.num_streams
inner join track
    on cut_ranking_raw.track_id = track.track_id
    and track.release_date = recent_names.recent_release_date
order by cut_ranking_raw.year, cut_ranking_raw.top_position;





