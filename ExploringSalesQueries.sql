--Inspecting data
SELECT * FROM dbo.sales_data_sample;


--Checking unique values
SELECT DISTINCT(status) FROM dbo.sales_data_sample; --nice to plot
SELECT DISTINCT(year_id) FROM dbo.sales_data_sample;
SELECT DISTINCT(PRODUCTLINE) FROM dbo.sales_data_sample; --nice to plot
SELECT DISTINCT(COUNTRY) FROM dbo.sales_data_sample; --nice to plot
SELECT DISTINCT(DEALSIZE) FROM dbo.sales_data_sample; --nice to plot
SELECT DISTINCT(TERRITORY) FROM dbo.sales_data_sample; --nice to plot



--ANALYSIS
--sales by productline
SELECT PRODUCTLINE, SUM(SALES) AS Revenue
FROM dbo.sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY 2 DESC;


--sales by year
SELECT YEAR_ID, SUM(SALES) AS Revenue
FROM dbo.sales_data_sample
GROUP BY YEAR_ID
ORDER BY 2 DESC;
--Why are sales down in 2005?
--only made sales in the first 5 months while in 2003 and 2004 they made sales in 12 months
--SELECT DISTINCT(MONTH_ID) FROM dbo.sales_data_sample
--WHERE YEAR_ID = 2005;


--sales by dealsize
SELECT DEALSIZE, SUM(SALES) AS Revenue
FROM dbo.sales_data_sample
GROUP BY DEALSIZE
ORDER BY 2 DESC;


--best month for sales in a specific year
SELECT MONTH_ID, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Count_Orders
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2004 --change this value to view differnt years --in 2005 data is not given for whole year
GROUP BY MONTH_ID
ORDER BY 2 DESC;


--November(MONTH_ID = 11) seems to be the best month for sales
--What products are sold in Nov
SELECT MONTH_ID, PRODUCTLINE, SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Count_Orders
FROM dbo.sales_data_sample
WHERE YEAR_ID = 2004 AND MONTH_ID = 11
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC;


--Who is our best customer? -> can be answered with RFM
--RFM (Recency-Frequency-Monetary)
--r (how long ago their last purchase was) -> last order date
--f (how often they purchase)			   -> count of total orders
--m (how much they spent)				   -> total spent (sum or avg)

DROP TABLE IF EXISTS #rfm
;WITH rfm AS(	--CTE
SELECT 
	CUSTOMERNAME, 
	SUM(SALES) AS MonetaryVal, 
	AVG(SALES) AS AvgMonetaryVal, 
	COUNT(ORDERNUMBER) AS Frequency, 
	MAX(ORDERDATE) AS LastOrderDate,
	(SELECT MAX(ORDERDATE) FROM dbo.sales_data_sample) AS MaxOrderDate,
	DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM dbo.sales_data_sample)) AS Recency
FROM dbo.sales_data_sample
GROUP BY CUSTOMERNAME
),

rfm_calc AS(
	SELECT rfm.*,
		NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_recency,
		NTILE(4) OVER (ORDER BY Frequency) AS rfm_frequency,
		NTILE(4) OVER (ORDER BY MonetaryVal) AS rfm_monetary
	FROM rfm
)

SELECT 
	rfm_calc.*, 
	(rfm_recency+rfm_frequency+rfm_monetary) AS rfm_cell,
	CAST(rfm_recency AS VARCHAR)+CAST(rfm_frequency AS VARCHAR)+CAST(rfm_monetary AS VARCHAR) AS rfm_cell_string
INTO #rfm --into temp table
from rfm_calc


SELECT * FROM #rfm--chk temp table


SELECT CUSTOMERNAME, rfm_recency, rfm_frequency,rfm_monetary,
	CASE
		WHEN rfm_cell_string IN (111, 112, 121, 122, 123, 132, 211, 212, 114, 141, 221) THEN 'lost customers' --havent purchased recently
		WHEN rfm_cell_string IN (133, 134, 143, 244, 334, 343, 344, 144, 232) THEN 'slipping away' --big spenders who havent purchased lately
		WHEN rfm_cell_string IN (311, 411, 331, 421, 412) THEN 'new customers'
		WHEN rfm_cell_string IN (222, 223, 233, 322, 234) THEN 'potential churners' --potential customers that may leave
		WHEN rfm_cell_string IN (323, 333, 321, 422, 332, 432, 423) THEN 'active' --buy often and recently but at low prices
		WHEN rfm_cell_string IN (433, 434, 443, 444) THEN 'loyal'
	END AS rfm_segment
FROM #rfm


--What 2 products are most often sold together
SELECT DISTINCT ORDERNUMBER, stuff(

	(SELECT ','+PRODUCTCODE 
	FROM dbo.sales_data_sample p
	WHERE ORDERNUMBER IN 
		(
		SELECT ORDERNUMBER
		FROM(SELECT ORDERNUMBER, COUNT(*) AS rownum
		FROM dbo.sales_data_sample
		WHERE STATUS = 'Shipped'
		GROUP BY ORDERNUMBER
		) m
	WHERE rownum = 2 ----how many products are sold together (2) -- can change this number to see other products sold together
	)
	AND p.ORDERNUMBER = s.ORDERNUMBER
	for xml path ('')),1 ,1 ,'') AS PRODUCTCODES

FROM dbo.sales_data_sample s
ORDER BY 2 DESC

---------------------------------------------------
---------------------------------------------------
SELECT * FROM dbo.sales_data_sample;


--sales by country
SELECT DISTINCT(COUNTRY), SUM(SALES) AS Revenue
FROM dbo.sales_data_sample
GROUP BY COUNTRY
ORDER BY SUM(SALES) DESC;

--usa, spain, france top 3 countries with sales
--what do these countries sell the most of 
SELECT DISTINCT(PRODUCTLINE), COUNT(*) 
FROM dbo.sales_data_sample
WHERE COUNTRY = 'USA' OR COUNTRY = 'Spain' OR COUNTRY ='France'
GROUP BY PRODUCTLINE
ORDER BY COUNT(*) DESC;

--they sell the most of Classic Cars
--in what month do they sell the most classic cars
SELECT YEAR_ID, MONTH_ID, COUNT(PRODUCTLINE) AS Classic_Cars_Sold FROM dbo.sales_data_sample
WHERE PRODUCTLINE = 'Classic Cars'
GROUP BY YEAR_ID, MONTH_ID
ORDER BY COUNT(PRODUCTLINE) DESC;

--they sell the most Classic Cars in november (keep in mind 2005 given info isnt for a full year)
--what else they sell in november
SELECT YEAR_ID, MONTH_ID, PRODUCTLINE, COUNT(PRODUCTLINE) AS Number_Sold
FROM dbo.sales_data_sample
WHERE YEAR_ID IN (2003,2004) AND MONTH_ID =11
GROUP BY YEAR_ID, MONTH_ID, PRODUCTLINE
ORDER BY Number_Sold DESC

--trains are not sold a lot in november
--are they sold more in other months
SELECT YEAR_ID, MONTH_ID, PRODUCTLINE, COUNT(PRODUCTLINE) AS Trains_Sold 
FROM dbo.sales_data_sample
WHERE PRODUCTLINE = 'Trains'
GROUP BY YEAR_ID, MONTH_ID,PRODUCTLINE
ORDER BY COUNT(PRODUCTLINE) DESC;

--they are not sold more in other months
--are they more expensive than other products sold
SELECT PRODUCTLINE, AVG(PRICEEACH) AS Avg_Price_Product
FROM dbo.sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY 2 DESC
--trains are not sold often and are on average the least expensive product sold

