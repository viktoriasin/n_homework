create database lab;

\c  lab

create table department
(id integer primary key, 
name varchar(250));

insert into department values (1, 'Therapy'), (2, 'Neurology'), (3, 'Cardiology') ,
 (4, 'Gastroenterology'),(5,'Hematology'), (6, 'Oncology');

create table employee 
(id integer primary key, 
department_id integer references department (id),
chief_doc_id integer,
name varchar(500) not null,
num_public integer);

insert into Employee values (1,1,1,'Kate',4),(2,1,1,'Lidia',2), (3,1,1,'Alexey',1),(4,1,2,'Pier',7),(5,1,2,'Aurel',6),(6,1,2,'Klaudia',1),(7,2,3,'Klaus',12),(8,2,3,'Maria',11),(9,2,4,'Kate',10),(10,3,5,'Peter',8),(11,3,5,'Sergey',9),(12,3,6,'Olga',12),(13,3,6,'Maria',14),(14,4,7,'Irina',2),(15,4,7,'Grit',10),(16,4,7,'Vanessa',16),(17,5,8,'Sasha',21),(18,5,8,'Ben',22),(19,6,9,'Jessy',19),(20,6,9,'Ann',18);


select dep.name,cnt.cnt_doc cnt_doc from department dep
join (
select count(distinct chief_doc_id) cnt_doc, department_id dep_id
from employee
group by department_id) cnt
on dep.id = cnt.dep_id;


select department_id dep_id
from employee
having count(id) >= 3;


select  department_id dep_id
from employee
group by department_id
having sum(num_public) >= all
(select sum(num_public) 
from employee 
group by department_id);

select  department_id, min(num_public) 
from employee
group by department_id

select * from (
select dep.name, em.name,num_public,  rank() over(partition by department_id order by num_public) rnk
from employee em
join department  dep
on dep.id = em.department_id) x
where rnk = 1;

with dep_list as (
select department_id dep_id
from employee
group by department_id
having count(distinct chief_doc_id) > 1
)
select round(avg(em.num_public) , 2)  avg, dep.name
from dep_list 
join department dep
on dep_list.dep_id = dep.id
join employee em
on dep.id = em.department_id
group by em.department_id, dep.name;
