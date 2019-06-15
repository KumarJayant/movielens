select count(1)
from "jku.movielens.db.data::links" l
where not exists (select 1 from "jku.movielens.db.data::movies" m where l.movieid = m.movieid)
union all
select count(1)
from "jku.movielens.db.data::movies" m
where not exists (select 1 from "jku.movielens.db.data::links" l where l.movieid = m.movieid);

select count(1)
from "jku.movielens.db.data::movies"
where genres is null or length(genres)=0;

do begin
  declare genrearray nvarchar(255) array;
  declare tmp nvarchar(255);
  declare idx integer;
  declare sep nvarchar(1) := '|';
  declare cursor cur for select distinct genres from "jku.movielens.db.data::movies";
  declare genres nvarchar (255) := '';
  idx := 1;
  for cur_row as cur() do
    select cur_row.genres into genres from dummy;
    tmp := :genres;
    while locate(:tmp,:sep) > 0 do
      genrearray[:idx] := substr_before(:tmp,:sep);
      tmp := substr_after(:tmp,:sep);
      idx := :idx + 1;
    end while;
    genrearray[:idx] := :tmp;
  end for;
  genrelist = unnest(:genrearray) as (genre);
  select genre from :genrelist group by genre;
end;

do begin
  declare genrearray nvarchar(255) array;
  declare tmp nvarchar(255);
  declare idx integer;
  declare sep nvarchar(1) := '|';
  declare cursor cur for select distinct genres from "jku.movielens.db.data::movies";
  declare genres nvarchar (255) := '';
  idx := 1;
  for cur_row as cur() do
    select cur_row.genres into genres from dummy;
    tmp := :genres;
    while locate(:tmp,:sep) > 0 do
      genrearray[:idx] := substr_before(:tmp,:sep);
      tmp := substr_after(:tmp,:sep);
      idx := :idx + 1;
    end while;
    genrearray[:idx] := :tmp;
  end for;
  genrelist = unnest(:genrearray) as (genre);
  select genre, count(1) from :genrelist group by genre;
end;

select
    movieid
  , title
  , occurrences_regexpr('[|]' in genres) + 1 as genre_count
  , genres
from "jku.movielens.db.data::movies"
order by genre_count desc;


select
  genre_count, count(1)
from (
  select occurrences_regexpr('[|]' in genres) + 1 genre_count
  from "jku.movielens.db.data::movies"
) group by genre_count order by genre_count;


select count(1)
from (
  select movieid, count(1) as tag_count
  from "jku.movielens.db.data::tags"
  group by movieid
);

select tag_count, count(1)
from (
  select movieid, count(1) as tag_count
  from "jku.movielens.db.data::tags"
  group by movieid
)
group by tag_count order by tag_count;

select rating_count, count(1) as movie_count
from (
  select movieid, count(1) as rating_count
  from "jku.movielens.db.data::ratings"
  group by movieid
)
group by rating_count order by rating_count asc;

select distinct
  min(rating_count) over( ) as min,
  max(rating_count) over( ) as max,
  avg(rating_count) over( ) as avg,
  sum(rating_count) over( ) as sum,
  median(rating_count) over( ) as median,
  stddev(rating_count) over( ) as stddev,
  count(*) over( ) as category_count
from (
  select movieid, count(1) as rating_count
  from "jku.movielens.db.data::ratings"
  group by movieid
)
group by rating_count;

select rating_count, count(1) as user_count
from (
  select userid, count(1) as rating_count
  from "jku.movielens.db.data::ratings"
  group by userid
)
group by rating_count order by 1 desc;

select distinct
  min(rating_count) over( ) as min,
  max(rating_count) over( ) as max,
  avg(rating_count) over( ) as avg,
  sum(rating_count) over( ) as sum,
  median(rating_count) over( ) as median,
  stddev(rating_count) over( ) as stddev,
  count(*) over( ) as category_count
from (
  select userid, count(1) as rating_count
  from "jku.movielens.db.data::ratings"
  group by userid
)
group by rating_count order by 1 desc;

select rating, count(1) as rating_count
from "jku.movielens.db.data::ratings"
group by rating order by 1 desc;

select rating,  count(1) as users_count from (
  select userid, rating, count(1) as rating_count
  from "jku.movielens.db.data::ratings"
  group by userid, rating
)
group by rating order by 1 desc;

select rating,  count(1) as movie_count from (
  select movieid, rating, count(1) as rating_count
  from "jku.movielens.db.data::ratings"
  group by movieid, rating
)
group by rating order by 1 desc;






