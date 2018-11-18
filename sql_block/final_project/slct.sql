--1

/*По таблицам Income и Outcome для каждого пункта приема найти остатки денежных средств на конец каждого дня, 
в который выполнялись операции по приходу и/или расходу на данном пункте.
Учесть при этом, что деньги не изымаются, а остатки/задолженность переходят на следующий день.
Вывод: пункт приема, день в формате "dd/mm/yyyy", остатки/задолженность на конец этого дня.
*/

with src as (select coalesce(inc.point, out.point) point, coalesce(inc.date,out.date) date,
sum_inc, sum_out, coalesce(sum_inc,0)- coalesce(sum_out,0) rst
from (
select i.point, i.date, sum(inc) sum_inc from income i
group by i.point, i.date
) inc
full outer join
(
select o.point, o.date, sum(out) sum_out from outcome o
group by o.point, o.date
)  out
on out.point = inc.point and out.date=inc.date
)
select  point, to_char(date,  'DD/MM/YYYY') ,  (select sum(rst) from src s2 where s1.point = s2.point and s2.date <= s1.date group by s2.point) from
src s1
order by point, date;

--2
/*
Среди тех, кто пользуется услугами только какой-нибудь одной компании, определить имена разных пассажиров, летавших чаще других. 
Вывести: имя пассажира и число полетов.
*/

select  name , count(t.trip_no) trip_Qty from trip t join pass_in_trip p 
on t.trip_no = p.trip_no join passenger ps on p.id_psg = ps.id_psg
group by p.id_psg, name
having count(distinct id_comp) = 1
and count(t.trip_no) >= all (select  count(t.trip_no)   from trip t join pass_in_trip p 
on t.trip_no = p.trip_no join passenger ps on p.id_psg = ps.id_psg
group by p.id_psg, name
having count(distinct id_comp) = 1);

--3
/*Определить время, проведенное в полетах, для пассажиров, летавших всегда на разных местах. 
Вывод: имя пассажира, время в минутах.
*/

with pass  as (
select p.id_psg, name from pass_in_trip pp
join passenger p
on p.id_psg = pp.id_psg
group by p.id_psg, name
having count(distinct place) = count(trip_no)
)
, tt as (
select t.trip_no,pp.id_psg, name, extract(HOUR from time_out) * 60  + extract(MINUTE from time_out) time_dep,
extract(HOUR from time_in) * 60  + extract(MINUTE from time_in) time_arr
from trip t
join pass_in_trip pp
on pp.trip_no = t.trip_no
join pass s
on s.id_psg = pp.id_psg)
SELECT name, sum(CASE 
 WHEN time_dep >= time_arr 
 THEN time_arr - time_dep + 1440 
 ELSE time_arr - time_dep 
 END  )
from tt
group by name, id_psg

--4
/*
Определить дни, когда было выполнено максимальное число рейсов из
Ростова ('Rostov'). Вывод: число рейсов, дата.
*/

SELECT COUNT(t.trip_no) AS cnt, t.date 
       FROM 
         (SELECT DISTINCT trip_no, date FROM Pass_in_trip) AS t, 
            Trip WHERE trip.trip_no=t.trip_no AND 
            trip.town_from='Rostov' 
       GROUP BY t.date
having count(t.trip_no) >= all  (SELECT  COUNT(t.trip_no) AS cnt
       FROM 
         (SELECT DISTINCT trip_no, date FROM Pass_in_trip) AS t, 
            Trip WHERE trip.trip_no=t.trip_no AND 
            trip.town_from='Rostov' 
       GROUP BY t.date);

--5

/*
Определить пассажиров, которые больше других времени провели в полетах. 
Вывод: имя пассажира, общее время в минутах, проведенное в полетах
*/

with  tt as (
select t.trip_no,pp.id_psg, name, extract(HOUR from time_out) * 60  + extract(MINUTE from time_out) time_dep,
extract(HOUR from time_in) * 60  + extract(MINUTE from time_in) time_arr
from trip t
join pass_in_trip pp
on pp.trip_no = t.trip_no
join passenger r
on r.id_psg = pp.id_psg)
, pass as (
SELECT name, sum(CASE 
 WHEN time_dep >= time_arr 
 THEN time_arr - time_dep + 1440 
 ELSE time_arr - time_dep 
 END  ) tm
from tt
group by name, id_psg)
select name, tm from (
select name ,tm,rank() over(order by tm desc ) rnk from pass) src
where rnk  = 1

--6
/*
Для каждой компании подсчитать количество перевезенных пассажиров (если они были в этом месяце) по декадам апреля 2003. При этом учитывать только дату вылета. 
Вывод: название компании, количество пассажиров за каждую декаду
*/

select c.name
, sum(case when extract(day from date) < 11 then  1 else 0 end) frst,
sum(case when extract(day from date ) < 21 and extract(day from date ) > 10 then 1 else 0 end) scnd,
sum(case when extract(day from date) < 31 and extract(day from date ) > 20 then 1  else 0 end) thrd
from (
select * from trip t
join pass_in_trip p
on t.trip_no = p.trip_no
where extract(month from date) = 4 and extract(year from date) = 2003
) z
join company c
on c.id_comp = z.id_comp
group by c.id_comp;

--7 

/*
Среди тех, кто пользуется услугами только одной компании, определить имена разных пассажиров, летавших чаще других. 
Вывести: имя пассажира, число полетов и название компании.
*/

select name, trip_Qty, (select distinct company.name from company join
trip on trip.id_comp = company.id_comp join pass_in_trip p
on p.trip_no = trip.trip_no
where z.id_psg = p.id_psg) com_name
 from (
select  p.id_psg, ps.name , count(t.trip_no) trip_Qty from trip t join pass_in_trip p 
on t.trip_no = p.trip_no join passenger ps on p.id_psg = ps.id_psg
group by p.id_psg, ps.name
having count(distinct t.id_comp) = 1
and count(t.trip_no) >= all (select  count(t.trip_no)   from trip t join pass_in_trip p 
on t.trip_no = p.trip_no join passenger ps on p.id_psg = ps.id_psg
group by p.id_psg, name
having count(distinct id_comp) = 1)
) z;
