
/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		-- Loading silver.crm_cust_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		truncate table silver.crm_cust_info;
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		insert into silver.crm_cust_info(cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
			(select 
				cst_id,
				cst_key,
				trim(cst_firstname) as cst_firstname,
				trim(cst_lastname) as cst_lastname ,
				case Upper(trim(cst_marital_status)) when 'M' then 'Married'
				when 'S' then 'single'
				else 'NA'
				end as cst_marital_status,
				case Upper(trim(cst_gndr))
				when 'M' then 'Male'
				when 'F' then 'Female'
				Else 'NA'
				end as cst_gndr,
				cst_create_date
			from (
				select 
					*,
					ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) flag_last 
				from Bronze.crm_cust_info 
					where cst_id is not null)t where flag_last=1);

			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';

		-- Loading [Silver].[crm_prd_id]
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: [Silver].[crm_prd_id]';
		truncate table [Silver].[crm_prd_id];
		PRINT '>> Inserting Data Into: [Silver].[crm_prd_id]';
		INSERT INTO [Silver].[crm_prd_id]
					   ([prd_id]
					   ,[cust_id]
					   ,[prd_key]
					   ,[prd_nm]
					   ,[prd_cost]
					   ,[prd_line]
					   ,[prd_start_dt]
					   ,[prd_end_dt])
     
			SELECT prd_id
				  ,replace(substring(prd_key,1,5),'-','_') as cust_id
				  ,substring(prd_key,7,len(prd_key)) as prd_key
				  ,prd_nm
				  ,isnull(prd_cost,0) as prd_cost
				  ,case upper(trim(prd_line)) 
						when 'R' then 'Road'
						when 'S' then 'Other Sales'
						when 'M' then 'Mountain'
						when 'T' then 'Touring'
						else 'NA'
				   end as prd_line
				  ,cast(prd_start_dt as date) as prd_start_dt
				  ,cast(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)as date) as prd_end_dt
			  FROM Bronze.crm_prd_id
			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';


		-- Loading silver.crm_sales_details
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		truncate table silver.crm_sales_details;
		PRINT '>> Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
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
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
					THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
					THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price  -- Derive price if original value is invalid
			END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';

		-- Loading silver.erp_cust_az12
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		truncate table silver.erp_cust_az12;
		PRINT '>> Inserting Data Into: silver.erp_cust_az12';
		insert into silver.erp_cust_az12(cid,gen,bdate)
		select 
		case 
			when cid like 'NAS%' then SUBSTRING(cid,4,len(cid)) 
			else cid 
		end as cid,
		case
			when upper(TRIM(gen))='F' or upper(gen)='FEMALE' 
				then 'Female'
			when upper(TRIM(gen))='M' or upper(gen)='MALE' 
				then 'Male'
			when upper(TRIM(gen))='' 
				then Null
			else null 
		end gen,
		case 
			when year(bdate)<1926 or bdate>GETDATE() 
				then NULL else bdate 
		end as bdate 
		from bronze.erp_cust_az12;
			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';


		-- Loading silver.erp_cust_az12
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		truncate table silver.erp_loc_a101;
		PRINT '>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(cid,cntry)
			select replace(cid,'-','') as cid,
			case 
				when upper(trim(cntry)) in ('US','USA') then 'United States'
				when upper(trim(cntry)) in ('DE') then 'Geermany'
				when upper(trim(cntry)) in ('') or cntry is NULL then 'NULL'
				else cntry
				end as cntry
			from Bronze.erp_loc_a101;
			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------'


		-- Loading silver.erp_cust_az12
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		truncate table silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2
			(id,
			cat,
			subcat,
			maintenance)
			select 
				id,cat,
				subcat,
				maintenance
			from Bronze.erp_px_cat_g1v2;
			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';

				SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
	
		END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
