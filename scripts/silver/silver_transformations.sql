-- Data cleaning & DDL for silver layer 
USE bronze;


-- Transforming crm_cust_id

-- Removing duplicates 
SELECT *
FROM crm_cust_info;

SELECT 
	cst_id,
    COUNT(*)
FROM crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- Check for unwanted spaces 
SELECT *
FROM crm_cust_info;

SELECT cst_firstname 
FROM crm_cust_info
WHERE CST_firstname <>  TRIM(cst_firstname);

UPDATE crm_cust_info
SET cst_firstname = TRIM(cst_firstname),
	cst_lastname = TRIM(cst_lastname);

-- Data standardization 

UPDATE crm_cust_info
SET cst_marital_status = 'Married'
WHERE cst_marital_status = 'M';

UPDATE crm_cust_info
SET cst_marital_status = 'Single'
WHERE cst_marital_status = 'S';

UPDATE crm_cust_info
SET cst_gndr = 'Male'
WHERE cst_gndr = 'M';

UPDATE crm_cust_info
SET cst_gndr = 'Female'
WHERE cst_gndr = 'F';


INSERT INTO silver.crm_cust_info 
SELECT * FROM bronze.crm_cust_info;

-- quality check 
SELECT *
FROM silver.crm_cust_info;

-- Transforming crm_prd_table 

SELECT *
FROM crm_prd_info;

SELECT 
	prd_id,
    COUNT(*)
FROM crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

ALTER TABLE silver.crm_prd_info
ADD COLUMN cat_id VARCHAR (65);

INSERT INTO silver.crm_prd_info (
	prd_id,
    cat_id,
     prd_key,
     prd_nm,
     prd_cost,
     prd_line,
     prd_start_dt,
     prd_end_dt)
     
SELECT 
	prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    NULLIF(prd_cost, '') AS prd_cost,
		CASE WHEN TRIM(prd_line) = 'M' THEN 'Mountain'
			 WHEN TRIM(prd_line) = 'R' THEN 'Road'
             WHEN TRIM(prd_line) = 'S' THEN 'Other Sales'
             WHEN TRIM(prd_line) = 'T' THEN 'Touring'
             ELSE 'N/A' 
		END AS prd_line,
    DATE_FORMAT(prd_start_dt, '%Y-%m-%d') AS prd_start_dt,
	DATE_FORMAT(DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY), '%Y-%m-%d') AS prd_end_dt
FROM bronze.crm_prd_info;

-- -- Transforming crm_sales_details table 



ALTER TABLE silver.crm_sales_info
MODIFY sls_ord_num VARCHAR(50);


INSERT INTO silver.crm_sales_info 
	(sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_ord_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price)
SELECT 
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    
    CASE 
        WHEN sls_order_dt = 0 THEN NULL
        WHEN sls_order_dt NOT REGEXP '^[0-9]{8}$' THEN NULL
        ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d') 
    END AS sls_order_dt,
    
    CASE 
        WHEN sls_ship_dt NOT REGEXP '^[0-9]{8}$' THEN NULL
        ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
    END AS sls_ship_dt,
    
    CASE 
        WHEN sls_due_dt NOT REGEXP '^[0-9]{8}$' THEN NULL
        ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
    END AS sls_due_dt,

    CASE 
        WHEN sls_sales <= 0 OR sls_sales <> sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,

	sls_quantity,
	
    CASE 
        WHEN sls_price <= 0 THEN ROUND(sls_sales / sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM bronze.crm_sales_info;

SELECT
	sls_order_dt
from bronze.crm_sales_info
WHERE sls_order_dt = '32154';

SELECT sls_order_dt
FROM crm_sales_info
WHERE sls_order_dt REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

SELECT *
FROM silver.crm_sales_info;

-- transforming & cleaning erp_cust_az12

SELECT *
FROM silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12 (
	cid,
    bdate,
gen)

SELECT 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LENGTH(cid))
			ELSE cid
	END AS cid,
    CASE WHEN bdate > NOW() THEN NULL
		ELSE bdate
	END AS bdate,
    CASE WHEN TRIM(gen) IN ('F', 'Female') THEN 'Female'
		 WHEN TRIM(gen) IN ('M', 'Male') THEN 'Male'
         ELSE 'N/A'
	END AS gen
FROM bronze.erp_cust_az12;


-- Transforming erp_loc_a101

SELECT *
FROM silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101
	( cid, cntry)
    
SELECT 
    REPLACE(cid,'-','') AS cid,
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US','USA','United States') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
        ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101;

-- Transforming erp_px_cat_g1v2

ALTER TABLE silver.erp_px_cat_g1v2
MODIFY id VARCHAR(50);

INSERT INTO silver.erp_px_cat_g1v2
(id,
cat,
subcat,
maintenance)

SELECT 
	id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT *
FROM silver.erp_px_cat_g1v2;

