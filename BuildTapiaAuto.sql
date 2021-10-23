--Created by Gabriel Lopez 
--INFO 3240 Project Phase I
--Peer Reviewed by Simona Kidane
--04/27/2021
--
--Building Tapia Auto Sales DB
IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE NAME = N'TapiaAutoSales')
	CREATE DATABASE TapiaAutoSales
GO
USE TapiaAutoSales
--
-- Alter the path so the script can find the CSV files
--
DECLARE
	@data_path NVARCHAR(256);
SELECT @data_path = 'C:\Tapia Auto Sales Project\New Data\';
--
-- Delete existing tables
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'SALES_VEHICLE'
       )
	DROP TABLE SALES_VEHICLE;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'SALE'
       )
	DROP TABLE SALE;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'CUSTOMER'
       )
	DROP TABLE CUSTOMER;
--

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'VEHICLE'
       )
	DROP TABLE VEHICLE;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'EMPLOYEE_HISTORY'
       )
	DROP TABLE EMPLOYEE_HISTORY;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'EMPLOYEE'
       )
	DROP TABLE EMPLOYEE;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'EMPLOYEE_TYPE'
       )
	DROP TABLE EMPLOYEE_TYPE;
--
IF EXISTS(

	SELECT *
	FROM sys.tables
	WHERE NAME = N'VEHICLE_TYPE'
       )
	DROP TABLE VEHICLE_TYPE;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'VENDOR'
       )
	DROP TABLE VENDOR;

--CREATE TABLES 
--
CREATE TABLE VENDOR
(
	VendorID  			INT CONSTRAINT pk_vendor PRIMARY KEY,
    [Name] 				NVARCHAR(25) CONSTRAINT nn_vend_first_name NOT NULL,
    StreetAddress		NVARCHAR(30) CONSTRAINT nn_vend_last_name NOT NULL,
    City				NVARCHAR(25)  CONSTRAINT nn_vend_city NOT NULL,
    [State]  			NVARCHAR(2) CONSTRAINT nn_vend_state NOT NULL,
	Zipcode				NVARCHAR(11) CONSTRAINT nn_vend_zipcode NOT NULL, 
    PhoneNumber  		NVARCHAR(15) CONSTRAINT nn_vend_phone NOT NULL,
	Email				NVARCHAR(30)
);
--
CREATE TABLE VEHICLE_TYPE
(
	VehicleTypeID  		   INT CONSTRAINT pk_vehicle_type PRIMARY KEY,
    TypeName			   NVARCHAR(20) CONSTRAINT nn_type_name NOT NULL,
	TypeDescription		   NVARCHAR(100)
);
--
CREATE TABLE EMPLOYEE_TYPE
	(EmployeeTypeID		INT CONSTRAINT pk_employee_type PRIMARY KEY,
	 TypeName			NVARCHAR(30) CONSTRAINT nn_type_name NOT NULL
	);
--
CREATE TABLE EMPLOYEE
	(EmployeeID			INT CONSTRAINT pk_employee_id PRIMARY KEY,
	FirstName			NVARCHAR(25) CONSTRAINT nn_employee_first_name NOT NULL,
	LastName			NVARCHAR(25) CONSTRAINT nn_employee_last_name NOT NULL,
	StreetAddress		NVARCHAR(50) CONSTRAINT nn_emp_street_address NOT NULL,
    City 				NVARCHAR(30) CONSTRAINT nn_emp_city NOT NULL,
    [State]  			NVARCHAR(2) CONSTRAINT nn_emp_state NOT NULL,
    Zipcode  			NVARCHAR(11) CONSTRAINT nn_emp_zipcode NOT NULL,
	PhoneNumber			NVARCHAR(14) CONSTRAINT nn_emp_phone NOT NULL CONSTRAINT un_employee_mobile_phone UNIQUE,
	DOB					DATE CONSTRAINT nn_dob NOT NULL,
	HireDate			DATE CONSTRAINT nn_hire_date NOT NULL
	
	);
--
CREATE TABLE EMPLOYEE_HISTORY
	(EmployeeTypeID		INT,
	EmployeeID			INT,
	StartDate			DATE CONSTRAINT nn_begin_date NOT NULL,
	EndDate				DATE,
	CONSTRAINT pk_employee_type_history PRIMARY KEY (EmployeeTypeID, EmployeeID, StartDate),
	CONSTRAINT fk_employee_type_id FOREIGN KEY (EmployeeTypeID) REFERENCES EMPLOYEE_TYPE(EmployeeTypeID),
	CONSTRAINT fk_employee_id FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEE(EmployeeID)
	);
	
--
CREATE TABLE VEHICLE
(
	VIN 				NVARCHAR(17) CONSTRAINT pk_vehicle PRIMARY KEY,
    Make   				NVARCHAR(25) CONSTRAINT nn_vehicle_name NOT NULL,
    Model				NVARCHAR(25) CONSTRAINT nn_vehicle_model NOT NULL,
    [Year] 				INT CONSTRAINT ck_vehicle_year CHECK ([Year] >= 1950) NOT NULL,
    MPG  				FLOAT,
    Color  				NVARCHAR(10) CONSTRAINT nn_vehicle_color NOT NULL,
    Doors  				INT CONSTRAINT ck_vehicle_door CHECK (Doors BETWEEN 2 AND 4) NOT NULL,
	Milage				INT DEFAULT 0 NOT NULL,
	AskingPrice			MONEY CONSTRAINT ck_asking_price CHECK (AskingPrice >= 1000 AND AskingPrice <= 200000) NOT NULL,
	VehicleTypeID  		INT CONSTRAINT fk_vehicle_type FOREIGN KEY REFERENCES VEHICLE_TYPE (VehicleTypeID),
	VendorID			INT CONSTRAINT fk_vendor_id FOREIGN KEY REFERENCES VENDOR (VendorID),
	ShipInDate			DATE CONSTRAINT nn_ship_date NOT NULL
);
--
CREATE TABLE CUSTOMER
(
	CustomerID  		INT CONSTRAINT pk_customer PRIMARY KEY,
    FirstName 			NVARCHAR(25) CONSTRAINT nn_cust_first_name  NOT NULL,
	LastName 			NVARCHAR(25) CONSTRAINT nn_cust_last_name NOT NULL,
	Income				MONEY NOT NULL,
	DOB					DATE CONSTRAINT nn_dob NOT NULL,
    StreetAddress		NVARCHAR(50) CONSTRAINT nn_cust_street_address NOT NULL,
    City 				NVARCHAR(30) CONSTRAINT nn_cust_city NOT NULL,
    [State] 			NVARCHAR(2) CONSTRAINT nn_cust_state NOT NULL,
    Zipcode  			NVARCHAR(11) CONSTRAINT nn_cust_zipcode NOT NULL,
    PhoneNumber  		NVARCHAR(15) CONSTRAINT nn_cust_phone NOT NULL CONSTRAINT un_customer_phone UNIQUE
);
--
CREATE TABLE SALE
(
	SaleID 			INT CONSTRAINT pk_sale_id PRIMARY KEY,
    SaleDate 		DATE CONSTRAINT nn_sale_date NOT NULL, 
	CustomerID		INT CONSTRAINT fk_sale__customer FOREIGN KEY REFERENCES CUSTOMER (CustomerID),
	EmployeeID		INT	CONSTRAINT fk_employee FOREIGN KEY REFERENCES EMPLOYEE (EmployeeID)
);

--
CREATE TABLE SALES_VEHICLE
(
	SaleID	   INT NOT NULL,
	VIN		   NVARCHAR(17) NOT NULL, 
	SalesPrice MONEY CONSTRAINT ck_sales_price CHECK (SalesPrice >= 1000 AND SalesPrice <= 200000) NOT NULL,
	CONSTRAINT pk_sales_vehicle_id PRIMARY KEY (SaleID, VIN),
	CONSTRAINT fk_sales_veh_sales_id FOREIGN KEY (SaleID) REFERENCES SALE(SaleID),
	CONSTRAINT fk_sales_veh_vin FOREIGN KEY (VIN) REFERENCES VEHICLE(VIN)

);

-- Load table data
--
EXECUTE (N'BULK INSERT VENDOR FROM ''' + @data_path + N'VendorData.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK,
	FIRSTROW=2 
	);
');
--
EXECUTE (N'BULK INSERT VEHICLE_TYPE FROM ''' + @data_path + N'VehicleTypeData.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK,
	FIRSTROW=2 
	);
');
--
EXECUTE (N'BULK INSERT EMPLOYEE_TYPE FROM ''' + @data_path + N'EmployeeTypeData.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK,
	FIRSTROW=2 
	);
');
--
EXECUTE (N'BULK INSERT EMPLOYEE FROM ''' + @data_path + N'EmployeeData.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK,
	FIRSTROW=2 
	);
');
--
EXECUTE (N'BULK INSERT EMPLOYEE_HISTORY FROM ''' + @data_path + N'EmployeeHistoryData.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK,
	FIRSTROW=2 
	);
');
--
EXECUTE (N'BULK INSERT VEHICLE FROM ''' + @data_path + N'VehicleData(new).csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK,
	FIRSTROW=2 
	);
');
--
EXECUTE (N'BULK INSERT CUSTOMER FROM ''' + @data_path + N'CustomerData(new).csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK,
	FIRSTROW=2 
	);
');
--
EXECUTE (N'BULK INSERT SALE FROM ''' + @data_path + N'SalesData.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	TABLOCK,
	FIRSTROW=2 
	);
');
--
EXECUTE (N'BULK INSERT SALES_VEHICLE FROM ''' + @data_path + N'SalesVehicle(new).csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	KEEPIDENTITY,
	TABLOCK,
	FIRSTROW=2 
	);
');
--
-- List table names and row counts for confirmation
--
SET NOCOUNT ON
SELECT 'CUSTOMER' AS "Table",	COUNT(*) AS "Rows"	FROM CUSTOMER				UNION
SELECT 'VENDOR',				COUNT(*)			FROM VENDOR					UNION
SELECT 'EMPLOYEE',				COUNT(*)			FROM EMPLOYEE				UNION
SELECT 'EMPLOYEE_TYPE',			COUNT(*)			FROM EMPLOYEE_TYPE			UNION
SELECT 'EMPLOYEE_HISTORY',		COUNT(*)			FROM EMPLOYEE_HISTORY		UNION
SELECT 'VEHICLE',				COUNT(*)			FROM VEHICLE				UNION
SELECT 'SALES_VEHICLE',			COUNT(*)			FROM SALES_VEHICLE			UNION
SELECT 'SALE',					COUNT(*)			FROM SALE					UNION
SELECT 'VEHICLE_TYPE',			COUNT(*)			FROM VEHICLE_TYPE            
ORDER BY 1;
SET NOCOUNT OFF
GO

