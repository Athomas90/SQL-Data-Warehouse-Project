-- DDL for gold layer
-- Creating Dimension Customers table

-- This script creates views for the Gold layer in the data warehouse. The Gold layer represents the final dimension and fact tables (Star Schema)
-- Each view performs transformations and combines data from the Silver layer 
  


CREATE VIEW gold.dim_customers AS 
	SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_num,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr = 'N/A' then ca.gen
	WHEN ci.cst_gndr =  ''  THEN ca.gen
		ELSE ci.cst_gndr
	END AS gender,
		ca.bdate AS birthdate,
		la.cntry AS country,
        ci.cst_created_date AS create_date
	FROM crm_cust_info AS ci
	LEFT JOIN erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid
	LEFT JOIN erp_loc_a101 AS la
	ON ca.cid = la.cid;
    
    
    
-- Creating Dimension Products table 

CREATE VIEW gold.dim_products AS 
SELECT
ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
	pi.prd_id AS product_id,
	pi.prd_key AS product_num,
	pi.prd_nm AS product_name,
    pi.cat_id AS category_id,
	ep.cat AS category,
    ep.subcat AS subcategory,
	ep.maintenance,
    pi.prd_cost AS product_cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS product_start_date
FROM crm_prd_info  AS pi
LEFT JOIN erp_px_cat_g1v2 AS ep
ON pi.cat_id =  ep.id
WHERE prd_end_dt IS NULL; -- Filter out historical data 

SELECT *
FROM gold.dim_customers;

SELECT *
FROM gold.dim_products;

-- -- Creating Sales fact table

CREATE VIEW gold.fact_sales AS
SELECT
	si.sls_ord_num AS order_num,
    dp.product_key,
    dc.customer_key,
    si.sls_ord_dt AS order_date,
    si.sls_ship_dt AS shipping_date,
    si.sls_due_dt AS due_date,
    si.sls_sales AS sales_amt,
    si.sls_quantity AS quantity,
   si.sls_price AS price
FROM silver.crm_sales_info AS si
LEFT JOIN gold.dim_products AS dp
ON si.sls_prd_key = dp.product_num
INNER JOIN gold.dim_customers AS dc
ON si.sls_cust_id = dc.customer_id;






