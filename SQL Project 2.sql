Select * from athlete_events;
Select * from athletes;
----1 which team has won the maximum gold medals over the years
with cte as 
(select a.*,b.* from athlete_events a
inner join athletes as b
on a.athlete_id=b.id)
select TOP 1 team,count(medal)as medal_own
from cte where medal='Gold'
group by team
order by medal_own desc;

---note:over the years means aggregate across the years (means include) all years
--this means don’t keep year in final grouping.

-----2 for each team print total silver medals and year in which they won maximum silver medal..
--output 3 columns team,total_silver_medals, year_of_max_silver



WITH CTE AS 
(select b.team,year, count(case when a.medal='Silver' then b.team end) as total
from athlete_events a
inner join athletes as b
on a.athlete_id=b.id
group by b.team,year
) 
,ranking as (select *,row_number() over(partition by team order by total desc) as rnk  from cte)
,total as ( select team ,sum(total) as totals from ranking group by team)
select t.team,t.totals as total_silver_medals,year as year_of_max_silver
from total t
left join ranking r
on t.team=r.team
where rnk=1
order by total_silver_medals desc;


---if you need to use results from both cte use join both and take the require columns and apply required filters



------3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

with cte as (
select  b.name,sum( case when a.medal='Gold' then 1 end) as total
,sum( case when a.medal in ('Bronze','Silver','NA') then 1 end ) as  Note_applicable
from athlete_events a
inner join athletes as b
on a.athlete_id=b.id
group by b.name)
select top 1 name, total from cte
where Note_applicable is null
order by total desc;

---If question mentioned both conditions then we need to check both conditions and return what we need 
--note: count includes the 0 also

--for validation--
select  a.medal,a.year,count(*)
from athlete_events a
inner join athletes as b
on a.athlete_id=b.id
where b.name in ('Ian James Thorpe' ,'Inge de Bruijn' ,'Jennifer Elisabeth "Jenny" Thompson (-Cumpelik)' ,
'Leontine Martha Henrica Petronella "Leontien" Zijlaard-van Moorsel ','Lenny Krayzelburg')
group by a.medal,a.year;




/* SQL Patterns

For each 
Group by/ partition by

maximum/highest/top
Rank(),order by desc top 1

latest/recent

order by desc 

only , never, excludinh

conditional statments */



----4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

/*--1.group by year for each year 
2.player with max gold medal using ranking
3 final o/p year,player name, how many number of gold medal in that year
4. in case of tie break print those player in one row with comma seperated*/

with cte as 
(select b.name,a.year,sum(case when medal='Gold' then 1 end) as total_medal from athlete_events a
inner join athletes as b
on a.athlete_id=b.id
group by a.year,b.name)
,ranking as (select *,rank() over(partition by year order by total_medal desc) as rnk from cte)
select STRING_AGG(name,' ,') WITHIN GROUP (order by total_medal desc) as players,year,total_medal from ranking
where rnk=1
group by year,total_medal
order by total_medal desc;

/*note: we should use sum(total_medal)
If two players tie with 3 gold each:
A = 3
B = 3
Your sum becomes:
6
But question asks:
number of golds won in that year (maximum)
Correct answer should remain:
3
not 6.
So use the max individual gold count, not sum.*/

---in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

--filter india which event ,yr, won 1st gold,silver n bronze medal

with cte as 
(select a.medal,year,sport
from athlete_events a
inner join athletes as b
on a.athlete_id=b.id
where b.team='India'
and medal in ('Gold','Silver','Bronze')
group by a.medal,year,sport)
,ranking as (select *, ROW_NUMBER() over(partition by medal order by year) as rnk
from cte)
select medal,year,sport from ranking
where rnk=1;

/*note: no need to use conditional statemets bcz question is not about count/ never worn the medals bcz it is occurence 
Don’t use conditional when question is about occurrence/order*/


---find players who won gold medal in summer and winter olympics both.
/*note:(means each player must won medal both summer n winter here where wont work bcz it checks row level a
nd it just give either won season*/

select b.name,a.medal
from athlete_events a
inner join athletes as b
on a.athlete_id=b.id
where medal in ('Gold')
group by name,medal
having count(distinct(season))=2

---find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select b.name,a.year,medal
from athlete_events a
inner join athletes as b
on a.athlete_id=b.id
group by b.name,a.year,medal
having count(distinct(medal))=3

----8 find players who have won gold medals in consecutive 3 summer olympics in the same event .
--Consider only olympics 2000 onwards. Assume summer olympics happens every 4 year starting 2000. print player name and event name.


--players own medals continues 3 summers in the same event from 2000

-->summer olympics happens every 4 yrs

with cte as
(select b.name, event, year
,lead(year,1,0) over(partition by name,event order by year) as rnk
--but 4 here is row offset, not 4 years. Becasue we need to compare adjacent rows to get that consecutive of 4 years
from athlete_events a
inner join athletes as b
on a.athlete_id=b.id
where year>=2000
and season='Summer'
and medal='Gold'
group by b.name,event,year)
,final as(select *,rnk-year as consecutive from cte)
select name,event from final
where consecutive=4
group by name,event
having count(*)=2
--but 4 here is row offset, not 4 years. Becasue we need to compare adjacent rows to get that consecutive of 4 years.
--rnk-year this will give first consecutive (2000-->2004)to check 3 consecutive 2000-->2004--->2008 u should group by name 
--n event if having count=2 so the result would be like this
/*Razaak 2000 football   gold
Razaak 2004 football   gold
Razaak 2008 football   gold
 
 Razaak 2000  2004 gold
Razaak 2004 2008   gold
Razaak 2008 0   */




