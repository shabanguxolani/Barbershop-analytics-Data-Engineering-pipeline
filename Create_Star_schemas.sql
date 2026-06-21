
USE Barbershop_analytics;
GO

-- CREATE DIMENSION TABLES

IF OBJECT_ID('dw.dim_customer','U') IS NOT NULL		-- dim_customers
	DROP TABLE dw.dim_customer;
GO

CREATE TABLE dw.dim_customer (
	customer_key INT IDENTITY(1,1) PRIMARY KEY,		--surrogate keys
	customer_id	 VARCHAR(20),
	full_name VARCHAR(50),
	gender_group VARCHAR(20),
	city VARCHAR(50),
	province VARCHAR(50),
	region VARCHAR (50),
	signup_date DATE,
	signup_year INT,
);
GO


IF OBJECT_ID('dw.dim_barber', 'U') IS NOT NULL		-- dim_barber
	DROP TABLE dw.dim_barber;
GO

CREATE TABLE dw.dim_barber (
	barber_key INT IDENTITY(1,1) PRIMARY KEY,		--surrogate keys
	barber_code VARCHAR(50) NOT NULL,
	barber_name VARCHAR(100),
	branch_code VARCHAR(50),
	branch_city_code VARCHAR(10),
	experience_level VARCHAR(20),
	experience_group VARCHAR(30),
	hire_date DATE,
	years_employed INT
);
GO

IF OBJECT_ID('dw.dim_branch', 'U') IS NOT NULL		-- dim_branch
	DROP TABLE dw.dim_branch;
GO

CREATE TABLE dw.dim_branch (
	branch_key INT IDENTITY(1,1) PRIMARY KEY,		--surrogate keys
	branch_code VARCHAR(50) NOT NULL,
	branch_name VARCHAR(200),
	branch_city_code VARCHAR(10),
	branch_suburb_code VARCHAR(10),
	province VARCHAR(100),
	city VARCHAR(100),
	suburb VARCHAR(50),
	region VARCHAR(50),
);
GO

IF OBJECT_ID('dw.dim_service', 'U') IS NOT NULL		-- dim_Date
	DROP TABLE dw.dim_service;
GO

CREATE TABLE dw.dim_service (
	service_key INT IDENTITY(1,1) PRIMARY KEY,		--surrogate keys
	service_code VARCHAR(50) NOT NULL,
	service_short_code VARCHAR(50),
	service_name VARCHAR(200),
	category VARCHAR(100),
	standard_group VARCHAR(100),
	standard_price DECIMAL(10,2),
	duration_minutes INT,
	duration_bucket VARCHAR(50),
	price_bucket VARCHAR(50)
);
GO

IF OBJECT_ID('dw.dim_date', 'U') IS NOT NULL		-- dim_date 
	DROP TABLE dw.dim_date;
GO

CREATE TABLE dw.dim_date (
	date_key INT PRIMARY KEY,						--surrogate keys
	full_date DATE NOT NULL,
	year INT,
	month_number INT,
	month_name VARCHAR(20),
	day_number INT,
	day_name VARCHAR(20),
	week_number INT,
	is_weekend BIT
);
GO


-- ===================================
-- GHOST RECORD OR UNKNOWN RECORD
-- ===================================

IF OBJECT_ID('dw.fact_bookings', 'U') IS NOT NULL
	DROP TABLE dw.fact_bookings;
GO

CREATE TABLE dw.fact_bookings (
	booking_key INT IDENTITY(1,1) PRIMARY KEY,
	booking_id VARCHAR(50) NOT NULL,
	
	--surrogate keys
	customer_key INT,
	barber_key INT,
	branch_key INT,
	service_key INT,
	date_key  INT,

	booking_datetime DATETIME2,
	booking_status VARCHAR(50),
	time_of_day_bucket VARCHAR(20),

	-- measures
	gross_amount DECIMAL(10,2),
	discount_amount DECIMAL(10,2),
	tip_amount DECIMAL(10,2),
	net_amount DECIMAL(10,2),

	--flags
	is_completed BIT,
	is_cancelled BIT,
	is_no_show BIT,
	has_discount BIT,
	has_tip Bit,
);
GO


