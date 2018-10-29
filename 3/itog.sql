--3.1

/*

Вывести список пользователей в формате userId, movieId, normed_rating, avg_rating где

userId, movieId - без изменения
для каждого пользователя преобразовать рейтинг r в нормированный - normed_rating=(r - r_min)/(r_max - r_min), где r_min и r_max соответственно минимально и максимальное значение рейтинга у данного пользователя
avg_rating - среднее значение рейтинга у данного пользователя
Вывести первые 30 таких записей
 
*/

SELECT USERID
, MOVIEID
, (RATING - MIN(RATING) OVER(PARTITION BY USERID)) / (MAX(RATING) OVER(PARTITION BY USERID) - MIN(RATING) OVER(PARTITION BY USERID)) NORMED_RATING
, AVG(RATING) OVER(PARTITION BY USERID) AVG_RATING 
FROM PUBLIC.RATINGS 
WHERE USERID <> 1 
ORDER BY USERID 
LIMIT 30;

--3.2

DROP TABLE IF EXISTS keywords;

CREATE TABLE keywords (
    movieId bigint,
    tags text
);

\copy keywords from '/data/keywords.csv' DELIMITER ',' CSV HEADER;

--LOAD
 --version 1
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
 ) hlp 
 on r.movieid = hlp.movieid 
 order by hlp.avg_rating desc
 , movieid asc
 limit 150
 )
 SELECT TR.MOVIEID, TAGS INTO top_rated_tags
 FROM  top_rated TR
 JOIN keywords TG
 ON TG.MOVIEID = TR.MOVIEID;


--version 2
WITH top_rated as (
 select h.movieid, h.avg_rating from 
 (select count(distinct userid) cnt
 , avg(rating) avg_rating
 , movieid
 from public.RATINGS
 group by movieid
 having count(distinct userid) > 50
 ) h
 order by avg_rating desc
 , movieid ASC
 limit 150
)

 SELECT TR.MOVIEID, TAGS INTO top_rated_tags
 FROM  top_rated TR
 JOIN keywords TG
 ON TG.MOVIEID = TR.MOVIEID;



 \copy (SELECT * FROM top_rated_tags LIMIT 100) TO 'top_ratings_file.csv' WITH CSV HEADER DELIMITER as E'\t';