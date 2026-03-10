Use DataWatehouse;

if OBJECT_ID('silver.crm_cust_info','U') is not null
   drop table silver.crm_cust_info;
create table silver.crm_cust_info(
cst_id int,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_marital_status nvarchar(50),
cst_gndr nvarchar(10),
cst_create_date date
);

if OBJECT_ID('silver.crm_prd_id','u') is not null
   drop table silver.crm_prd_id;
create table silver.crm_prd_id	(prd_id int,
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost int,
prd_line nvarchar(50),
prd_start_dt datetime,
prd_end_dt datetime);

if OBJECT_ID('silver.crm_sales_details','u') is not null
   drop table silver.crm_sales_details;
create table silver.crm_sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id	int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int);

if OBJECT_ID('silver.erp_loc_a101','u') is not null
   drop table silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
cid NVARCHAR(50),
cntry NVARCHAR(58)
);

if OBJECT_ID('silver.erp_cust_az12','u') is not null
   drop table silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
cid NVARCHAR(50),
bdate DATE,
gen NVARCHAR(50)
);

if OBJECT_ID('silver.erp_px_cat_g1v2','u') is not null
   drop table silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
id NVARCHAR(50),
cat NVARCHAR(50),
subcat NVARCHAR(50),
maintenance NVARCHAR(50)
);
