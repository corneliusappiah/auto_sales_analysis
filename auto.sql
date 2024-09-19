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
## Exploratory Analysis





