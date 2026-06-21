USE Barbershop_analytics;
GO

-- Staging Bookings

TRUNCATE TABLE staging.bookings;

INSERT INTO staging.bookings (
    booking_id, customer_id, barber_code, service_code, service_short_code,branch_code, 
    branch_city_code, branch_suburb_code, booking_datetime, booking_date, booking_year,
    booking_month, booking_month_name, booking_day_name, booking_hour, time_of_day_bucket,
    is_weekend, booking_status, is_completed, is_cancelled, is_no_show, gross_amount,
    discount_amount, tip_amount, net_amount, has_discount, has_tip , source_file_name, loaded_at
)
SELECT
    NULLIF(TRIM(booking_id), ''),
    COALESCE(NULLIF(UPPER(TRIM(customer_id)), ''), 'UNKNOWN'),
    COALESCE(NULLIF(UPPER(TRIM(barber_code)), ''), 'UNKNOWN'),
    CASE
        WHEN service_code IS NULL OR TRIM(service_code) = '' THEN 'UNKNOWN'
        WHEN UPPER(TRIM(service_code)) = 'SVC-UNKNOWN' THEN 'UNKNOWN'
    ELSE
        UPPER(service_code)
    END,
    CASE
        WHEN service_code IS NULL OR TRIM(service_code) = '' THEN 'UNKNOWN'
        WHEN UPPER(TRIM(service_code)) = 'SVC-UNKNOWN' THEN 'UNKNOWN'
    ELSE
        REPLACE(UPPER(TRIM(service_code)), 'SVC-', '')
    END,
    COALESCE(NULLIF(UPPER(TRIM(branch_code)), ''), 'UNKNOWN'),
    CASE
        WHEN branch_code IS NULL OR TRIM(branch_code) = '' THEN 'UNKNOWN'
    ELSE
        SUBSTRING(UPPER(TRIM(branch_code)), 4, 3)
    END,
    CASE   
        WHEN branch_code IS NULL OR TRIM(branch_code) = '' THEN 'UNKNOWN'
    ELSE
        RIGHT(UPPER(TRIM(branch_code)), 3)
    END,
    TRY_CONVERT(DATETIME2, booking_datetime),
    CAST(TRY_CONVERT(DATETIME2, booking_datetime) AS DATE),
    DATEPART(YEAR, TRY_CONVERT(DATETIME2, booking_datetime)),
    DATEPART(MONTH, TRY_CONVERT(DATETIME2, booking_datetime)),
    DATENAME(MONTH, TRY_CONVERT(DATETIME2, booking_datetime)),
    DATENAME(WEEKDAY, TRY_CONVERT(DATETIME2, booking_datetime)),
    DATEPART(HH, TRY_CONVERT(DATETIME2, booking_datetime)),
    CASE
        WHEN DATEPART(HH, TRY_CONVERT(DATETIME2, booking_datetime)) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN DATEPART(HH, TRY_CONVERT(DATETIME2, booking_datetime)) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN DATEPART(HH, TRY_CONVERT(DATETIME2, booking_datetime)) BETWEEN 17 AND 20 THEN 'Evening'
    ELSE   
        'Other'
    END,
    CASE
        WHEN DATENAME(WEEKDAY, TRY_CONVERT(DATETIME2, booking_datetime)) IN ('Saturday','Sunday') THEN 1
    ELSE
        0
    END,
    COALESCE(NULLIF(TRIM(booking_status), ''), 'UNKNOWN'),
    CASE   
        WHEN booking_status = 'Completed' THEN 1
    ELSE
        0
    END,
    CASE 
        WHEN booking_status = 'Cancelled' THEN 1
    ELSE
        0
    END,
    CASE    
       WHEN booking_status = 'No Show' THEN 1
    ELSE
        0
    END,
    TRY_CONVERT(DECIMAL(10, 2), booking_amount),
    TRY_CONVERT(DECIMAL(10, 2), discount_amount),
    TRY_CONVERT(DECIMAL(10, 2), tip_amount),
    ISNULL(TRY_CONVERT(DECIMAL(10, 2), booking_amount),0)
    - ISNULL(TRY_CONVERT(DECIMAL(10, 2), discount_amount), 0)
    + ISNULL(TRY_CONVERT(DECIMAL(10, 2), tip_amount), 0),
    CASE
        WHEN ISNULL(TRY_CONVERT(DECIMAL(10, 2), discount_amount),0) > 0 THEN 1
    ELSE
        0
    END,
    CASE
        WHEN ISNULL(TRY_CONVERT(DECIMAL(10, 2), tip_amount),0) > 0 THEN 1
    ELSE
        0
    END,
    source_file_name,
    loaded_at

FROM bronze.bookings_raw

SELECT * FROM staging.bookings

-- Staging Payments 

TRUNCATE TABLE staging.payments;

INSERT INTO staging.payments (
    payment_id, booking_id, payment_method, payment_method_group,
    payment_amount, payment_status, is_successful_payment, is_failed_payment,
    is_reversed_payment, payment_datetime, payment_date, payment_hour,
    source_file_name, loaded_at
)
SELECT
    NULLIF(TRIM(payment_id), ''),
    COALESCE(NULLIF(UPPER(TRIM(booking_id)), ''), 'UNKNOWN'),
    COALESCE(NULLIF(TRIM(payment_method), ''), 'Unknown'),
    CASE
        WHEN payment_method = 'Cash' THEN 'Cash'
        WHEN payment_method IN ('Card', 'Mobile Wallet', 'EFT') THEN 'Digital'
        ELSE 'Other'
    END,
    TRY_CONVERT(DECIMAL(10,2), payment_amount),
    COALESCE(NULLIF(TRIM(payment_status), ''), 'Unknown'),
    CASE WHEN payment_status = 'Successful' THEN 1 ELSE 0 END,
    CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END,
    CASE WHEN payment_status = 'Reversed' THEN 1 ELSE 0 END,
    TRY_CONVERT(DATETIME2, payment_datetime),
    CAST(TRY_CONVERT(DATETIME2, payment_datetime) AS DATE),
    DATEPART(HOUR, TRY_CONVERT(DATETIME2, payment_datetime)),
    source_file_name,
    loaded_at
FROM bronze.payments_raw;
GO

-- SELECT * FROM staging.payments

-- Staging Branches

TRUNCATE TABLE staging.branches;

INSERT INTO staging.branches (
    branch_code, branch_name, branch_city_code, branch_suburb_code,
    province, city, suburb, region, source_file_name, loaded_at
)
SELECT
    COALESCE(NULLIF(UPPER(TRIM(branch_code)), ''), 'UNKNOWN'),
    COALESCE(NULLIF(TRIM(branch_name), ''), 'Unknown Branch'),
    CASE WHEN branch_code IS NULL OR TRIM(branch_code) = '' THEN 'UNKNOWN' ELSE SUBSTRING(UPPER(TRIM(branch_code)), 4, 3) END,
    CASE WHEN branch_code IS NULL OR TRIM(branch_code) = '' THEN 'UNKNOWN' ELSE RIGHT(UPPER(TRIM(branch_code)), 3) END,
    COALESCE(NULLIF(TRIM(province), ''), 'Unknown'),
    COALESCE(NULLIF(TRIM(city), ''), 'Unknown'),
    COALESCE(NULLIF(TRIM(suburb), ''), 'Unknown'),
    CASE
        WHEN province IN ('Gauteng', 'Limpopo', 'Free State') THEN 'Inland'
        WHEN province IN ('Western Cape', 'KwaZulu-Natal') THEN 'Coastal'
        ELSE 'Unknown'
    END,
    source_file_name,
    loaded_at
FROM bronze.branches_raw;
GO

-- SELECT * FROM staging.branches

-- Staging Services

TRUNCATE TABLE staging.services;

INSERT INTO staging.services (
    service_code, service_short_code, service_name, category, service_group,
    standard_price, duration_minutes, duration_bucket, price_bucket,
    source_file_name, loaded_at
)
SELECT
    COALESCE(NULLIF(UPPER(TRIM(service_code)), ''), 'UNKNOWN'),
    REPLACE(COALESCE(NULLIF(UPPER(TRIM(service_code)), ''), 'UNKNOWN'), 'SVC-', ''),
    COALESCE(NULLIF(TRIM(service_name), ''), 'Unknown Service'),
    COALESCE(NULLIF(TRIM(category), ''), 'Unknown'),
    CASE
        WHEN category IN ('Hair', 'Beard', 'Combo') THEN 'Core Grooming'
        WHEN category = 'Hair Care' THEN 'Treatment'
        ELSE 'Other'
    END,
    TRY_CONVERT(DECIMAL(10,2), standard_price),
    TRY_CONVERT(INT, duration_minutes),
    CASE
        WHEN TRY_CONVERT(INT, duration_minutes) <= 30 THEN 'Short'
        WHEN TRY_CONVERT(INT, duration_minutes) <= 60 THEN 'Medium'
        ELSE 'Long'
    END,
    CASE
        WHEN TRY_CONVERT(DECIMAL(10,2), standard_price) < 100 THEN 'Budget'
        WHEN TRY_CONVERT(DECIMAL(10,2), standard_price) <= 200 THEN 'Standard'
        ELSE 'Premium'
    END,
    source_file_name,
    loaded_at
FROM bronze.services_raw;
GO

-- SELECT * FROM staging.[services]

-- Staging Barbers

TRUNCATE TABLE staging.barbers;

INSERT INTO staging.barbers (
    barber_code, barber_name, branch_code, branch_city_code,
    experience_level, experience_group, hire_date, years_employed,
    source_file_name, loaded_at
)
SELECT
    COALESCE(NULLIF(UPPER(TRIM(barber_code)), ''), 'UNKNOWN'),
    COALESCE(NULLIF(TRIM(barber_name), ''), 'Unknown Barber'),
    COALESCE(NULLIF(UPPER(TRIM(branch_code)), ''), 'UNKNOWN'),
    CASE WHEN branch_code IS NULL OR TRIM(branch_code) = '' THEN 'UNKNOWN' ELSE SUBSTRING(UPPER(TRIM(branch_code)), 4, 3) END,
    COALESCE(NULLIF(TRIM(experience_level), ''), 'Unknown'),
    CASE
        WHEN experience_level = 'Junior' THEN 'Entry Level'
        WHEN experience_level = 'Mid-Level' THEN 'Mid Level'
        WHEN experience_level IN ('Master Barber', 'Senior') THEN 'Experienced'
        ELSE 'Unknown'
    END,
    TRY_CONVERT(DATE, hire_date),
    DATEDIFF(YEAR, TRY_CONVERT(DATE, hire_date), GETDATE()),
    source_file_name,
    loaded_at
FROM bronze.barbers_raw;
GO

-- SELECT * FROM staging.barbers

-- Staging Customers

TRUNCATE TABLE staging.customers;

WITH CleanedData AS (
    SELECT
        COALESCE(NULLIF(UPPER(TRIM(customer_id)), ''), 'UNKNOWN') AS customer_id,
        COALESCE(NULLIF(TRIM(first_name), ''), 'UNKNOWN') AS first_name,
        COALESCE(NULLIF(TRIM(last_name), ''), 'UNKNOWN') AS last_name,
        COALESCE(NULLIF(TRIM(phone_number), ''), 'UNKNOWN') AS phone_number,
        COALESCE(NULLIF(LOWER(TRIM(email)), ''), 'UNKNOWN') AS email,
        COALESCE(NULLIF(TRIM(gender), ''), 'UNKNOWN') AS gender,
        COALESCE(NULLIF(TRIM(city), ''), 'UNKNOWN') AS city,
        COALESCE(NULLIF(TRIM(province), ''), 'UNKNOWN') AS province,
        TRY_CONVERT(DATETIME, signup_date) AS signup_date,
        source_file_name,
        loaded_at
    FROM bronze.customers_raw
)

INSERT INTO staging.customers (
    customer_id, first_name, last_name, full_name, phone_number, email, email_domain,
    gender, gender_group, city, province, region, signup_date, signup_year,
    source_file_name, loaded_at
)

SELECT
    customer_id,
    first_name,
    last_name,
    CONCAT(first_name, ' ', last_name) AS full_name,
    phone_number,
    email,

    CASE
        WHEN email LIKE '%@%' THEN SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email))
        ELSE 'UNKNOWN'
    END AS email_domain,

    gender,

    CASE
        WHEN gender LIKE 'M%' THEN 'Male'
        WHEN gender LIKE 'F%' THEN 'Female'
        ELSE 'Other'
    END AS gender_group,

    city,
    province,

    CASE
        WHEN province IN ('Mpumalanga', 'Gauteng', 'Limpopo', 'Free State', 'North West', 'Northern Cape')
            THEN 'Inland'
        WHEN province IN ('KwaZulu-Natal', 'Western Cape', 'Eastern Cape')
            THEN 'Coastal'
        ELSE 'Other'
    END AS region,

    signup_date,
    YEAR(signup_date) AS signup_year,
    source_file_name,
    loaded_at

FROM CleanedData;
-- SELECT * FROM staging.customers