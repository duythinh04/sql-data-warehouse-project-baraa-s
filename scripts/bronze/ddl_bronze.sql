/*
====================================================
DDL Script: Create Bronze Tables
====================================================
Script Purpose:
  This script create tables in the 'bronze' schema, dropping existsting tables if they already exists.
  Run this script to re-define the DDL structure of 'bronze' Tables
WARNING: This script will delete all data in existing table. Take backup save if needed

*/
IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE BRONZE.crm_cust_info
GO
CREATE TABLE BRONZE.crm_cust_info
(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
GO
IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE BRONZE.crm_prd_info
GO
CREATE TABLE BRONZE.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
);
GO
IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE BRONZE.crm_sales_details
GO
CREATE TABLE BRONZE.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id NVARCHAR(50),
	sls_order_dt NVARCHAR(50),
	sls_ship_dt NVARCHAR(50),
	sls_due_dt NVARCHAR(50),
	sls_sales NVARCHAR(50),
	sls_quantity NVARCHAR(50),
	sls_price NVARCHAR(50),
);
GO
IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE BRONZE.erp_cust_az12
GO
CREATE TABLE BRONZE.erp_cust_az12(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50)
);
GO
IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE BRONZE.erp_loc_A101
GO
CREATE TABLE BRONZE.erp_loc_A101(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50),
);
GO
IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE BRONZE.erp_px_cat_g1v2
GO
CREATE TABLE BRONZE.erp_px_cat_g1v2(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTENANCE NVARCHAR(50)
);
GO

