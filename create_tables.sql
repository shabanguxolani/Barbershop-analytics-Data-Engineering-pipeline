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

--======================================================
-- CREATE STAGING TABLES
--======================================================
--Customers 

IF OBJECT_ID('staging.customers', 'U') IS NOT NULL
    DROP TABLE staging.customers;
GO

CREATE TABLE staging.customers (
    customer_id VARCHAR(50),
    first_name VARCHAR(200),
    last_name VARCHAR(50),
    full_name VARCHAR(250),
    phone_number VARCHAR(50),
    email VARCHAR(200),
    email_domain VARCHAR(100),
    gender VARCHAR(50),
    gender_group VARCHAR(20),
    city VARCHAR(50),
    province VARCHAR(50),
    region VARCHAR(50),
    signup_date DATE,
    signup_year INT,
    source_file_name VARCHAR(200),
    loaded_at DATETIME2
);
GO

-- BARBERS
IF OBJECT_ID('staging.barbers', 'U') IS NOT NULL
    DROP TABLE staging.barbers;
GO

CREATE TABLE staging.barbers (
    barber_code VARCHAR(20),
    barber_name VARCHAR(100),
    branch_code VARCHAR(20),
    branch_city_code VARCHAR(10),
    experience_level VARCHAR(20),
    experience_group VARCHAR(30),
    hire_date DATE,
    years_employed INT,
    source_file_name VARCHAR(200),
    loaded_at DATETIME2
);
GO

-- BRANCHES
IF OBJECT_ID('staging.branches', 'U') IS NOT NULL
    DROP TABLE staging.branches;
GO

CREATE TABLE staging.branches (
    branch_code VARCHAR(50),
    branch_name VARCHAR(200),
    branch_city_code VARCHAR(10),
    branch_suburb_code VARCHAR(10),
    province VARCHAR(100),
    city VARCHAR(100),
    suburb VARCHAR(50),
    region VARCHAR(50),
    source_file_name VARCHAR(200),
    loaded_at DATETIME2
);
GO

--SERVICES
IF OBJECT_ID('staging.services', 'U') IS NOT NULL
    DROP TABLE staging.services;
GO

CREATE TABLE staging.services (
    service_code VARCHAR(50),
    service_short_code VARCHAR(50),
    [service_name] VARCHAR(200),
    category VARCHAR(100),
    service_group VARCHAR(100),
    standard_price DECIMAL(10,2),
    duration_minutes INT,
    duration_bucket VARCHAR(50),
    price_bucket VARCHAR(50),
    source_file_name VARCHAR(200),
    loaded_at DATETIME2
);
GO

-- BOOKINGS
IF OBJECT_ID('staging.bookings', 'U') IS NOT NULL
    DROP TABLE staging.bookings;
GO

CREATE TABLE staging.bookings (
    booking_id VARCHAR(50),
    customer_id VARCHAR(50),
    barber_code VARCHAR(50),
    service_code VARCHAR(50),
    service_short_code VARCHAR(50),
    branch_code VARCHAR(50),
    branch_city_code VARCHAR(10),
    branch_suburb_code VARCHAR(10),
    booking_datetime DATETIME2,
    booking_date DATE,
    booking_year INT,
    booking_month INT,
    booking_month_name VARCHAR(20),
    booking_day_name VARCHAR(20),
    booking_hour INT,
    time_of_day_bucket VARCHAR(20),
    is_weekend BIT,
    booking_status VARCHAR(50),
    is_completed BIT,
    is_cancelled BIT,
    is_no_show BIT,
    gross_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    tip_amount DECIMAL(10,2),
    net_amount DECIMAL(10,2),
    has_discount BIT,
    has_tip BIT,
    source_file_name VARCHAR(200),
    loaded_at DATETIME2
);
GO

-- PAYMENTS
IF OBJECT_ID('staging.payments', 'U') IS NOT NULL
    DROP TABLE staging.payments;
GO

CREATE TABLE staging.payments (
    payment_id VARCHAR(50),
    booking_id VARCHAR(50),
    payment_method VARCHAR(50),
    payment_method_group VARCHAR(50),
    payment_amount DECIMAL(10,2),
    payment_status VARCHAR(50),
    is_successful_payment BIT,
    is_failed_payment BIT,
    is_reversed_payment BIT,
    payment_datetime DATETIME2,
    payment_date DATE,
    payment_hour INT,
    source_file_name VARCHAR(200),
    loaded_at DATETIME2
);
GO