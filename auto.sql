use autosales;
select * from auto;
## creating a stagging table for analysis , i Add row_number column to deal with duplicates

select * ,row_number()over(partition by ORDERNUMBER,QUANTITYORDERED,PRICEEACH,ORDERLINENUMBER,SALES,ORDERDATE,DAYS_SINCE_LASTORDER,STATUS,PRODUCTLINE,
MSRP,PRODUCTCODE,CUSTOMERNAME,PHONE,ADDRESSLINE1,CITY,POSTALCODE,COUNTRY,CONTACTLASTNAME,CONTACTFIRSTNAME,DEALSIZE)as row_num from auto;
CREATE TABLE `auto1` (
  `ORDERNUMBER` int DEFAULT NULL,
  `QUANTITYORDERED` int DEFAULT NULL,
  `PRICEEACH` double DEFAULT NULL,
  `ORDERLINENUMBER` int DEFAULT NULL,
  `SALES` double DEFAULT NULL,
  `ORDERDATE` text,
  `DAYS_SINCE_LASTORDER` int DEFAULT NULL,
  `STATUS` text,
  `PRODUCTLINE` text,
  `MSRP` int DEFAULT NULL,
  `PRODUCTCODE` text,
  `CUSTOMERNAME` text,
  `PHONE` text,
  `ADDRESSLINE1` text,
  `CITY` text,
  `POSTALCODE` int DEFAULT NULL,
  `COUNTRY` text,
  `CONTACTLASTNAME` text,
  `CONTACTFIRSTNAME` text,
  `DEALSIZE` text,row_num int not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
insert into auto1
select *,row_number()over(partition by ORDERNUMBER,QUANTITYORDERED,PRICEEACH,ORDERLINENUMBER,SALES,ORDERDATE,DAYS_SINCE_LASTORDER,STATUS,PRODUCTLINE,
MSRP,PRODUCTCODE,CUSTOMERNAME,PHONE,ADDRESSLINE1,CITY,POSTALCODE,COUNTRY,CONTACTLASTNAME,CONTACTFIRSTNAME,DEALSIZE)as row_num from auto;
select * from auto1;
describe auto1;
##---------------------------------------------------------------------------------------------------------------------------------------------
## checking for duplicate 
select * from auto1
where row_num>1;
## ------------------------------------------------------------------------------------------------------------------------------------------
# working on data 

UPDATE auto1
SET ORDERDATE = CASE
    -- Check for MM/DD/YYYY format (first part is month, second part is day)
    WHEN ORDERDATE LIKE '__/__/____' AND SUBSTRING_INDEX(ORDERDATE, '/', 1) <= 12 THEN
        DATE_FORMAT(STR_TO_DATE(ORDERDATE, '%m/%d/%Y'), '%Y-%m-%d')
    -- Check for DD/MM/YYYY format (first part is day, second part is month)
    WHEN ORDERDATE LIKE '__/__/____' AND SUBSTRING_INDEX(ORDERDATE, '/', 1) > 12 THEN
        DATE_FORMAT(STR_TO_DATE(ORDERDATE, '%d/%m/%Y'), '%Y-%m-%d')
    ELSE NULL
END;

alter Table auto1
modify column ORDERDATE Date;
#----------------------------------------------------------------------------------------------------------------------------------------------
# creating a new column for year and Month 
select * from auto1;
select ORDERDATE, year(ORDERDATE) as Year from auto1;
alter table auto1
add column Year int;

update auto1
set Year=year(ORDERDATE);
alter table auto1
add column Month varchar(30);
update auto1
set Month=monthname(ORDERDATE);
## data clearning , dealing with blanks and null
select * from auto1;
select DEALSIZE from auto1
where DEALSIZE is null or DEALSIZE='';
alter table auto1
drop column row_num;
## Exploratory Analysis
# What is the Total Sales made 
select concat(round(sum(SALES),2),'$') as Total_Sales from auto1;
##------------------------------------------------------------------------------------------------------------------------------------------
## calculate the  Average Sales
select concat(round(Avg(SALES),2),'$') as Total_Sales from auto1;
#-------------------------------------------------------------------------------------------------------------------------------------------
# What is the Total Quantity Ordered
select concat(round(sum(QUANTITYORDERED),2),'$') as Total_QUANTITYORDERED from auto1;
#•	What are the total sales for each product line over the entire dataset?
select PRODUCTLINE,round(sum(SALES)) as Total from auto1
group by PRODUCTLINE
order by Total desc;
##-------------------------------------------------------------------------------------------------------------------------------------------
##•	How do monthly sales figures compare across different product lines?
select Month,PRODUCTLINE, round(sum(SALES),2)as Total_sales  from auto1
group by Month,PRODUCTLINE
order by Month;
##------------------------------------------------------------------------------------------------------------------------------------------
##•	What is the average sale amount per order for each product line?
select PRODUCTLINE,round(avg(SALES),2) as Average_Sales from auto1
group by PRODUCTLINE;
##-----------------------------------------------------------------------------------------------------------------------------------------
#•	What is the average number of orders placed by each customer?
select CUSTOMERNAME,count(ORDERLINENUMBER),avg(count(ORDERLINENUMBER)) OVER () AS Average_Orders_Per_Customer from auto1
group by CUSTOMERNAME;
##------------------------------------------------------------------------------------------------------------------------------------------
##  How many unique customers purchased each product line?
select PRODUCTLINE,count(distinct CUSTOMERNAME) as customer_count from auto1
group by PRODUCTLINE;
##•	What is the distribution of sales by customer location (country or city)?
select COUNTRY,round(sum(SALES)) as Total_sale  from auto1
group by COUNTRY,SALES
order by SALES desc;
select CITY,round(sum(SALES))  as Total_sale  from auto1
group by CITY,SALES
order by SALES desc;
##-----------------------------------------------------------------------------------------------------------------------------------------
##•	How do return rates vary by customer segment or product line?
select *from auto1;
select CUSTOMERNAME,count(case when STATUS='Cancelled' then 1 end)as number_order, count(ORDERNUMBER) as Total_order,count(case when STATUS= 'Cancelled' then 1 end)/count(ORDERNUMBER)* 100  as Rutun_rate from auto1
group by CUSTOMERNAME;

select distinct STATUS from auto1;
select PRODUCTLINE,count(case when STATUS='Cancelled' then 1 end)as number_order, count(ORDERNUMBER) as Total_order,count(case when STATUS= 'Cancelled' then 1 end)/count(ORDERNUMBER)* 100  as Rutun_rate from auto1
group by PRODUCTLINE;
##----------------------------------------------------------------------------------------------------------------------------------------------------
## •	Which productlines have shown the highest growth in sales over the last year?
select * from auto1;
#------------------------------------------------------------------------------------------------------------------------------------------------
# What are the top 5  productline by quantity sold in product size?
select PRODUCTLINE,count(PRODUCTLINE) as count from auto1
where DEALSIZE='Small'
group by PRODUCTLINE
order by count desc limit 5;

select PRODUCTLINE,count(PRODUCTLINE) as count from auto1
where DEALSIZE='Medium'
group by PRODUCTLINE
order by count desc limit 5;

select PRODUCTLINE,count(PRODUCTLINE) as count from auto1
where DEALSIZE='Large'
group by PRODUCTLINE
order by count desc limit 5;

##--------------------------------------------------------------------------------------------------------------------------------------------------
# •	What percentage of total orders were canceled or returned for each product line?
select PRODUCTLINE,sum(QUANTITYORDERED) as Total_orders from auto1
group by PRODUCTLINE;
select PRODUCTLINE,Total_orders,Total_return ,round((Total_return /Total_orders)*100,2)as percent_return
 from (select PRODUCTLINE as PRODUCTLINE,sum(QUANTITYORDERED) as Total_orders,sum(case when STATUS='Cancelled' then QUANTITYORDERED else 0 end )as Total_return from auto1
 group by PRODUCTLINE) as Subquery
 order by percent_return desc;
 #-------------------------------------------------------------------------------------------------------------------------------------------------
 #•	How much revenue has been lost due to returns for each product line?
 select  PRODUCTLINE, STATUS as Return_product,  round(sum(SALES),2) as Total_rev_lost from auto1
 where STATUS='Cancelled'
 group by  PRODUCTLINE, STATUS;
 
 
 
 








