/*
========================================================
Create Dimesion table for customer & product tables, Fact table for 
========================================================
Script Purpose:


*/
CREATE VIEW gold.dim_customer as
SELECT
	ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as customer_firstname,
	ci.cst_lastname as customer_lastname,
	ci.cst_marital_status as marital_status,
	CASE 
		WHEN ci.cst_gndr !='n/a' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen,'n/a')
	END AS gender,
	ci.cst_create_date as create_date,
	ca.BDATE as	birthday,
	la.cntry as country
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
on ci.cst_key=ca.CID
LEFT JOIN silver.erp_loc_A101 la
on ci.cst_key = la.cid

CREATE VIEW gold.dim_product as
SELECT 
       ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) as product_key,
       pn.prd_id as product_id,
       pn.cat_id as category_id,
       pn.prd_key as product_code,
       pn.prd_nm as product_name,
       pc.CAT as category_name,
       pc.SUBCAT as sub_category_name,
       pc.MAINTENANCE as maintenance,
       pn.prd_cost as product_cost,
       pn.prd_line as product_line,
       pn.prd_start_dt as product_start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc  
ON pc.ID = pn.cat_id
WHERE prd_end_dt IS NULL

CREATE VIEW gold.fact_sales as
SELECT 
	sd.sls_ord_num as order_number,
	dpro.product_key,
	dcus.customer_key,
	sd.sls_order_dt as sales_order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quanity,
	sls_price as price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product dpro 
ON sd.sls_prd_key = dpro.product_code
LEFT JOIN gold.dim_customer dcus
ON dcus.customer_id = sd.sls_cust_id
