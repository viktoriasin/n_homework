
--1.1 выбрать 10 записей из таблицы rating
SELECT * FROM PUBLIC.RATINGS LIMIT 10;

--1.2 выбрать из таблицы links всё записи, у которых imdbid оканчивается на "42", а поле movieid между 100 и 1000
SELECT * FROM PUBLIC.LINKS WHERE IMDBID LIKE '%42' AND MOVIEID BETWEEN 100 AND 1000 LIMIT 10;

--2.1 выбрать из таблицы links все imdbId, которым ставили рейтинг 5
SELECT DISTINCT L.IMDBID FROM PUBLIC.LINKS L JOIN PUBLIC.RATINGS R ON L.MOVIEID = R.MOVIEID 
WHERE R.RATING = 5 ORDER BY L.IMDBID LIMIT 10;

 --3.1 Посчитать число фильмов без оценок
 SELECT COUNT(L.MOVIEID) FROM PUBLIC.LINKS L LEFT JOIN PUBLIC.RATINGS R ON L.MOVIEID = R.MOVIEID
 WHERE R.MOVIEID IS NULL;

 --3.2 вывести top-10 пользователей, у который средний рейтинг выше 3.5
 SELECT USERID, AVG(RATING) AVG_R FROM PUBLIC.RATINGS
 GROUP BY USERID
 HAVING AVG(RATING) > 3.5
 ORDER BY USERID
 LIMIT 10;

--4.1 достать любые 10 imbdId из links у которых средний рейтинг больше 3.5
SELECT L.IMDBID FROM PUBLIC.LINKS L JOIN 
(SELECT 
R.MOVIEID, AVG(R.RATING) 
FROM PUBLIC.RATINGS R
GROUP BY R.MOVIEID
HAVING AVG(R.RATING) > 3.5) RTNG
ON L.MOVIEID = RTNG.MOVIEID LIMIT 10;



--4.2  посчитать средний рейтинг по пользователям, у которых более 10 оценок. Нужно подсчитать средний рейтинг по все пользователям, 
--     которые попали под условие - то есть в ответе должно быть одно число.
WITH CNT_U AS (SELECT USERID, COUNT(RATING)
FROM PUBLIC.RATINGS
GROUP BY USERID
HAVING COUNT(RATING) > 10)
SELECT AVG(RATING) AVG_RTNG
FROM PUBLIC.RATINGS JOIN CNT_U 
ON RATINGS.USERID = CNT_U.USERID;


