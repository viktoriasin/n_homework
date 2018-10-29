
 --TRANSFORM
 WITH top_rated as (
select distinct r.movieid
, hlp.avg_rating 
from ratings r 
join (select count(distinct userid) cnt
, avg(rating) avg_rating
, movieid 
from public.ratings
 group by movieid 
 having count(distinct userid) > 50 
 limit 150) hlp 
 on r.movieid = hlp.movieid 
 order by hlp.avg_rating desc
 , movieid asc
 )
 SELECT TR.MOVIEID, TAGS 
 FROM  top_rated TR
 JOIN keywords TG
 ON TG.MOVIEID = TR.MOVIEID;


--LOAD
 --ver 1
 WITH top_rated as (
select distinct r.movieid
, hlp.avg_rating 
from ratings r 
join (select count(distinct userid) cnt
, avg(rating) avg_rating
, movieid 
from public.ratings
 group by movieid 
 having count(distinct userid) > 50 
 limit 150) hlp 
 on r.movieid = hlp.movieid 
 order by hlp.avg_rating desc
 , movieid asc
 )
 SELECT TR.MOVIEID, TAGS INTO top_rated_tags
 FROM  top_rated TR
 JOIN keywords TG
 ON TG.MOVIEID = TR.MOVIEID;


--ver 2
WITH top_rated as (
 select h.movieid, h.avg_rating from 
 (select count(distinct userid) cnt
 , avg(rating) avg_rating
 , movieid
 from public.RATINGS
 group by movieid
 having count(distinct userid) > 50
 limit 150) h
 order by avg_rating desc
 , movieid ASC
)

 SELECT TR.MOVIEID, TAGS INTO top_rated_tags
 FROM  top_rated TR
 JOIN keywords TG
 ON TG.MOVIEID = TR.MOVIEID;



 \copy (SELECT * FROM top_rated_tags LIMIT 100) TO 'top_ratings_file.csv' WITH CSV HEADER DELIMETER as E'\t';