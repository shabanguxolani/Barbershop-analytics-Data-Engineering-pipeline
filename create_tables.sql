-- CREATE DATABASE Barbershop_analytics;
-- GO

USE Barbershop_analytics;
GO

-- CREATE SCHEMAS

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE [NAME] = 'bronze')		-- Bronze schema for raw data
BEGIN
	EXEC('CREATE SCHEMA bronze')
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE [NAME] = 'staging')		-- Staging schema for processed / cleaning data
BEGIN
	EXEC('CREATE SCHEMA staging')
END

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE [NAME] = 'dw')		-- Data warehouse schema for processed data
BEGIN
	EXEC('CREATE SCHEMA dw')
END

-- CREATE TABLES

IF OBJECT_ID('bronze.customers_raw','U') IS NOT NULL
	DROP TABLE bronze.customers_raw;
	GO

CREATE TABLE bronze.customers_raw (			-- customers table
	customer_id	VARCHAR(80),
	first_name	VARCHAR(80),
	last_name	VARCHAR(80),
	phone_number	VARCHAR(80),
	email	VARCHAR(80),
	gender	VARCHAR(80),
	city	VARCHAR(80),
	province	VARCHAR(80),
	signup_date	VARCHAR(80),
	source_file_name	VARCHAR(200),
	loaded_at DATETIME DEFAULT GETDATE()

);
GO

IF OBJECT_ID('bronze.barbers_raw','U') IS NOT NULL
	DROP TABLE bronze.barbers_raw;
	GO

CREATE TABLE bronze.barbers_raw (			-- barbers table	
	barber_code	VARCHAR(80),
	barber_name	VARCHAR(80),
	branch_code	VARCHAR(80),
	experience_level	VARCHAR(80),
	hire_date	VARCHAR(80),
	source_file_name	VARCHAR(200),
	loaded_at DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('bronze.branches_raw', 'U') IS NOT NULL 
	DROP TABLE bronze.branches_raw;
	GO

CREATE TABLE bronze.branches_raw (			-- branches table
	branch_code	VARCHAR(80),
	branch_name	VARCHAR(80),
	province	VARCHAR(80),
	city	VARCHAR(80),
	suburb	VARCHAR(80),
	source_file_name	VARCHAR(200),
	loaded_at DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('bronze_bookings_raw', 'U') IS NOT NULL
	DROP TABLE bronze_bookings_raw;
	GO

CREATE TABLE bronze_bookings_raw (			-- bookings table 
	booking_id	VARCHAR(80),
	customer_id	VARCHAR(80),
	barber_code	VARCHAR(80),
	service_code	VARCHAR(80),
	branch_code	VARCHAR(80),
	booking_datetime	VARCHAR(80),
	booking_status	VARCHAR(80),
	booking_amount	VARCHAR(80),
	discount_amount	VARCHAR(80),
	tip_amount	VARCHAR(80),
	source_file_name	VARCHAR(200),
	loaded_at DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('bronze_services_raw', 'U') IS NOT NULL
	DROP TABLE bronze_services_raw;
	GO

CREATE TABLE bronze_services_raw (			-- services table 
	service_code	VARCHAR(80),
	[service_name]	VARCHAR(80),
	category	VARCHAR(80),
	standard_price	VARCHAR(80),
	duration_minutes	VARCHAR(80),
	source_file_name	VARCHAR(200),
	loaded_at DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('bronze_payments_raw', 'U') IS NOT NULL
	DROP TABLE bronze_payments_raw;
	GO

CREATE TABLE bronze_payments_raw (			-- payments table
	payment_id	VARCHAR(80),
	booking_id	VARCHAR(80),
	payment_method	VARCHAR(80),
	payment_amount	VARCHAR(80),
	payment_status	VARCHAR(80),
	payment_datetime	VARCHAR(80),
	source_file_name	VARCHAR(200),
	loaded_at DATETIME DEFAULT GETDATE()
);
GO