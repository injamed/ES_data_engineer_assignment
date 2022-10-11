# Report

## Queries and design decisions
As hinted in the description, **stream** table includes multiple events with the
same event_id:

`sqlite> select count(event_id) from stream;`
237001

`sqlite> select count(distinct event_id) from stream;`
215358

-> 21643 repeating events.

For examample, by running

`sqlite> select event_id, count(*) as cnt from stream group by 1 order by 2 desc limit 16;`
we see that 3ec9a256-a08f-4f9c-9872-eac1af526188 appears 5 times

`sqlite> select * from stream where event_id = "3ec9a256-a08f-4f9c-9872-eac1af526188"`
with the same device_sent_ts and different collector received timestamps.

In the fact table I decided to keep unique events with the shortest time
between sending and reception (checked, just in case, that collection time
is always later than creation).

## Questions
> 1. How many tracks do we have in our catalog?

Similarly to streams in track table, same track_id can correspond to the 
multiple different titles, durations, and release dates suggesting that stream
and track tables were populated using similar algorithms. It may mean a data
quality issue or design when, for example, track is deleted from the
catalogue, it's id becomes available for re-use.

Track names are not unique either, though it is not uncommon that the same names
are used by different artists. 

I took the assumption that ids are reused (as above), therefore count of tracks
in catalogue would be a count of unique track ids.

> 2. Which song has been streamed for the most minutes, 
> and how many people worked on it?

For this question I apply simplified version of the unique track - for the same
track id it is the most recent release date.
Track "Upgradable high-level migration", 6 artists worked on it.

> 3. Who are the 3 most played artists, and how many plays do they have?

Each play (stream event) is a play of the track. In the cases then multiple
artists worked on the track one can argue differently about the attribution
of one play to the artist. Possible considerations: 
- assign each artist who worked on the track one play when jointy created track 
is played,
- assign each artist 1/(number of artists worked on the track) fraction of the
play,
- assign each artist full or length of play duration or length of play duration/
(number of artists worked on the track).

I assume the first choise and grant each artist who worked on the track one play,
this will expand streams fact table to the grain of artist (each stream will
be artibuted to each artists who participated in the track creation).

Also, artist table have two duplicated names per id. I assume, for simplicity,
the same situation with id re-use and select unique artist as first
alphabetically (see the query).

|artist name|number of plays|
|-----------|---------------|
|Herr Nicolai Wulf B.Eng.|417|
|Céline-Jessica Paquin|347|
|Émilie Dubois|332|

> 4. What were the titles of the top 3 most streamed songs during each year, 
> and how many streams did they get?

Comments mainly in the question_4.sql, in particular regarding same ranking,
as well as query result

|year|top position|track name|number of streams|
|----|------------|----------|-----------------|
|2012|1|Intuitive holistic matrix|3|
|2012|2|Universal fresh-thinking implementation|3|
|2012|3|Re-engineered zero administration parallelism|3|
|2013|1|Customizable 5thgeneration synergy|6|
|2013|2|Automated tertiary challenge|5|
|2013|3|Intuitive intangible conglomeration|5|
|2014|1|Business-focused local infrastructure|7|
|2014|2|Intuitive intangible conglomeration|7|
|2014|3|Networked radical database|7|
|2015|1|Re-contextualized content-based workforce|10|
|2015|2|Balanced intangible capacity|7|
|2015|3|Implemented intangible software|7|
|2016|1|Cross-group radical moderator|8|
|2016|2|Down-sized systematic alliance|7|
|2016|3|Business-focused logistical methodology|7|
|2017|1|Cloned modular application|8|
|2017|2|Extended web-enabled toolset|8|
|2017|3|Programmable asynchronous encoding|8|
|2018|1|Re-engineered multi-state process improvement|10|
|2018|2|Switchable web-enabled approach|9|
|2018|3|Customer-focused systematic support|9|
|2019|1|Compatible fresh-thinking workforce|11|
|2019|2|Automated non-volatile artificial intelligence|11|
|2019|3|Robust user-facing system engine|11|
|2020|1|Compatible asynchronous methodology|16|
|2020|2|Focused radical architecture|16|
|2020|3|Profit-focused bi-directional structure|14|

> 5. How long do we need to expect to wait until we have received 99% of a 
> given set of stream events at the collector relative to when the events were 
> created?

Important reminder here is that duplicated events are removed from the
fact_stream and we have only "fastest event reception".
With this consideration the answer is: about 14 seconds.

> 6. Would you have built any other tables on top of the provided data 
> to aid your work?

There are two/three types of the insides questions grain provided data contents:
track (in time), artists (in time), and track-artists.
With the current structure it is relativaly easy to answer track questions,
relativaly hard to answer artist and combined questions. Something alike bridge
table for artist group will be useful.

> 7. artist and track contain PII data; how would you handle this kind of 
> sensitive data while creating a data model on top of those tables?

Firstly I would avoid joining sensitive columns (names/track_names) in the
downstream models unless nessessary, for example in case of aggreggate
statistics. Secondly, one can hash sensitive data. Thirdly, split sensitive
and non-sensitive (hashed) data into different schemas and provide relevant
role access.

> 8. stream_new represents new data that we would like to merge with the old 
> stream data as it comes in; how would you design the fact table (fact_stream) 
> to scale efficiently?

Probably I am missng on this quesion and overarching idea of fact table, but
will try. stream data is already facts as is, so we append new data daily with 
the appropriate data storage and retention considerations. Since we have 
duplicating events, we may either update the last event (by event_id) with 
the new loading time or disregard (not insert) duplicated events into 
stream table. In case of updating, a column "updated_at" will be tracking 
the update timestamps.

> 9. Your stakeholder wants to know the exact amount of plays per day, 
> but as you saw the streams can arrive delayed in the database. 
> How would you handle the delayed data?

Exact number of streams for date X can only fully be available on the day X+1,
and, as we know from the previous exploration, delay in receiving the first
event (in possibly duplicated sequence) is short enough to rely on daily
statistic.
Other thing to consider in this question is when stakeholder needs to know
exact statistic and if it is within expected delay window.

> 10. To increase the robustness of our reporting layer we would like to have
> data quality tests in place. What tests would you propose and how would you 
> implement them?

Non-null, relationships and uniquness (relevant to the data at hand) tests
are available as generic on source data and derived data models in dbt
https://docs.getdbt.com/docs/building-a-dbt-project/tests, as well as custom
tests which can also be implemented in dbt.

