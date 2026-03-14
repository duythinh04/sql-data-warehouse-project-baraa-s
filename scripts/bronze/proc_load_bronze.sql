/*
=============================================================
Store Proceduc: Load Bronze Layer (Source => Bronze Layer)
=============================================================
Script Purpose:
  This store procedure will load data from external CSV file.
  It perform the following actions:
    - Truncate all bronze tables before insert new data.
    - Use `Bulk Insert` command to load data from CSV file to bronze tables.
Parameters:
  None
This stored proceduce does not accept any parameters or return any values.

Usage example:
  Exec bronze.load_bronze
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
		DECLARE @start_time DATETIME, @batch_start_time DATETIME,
				@end_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE()
		PRINT '==========================================='
		PRINT 'Loading Bronze Layer'
		PRINT '==========================================='
		PRINT '-------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '-------------------------------------------'

		SET @start_time = GETDATE()
		PRINT '--TRUNCATING TABLE bronze.crm_cust_info'
		TRUNCATE TABLE bronze.crm_cust_info
		PRINT '++INSERT TABLE bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\DataWarehouseNDT\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH
		(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time = GETDATE()
		PRINT '>>Load time:' + CAST(DATEDIFF(second,@end_time,@start_time) as Varchar)
		PRINT '-------------------------------------------'
		--
		SET @start_time = GETDATE()
		PRINT '--TRUNCATING TABLE bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info
		PRINT '++INSERT TABLE bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\DataWarehouseNDT\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT '>>Load time:' + CAST(DATEDIFF(second,@end_time,@start_time) as Varchar)
		PRINT '-------------------------------------------'

		--
		SET @start_time = GETDATE()
		PRINT '--TRUNCATING TABLE bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details
		PRINT '++INSERT TABLE crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\DataWarehouseNDT\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT '>>Load time:' + CAST(DATEDIFF(second,@end_time,@start_time) as Varchar)
		PRINT '-------------------------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '-------------------------------------------'
		SET @start_time = GETDATE()
		PRINT '--TRUNCATING TABLE bronze.erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12
		PRINT '++INSERT TABLE bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\DataWarehouseNDT\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT '>>Load time:' + CAST(DATEDIFF(second,@end_time,@start_time) as Varchar)
		PRINT '-------------------------------------------'

		--

		SET @start_time = GETDATE()
		PRINT '--TRUNCATING TABLE bronze.erp_loc_A101'
		TRUNCATE TABLE bronze.erp_loc_A101
		PRINT '++INSERT TABLE bronze.erp_loc_A101'
		BULK INSERT bronze.erp_loc_A101
		FROM 'C:\DataWarehouseNDT\sql-data-warehouse-project\datasets\source_erp\loc_A101.csv'
		WITH
		(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT '>>Load time:' + CAST(DATEDIFF(second,@end_time,@start_time) as Varchar)
		PRINT '-------------------------------------------'

		--
		SET @start_time = GETDATE()
		PRINT '--TRUNCATING TABLE bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		PRINT '++INSERT TABLE bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\DataWarehouseNDT\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		)
		SET @end_time = GETDATE()
		PRINT '>>Load time:' + CAST(DATEDIFF(second,@end_time,@start_time) as Varchar)
		PRINT '-------------------------------------------'
	SET @batch_end_time = GETDATE()
	PRINT 'BRONZE LAYER LOAD TIME:' + CAST(DATEDIFF(second,@batch_end_time,@batch_start_time) as Varchar)
	END TRY
	BEGIN CATCH
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
	PRINT '----------------=-----------------------'
	PRINT 'Error Messsage' + ERROR_MESSAGE();
	PRINT 'Error Messsage' + CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT 'Error Messsage' + CAST(ERROR_STATE() AS NVARCHAR);
	PRINT '----------------=-----------------------'
	END CATCH

END
