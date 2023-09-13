


----E-COMMERCE DATA AND CUSTOMER RETENTION ANALYSIS

---- PART 1: ANALYSING THE DATA

---- 1. TOP 3 CUSTOMERS WHO HAVE THE MAXIMUM COUNT OF ORDERS:

---based on order quantity :

SELECT TOP 3 cust_id, customer_name, SUM(order_quantity) Order_Quantity
FROM		dbo.T1
GROUP BY	cust_id, customer_name
ORDER BY	order_quantity DESC;

----based on number of order

SELECT TOP 3 cust_id, customer_name, COUNT(ord_id) Order_Quantity
FROM		dbo.T1
GROUP BY	cust_id, customer_name
ORDER BY	order_quantity DESC;



---- 2. CUSTOMER WHOSE ORDER TOOK THE MAXIMUM TIME TO GET SHIPPING:

SELECT TOP 1 cust_id, customer_name, DaysTakenForShipping
FROM		dbo.T1
ORDER BY	DaysTakenForShipping DESC;

---- 3. TOTAL NUMBER OF UNIQUE CUSTOMERS IN JANUARY AND HOW MANY OF THEM CAME BACK AGAIN IN THE EACH ONE MONTHS OF 2011:
WITH January_cust AS
(
SELECT		cust_id
FROM		dbo.T1
WHERE		YEAR(Order_Date) = 2011
AND			MONTH(Order_Date) = 01
GROUP BY	cust_id
) 
SELECT DISTINCT MONTH(Order_Date) Order_Month,
			COUNT(DISTINCT A.Cust_id) Number_of_Retention
FROM		January_Cust A, dbo.T1 B
WHERE		YEAR(Order_Date) = 2011
AND			A.Cust_ID = B.Cust_ID
GROUP BY	MONTH(B.Order_Date)
ORDER BY	order_month;


---for checking the query 
SELECT		DISTINCT A.cust_id
FROM		dbo.T1 A JOIN (SELECT DISTINCT		cust_id
						FROM		dbo.T1
						WHERE		YEAR(Order_Date) = 2011
						AND			MONTH(Order_Date) = 01
						GROUP BY	cust_id) AS T ON A.Cust_ID = T.Cust_ID
WHERE		YEAR(Order_Date) = 2011
AND			MONTH(Order_Date) = 12;



---- 4. FOR EACH USER THE TIME ELAPSED BETWEEN THE FIRST PURCHASING AND THE THIRD PURCHASING, IN ASCENDING ORDER BY CUSTOMER ID:

WITH order_rank AS
(
SELECT DISTINCT cust_id, ord_id, order_date,
		DENSE_RANK()OVER (PARTITION BY cust_id ORDER BY order_date) rn,
		FIRST_VALUE(Order_Date) OVER(PARTITION BY Cust_id ORDER BY Order_Date) first_order
FROM	dbo.T1
), order_order AS
(
SELECT	cust_id, order_date, rn,
		LEAD(order_date, 2) OVER(PARTITION BY cust_id ORDER BY order_date) order_3
FROM	order_rank
)
SELECT	cust_id, order_date, order_3, DATEDIFF(DAY, order_date, order_3) Day_diffFROM	order_orderWHERE	rn = 1
AND		DATEDIFF(DAY, order_date, order_3) IS NOT NULL


---- just for comparing the functions

SELECT  DISTINCT Cust_id, order_date, ord_id,
		ROW_NUMBER () OVER(partition by Cust_id Order BY Order_Date),
		RANK() OVER(partition by Cust_id Order BY Order_Date),
		DENSE_RANK() OVER(partition by Cust_id Order BY Order_Date)
FROM	dbo.T1;



--- 5. CUSTOMERS WHO PURCHASED BOTH PRODUCT 11 AND PRODUCT 14, AS WELL AS THE RATIO OF THESE PRODUCTS TO THE TOTAL NUMBER OF PRODUCTS PURCHASED BY THE CUSTOMER:

WITH Prod11T AS
(
SELECT		cust_id, customer_name, SUM(order_quantity) OVER(PARTITION BY cust_id) quantity11
FROM		dbo.T1
WHERE		prod_ID =  'Prod_11'
), Prod14T AS
(
SELECT		cust_id, customer_name, order_quantity, SUM(order_quantity) OVER(PARTITION BY cust_id) quantity14
FROM		dbo.T1
WHERE		prod_ID = 'Prod_14' 
), Joining AS
(
SELECT	DISTINCT B.cust_id, B.customer_name, quantity11+quantity14 total_quantity_11_14
FROM	dbo.T1 A, Prod11T B, Prod14T C
WHERE	B.Cust_ID = C.Cust_ID
)
SELECT DISTINCT A.*, 
		SUM(order_quantity) OVER(PARTITION BY A.cust_id) total_num_of_quantity, 
		CAST(ROUND(total_quantity_11_14/SUM(order_quantity) OVER(PARTITION BY A.cust_id), 2) AS DECIMAL(3,2)) ratio
FROM	Joining A, dbo.T1 B
WHERE	A.cust_id = B.cust_id

 

 -----CUSTOMER SEGMENTATION

 CREATE OR ALTER VIEW DistinctOrder AS
 SELECT DISTINCT Ord_ID, Cust_ID, Order_date
 FROM	dbo.T1;

 --- 1. VISIT LOGS OF CUSTOMERS ON A MONTHLY BASIS. (FOR EACH LOG, THREE FIELD IS KEPT: CUST_ID, YEAR, MONTH):

CREATE OR ALTER VIEW Visits_by_Customers AS
SELECT DISTINCT cust_id,
		YEAR(Order_date) AS [Year],
		MONTH(Order_date) AS [Month]
FROM	DistinctOrder



---- 2. THE NUMBER OF MONTHLY VISITS BY USERS. (SHOW SEPARATELY ALL MONTHS FROM THE BEGINNING BUSINESS):
CREATE OR ALTER VIEW Total_Monthly_Visits AS
SELECT DISTINCT YEAR(Order_Date) AS [Year],
		MONTH(Order_Date) AS [Month],
		COUNT(Order_Date) OVER (PARTITION BY YEAR(Order_Date), MONTH(Order_Date)) NumOfVisits
FROM	DistinctOrder
	   	 


---- 3. FOR EACH VISIT OF CUSTOMERS,  SHOWING THE NEXT MONTH OF THE VISIT AS A SEPARATE COLUMN:

CREATE OR ALTER VIEW Next_Visits AS
SELECT	Cust_ID,
		Order_Date,
		LEAD(Order_date, 1) OVER (PARTITION BY cust_id ORDER BY YEAR(Order_date), MONTH(Order_date)) AS Next_Order
FROM	DistinctOrder



---- 4. THE MONTHLY TIME GAP BETWEEN TWO CONSECUTIVE VISITS BY EACH CUSTOMER:

CREATE OR ALTER VIEW Visit_Gap AS
SELECT	* , DATEDIFF(MONTH, Order_Date, Next_Order) Gap
FROM	Next_Visits



---- 5. CATEGORISATION OF CUSTOMERS USING AVERAGE TIME GAPS:

SELECT DISTINCT cust_id,
		AVG(Gap) OVER (PARTITION BY Cust_ID ) Average_Gap,
		CASE 
			WHEN AVG(Gap) OVER (PARTITION BY Cust_ID) IS NULL THEN 'Churned'
			WHEN AVG(Gap) OVER (PARTITION BY Cust_ID) <= 1 THEN 'Regular'
			ELSE 'Irregular'
		END AS Segment
FROM	Visit_Gap



-----MONTH-WISE RETENTION RATE

WITH Monthly_Retention AS
(
SELECT 
    YEAR(Order_Date) Year,
    MONTH(Order_date) Month,
    COUNT(DISTINCT cust_id) AS Customers,
    LAG(COUNT(DISTINCT cust_id)) OVER (ORDER BY YEAR(Order_Date), MONTH(Order_date)) AS Prev_Customers
FROM 
    DistinctOrder
GROUP BY 
    YEAR(Order_Date),
    MONTH(Order_date)
)
SELECT 
    Year,
    Month,
    CAST(ROUND(1.0 * Customers / NULLIF(Prev_Customers, 0), 2) AS DECIMAL(3,2)) AS Retention_Rate
FROM 
    Monthly_Retention;