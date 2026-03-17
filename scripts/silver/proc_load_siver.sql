/*
=============================================================
Load Data from Bronze table to Silver table Script
============================================================
Script Purpose:
  This script will create Procedure with:
  -Truncate exists Tables 
  -Insert data into Tables
  -Caculate time load data intro each table
  -Caculate time load entire batch
  -Create comment for each table
  -Return error message
  How to use:
  -Excute entire Procedure if create/update script
  -Uncomment "EXEC SILVER.load_silver" and run "EXEC SILVER.load_silver"
WARNING: this script will truncate ALL DATA from tables, backup data if needed
*/
--EXEC SILVER.load_silver
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME,@end_time DATETIME,
            @batch_start_time DATETIME, @batch_end_time DATETIME
------------------TRUNCATE & INSERT [SILVER].[crm_cust_info]---------
    BEGIN TRY 
        SET @batch_start_time = GETDATE() 
        PRINT'---------------------LOADING SILVER LAYER--------------------'
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE [SILVER].[crm_cust_info]... '
            TRUNCATE TABLE [SILVER].[crm_cust_info]
        PRINT '>>DONE'
        PRINT '>>INSERT CLEAN DATA TO TABLE [SILVER].[crm_cust_info]...'
            INSERT INTO [SILVER].[crm_cust_info] (
	            cst_id,
	            cst_key,
	            cst_firstname,
	            cst_lastname,
	            cst_marital_status,
	            cst_gndr,
	            cst_create_date
            )
             SELECT 
	            cst_id,
	            cst_key,
	            TRIM(cst_firstname) as cst_firstname,
	            TRIM(cst_lastname) as cst_lastname,

	            CASE WHEN UPPER(TRIM(cst_marital_status))  = 'S' THEN 'Single'
		            When UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		            ELSE 'n/a' 
	            END cst_marital_status,

	            CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
		            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
		            ELSE 'n/a'
	            END cst_gndr,
	            cst_create_date 
            FROM
            (
		            SElECT 
		            *,
		            ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date desc) flag_last
		            FROM [BRONZE].[crm_cust_info]
		            WHERE cst_id is not null 
            ) t 
            WHERE flag_last=1
            SET @end_time = GETDATE()
            PRINT '>>Load time:' + CAST(DATEDIFF(second,@start_time,@end_time) as Varchar)
        PRINT '>>DONE TABLE SILVER.crm_cust_info'
        PRINT'------------------------------------------------------------------'
        -------------------TRUNCATE & INSERT [SILVER].[crm_prd_info]------------
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE [SILVER].[crm_prd_info]... '
            TRUNCATE TABLE [SILVER].[crm_prd_info]
        PRINT '>>DONE'
        PRINT '>>INSERT CLEAN DATA TO TABLE [SILVER].[crm_prd_info]...'
            INSERT INTO [SILVER].[crm_prd_info]
            (
	               [prd_id]
                  ,[cat_id]
                  ,[prd_key]
                  ,[prd_nm]
                  ,[prd_cost]
                  ,[prd_line]
                  ,[prd_start_dt]
                  ,[prd_end_dt]
            )
            SELECT 
                prd_id,
                REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
                SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
                prd_nm,
            CASE 
                WHEN prd_cost< 0 THEN ABS(prd_cost)
	            WHEN prd_cost IS NULL then ISNULL(prd_cost,0)
	            ELSE prd_cost
            END prd_cost,
            CASE 
                    UPPER(TRIM(prd_line))
	             WHEN 'R' THEN 'Road'
	             WHEN  'S' THEN 'Street'
	             WHEN  'M' THEN 'Mountain'
	             WHEN 'T' THEN 'Touring'
	             ELSE 'N/a'
            END prd_line,
	            CAST(prd_start_dt AS DATE),
	            CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE)
            FROM [BRONZE].[crm_prd_info]
        SET @end_time = GETDATE()
        PRINT '>>Load time:' + CAST(DATEDIFF(second,@start_time,@end_time) as Varchar)
        PRINT '>>DONE TABLE SILVER.[crm_prd_info]'
        PRINT '----------------------------------------------------------'
        ----------------TRUNCATE & INSERT DATA SILVER.crm_sales_details-----------------
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE SILVER.crm_sales_details... '
            TRUNCATE TABLE SILVER.crm_sales_details
        PRINT '>>DONE'
        PRINT '>>INSERT CLEAN DATA TO TABLE SILVER.crm_sales_details...'
            INSERT INTO SILVER.crm_sales_details
            (
                sls_ord_num,
	            sls_prd_key,
	            sls_cust_id,
	            sls_order_dt,
	            sls_ship_dt,
	            sls_due_dt,
	            sls_sales,
	            sls_quantity,
	            sls_price
              )
            SELECT 
	               [sls_ord_num]
                  ,[sls_prd_key]
                  ,[sls_cust_id]
                  ,
                      CASE
                        WHEN [sls_order_dt] = 0 or LEN([sls_order_dt]) != 8 then NULL
                      ELSE CAST(CAST([sls_order_dt] as VARCHAR)as DATE) 
                      END
                      sls_order_dt
                  ,
                      CASE
                        WHEN [sls_ship_dt] = 0 or LEN([sls_ship_dt]) != 8 then NULL
                      ELSE CAST(CAST([sls_ship_dt] as VARCHAR)as DATE) 
                      END
                      [sls_ship_dt]
                  ,   CASE
                        WHEN [sls_due_dt] = 0 or LEN([sls_due_dt]) != 8 then NULL
                      ELSE CAST(CAST([sls_due_dt] as VARCHAR)as DATE) 
                      END
                      [sls_due_dt]     
                  , CASE
                         WHEN [sls_sales] <= 0 OR [sls_sales] IS NULL OR [sls_sales] != [sls_quantity]*ABS([sls_price])
                         THEN [sls_quantity]*ABS([sls_price])
                    ELSE [sls_sales]
                    END AS [sls_sales]
                  ,
                    [sls_quantity]

                  , CASE
                        WHEN [sls_price] <=0 OR [sls_price] IS NULL 
                        THEN [sls_sales]/NULLIF([sls_quantity],0)
                    ELSE [sls_price]
                    END AS [sls_price]
            FROM [BRONZE].[crm_sales_details]
        SET @end_time = GETDATE()
        PRINT '>>Load time:' + CAST(DATEDIFF(second,@start_time,@end_time) as Varchar)
        PRINT '>>DONE TABLE SILVER.crm_sales_details'
        PRINT '------------------------------------------------------------------'
        --------------TRUNCATE & INSERT TABLE [SILVER].[erp_cust_az12]-------------
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE SILVER.erp_cust_az12... '
          TRUNCATE TABLE SILVER.erp_cust_az12
        PRINT '>>DONE'
        PRINT '>>INSERT CLEAN DATA TO TABLE SILVER.erp_cust_az12..'
        INSERT INTO [SILVER].[erp_cust_az12]
            (
                CID,BDATE,GEN
            )
            Select 
                CASE 
                    WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
                ELSE CID
                END AS CID,
                CASE 
                    WHEN BDATE > GETDATE() THEN NULL
                    ELSE BDATE
                END AS BDATE,
                CASE
                    WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') Then 'Female'
                    WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
                    ELSE 'N/a'
                    END GEN
            FROM [BRONZE].[erp_cust_az12]
        SET @end_time = GETDATE()
        PRINT '>>Load time:' + CAST(DATEDIFF(second,@start_time,@end_time) as Varchar)
        PRINT '>>DONE TABLE SILVER.erp_cust_az12'
        PRINT '--------------------------------------------------------------'
        -----------------TRUNCATE & INSERT TABLE [SILVER].[erp_loc_A101]----------------
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING TABLE SILVER.erp_loc_A101... '
            TRUNCATE TABLE silver.erp_loc_A101
        PRINT '>>DONE'
        PRINT '>>INSERT CLEAN DATA TO TABLE SILVER.erp_loc_A101...'
        INSERT INTO silver.erp_loc_A101
            (
                CID,CNTRY
            )
            SELECT 
                REPLACE(CID,'-','') CID,
                CASE 
                    WHEN CNTRY = 'DE' then 'Germany'
                    WHEN CNTRY IN ('USA','United States','US') THEN 'United States'
                    WHEN TRIM(CNTRY)='' OR CNTRY IS NULL then 'N/a'
                    ELSE TRIM(CNTRY)
                END CNTRY
            FROM BRONZE.erp_loc_A101
        SET @end_time = GETDATE()
        PRINT '>>Load time:' + CAST(DATEDIFF(second,@start_time,@end_time) as Varchar)
        PRINT '>>DONE TABLE SILVER.erp_cust_az12'
        PRINT '--------------------------------------------------------------'
        --------------TRUNCATE & INSERT [SILVER].[erp_px_cat_g1v2] ---------------
        PRINT '>>TRUNCATING TABLE SILVER.erp_px_cat_g1v2... '
            TRUNCATE TABLE SILVER.erp_px_cat_g1v2
        PRINT '>>DONE'
        PRINT '>>INSERT CLEAN DATA TO TABLE SILVER.erp_px_cat_g1v2...'
        INSERT INTO SILVER.erp_px_cat_g1v2
            (
            ID,CAT,SUBCAT,MAINTENANCE
            )
            SELECT ID,CAT,SUBCAT,MAINTENANCE
            FROM bronze.erp_px_cat_g1v2
        SET @batch_end_time = GETDATE() 
        SET @end_time = GETDATE()
        PRINT '>>Load time:' + CAST(DATEDIFF(second,@start_time,@end_time) as Varchar)
        PRINT '>>DONE TABLE SILVER.erp_px_cat_g1v2'
        PRINT '--------------------------------------------------------------'
        PRINT 'SILVER LAYER LOAD TIME:' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) as Varchar)
    END TRY
    BEGIN CATCH
        PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
	    PRINT '----------------=-----------------------'
	    PRINT 'Error Messsage' + ERROR_MESSAGE();
	    PRINT 'Error Messsage' + CAST(ERROR_NUMBER() AS NVARCHAR);
	    PRINT 'Error Messsage' + CAST(ERROR_STATE() AS NVARCHAR);
	    PRINT '----------------=-----------------------'
    END CATCH
END
