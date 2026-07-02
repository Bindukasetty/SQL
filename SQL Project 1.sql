select * from credit_card_transcations;


--which city spends max in all exp_type

select city,exp_type,max(amount) as amount_spend
from credit_card_transcations
group by city,exp_type
order by city,amount_spend desc;


--top 3 in each type

with cte as(
select city,exp_type,max(amount) as amount_spend
from credit_card_transcations
group by city,exp_type
)
,ranking as (select *, row_number() over (partition by city order by amount_spend desc) as rnk from cte)
select * from ranking
where rnk<=3

select distinct
(exp_type)  from credit_card_transcations

select distinct(card_type) from credit_card_transcations




1-- write a query to print top 5 cities with highest spends and their percentage 
--contribution of total credit card spends 


with cte as
(select city,sum(cast(amount as bigint)) as city_spends
from credit_card_transcations
group by city)
select top 5
* ,cast(city_spends * 100/sum((city_spends)) over() as varchar) +'%' as percentage
from cte
order by city_spends desc;

--outcomes--sum(sales) over()--SQL looks at all rows together
--we cant concatinate int+string--fisrt convert varchar then concatinate

---write a query to print highest spend month and amount spent in that month for each card type



select * from credit_card_transcations;
---write a query to print highest spend month and amount spent in that month for each card type

with cte as(
select card_type,sum(amount) as total_Spend,format(transaction_date,'yyyyMM') as year_month
from credit_card_transcations
group by card_type,format(transaction_date,'yyyyMM'))
,ranking as(select *, ROW_NUMBER() over(partition by card_type order by total_Spend desc) as highest_sale from cte)

select card_type,total_Spend,year_month from ranking
where highest_sale=1

---write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
with cte as
(select *,sum(amount) over(partition by card_type order by transaction_date )  as total_Spend from credit_card_transcations)
,cummulative as (select *
from cte where total_Spend>=1000000)
,ranking as( select *,row_number() over (partition by card_type order by total_Spend ) as rnk from cummulative)
select * from ranking
where rnk=1;

--Note:in 1st cte why we give order by transaction_date why not amount?
--ans That means SQL is treating all transactions on the same date as one block and adding up the next day.
-- why we gave date means To identify exact transaction, we need to process transactions in the order they happened.
--If you date desc it will take latest transaction

---write a query to find city which had lowest percentage spend for gold card type




with cte as
(select city,sum(cast(amount as bigint)) as city_spends
from credit_card_transcations
where card_type='gold'
group by city)
select top 1 city,cast(city_spends*100.00/sum((city_spends)) over() as varchar)+'%' as percentage
from cte
order by percentage asc

---write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)


with cte as
(select city,exp_type,sum(amount) as total_spends
from credit_card_transcations
group by city,exp_type)
, cte1 as (select *,row_number() over(partition by city order by total_spends desc) as high_Spends
,row_number() over(partition by city order by total_spends )as low_Spends
from cte)
select city,max(case when high_Spends=1 then exp_type end )highest_expense_type
,max(case when low_Spends=1 then exp_type end )lowest_expense_type
from cte1
group by city;
/*
note:why we use max here bcz for each city only one row has
highest value and one row has lowest value rest all null
max() simply picks the non-null values*/

--write a query to find percentage contribution of spends by females for each expense type


with male_female as 
(select exp_type,gender,cast(sum(amount)as bigint) as total_Spend
from credit_card_transcations
group by exp_type,gender)
select  exp_type,cast(max(case when gender='F' then total_Spend end)*100/sum(total_Spend) as varchar)+'%' as female_percentage
from  male_female
group by exp_type;

---which card and expense type combination saw highest month over month growth in Jan-2014

with cte as
(select exp_type,card_type,format(transaction_date,'yyyyMM') as month_year,sum(amount) as total_Spend
from credit_card_transcations
group by exp_type,card_type,format(transaction_date,'yyyyMM'))
,sales as (select *,lag(total_Spend,1,0) over(partition by exp_type,card_type order by month_year) as growth_Sales
from cte)
select top 1*,total_Spend-growth_Sales as M_to_M_growth from sales
where month_year='201401'
order by M_to_M_growth desc;


--during weekends which city has highest total spend to total no of transcations ratio 

select top 1 city, cast(sum(amount) as bigint)/count(*) as total_Sales   
from credit_card_transcations 
where DATEPART(w,transaction_date) in(1,7)
group by city
order by total_Sales desc

--which city took least number of days to reach its 500th 
--transaction after the first transaction in that city

with cte as 
(select *,row_number() over(partition by city order by transaction_date) as transaction_count
from credit_card_transcations)
,fifth_hundered as 
(select *,case when transaction_count=1 then transaction_date end first_tran, 
case when transaction_count=500 then transaction_date end second_tran from cte
),final as(select city ,max(first_tran) as firstdate,max(second_tran) as last_date from fifth_hundered
group by city)

select top 1 * ,DATEDIFF(day,firstdate,last_date) as no_of_days from final
where last_date is not null
order by no_of_days


/*“cumulative threshold” → SUM() OVER
“nth row per group” → ROW_NUMBER()
“compare current vs previous” → LAG()
“pivot rows into columns” → conditional aggregation
“first / last event” → ranking + aggregation*/
--[1,2,3,4,5,4]









