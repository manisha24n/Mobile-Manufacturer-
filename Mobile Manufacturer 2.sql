--SQL Advance Case Study

create database sql_basic

use [sql_basic]

select * from [dbo].[Customer$]
select * from [dbo].[prod_cat_info$]
select * from [dbo].[Transactions$]

-- DATA PREPARATION AND UNDERSTANDING

-- Q.1 Begin

SELECT 
    (SELECT COUNT(*) from [dbo].[Customer$]) as Total_rows_customer,
	(SELECT COUNT(*) from [dbo].[prod_cat_info$]) as Total_rows_prod_cat_info,
	(SELECT COUNT(*) from [dbo].[Transactions$]) as Total_rows_Transaction;

-- Q.1 End

-- Q.2 Begin

select count([total_amt]) from Transactions$
where Qty<0

-- Q.2 End

-- Q.3 Begin 

select convert(Date,DOB,105) as Birth_Date from [dbo].[Customer$]
select convert(Date,tran_date,105) as Tran_Date from [dbo].[Transactions$]

-- Q.3 End

-- Q.4 Begin

select datediff(day,min(convert(Date,tran_date,105)),max(convert(date,tran_date,105))) Diff_in_Days,
datediff(month,min(convert(Date,tran_date,105)),max(convert(date,tran_date,105))) Diff_in_months,
datediff(year,min(convert(date,tran_date,105)),max(convert(date,tran_date,105))) Diff_in_years
from Transactions$

-- Q.4 End

-- Q.5 Begin

select prod_cat
from [dbo].[prod_cat_info$]
where prod_subcat like 'DIY'

-- Q.5 End

-- DATA ANALYSIS

-- Q.1 Begin

select top 1 store_type, count(transaction_id)
from [dbo].[Transactions$]
group by store_type
order by count(transaction_id)desc

-- Q.1 End

-- Q.2 Begin

select gender, count(gender)
from [dbo].[Customer$]
group by gender

-- Q.2 End

-- Q.3 Begin

select top 1 city_code, count(customer_Id)
from [dbo].[Customer$]
group by city_code
order by count(customer_Id) desc

-- Q.3 End

-- Q.4 Begin

select prod_cat, count(prod_subcat) sub_cat_count
from [dbo].[prod_cat_info$]
where prod_cat='Books'
group by prod_cat

-- Q.4 End

-- Q.5 Begin

alter table [dbo].[Transactions$]
alter column qty int

select top 1 prod_cat, sum(Qty) from [dbo].[Transactions$] t
inner join [dbo].[prod_cat_info$] p
on t.prod_cat_code=p.prod_cat_code
group by prod_cat
order by sum(qty) desc

-- Q.5 End

-- Q.6 Begin

select sum(total_amt) Amt
from Transactions$ t left join prod_cat_info$ p
on t.prod_cat_code=p.prod_cat_code
where p.prod_cat in ('Electronics','Books')

-- Q.6 End

-- Q.7 Begin
select Model_name
from (select top 5 Model_name, sum(Quantity) as quantity_,
year from [dbo].[FACT_TRANSACTIONS] f
join [dbo].[DIM_MODEL] mo
on f.[IDModel]=mo.[IDModel]
join [dbo].[DIM_DATE] d
on f.Date = d. Date
where year = 2008
group by Model_name, year
order by sum(Quantity) desc) t1
INTERSECT
select Model_name
from (select top 5 Model_name, sum(Quantity) as quantity_,
year from [dbo].[FACT_TRANSACTIONS] f
join [dbo].[DIM_MODEL] mo
on f.[IDModel]=mo.[IDModel]
join [dbo].[DIM_DATE] d
on f.Date = d. Date
where year = 2009
group by Model_name, year
order by sum(Quantity) desc) t1
INTERSECT
select Model_name
from (select top 5 Model_name, sum(Quantity) as quantity_,
year from [dbo].[FACT_TRANSACTIONS] f
join [dbo].[DIM_MODEL] mo
on f.[IDModel]=mo.[IDModel]
join [dbo].[DIM_DATE] d
on f.Date = d. Date
where year = 2010
group by Model_name, year
order by sum(Quantity) desc) t1


-- Q.7 End

-- Q.8 Begin
select * from (
select top 1 Manufacturer_Name, sum(TotalPrice) as sales
from (select top 2 Manufacturer_Name, sum(TotalPrice) as totalprice from
[dbo].[FACT_TRANSACTIONS] f
right join [dbo].[DIM_MODEL] mo
on f.IDModel= mo.IDModel
right join [dbo].[DIM_MANUFACTURER] ma
on mo.IDManufacturer= ma.IDManufacturer
right join [dbo].[DIM_DATE] d
on f.Date= d.Date
where year= 2009
group by Manufacturer_Name
order by sum(TotalPrice) desc) as subquery
group by Manufacturer_Name
order by sum(TotalPrice) asc) t3
union
select * from (
select top 1 Manufacturer_Name, sum(TotalPrice) as sales
from (select top 2 Manufacturer_Name, sum(TotalPrice) as totalprice from
[dbo].[FACT_TRANSACTIONS] f
right join [dbo].[DIM_MODEL] mo
on f.IDModel= mo.IDModel
right join [dbo].[DIM_MANUFACTURER] ma
on mo.IDManufacturer= ma.IDManufacturer
right join [dbo].[DIM_DATE] d
on f.Date= d.Date
where year= 2010
group by Manufacturer_Name
order by sum(TotalPrice) desc) as subquery
group by Manufacturer_Name
order by sum(TotalPrice) asc) t3

-- Q.8 End

-- Q.9 Begin

select p.prod_subcat, round(sum(total_amt),2) Revenue
from Transactions$ t
left join Customer$ c on c.customer_Id=t.cust_id
left join prod_cat_info$ p on t.prod_cat_code=p.prod_cat_code
where gender='M' and prod_cat='Electronics'
group by p.prod_subcat

-- Q.9 End

-- Q.10 Begin

select top 5 prod_subcat, round((sum(total_amt)/(select sum(total_amt)
from Transactions$))*100,2) as SalesPercentage, abs(round(sum(case when total_amt<0 then 
total_amt else null end)/sum(total_amt)*100,2)) as PercentageOfReturn
from Transactions$ t
inner join [dbo].[prod_cat_info$] p on t.prod_cat_code = p.prod_cat_code and prod_subcat_code = prod_sub_cat_code
group by prod_subcat
order by sum(total_amt) desc

-- Q.10 End

-- Q.11 Begin

select sum(total_amt) as Net_Total_Revenue from Transactions$
where cust_id in (select customer_id from Customer$ where datediff(year,convert(date,dob,105),getdate())
between 25 and 35) and convert(date,tran_date,105) between dateadd(day,-30,(select max(convert(date,
tran_date,105)) from Transactions$)) and (select max(convert(date,tran_date,105)) from Transactions$)

-- Q.11 End

-- Q.12 Begin

select top 1 prod_cat, sum(total_amt) as max_val_return from Transactions$ t1
inner join prod_cat_info$ t2
on t1.prod_cat_code = t2.prod_cat_code and t1.prod_subcat_code = t2.prod_sub_cat_code
where total_amt<0 and convert(date,tran_date,105) 
between dateadd(month,-3,(select max(convert(date,tran_date,105)) from Transactions$)) and
(select max(convert(date,tran_date,105)) from Transactions$)
group by prod_cat
order by count(Qty) desc

-- Q.12 End

-- Q.13 Begin

select store_type, sum(total_amt) total_sales, sum(Qty) total_quantity
from Transactions$
group by Store_type
having sum(total_amt) >= all (select sum(total_amt) from Transactions$
group by store_type)
and sum(Qty) >= all (select sum(Qty) from Transactions$
group by store_type)

-- Q.13 End

-- Q.14 Begin

select prod_cat, avg(total_amt) as AVERAGE from Transactions$ t
inner join prod_cat_info$ p
on t.prod_cat_code= p.prod_cat_code and prod_sub_cat_code= prod_subcat_code
group by prod_cat
having avg(total_amt)> (select avg(total_amt) from Transactions$)

-- Q.14 End

-- Q.15 Begin

select prod_cat, prod_subcat, avg(total_amt) as Average_Revenue, sum(total_amt) as Total_Revenue
from Transactions$ t
inner join prod_cat_info$ p
on t.prod_cat_code = p.prod_cat_code and prod_sub_cat_code = prod_subcat_code
where prod_cat in
(select top 5 prod_cat from Transactions$ t
inner join prod_cat_info$ p
on p.prod_cat_code = t.prod_cat_code and prod_sub_cat_code = prod_subcat_code
group by prod_cat
order by sum(Qty) desc)
group by prod_cat, prod_subcat

-- Q.15 End














