-- Clear tables content
truncate table "jku.movielens.db.hdb.pal::apriori.parameter";
truncate table "jku.movielens.db.hdb.pal::apriori.rules";
truncate table "jku.movielens.db.hdb.pal::apriori.pmml";

-- Insert operation parameters
insert into "jku.movielens.db.hdb.pal::apriori.parameter" VALUES ('MIN_SUPPORT'     , null, 0.1, null);
insert into "jku.movielens.db.hdb.pal::apriori.parameter" VALUES ('MIN_CONFIDENCE'  , null, 0.1, null);
insert into "jku.movielens.db.hdb.pal::apriori.parameter" VALUES ('MAX_CONSEQUENT'  , 1  , null, null);
insert into "jku.movielens.db.hdb.pal::apriori.parameter" VALUES ('MAX_ITEM_LENGTH' , 1  , null, null);

call "jku.movielens.db.hdb.pal.afllang::apriori"(
  "jku.movielens.db.hdb.pal::apriori.movielens_dataset",
  "jku.movielens.db.hdb.pal::apriori.parameter",
  "jku.movielens.db.hdb.pal::apriori.rules",
  "jku.movielens.db.hdb.pal::apriori.pmml"
) with overview;

select reco_count, count(1) as user_count
from (
  select userid, max(rank) as reco_count
  from "jku.movielens.db.hdb.pal.views::apriori_collaborative"
  group by userid
) group by reco_count order by reco_count desc;

select
    count(1) as movie_count
  , count(1) *100 / (select count(1) as count from "jku.movielens.db.data::movies" ) as movie_ratio
from (
  select movieid
  from "jku.movielens.db.hdb.pal.views::apriori_collaborative"
  group by movieid
);

select
    count(1) as movie_count
  , count(1) *100 / (select count(1) as count from "jku.movielens.db.data::movies" ) as movie_ratio
from (
  select prerule as movieid
  from "jku.movielens.db.hdb.pal::apriori.rules"
  where prerule not like '%&%'
  group by prerule
);

select reco_count, count(1) as movie_count
from (
  select movieid, max(rank) as reco_count
  from "jku.movielens.db.hdb.pal.views::apriori_contentbased"
  group by movieid
) group by reco_count order by 1 desc;

select
    count(1) as movie_count
  , count(1) *100 / (select count(1) as count from "jku.movielens.db.data::movies" ) as movie_ratio
from (
  select movieid
  from "jku.movielens.db.hdb.pal.views::apriori_contentbased"
  group by movieid
);

select rating_count, count(1) as movie_count
from (
  select ratings.movieid, count(1) as rating_count
  from "jku.movielens.db.data::ratings" ratings
  left outer join (
    select movieid
    from (
      select prerule as movieid
      from "jku.movielens.db.hdb.pal::apriori.rules"
      where prerule not like '%&%'
      group by prerule
    )
  ) t1 on (ratings.movieid = t1.movieid)
  where t1.movieid is null
  group by ratings.movieid
) group by rating_count;





