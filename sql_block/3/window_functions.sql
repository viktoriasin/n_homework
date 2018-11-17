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