##Inspecting data
SELECT * FROM sales_data_sample;

##Checking unique values
SELECT distinct status from sales_data_sample;
SELECT distinct year_id from sales_data_sample;
SELECT distinct productline from sales_data_sample;
SELECT distinct COUNTRY from sales_data_sample;
SELECT distinct DEALSIZE from sales_data_sample;
SELECT distinct TERRITORY from sales_data_sample
sales_data_sample;

##Analysis
##Grouping sales by production
select PRODUCTLINE, SUM(SALES) as REVENUE
from sales_data_sample
group by PRODUCTLINE
order by 2 desc;

select YEAR_ID, SUM(SALES) as REVENUE
from sales_data_sample
group by YEAR_ID
order by 2 desc;

select DEALSIZE, SUM(SALES) as REVENUE
from sales_data_sample
group by DEALSIZE
order by 2 desc;

##What was the best month for sales in a specific year? How much was earned that month?
select MONTH_ID, sum(sales) REVENUE, count(ORDERNUMBER) FRECUENCY
from sales_data_sample
where YEAR_ID = 2004
group by MONTH_ID
order by 2 desc;

##November seems to be the month, what product do they sell in November
select MONTH_ID, PRODUCTLINE, sum(SALES) REVENUE, count(ORDERNUMBER) FREQUENCY
from sales_data_sample
where YEAR_ID = 2004 AND MONTH_ID = 11 
group by MONTH_ID, PRODUCTLINE
order by 3 desc;

##who is our best custumer (with RFM);
DROP TABLE IF EXISTS rfm;
with rfm as 
(
	select 
		CUSTOMERNAME, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from sales_data_sample) as max_order_date,
        DATEDIFF(max(ORDERDATE), (select max(ORDERDATE) from sales_data_sample)) as Recency
	from sales_data_sample
	group by CUSTOMERNAME
),
rfm_calc as
(
	select r.*,
		NTILE(4) OVER (order by Recency desc) as rfm_recency,
		NTILE(4) OVER (order by Frequency) as rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) as rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	concat(rfm_recency, rfm_frequency, rfm_monetary) as rfm_cell_string
into rfm
from rfm_calc c;

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  ##lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' ##(Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' ##(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from rfm;

##What products are most often sold together? 
SELECT * FROM sales_data_sample WHERE ORDERNUMBER = 10411;
SELECT DISTINCT OrderNumber, GROUP_CONCAT(PRODUCTCODE SEPARATOR ',') AS ProductCodes
FROM sales_data_sample s
WHERE ORDERNUMBER IN (
SELECT ORDERNUMBER
FROM (
SELECT ORDERNUMBER, COUNT(*) AS rn
FROM sales_data_sample
WHERE STATUS = 'Shipped'
GROUP BY ORDERNUMBER
) m
WHERE rn = 3
)
GROUP BY OrderNumber
ORDER BY 2 DESC;

##EXTRA
##What city has the highest number of sales in a specific country
SELECT city, SUM(sales) AS Revenue
FROM sales_data_sample
WHERE country = 'UK'
GROUP BY city
ORDER BY 2 DESC;

##What is the best product in United States?
SELECT
country,
YEAR_ID,
PRODUCTLINE,
SUM(sales) AS Revenue
FROM sales_data_sample





