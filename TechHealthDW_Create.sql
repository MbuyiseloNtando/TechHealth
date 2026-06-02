-- Create the TechHealthDW database
CREATE DATABASE TechHealthDW;
GO

-- Use the newly created database
USE TechHealthDW;
GO

-- Create dimension tables
-- DimDate dimension table
CREATE TABLE [dbo].[DimDate] (
    date_key INT PRIMARY KEY,  -- was DATE
    date DATE NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
        year INT NOT NULL,
    quarter INT NOT NULL,
    is_weekend BIT NOT NULL,
    month_name VARCHAR(10) NOT NULL
);
GO

-- DimCustomer dimension table
CREATE TABLE [dbo].[DimCustomer] (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    user_id VARCHAR(10) NOT NULL,  -- Original key from source
    age INT NOT NULL,
    gender CHAR(1) NOT NULL,
    occupation VARCHAR(100) NULL,
    income_bracket VARCHAR(20) NULL,
    subscription_type VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL
);
GO

-- DimLocation dimension table
CREATE TABLE [dbo].[DimLocation] (
    location_key INT IDENTITY(1,1) PRIMARY KEY,
    location_id INT NULL, -- Original key from source
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NULL,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(50) NULL
);
GO

-- DimDevice dimension table
CREATE TABLE [dbo].[DimDevice] (
    device_key INT IDENTITY(1,1) PRIMARY KEY,
    device_id VARCHAR(10) NOT NULL, -- Original key from source
    device_type VARCHAR(100) NOT NULL,
    firmware_version VARCHAR(10) NOT NULL,
    battery_life_days DECIMAL(3,1) NOT NULL,
    sleep_tracking_enabled BIT NOT NULL,
    heart_rate_monitoring_enabled BIT NOT NULL,
    gps_enabled BIT NOT NULL
);
GO

-- DimCoach dimension table
CREATE TABLE [dbo].[DimCoach] (
    coach_key INT IDENTITY(1,1) PRIMARY KEY,
    coach_id VARCHAR(10) NOT NULL, -- Original key from source
    first_name VARCHAR(50) NULL,
    last_name VARCHAR(50) NULL,
    specialization VARCHAR(100) NULL,
    experience_years INT NULL,
    region VARCHAR(50) NULL
);
GO

-- DimProduct dimension table
CREATE TABLE [dbo].[DimProduct] (
    product_key INT IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(20) NOT NULL, -- Original key from source
    product_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(50) NOT NULL
);
GO

-- Create fact tables
-- FactSales fact table
CREATE TABLE [dbo].[FactSales] (
    sale_key INT IDENTITY(1,1) PRIMARY KEY,
    sale_id VARCHAR(10) NOT NULL, -- Original key from source
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    location_key INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    discount_applied DECIMAL(5,2) NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    sales_channel VARCHAR(50) NOT NULL,
    CONSTRAINT FK_FactSales_DimDate 
        FOREIGN KEY (date_key) REFERENCES DimDate(date_key),
    CONSTRAINT FK_FactSales_DimCustomer 
        FOREIGN KEY (customer_key) REFERENCES DimCustomer(customer_key),
    CONSTRAINT FK_FactSales_DimProduct 
        FOREIGN KEY (product_key) REFERENCES DimProduct(product_key),
    CONSTRAINT FK_FactSales_DimLocation 
        FOREIGN KEY (location_key) REFERENCES DimLocation(location_key)
);
GO

-- FactHealthMetrics fact table
CREATE TABLE [dbo].[FactHealthMetrics] (
    health_metric_key INT IDENTITY(1,1) PRIMARY KEY,
    record_id VARCHAR(10) NOT NULL, -- Original key from source
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    avg_heart_rate INT NOT NULL,
    avg_daily_steps INT NOT NULL,
    avg_sleep_hours DECIMAL(3,1) NOT NULL,
    avg_deep_sleep_hours DECIMAL(3,1) NOT NULL,
    avg_daily_calories INT NOT NULL,
    avg_exercise_minutes INT NOT NULL,
    avg_stress_level DECIMAL(3,1) NULL,
    avg_blood_oxygen DECIMAL(4,1) NOT NULL,
    total_active_days INT NOT NULL,
    workout_frequency INT NOT NULL,
    CONSTRAINT FK_FactHealthMetrics_DimDate 
        FOREIGN KEY (date_key) REFERENCES DimDate(date_key),
    CONSTRAINT FK_FactHealthMetrics_DimCustomer 
        FOREIGN KEY (customer_key) REFERENCES DimCustomer(customer_key)
);
GO

-- FactDevices fact table
CREATE TABLE [dbo].[FactDevices](
    device_usage_key INT IDENTITY(1,1) PRIMARY KEY,
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    device_key INT NOT NULL,
    last_sync_date DATE NOT NULL,
    sync_frequency_daily INT NOT NULL,
    active_hours_daily DECIMAL(3,1) NOT NULL,
    total_steps_recorded BIGINT NOT NULL,
    total_workouts_recorded INT NOT NULL,
    device_status VARCHAR(50) NOT NULL,
    CONSTRAINT FK_FactDevices_DimDate FOREIGN KEY (date_key) REFERENCES DimDate(date_key),
    CONSTRAINT FK_FactDevices_DimCustomer FOREIGN KEY (customer_key) REFERENCES DimCustomer(customer_key),
    CONSTRAINT FK_FactDevices_DimDevice FOREIGN KEY (device_key) REFERENCES DimDevice(device_key)
);
GO
-- Create FactCoach_Assignment fact table
CREATE TABLE [dbo].[FactCoach_Assignment] (
    coach_assignment_key INT IDENTITY(1,1) PRIMARY KEY,
    coach_key INT NOT NULL,
    customer_key INT NOT NULL,
    start_date_key INT NOT NULL,
    end_date_key INT NOT NULL,
    CONSTRAINT FK_FactCoachAssignment_DimCoach FOREIGN KEY (coach_key) REFERENCES DimCoach(coach_key),
    CONSTRAINT FK_FactCoachAssignment_DimCustomer FOREIGN KEY (customer_key) REFERENCES DimCustomer(customer_key),
    CONSTRAINT FK_FactCoachAssignment_StartDate FOREIGN KEY (start_date_key) REFERENCES DimDate(date_key),
    CONSTRAINT FK_FactCoachAssignment_EndDate FOREIGN KEY (end_date_key) REFERENCES DimDate(date_key)
);
GO

-- Add indexes to improve query performance
CREATE INDEX IDX_FactSales_DateKey ON FactSales(date_key);
GO
CREATE INDEX IDX_FactSales_CustomerKey ON FactSales(customer_key);
GO
CREATE INDEX IDX_FactSales_ProductKey ON FactSales(product_key);
GO

CREATE INDEX IDX_FactHealthMetrics_DateKey ON FactHealthMetrics(date_key);
GO
CREATE INDEX IDX_FactHealthMetrics_CustomerKey ON FactHealthMetrics(customer_key);
GO
CREATE INDEX IDX_FactDevices_DateKey ON FactDevices(date_key);
GO
CREATE INDEX IDX_FactDevices_CustomerKey ON FactDevices(customer_key);
GO
CREATE INDEX IDX_FactDevices_DeviceKey ON FactDevices(device_key);
GO

-- Index for date-based filtering or grouping (e.g., active assignments over time)
CREATE INDEX IDX_FactCoachAssignment_StartDateKey ON FactCoach_Assignment(start_date_key);
GO
CREATE INDEX IDX_FactCoachAssignment_EndDateKey ON FactCoach_Assignment(end_date_key);
GO

-- Index for coach-based analysis (e.g., coach workload, customer count per coach)
CREATE INDEX IDX_FactCoachAssignment_CoachKey ON FactCoach_Assignment(coach_key);
GO

-- Index for customer-based filtering (e.g., who was coached, repeat assignments)
CREATE INDEX IDX_FactCoachAssignment_CustomerKey ON FactCoach_Assignment(customer_key);
GO



-- First, populate the dimension tables

-- Populate DimDate with a simple date range 
-- This will create over 2,000 non-duplicate dates 
WITH DateSequence AS (
    SELECT CAST('2020-01-01' AS DATE) AS [date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [date])
    FROM DateSequence
    WHERE [date] < '2025-12-31'
)
INSERT INTO [dbo].[DimDate] (
    date_key, date, day, month, year, quarter, is_weekend, month_name
)

SELECT 
    CONVERT(INT, FORMAT([date], 'yyyyMMdd')) AS date_key,
    [date],
    DATEPART(DAY, [date]),
    DATEPART(MONTH, [date]),
    DATEPART(YEAR, [date]),
    DATEPART(QUARTER, [date]),
    CASE WHEN DATEPART(WEEKDAY, [date]) IN (6, 7) THEN 1 ELSE 0 END,
    DATENAME(MONTH, [date])
FROM DateSequence
-- MAXRECURSION 0 is required to generate more than 100 rows.
OPTION (MAXRECURSION 0);
GO

-- Populate DimCustomer
INSERT INTO [dbo].[DimCustomer] (user_id, age, gender, occupation, income_bracket, subscription_type, registration_date)
SELECT
    user_id,
    age,
    gender,
    occupation,
    income_bracket,
    subscription_type,
    registration_date
FROM TechHealthDb.dbo.Customers;
GO

-- Populate DimLocation
INSERT INTO [dbo].[DimLocation] (location_id, city, state, country, region)
SELECT
    gl.geo_id,
    gl.city,
    gl.state,
    gl.country,
    s.region
FROM TechHealthDb.dbo.GeoLocation gl
LEFT JOIN (SELECT DISTINCT region, user_id FROM TechHealthDb.dbo.Sales) s
ON gl.geo_id = (SELECT location_id FROM TechHealthDb.dbo.Customers WHERE user_id = s.user_id);
GO

-- Populate DimDevice
INSERT INTO [dbo].[DimDevice] (device_id, device_type, firmware_version, battery_life_days, 
                     sleep_tracking_enabled, heart_rate_monitoring_enabled, gps_enabled)
SELECT
    device_id,
    device_type,
    firmware_version,
    battery_life_days,
    sleep_tracking_enabled,
    heart_rate_monitoring_enabled,
    gps_enabled
FROM TechHealthDb.dbo.Devices;
GO

-- Populate DimCoach
INSERT INTO [dbo].[DimCoach] (coach_id, first_name, last_name, specialization, experience_years, region)
SELECT
    coach_id,
    first_name,
    last_name,
    specialization,
    experience_years,
    region
FROM TechHealthDb.dbo.Coaches;
GO

-- Populate DimProduct
SELECT * FROM TechHealthDW.DBO.DimProduct
SELECT * FROM TechHealthDb.dbo.[Products]

INSERT INTO [dbo].[DimProduct] (product_id, product_name, product_category)
SELECT 
   product_id,
   product_name,
   product_category
FROM TechHealthDb.dbo.[Products];
GO
    

-- Next, populate the fact tables.
-- Populate FactSales with INT-formatted date_key
INSERT INTO [dbo].[FactSales] (sale_id, date_key, customer_key, product_key, location_key, 
                     unit_price, quantity, discount_applied, total_amount, 
                     payment_method, sales_channel)
SELECT
    s.sale_id,
    CONVERT(INT, FORMAT(s.sale_date, 'yyyyMMdd')) AS date_key,  -- fixed here
    dc.customer_key,
    dp.product_key,
    dl.location_key,
    s.unit_price,
    s.quantity,
    s.discount_applied,
    s.total_amount,
    s.payment_method,
    s.sales_channel
FROM TechHealthDb.dbo.Sales s
JOIN [dbo].[DimCustomer] dc 
    ON s.user_id = dc.user_id
JOIN [dbo].[DimProduct] dp 
    ON s.product_id = dp.product_id
JOIN TechHealthDb.dbo.Customers c 
    ON s.user_id = c.user_id
JOIN [dbo].[DimLocation] dl 
    ON c.location_id = dl.location_id;
GO

SELECT * from TechHealthDW.dbo.FactSales
SELECT * FROM TechHealthDW.dbo.DimCustomer

-- Populate FactHealthMetrics with properly formatted date_key
INSERT INTO [dbo].[FactHealthMetrics] (
    record_id, date_key, customer_key, avg_heart_rate, avg_daily_steps, 
    avg_sleep_hours, avg_deep_sleep_hours, avg_daily_calories, 
    avg_exercise_minutes, avg_stress_level, avg_blood_oxygen, 
    total_active_days, workout_frequency)
SELECT
    hm.record_id,
    CONVERT(INT, FORMAT(hm.month_date, 'yyyyMMdd')) AS date_key,  -- fix applied here
    dc.customer_key,
    hm.avg_heart_rate,
    hm.avg_daily_steps,
    hm.avg_sleep_hours,
    hm.avg_deep_sleep_hours,
    hm.avg_daily_calories,
    hm.avg_exercise_minutes,
    hm.avg_stress_level,
    hm.avg_blood_oxygen,
    hm.total_active_days,
    hm.workout_frequency
FROM TechHealthDb.dbo.HealthMetrics hm
JOIN [dbo].[DimCustomer] dc ON hm.user_id = dc.user_id;
GO

-- Populate FactCoach_Assignment
INSERT INTO [dbo].[FactCoach_Assignment] (
    coach_key,
    customer_key,
    start_date_key,
    end_date_key
)
SELECT 
    dc.coach_key,
    dcu.customer_key,
    ds.date_key AS start_date_key,
    de.date_key AS end_date_key
FROM TechHealthDb.dbo.Coach_Customer cc
JOIN [dbo].[DimCoach] dc ON cc.coach_id = dc.coach_id
JOIN [dbo].[DimCustomer] dcu ON cc.user_id = dcu.user_id
JOIN [dbo].[DimDate] ds ON cc.start_date = ds.date
JOIN [dbo].[DimDate] de ON cc.end_date = de.date;
GO

-- Populate FactDevices
INSERT INTO [dbo].[FactDevices] (date_key, customer_key, device_key, last_sync_date, 
                      sync_frequency_daily, active_hours_daily, total_steps_recorded, 
                      total_workouts_recorded, device_status)
SELECT
    CONVERT(INT, FORMAT(d.purchase_date, 'yyyyMMdd')) AS date_key,
    dc.customer_key,
    dd.device_key,
    d.last_sync_date,
    d.sync_frequency_daily,
    d.active_hours_daily,
    d.total_steps_recorded,
    d.total_workouts_recorded,
    d.device_status
FROM TechHealthDb.dbo.Devices d
JOIN [dbo].[DimCustomer]  dc ON d.user_id = dc.user_id
JOIN [dbo].[DimDevice] dd ON d.device_id = dd.device_id;
GO

SELECT * FROM [dbo].FactSales

