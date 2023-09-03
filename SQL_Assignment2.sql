





----------------QUESTION 1:

SELECT
    DISTINCT A.customer_id,
    A.first_name,
    A.last_name,
    IIF(D_.product_id IS NOT NULL, 'YES', 'NO') AS Other
FROM sale.customer A
LEFT JOIN sale.orders B ON A.customer_id = B.customer_id
LEFT JOIN sale.order_item C ON B.order_id = C.order_id
LEFT JOIN product.product D ON C.product_id = D.product_id
LEFT JOIN sale.order_item C_ ON C.order_id = C_.order_id
LEFT JOIN product.product D_ ON C_.product_id = D_.product_id
    AND D_.product_name = 'Polk Audio - 50 W Woofer - Black'
WHERE D.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' 
ORDER BY A.customer_id;

----------------QUESTION 2

-----a)

CREATE TABLE Actions (
    Visitor_ID INT PRIMARY KEY,
    Adv_Type VARCHAR(10),
    Action VARCHAR(10)
);

INSERT INTO Actions (Visitor_ID, Adv_Type, Action) VALUES
    (1, 'A', 'Left'),
    (2, 'A', 'Order'),
    (3, 'B', 'Left'),
    (4, 'A', 'Order'),
    (5, 'A', 'Review'),
    (6, 'A', 'Left'),
    (7, 'B', 'Left'),
    (8, 'B', 'Order'),
    (9, 'B', 'Review'),
    (10, 'A', 'Review');


-----b)

SELECT Adv_Type, COUNT(*) AS Total_Actions, SUM(CASE WHEN Action = 'Order' THEN 1 ELSE 0 END) AS Total_Orders
FROM Actions
GROUP BY Adv_Type;


-----c)

SELECT Adv_Type, ROUND(CAST(Total_Orders AS FLOAT) / CAST(Total_Actions AS FLOAT),2) AS Conversion_Rate
FROM (
    SELECT Adv_Type, COUNT(*) AS Total_Actions, SUM(CASE WHEN Action = 'Order' THEN 1 ELSE 0 END) AS Total_Orders
    FROM Actions
    GROUP BY Adv_Type
) AS T;


















