# Barbershop Analytics Project Notes 

## Business Problem

Barbershops often struggle to track and understand their overall business performance due to fragmented data stored in separate CSV files. Without a unified system, it becomes difficult to monitor customer behaviour, service popularity, revenue trends, and branch performance. This limits data-driven decision-making and makes reporting slow and inconsistent.

## Source Files

The project uses the following raw CSV datasets:

- customers.csv   – Customer information such as names and contact details
- barbers.csv     – Barber details and assigned branches
- branches.csv    – Information about barbershop locations
- bookings.csv    – Appointment records linking customers, barbers, and services
- services.csv    – List of services offered (e.g., haircut, beard trim)
- payments.csv    – Payment transactions for each booking

## Business Questions

This data pipeline is designed to help answer key business questions such as:

- Which services generate the highest revenue?
- Which branch performs the best in terms of bookings and income?
- Who are the top-performing barbers based on completed bookings?
- What are the peak booking times and customer trends?
- How many repeat customers does the business have?
- What is the total revenue per branch over time?
- Which services are most popular among customers?
