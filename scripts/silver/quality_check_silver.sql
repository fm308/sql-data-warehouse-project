-- ============================================
-- Checking 'silver.crm_cust_info'
-- ============================================


-- Check for unwanted spaces
-- Expectation: No Results
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Standarization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;


-- ============================================
-- Checking 'silver.crm_sales_details'
-- ============================================



-- sls_ord_num correct with TRIM
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- Next col sls_prd_key and sls_cust_id correct (no cleansing needed)
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)


-- Next col sls_order_dt (Check for Invalid Dates)

SELECT
NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

-- Next col sls_ship_dt (Check for Invalid Dates)

SELECT
NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101


-- Next col sls_due_dt (Check for Invalid Dates)

SELECT
NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0 
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101


-- Check for invalid Date Orders
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


-- Check Data Conisistency: Between Sales, Quantity and Price
-- >> Sales = Qunatity * Price
-- >> Values must not be NULL, zero, or negative

-- Business Rules : if sales is negative, zero, or null, derive it using Qunatity and Price
--         if Price is zero or null, calculate it using Sales and Quantity
--		   if Price is negative, convert it to a positive value
SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price as old_sls_price,

CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales < 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price
  


-- ============================================
-- Checking 'silver.crm_prd_info'
-- ============================================

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result
USE DataWarehouse
SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted Spaces
-- Expectation: No Results

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLs or Negative Numbers
-- Expectation: No Results

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL


-- Data Standarization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders (End date must not be earlier than the start date (logika jako ss excela w wordzie)

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


-- ============================================
-- Checking 'silver.erp_cust_az12'
-- ============================================
SELECT DISTINCT 
  bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Data Standarization & Consistency

SELECT DISTINCT 
  gen
FROM silver.erp_cust_az12;

-- ============================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ============================================

-- Check for unwanted Spaces

SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);


-- Data Standarization & Consistency

SELECT DISTINCT
cat --subcat, maintenance
FROM silver.erp_px_cat_g1v2;


  -- ============================================
-- Checking 'silver.erp_loc_a101'
-- ============================================

  
-- Data Standarization & Consistency

SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;



