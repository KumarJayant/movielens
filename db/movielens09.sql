DO BEGIN
  call "jku.movielens.db.hdb.apl.procedures::recommendation_execute"(
    BESTSELLERTHRESHOLD    => 50000,
    MAXTOPNODES            => 100000,
    MINIMUMCONFIDENCE      => 0.05,
    MINIMUMPREDICTIVEPOWER => null,
    MINIMUMSUPPORT         => 2,
    OPERATION_LOG   => :OPERATION_LOG,
    SUMMARY         => :SUMMARY,
    INDICATORS      => :INDICATORS,
    MODEL_SQL_CODE  => :MODEL_SQL_CODE
  );

  select 'distinct users included in the model'  as key, count(1) as value from "jku.movielens.db.hdb.apl::recommendation.model_node_user"
  union all
  select 'distinct movies included in the model' as key, count(1) as value from "jku.movielens.db.hdb.apl::recommendation.model_node_movie";
END;

DO BEGIN
  call "jku.movielens.db.hdb.apl.procedures::recommendation_result_collaborative"(
    USERID              => 32,
    INCLUDEBESTSELLER   => 0,
    BESTSELLERTHRESHOLD => 50000,
    SKIPALREADYOWNED    => 1,
    KEEPTOPN            => 5,
    RESULTS             => :results
  );
  select * from :results;
END;

DO BEGIN
  call "jku.movielens.db.hdb.apl.procedures::recommendation_result_contentbased"(
    MOVIEID             => 32,
    INCLUDEBESTSELLER   => 0,
    BESTSELLERTHRESHOLD => 50000,
    KEEPTOPN            => 5,
    RESULTS             => :results
  );
  select * from :results;
END;

DO BEGIN
  call "jku.movielens.db.hdb.pal.procedures::apriori_execute"(
    MIN_SUPPORT    => 0.1,
    MIN_CONFIDENCE => 0.1,
    MIN_LIFT       => 0.0,
    UBIQUITOUS     => 1.0,
    RULES   => :rules,
    PMML    => ?
  );

  select 'rules count' as key, count(1) as value from :rules;
END;

DO BEGIN
  call "jku.movielens.db.hdb.pal.procedures::apriori_result_collaborative"(
    USERID    => 23,
    KEEPTOPN  => 5,
    RESULTS   => :results
  );
  select * from :results;
END;

DO BEGIN
  call "jku.movielens.db.hdb.pal.procedures::apriori_result_contentbased"(
    MOVIEID   => 32,
    KEEPTOPN  => 5,
    RESULTS   => :results
  );
  select * from :results;
END;




