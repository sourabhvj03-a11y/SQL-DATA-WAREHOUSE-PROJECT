/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
create or alter procedure Bronze.load_Bronze as
begin
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 

        begin try
            SET @batch_start_time = GETDATE();
		    PRINT '================================================';
		    PRINT 'Loading Bronze Layer';
		    PRINT '================================================';

		    PRINT '------------------------------------------------';
		    PRINT 'Loading CRM Tables';
		    PRINT '------------------------------------------------';

		    SET @start_time = GETDATE();
		    PRINT '>> Truncating Table: Bronze.crm_cust_info;';

            truncate table Bronze.crm_cust_info;
            PRINT '>> Inserting Data Into: Bronze.crm_cust_info';
            bulk insert Bronze.crm_cust_info from "C:\Users\Abcom\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv"
            with (firstrow=2,fieldterminator=',',tablock);
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		    PRINT '>> -------------';


            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: Bronze.crm_prd_id';
            truncate table Bronze.crm_prd_id;
            PRINT '>> Inserting Data Into: Bronze.crm_prd_id';
            bulk insert Bronze.crm_prd_id from "C:\Users\Abcom\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv"
            with (firstrow=2,fieldterminator=',',tablock);
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		    PRINT '>> -------------';

            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: Bronze.crm_sales_details';
            truncate table Bronze.crm_sales_details;
            PRINT '>> Inserting Data Into: Bronze.crm_prd_id';
            bulk insert Bronze.crm_sales_details from "C:\Users\Abcom\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv"
            with (firstrow=2,fieldterminator=',',tablock);
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		    PRINT '>> -------------';

            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: Bronze.erp_px_cat_g1v2';
            truncate table Bronze.erp_px_cat_g1v2;
            PRINT '>> Inserting Data Into: Bronze.erp_px_cat_g1v2';
            bulk insert Bronze.erp_px_cat_g1v2 from "C:\Users\Abcom\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv"
            with (firstrow=2,fieldterminator=',',tablock);
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		    PRINT '>> -------------';

            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: Bronze.erp_LOC_A101';
            truncate table Bronze.erp_LOC_A101;
            PRINT '>> Inserting Data Into: Bronze.erp_LOC_A101';
            bulk insert Bronze.erp_LOC_A101 from "C:\Users\Abcom\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv"
            with (firstrow=2,fieldterminator=',',tablock);
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		    PRINT '>> -------------';

            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: Bronze.erp_PX_CAT_G1V2';
            truncate table Bronze.erp_PX_CAT_G1V2;
            PRINT '>> Inserting Data Into: Bronze.erp_PX_CAT_G1V2';
            bulk insert Bronze.erp_PX_CAT_G1V2 from "C:\Users\Abcom\Desktop\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv"
            with (firstrow=2,fieldterminator=',',tablock);
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		    PRINT '>> -------------';

        end try
        begin catch

        end catch
end
