
-- Load the fact table

TRUNCATE TABLE dw.fact_bookings;

INSERT INTO dw.fact_bookings (
	booking_id, customer_key, barber_key, branch_key, service_key, date_key,
	booking_datetime, booking_status, time_of_day_bucket, gross_amount,
	discount_amount, tip_amount, net_amount, is_completed, is_cancelled,
	is_no_show, has_discount, has_tip
)
SELECT
	b.booking_id,
    ISNULL(c.customer_key, -1) AS customer_key,
    ISNULL(br.barber_key, -1) AS barber_key,
    ISNULL(branch.branch_key, -1) AS branch_key,
    ISNULL(s.service_key, -1) AS service_key,
    ISNULL(d.date_key, -1) AS date_key,
    b.booking_datetime,
    b.booking_status,
    b.time_of_day_bucket,
    b.gross_amount,
    b.discount_amount,
    b.tip_amount,
    b.net_amount,
    b.is_completed,
    b.is_cancelled,
    b.is_no_show,
    b.has_discount,
    b.has_tip
FROM staging.bookings AS b
LEFT JOIN dw.dim_customer AS c
	ON b.customer_id	= c.customer_id
LEFT JOIN dw.dim_barber AS br
	ON b.barber_code	= br.barber_code
LEFT JOIN dw.dim_branch AS branch
	ON b.branch_code	= branch.branch_code
LEFT JOIN dw.dim_service AS s
	ON b.service_code	= s.service_code
LEFT JOIN dw.dim_date AS d
	ON b.booking_date	= d.full_date;
GO
