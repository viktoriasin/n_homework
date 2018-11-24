--1

/*
Вывести id, текущую, предыдущую, следующую дату полета пассажира.
*/

Select id_psg,
TO_CHAR(DATE,'Day, DD MONTH YYYY') cur_date,
coalesce(to_char(lag(date) over(partition by id_psg order by date),'Day,DD MONTH YYYY'),'this is the first trip') prev_date,
coalesce(to_char(lead(date) over(partition by id_psg order by date),'Day, DD MONTH YYYY'), 'this is the last trip by now') date_next 
from pass_in_trip;

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

--8
 /*
 Для каждой компании, перевозившей пассажиров, подсчитать время, которое провели в полете самолеты с пассажирами. 
Вывод: название компании, время в минутах.
*/
with trip_t as (
select p.trip_no, t.id_comp, extract(HOUR from time_out) * 60  + extract(MINUTE from time_out) time_dep,
extract(HOUR from time_in) * 60  + extract(MINUTE from time_in) time_arr
from trip t 
join pass_in_trip p
on t.trip_no = p.trip_no
GROUP BY t.trip_no,p.trip_no, date, time_out, time_in
)
select c.name,  sum(CASE 
 WHEN time_dep >= time_arr 
 THEN time_arr - time_dep + 1440 
 ELSE time_arr - time_dep 
 END  ) tm
 from trip_t t
 join company c
 on t.id_comp = c.id_comp
 group by t.id_comp, c.name;


--9
/*
Среди пассажиров, которые пользовались услугами не менее двух авиакомпаний, найти тех, кто совершил одинаковое количество полётов самолетами каждой из этих авиакомпаний. Вывести имена таких пассажиров.
*/
with pass as (
Select p.id_psg from pass_in_trip p 
join trip t
on p.trip_no = t.trip_no
group by p.id_psg
having count(distinct id_comp) >= 2)
, cnt_comp as (
select p.id_psg, t.id_comp, count(*) cnt
from pass_in_trip p
join pass s
on s.id_psg = p.id_psg
join trip t 
on p.trip_no = t.trip_no
group by p.id_psg, t.id_comp
)
select name from (
select id_psg, cnt
from cnt_comp
group by id_psg, cnt
) idp
join passenger r
on r.id_psg = idp.id_psg
group by idp.id_psg, r.name
having count(*) = 1;


--10
/*
Для последовательности пассажиров, упорядоченных по id_psg, определить того, 
кто совершил наибольшее число полетов, а также тех, кто находится в последовательности непосредственно перед и после него.
Для первого пассажира в последовательности предыдущим будет последний, а для последнего пассажира последующим будет первый.
Для каждого пассажира, отвечающего условию, вывести: имя, имя предыдущего пассажира, имя следующего пассажира. 
*/
with init as (
select coalesce(d.id_psg,p.id_psg) id_psg, name, coalesce(cnt,0) cnt 
from passenger p left join (
select id_psg, count(id_comp) cnt from pass_in_trip p join trip t on p.trip_no = t.trip_no
group by id_psg) d
on p.id_psg = d.id_psg
)
, init_main_pas as (
select init.id_psg,p.name, cnt, lag(init.id_psg) over(order by init.id_psg) p1_id,
lead(init.id_psg) over(order by init.id_psg) p2_id
from init
join passenger p
on init.id_psg = p.id_psg)
, names as 
(
select f.name name_f,l.name name_l from
(select name from (select name, row_number() over(order by id_psg) rnk from passenger) z where rnk =1 ) f ,
(select name from (select name, row_number() over(order by id_psg desc) rnk from passenger) z where rnk =1 ) l
)
, init_main_next as (
select i.id_psg, cnt, i.name psg, coalesce(p1.name,n.name_l) f_name , coalesce(p2.name,n.name_f) l_name
from init_main_pas i
left join passenger p1
on p1.id_psg = i.p1_id
left join passenger p2
on p2.id_psg = i.p2_id
join names n on 1 = 1
)
select psg, f_name prev, l_name nxt from (
select psg, f_name, l_name,rank() over(order by cnt desc) rnk from init_main_next) ii
where rnk = 1;