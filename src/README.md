# Report

## Queries and design decisions
As hinted in the description, **stream** table includes multiple events with the
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

Herr Nicolai Wulf B.Eng.|417 plays
Céline-Jessica Paquin|347 plays
Émilie Dubois|332 plays

> 5. How long do we need to expect to wait until we have received 99% of a 
> given set of stream events at the collector relative to when the events were 
> created?

Important reminder here is that duplicated events are removed from the
fact_stream and we have only "fastest event reception".
With this limitation the answer is: about 14 seconds.