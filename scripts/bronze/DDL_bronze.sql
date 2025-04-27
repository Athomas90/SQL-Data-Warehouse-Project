-- DDL to create  bronze layer tables 

CREATE TABLE bronze.crm_cust_info (
cst_id INT,
cst_key VARCHAR (65),
cst_firstname VARCHAR (50),
cst_lastname VARCHAR (50),
cst_marital_status VARCHAR (50),
cst_gndr VARCHAR (50),
cst_created_date DATE);


CREATE TABLE bronze.crm_prd_info (
prd_id INT,
prd_key VARCHAR (65),
prd_nm VARCHAR (50),
prd_cost INT,
prd_line VARCHAR (50),
prd_state_dt DATE,
prd_end_dt DATE);


CREATE TABLE bronze.crm_sales_info (
sls_ord_num INT,
sls_prd_key VARCHAR (65),
sls_cust_id INT,
sls_ord_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT
);


CREATE TABLE bronze.erp_cust_az12 (
cid VARCHAR (65),
bdate DATE,
gen VARCHAR (50)
);


CREATE TABLE bronze.erp_loc_a101 (
cid VARCHAR (65),
cntry VARCHAR (50)
);


CREATE TABLE bronze.erp_px_cat_g1v2 (
id INT,
cat VARCHAR (50),
subcat VARCHAR (50),
maintenance VARCHAR (50)
);



LOAD DATA INFILE '/Users/andreathomas/Desktop/datawarehouse project /sql-data-warehouse-project 2/datasets/source_crm/cust_info.csv'
INTO TABLE crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*)
FROM erp_loc_a101;
