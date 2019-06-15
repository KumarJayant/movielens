-- Insert operation parameters
truncate table "jku.movielens.db.hdb.apl::recommendation.function_header";
insert into "jku.movielens.db.hdb.apl::recommendation.function_header" values ('Oid', '#42');
insert into "jku.movielens.db.hdb.apl::recommendation.function_header" values ('LogLevel', '8');

truncate table "jku.movielens.db.hdb.apl::recommendation.operation_config";
insert into "jku.movielens.db.hdb.apl::recommendation.operation_config" values ('APL/ModelType'  , 'recommendation');
insert into "jku.movielens.db.hdb.apl::recommendation.operation_config" values ('APL/User'       , 'USERID'        ); -- mandatory
insert into "jku.movielens.db.hdb.apl::recommendation.operation_config" values ('APL/Item'       , 'MOVIEID'       ); -- mandatory
insert into "jku.movielens.db.hdb.apl::recommendation.operation_config" values ('APL/RuleWeight' , 'Support'       );

-- Clear other tables content
truncate table "jku.movielens.db.hdb.apl::recommendation.variable_descs";
truncate table "jku.movielens.db.hdb.apl::recommendation.operation_log";
truncate table "jku.movielens.db.hdb.apl::recommendation.summary";
truncate table "jku.movielens.db.hdb.apl::recommendation.indicators";

truncate table "jku.movielens.db.hdb.apl::recommendation.model";
truncate table "jku.movielens.db.hdb.apl::recommendation.model_node_user";
truncate table "jku.movielens.db.hdb.apl::recommendation.model_node_movie";
truncate table "jku.movielens.db.hdb.apl::recommendation.model_links";
truncate table "jku.movielens.db.hdb.apl::recommendation.model_sql_code";

call "jku.movielens.db.hdb.apl.afllang::recommendation"(
  "jku.movielens.db.hdb.apl::recommendation.function_header",
  "jku.movielens.db.hdb.apl::recommendation.operation_config",
  "jku.movielens.db.hdb.apl::recommendation.variable_descs",
  "jku.movielens.db.data::ratings",
  "jku.movielens.db.hdb.apl::recommendation.model",
  "jku.movielens.db.hdb.apl::recommendation.model_node_user",
  "jku.movielens.db.hdb.apl::recommendation.model_node_movie",
  "jku.movielens.db.hdb.apl::recommendation.model_links",
  "jku.movielens.db.hdb.apl::recommendation.operation_log",
  "jku.movielens.db.hdb.apl::recommendation.summary",
  "jku.movielens.db.hdb.apl::recommendation.indicators",
  "jku.movielens.db.hdb.apl::recommendation.model_sql_code"
) with overview;


select * from "jku.movielens.db.hdb.apl::recommendation.operation_log";

select * from "jku.movielens.db.hdb.apl::recommendation.summary";

select * from "jku.movielens.db.hdb.apl::recommendation.indicators";

select * from "jku.movielens.db.hdb.apl::recommendation.model_sql_code";

select reco_count, count(1) as user_count
from (
  select userid, max(rank) as reco_count
  from "jku.movielens.db.hdb.apl.views::recommendation_collaborative"
  group by userid
) group by reco_count order by 1 desc;

select
    count(1) as movie_count
  , count(1) * 100 / (select count(1) as cnt from "jku.movielens.db.data::movies") as movie_ratio
from (
  select movieid
  from "jku.movielens.db.hdb.apl.views::recommendation_collaborative"
  group by movieid
);

select
    count(1) as movie_count
  , count(1) * 100 / (select count(1) as cnt from "jku.movielens.db.data::movies") as movie_ratio
from (
    select movieid
    from (
      select kxnodesecond   as movieid from "jku.movielens.db.hdb.apl::recommendation.model_links" where graph_name = 'Item' group by  kxnodesecond
      union all
      select kxnodesecond_2 as movieid from "jku.movielens.db.hdb.apl::recommendation.model_links" where graph_name = 'Item' group by  kxnodesecond_2
    ) group by movieid
);


select reco_count, count(1) as movie_count
from (
  select movieid, max(rank) as reco_count
  from "jku.movielens.db.hdb.apl.views::recommendation_contentbased"
  group by movieid
) group by reco_count;

select
    count(1) as movie_count
  , count(1) * 100 / (select count(1) as cnt from "jku.movielens.db.data::movies" ) as movie_ratio
from (
  select movieid
  from "jku.movielens.db.hdb.apl.views::recommendation_contentbased"
  group by movieid
);

select rating_count, count(1) as movie_count
from (
  select ratings.movieid, count(1) as rating_count
  from "jku.movielens.db.data::ratings" ratings
  left outer join (
    select movieid
    from (
      select movieid
      from (
        select kxnodesecond   as movieid from "jku.movielens.db.hdb.apl::recommendation.model_links" where graph_name = 'Item' group by  kxnodesecond
        union all
        select kxnodesecond_2 as movieid from "jku.movielens.db.hdb.apl::recommendation.model_links" where graph_name = 'Item' group by  kxnodesecond_2
      ) group by movieid
    )
  ) t1 on (ratings.movieid = t1.movieid)
  where t1.movieid is null
  group by ratings.movieid
) group by rating_count;






