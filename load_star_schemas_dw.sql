USE Barbershop_analytics;
GO

-- CREATE FACT TABLE		GHOST RECORD OR UNKNOWN RECORD

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

