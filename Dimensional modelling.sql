create TABLE [location] (
  [location_id] integer identity(1,1),
  [city] varchar(100),
  [state] varchar(100),
  [postal_Code] integer,
  [region] varchar(50),
  [country] varchar(50),
  PRIMARY KEY ([location_id])
);
insert into [location]
select distinct city,state,postal_code,region,country
from Orders
where city is not null
select *
from [location];



with ranking as(
select distinct city,state,postal_code,region,country,
row_number() over(partition by city order by state) as rn
from
(select distinct city,state,postal_code,region,country
from Orders) A)
insert into [location]
select city,state,postal_code,region,country
from ranking
where city is not null and rn=1;



create TABLE [customer] (
  [customer_key] int identity(1,1),
  [customer_id] varchar(50),
  [customer_name] varchar(50),
  PRIMARY KEY ([customer_key])
);

insert into customer
select distinct customer_id,customer_name
from Orders
select * from customer



create TABLE [order] (
  [order_id] varchar(50),
  [product_key] integer,
  [order_date] date,
  [order_shipdate] date,
  [customer_key] integer,
  [location_id] integer,
  PRIMARY KEY ([order_id], [product_key]),
  CONSTRAINT [FK_orders_location_id]
    FOREIGN KEY ([location_id])
      REFERENCES [location]([location_id]),
  CONSTRAINT [FK_orders_customer_id]
    FOREIGN KEY ([customer_key])
      REFERENCES [customer]([customer_key])
);

insert into [order]

select order_id,product_id,order_date,ship_date,customer_id,city
from Orders o
inner join product p 
on p.product_

select * from [product]
select * from [order]
select * from [customer]
select * from [location]

create TABLE [product] (
[product_key] int identity(1,1),
  [product_id] varchar(30),
  [product_name] varchar(200),
  [price] decimal(10,2),
  [sub_category] varchar(50),
  [category] varchar(50),
  PRIMARY KEY ([product_key])
);

insert into [product]
with ranking as(
select distinct product_id,product_name,100 as sales,sub_category,category,
row_number() over(partition by product_id order by product_name) as rn
from
(select distinct product_id,product_name,100 as sales,sub_category,category
from Orders) A)
insert into [product]
select product_id,product_name,100 as sales,sub_category,category from ranking
where rn=1




--Master data insertion
insert into [order]

select order_id,p.product_key,order_date,ship_date,c.customer_key,l.location_id
from Orders o
inner join product p 
on p.product_id=o.product_id
left join customer c
on c.customer_id=o.customer_id
inner join location l
on l.city=o.city

insert into Orders
select * from orders_backup


--how to delete duplicates--
delete from Orders where row_id in(
select min(row_id) from Orders
group by order_id,product_id
having count(*)>1)


---how to find duplicates--
select count(1),city from [location]
group by city
having count(*)>1


select * from [product]
select * from [order]
select * from [customer]
select * from [location]
select * from Orders


 ---Main query---we can do any calculations
 select region,sum(price) from [order] as o
 inner join [location] as l
 on o.location_id=l.location_id
 inner join product p
 on o.product_key=p.product_key
 group by region
