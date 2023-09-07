







---- Generate a report, including product IDs and discount effects on 
------whether the increase in the discount rate positively impacts the number of orders for the products.
WITH T1 AS
(
SELECT	 product_id, discount, COUNT(A.order_id) num_of_order,
		LAG(discount,1, discount) OVER (Partition BY product_id ORDER BY discount) previous_discount,
		LAG(COUNT(A.order_id),1, COUNT(A.order_id)) OVER (Partition BY product_id ORDER BY discount) previous_num_of_order
FROM	sale.orders A, sale.order_item B
WHERE	A.order_id = B.order_id
GROUP BY discount, product_id
)
SELECT  product_id,
		CASE 
			WHEN SUM(num_of_order-previous_num_of_order)>0 THEN 'POSITIVE'
			WHEN SUM(num_of_order-previous_num_of_order)<0 THEN 'NEGATIVE'
			ELSE 'NEUTRAL' 
		END
FROM T1
GROUP BY product_id
		




---- Alternative solution:

WITH T1 AS
(
SELECT	 product_id, discount, COUNT(A.order_id) num_of_order,
		LAG(discount,1, discount) OVER (Partition BY product_id ORDER BY discount) previous_discount,
		LAG(COUNT(A.order_id),1, COUNT(A.order_id)) OVER (Partition BY product_id ORDER BY discount) previous_num_of_order
FROM	sale.orders A, sale.order_item B
WHERE	A.order_id = B.order_id
GROUP BY discount, product_id
), T2 AS
(
SELECT  T1.product_id, discount,  previous_discount, num_of_order,previous_num_of_order,
		SUM(num_of_order-previous_num_of_order) OVER (Partition BY product_id) total_effect
FROM T1

)
SELECT	T2.product_id, total_effect, discount,  previous_discount, num_of_order,previous_num_of_order,
		CASE 
			WHEN total_effect >0 THEN 'POSITIVE'
			WHEN total_effect <0 THEN 'NEGATIVE'
			ELSE 'NEUTRAL' 
		END
FROM T2
GROUP BY product_id,  discount,  previous_discount, num_of_order,previous_num_of_order, total_effect








