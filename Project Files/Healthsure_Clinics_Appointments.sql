DROP DATABASE IF EXISTS `Healthsure_Appointments`;
CREATE DATABASE `Healthsure_Appointments`;
USE `Healthsure_Appointments`;

-- Import dataset via Table Data Import Wizard and Create a staging table for transformation
CREATE TABLE stg_appointments AS
SELECT * FROM appointments_raw;

-- Confirm it worked
SELECT *
FROM stg_appointments;

SELECT COUNT(*) FROM appointments_raw;
SELECT COUNT(*) FROM stg_appointments;

/*
=============================================
TRANSFORMATION PLAN – STAGING TABLE
=============================================

OBJECTIVE:
Clean and prepare the raw data for analysis by transforming key columns into business-friendly formats and creating a dimensional model.

STEPS:
1. ✅ Check for duplicate rows (exact and partial) and remove if necessary.
	2. ✅ Recode binary columns to 'Yes'/'No' (SocialWelfare, Hypertension, Diabetes, Alcoholism, Handicap etc.).
3. ✅ Convert date fields (ScheduledDay, AppointmentDay) into:
    - Date
    - DateTime
4. ⏳ Clean Neighbourhood & Alter data types for better performance and consistency
5. ⏳ Identify and recreate fact vs. dimension fields for star schema. Also create surrogate keys for dimension tables:
    - Fact Table: Appointment_Fact
    - Dimensions: Patient, Neighbourhood
6. ⏳ Check for inconsistencies using joins.
7. ⏳ Normalize and split staging table into Fact and Dimension tables.
8. ⏳ Add indexes and constraints for referential integrity.
*/

-- 1. ✅ Check for duplicate rows (exact and partial) and remove if necessary.
SELECT COUNT(*) AS TotalRows, COUNT(DISTINCT PatientID, AppointmentID, Gender, ScheduledDay, AppointmentDay,
        Age, Neighbourhood, SocialWelfare, Hypertension, Diabetes, 
        Alcoholism, Handicap, SMS_Received, Appointment_Status) AS DistinctRows
FROM stg_appointments;

-- Checks
SELECT AppointmentID, COUNT(*) AS Count
FROM stg_appointments
GROUP BY AppointmentID
HAVING Count > 1;

SELECT PatientId, COUNT(*) AS VisitCount
FROM stg_appointments
GROUP BY PatientId
ORDER BY VisitCount DESC;
-- Result: There are repeat visits but no duplicates established yet

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY
               AppointmentID,
               PatientID,
               Gender,
               ScheduledDay,
               AppointmentDay,
               Age,
               Neighbourhood,
               SocialWelfare,
               Hypertension,
               Diabetes,
               Alcoholism,
               SMS_received,
               Handicap,
               Appointment_Status
           ) AS rn
    FROM stg_appointments
) AS sub
WHERE rn > 1;
-- > Result: NO DUPLICATES '0 row(s) returned'

-- 2. ✅ Recode binary columns to 'Yes'/'No' (SocialWelfare, Hypertension, Diabetes, Alcoholism, Handicap etc.).
-- a.) Firstly, verify that all values are either 0 or 1
SELECT DISTINCT SocialWelfare
FROM stg_appointments 
WHERE SocialWelfare NOT IN (0, 1);

SELECT DISTINCT Hypertension 
FROM stg_appointments 
WHERE Hypertension NOT IN (0, 1);

SELECT DISTINCT Diabetes 
FROM stg_appointments 
WHERE Diabetes NOT IN (0, 1);

SELECT DISTINCT Alcoholism 
FROM stg_appointments 
WHERE Alcoholism NOT IN (0, 1);

SELECT DISTINCT Handicap 
FROM stg_appointments 
WHERE Handicap NOT IN (0, 1);

-- > Result: ZERO ROWS RETURNED FOR EACH
-- b.) Recode binary columns to 'Yes'/'No'
SELECT SocialWelfare, 
CASE 
	WHEN SocialWelfare = 1 THEN 'Yes'
	ELSE 'No'
END AS SocialWelfare
FROM stg_appointments;

-- Recode SocialWelfare
ALTER TABLE stg_appointments
MODIFY SocialWelfare VARCHAR(3);

UPDATE stg_appointments
SET SocialWelfare = CASE 
	WHEN SocialWelfare = 1 THEN 'Yes'
	ELSE 'No'
END;

-- Check update
SELECT SocialWelfare
FROM stg_appointments;

-- Recode Hypertension
ALTER TABLE stg_appointments
MODIFY Hypertension VARCHAR(3);

UPDATE stg_appointments
SET Hypertension = CASE
	WHEN Hypertension = 1 THEN 'Yes'
	ELSE 'No'
END;

-- Recode Diabetes
ALTER TABLE stg_appointments
MODIFY Diabetes VARCHAR(3);

UPDATE stg_appointments
SET Diabetes = CASE
	WHEN Diabetes = 1 THEN 'Yes'
    ELSE 'No'
END;

-- Recode Alcoholism
ALTER TABLE stg_appointments
MODIFY Alcoholism VARCHAR(3);

UPDATE stg_appointments
SET Alcoholism = CASE
	WHEN Alcoholism = 1 THEN 'Yes'
    ELSE 'No'
END;

-- Recode Handicap
ALTER TABLE stg_appointments
MODIFY Handicap VARCHAR(3);

UPDATE stg_appointments
SET Handicap = CASE
	WHEN Handicap = 1 THEN 'Yes'
    ELSE 'No'
END;

/*
3. ✅ Convert date fields (ScheduledDay, AppointmentDay) into:
    - Date
    - DateTime
*/

-- Create new Date columns
ALTER TABLE stg_appointments
ADD COLUMN ScheduledDate DATE,
ADD COLUMN AppointmentDate DATE;

SELECT
ScheduledDay,
STR_TO_DATE(LEFT(ScheduledDay, 10), '%Y-%m-%d') AS ScheduledDate,
AppointmentDay,
STR_TO_DATE(LEFT(AppointmentDay, 10), '%Y-%m-%d') AS AppointmentDate
FROM stg_appointments;

-- Strip off the timezones and update the new date tables
UPDATE stg_appointments
SET ScheduledDate = STR_TO_DATE(LEFT(ScheduledDay, 10), '%Y-%m-%d'),
    AppointmentDate = STR_TO_DATE(LEFT(AppointmentDay, 10), '%Y-%m-%d');
    
SELECT
ScheduledDay,
ScheduledDate,
AppointmentDay,
AppointmentDate
FROM stg_appointments;

-- Create new DateTime columns
ALTER TABLE stg_appointments
ADD COLUMN ScheduledDateTime DATETIME,
ADD COLUMN AppointmentDateTime DATETIME;

SELECT
ScheduledDay, STR_TO_DATE(ScheduledDay, '%Y-%m-%dT%H:%i:%sZ'),
AppointmentDay, STR_TO_DATE(AppointmentDay, '%Y-%m-%dT%H:%i:%sZ')
FROM stg_appointments;

UPDATE stg_appointments
SET
  ScheduledDateTime = STR_TO_DATE(ScheduledDay, '%Y-%m-%dT%H:%i:%sZ'),
  AppointmentDateTime = STR_TO_DATE(AppointmentDay, '%Y-%m-%dT%H:%i:%sZ');

-- Check time stamps
SELECT ScheduledDateTime, AppointmentDateTime, TIME(ScheduledDateTime) AS ScheduledTime, TIME(AppointmentDateTime) AS AppointmentTime
FROM appointments_fact
ORDER BY 2;

-- 4. ⏳ Clean Neighbourhood & Alter data types for better performance and consistency
ALTER TABLE stg_appointments
MODIFY Gender VARCHAR(10),
MODIFY Neighbourhood VARCHAR(100),
MODIFY Appointment_Status VARCHAR(10);

-- Clean Neighbourhood column
	-- First, create a helper function for proper case:
DELIMITER $$

CREATE FUNCTION ProperCase(str VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
  DECLARE c CHAR(1);
  DECLARE s VARCHAR(255);
  DECLARE i INT DEFAULT 1;
  DECLARE bool INT DEFAULT 1;

  SET s = LOWER(str);

  WHILE i <= CHAR_LENGTH(str) DO 
    SET c = SUBSTRING(s, i, 1);
    IF bool = 1 AND c REGEXP '[a-z]' THEN
      SET s = CONCAT(
        LEFT(s, i - 1),
        UPPER(c),
        SUBSTRING(s, i + 1)
      );
      SET bool = 0;
    ELSEIF c = ' ' THEN
      SET bool = 1;
    END IF;
    SET i = i + 1;
  END WHILE;

  RETURN s;
END$$

DELIMITER ;

UPDATE stg_appointments
SET Neighbourhood = ProperCase(Neighbourhood);

SELECT DISTINCT s.Neighbourhood, l.Neighbourhood
FROM stg_appointments s
JOIN location_dim l ON
s.Neighbourhood = l.Neighbourhood
WHERE s.Neighbourhood <> l.Neighbourhood;

/*
5. ⏳ Identify and recreate fact vs. dimension fields for star schema. Also create surrogate keys for dimension tables:
    - Fact Table: Appointment_Fact
    - Dimensions: Patient, Date, Neighbourhood
*/
-- Create Location_Dim from Neighbourhood
	-- Check for duplicates
SELECT NeighbourHood, COUNT(*)
FROM stg_appointments
GROUP BY Neighbourhood
ORDER BY 1;
-- RESULT: 'DA PENHA' & 'JARDIM DA PENHA' seem to be the same
-- ACTION: CONSOLIDATE BOTH INTO 'JARDIM DA PENHA'

UPDATE stg_appointments
SET Neighbourhood = 'JARDIM DA PENHA'
WHERE Neighbourhood = 'DA PENHA';

/*
UPON EXTENSIVE SEARCH, 'DA PENHA' & 'JARDIM DA PENHA' HAVE BEEN REVEALED TO BE DIFFERENT NEIGHBOURHOODS. TO CORRECT THIS ERROR, WE WILL:
RE-UPDATE THE NEIGHBOURHOOD COLUMN FROM THE RAW APPOINMENTS_RAW TABLE INTO THE STG_APPOINTMENTS TABLE USING APPOINTMENTID AS THE UNIQUE IDENTIFIER
*/
-- RECHECK BOTH TABLES TO CONFIRM APPOINTMENTID IS NOT DUPLICATED
SELECT *
FROM (
	SELECT AppointmentID, COUNT(*) AS Dup
	FROM appointments_raw 
	GROUP BY AppointmentID
    ) AS Sub
WHERE Dup != 1;

SELECT *
FROM (
    SELECT AppointmentID, COUNT(*) AS Dup
    FROM stg_appointments 
    GROUP BY AppointmentID
) AS Sub
WHERE Dup != 1;

-- Re-Update stg_appointments with correct Neighbourhood values from appointments_raw
UPDATE stg_appointments AS stg
JOIN appointments_raw AS raw
  ON stg.AppointmentID = raw.AppointmentID
SET stg.Neighbourhood = raw.Neighbourhood;
-- RESULT:  "Lost connection to MySQL server during query" (Error 2013)
-- typically happens because the query takes too long or processes too many rows at once, causing the connection to timeout or crash.

-- FIX
CREATE TEMPORARY TABLE temp_neighbourhoods AS
SELECT AppointmentID, Neighbourhood FROM appointments_raw;

UPDATE stg_appointments AS stg
JOIN temp_neighbourhoods AS temp
  ON stg.AppointmentID = temp.AppointmentID
SET stg.Neighbourhood = temp.Neighbourhood;
-- RESULT: UNSUCCESSFUL

-- Add index to stg_appointments
CREATE INDEX idx_stg_appt_id 
ON stg_appointments(AppointmentID);

-- Add index to appointments_raw
CREATE INDEX idx_raw_appt_id 
ON appointments_raw(AppointmentID);
-- RESULT: SUCCESSFUL

-- REupdate stg_appointments with correct Neighbourhood values from appointments_raw
UPDATE stg_appointments AS stg
JOIN appointments_raw AS raw
  ON stg.AppointmentID = raw.AppointmentID
SET stg.Neighbourhood = raw.Neighbourhood;
-- RESULT: SUCCESSFUL - '2217 row(s) affected Rows matched: 110527  Changed: 2217  Warnings: 0

-- Create Location Dim Table and import .csv document into table
CREATE TABLE location_dim (
    LocationKey INT AUTO_INCREMENT PRIMARY KEY,
    Neighbourhood VARCHAR(100) NOT NULL,
    AdministrativeRegion VARCHAR(100) NOT NULL,
    UNIQUE (Neighbourhood)
);

-- Add Zones and Socioeconomic status to table
ALTER TABLE location_dim
ADD COLUMN Zone VARCHAR(20),
ADD COLUMN SocioeconomicStatus VARCHAR(20);

-- Create Temporary Table with All Columns, import csv, update location_dim table, & drop temp table
CREATE TABLE temp_location_update (
  LocationKey INT,
  Neighbourhood VARCHAR(100),
  AdministrativeRegion VARCHAR(100),
  Zone VARCHAR(20),
  SocioeconomicStatus VARCHAR(20)
);

UPDATE location_dim l
JOIN temp_location_update t ON l.LocationKey = t.LocationKey
SET
  l.Zone = t.Zone,
  l.SocioeconomicStatus = t.SocioeconomicStatus;

DROP TABLE temp_location_update;

-- Script to confirm there are no inconsistencies to create the dim table
SELECT DISTINCT
    a.PatientID,
    a.Gender AS Gender_A, b.Gender AS Gender_B,
    a.Neighbourhood AS Neigh_A, b.Neighbourhood AS Neigh_B,
    a.SocialWelfare AS SW_A, b.SocialWelfare AS SW_B
FROM stg_appointments a
JOIN stg_appointments b
  ON a.PatientID = b.PatientID
  AND (
    a.Gender <> b.Gender OR
    a.Neighbourhood <> b.Neighbourhood OR
    a.SocialWelfare <> b.SocialWelfare
  );
-- RESULT: NO INCONSISTENCY FOUND

-- Create Patient Dim Table
CREATE TABLE patient_dim (
  PatientID BIGINT PRIMARY KEY,
  Gender VARCHAR(3),
  LocationKey INT,
  SocialWelfare VARCHAR(3),
  FOREIGN KEY (LocationKey) REFERENCES location_dim(LocationKey)
);

INSERT INTO patient_dim (PatientID, Gender, LocationKey, SocialWelfare)
SELECT 
    a.PatientID,
    a.Gender,
    l.LocationKey,
    a.SocialWelfare
FROM (
    SELECT DISTINCT PatientID, Gender, Neighbourhood, SocialWelfare
    FROM stg_appointments
) AS a
JOIN location_dim AS l
  ON l.Neighbourhood = a.Neighbourhood;
  
-- Validation of results using the staging table and dimension tables
SELECT PatientId, Neighbourhood, COUNT(Neighbourhood)
FROM stg_appointments
GROUP BY Neighbourhood;

SELECT 
    a.PatientID,
    l.Neighbourhood,
    COUNT(*) AS AppointmentCount
FROM stg_appointments a
JOIN patient_dim p ON a.PatientID = p.PatientID
JOIN location_dim l ON p.LocationKey = l.LocationKey
GROUP BY l.Neighbourhood;
-- RESULT: SUCCESSFUL

SELECT LocationKey
FROM stg_appointments;

-- Update stg_appointments table with LocationKey
-- Add a new column to hold LocationKey
ALTER TABLE stg_appointments ADD COLUMN LocationKey INT;

CREATE INDEX idx_neighbourhood_location_dim ON location_dim (Neighbourhood);


-- Create appointments_fact table
CREATE TABLE appointments_fact (
  AppointmentID INT PRIMARY KEY,
  PatientID BIGINT,
  LocationKey INT,
  ScheduledDate DATE,
  AppointmentDate DATE,
  Age INT,
  Hypertension VARCHAR(3),
  Diabetes VARCHAR(3),
  Alcoholism VARCHAR(3),
  SMS_received INT,
  Handicap VARCHAR(3),
  Appointment_Status VARCHAR(10),
  ScheduledDateTime DATETIME,
  AppointmentDateTime DATETIME,
  FOREIGN KEY (PatientID) REFERENCES patient_dim(PatientID),
  FOREIGN KEY (LocationKey) REFERENCES location_dim(LocationKey)
);

INSERT INTO appointments_fact (
  AppointmentID,
  PatientID,
  LocationKey,
  ScheduledDate,
  AppointmentDate,
  Age,
  Hypertension,
  Diabetes,
  Alcoholism,
  SMS_received,
  Handicap,
  Appointment_Status,
  ScheduledDateTime,
  AppointmentDateTime
)
SELECT
  s.AppointmentID,
  s.PatientID,
  l.LocationKey,
  s.ScheduledDate,
  s.AppointmentDate,
  s.Age,
  s.Hypertension,
  s.Diabetes,
  s.Alcoholism,
  s.SMS_received,
  s.Handicap,
  s.Appointment_Status,
  s.ScheduledDateTime,
  s.AppointmentDateTime
FROM stg_appointments s
JOIN location_dim l
  ON s.Neighbourhood = l.Neighbourhood;


-- 6. ⏳ Check for inconsistencies using joins.
	-- CHECK FOR PATIENT DATA INCONCISTENCY USING JOINS
SELECT DISTINCT
    a.PatientID,
    a.Gender AS Gender_A, b.Gender AS Gender_B,
    a.Age AS Age_A, b.Age AS Age_B,
    a.Neighbourhood AS Neigh_A, b.Neighbourhood AS Neigh_B,
    a.Handicap AS Handicap_A, b.Handicap AS Handicap_B
FROM stg_appointments a
JOIN stg_appointments b
  ON a.PatientID = b.PatientID
  AND (
    a.Gender <> b.Gender OR
    a.Age <> b.Age OR
    a.Neighbourhood <> b.Neighbourhood OR
    a.Handicap <> b.Handicap
  );
-- RESULT: 27292 ROWS RETURNED - (IT SEEMS THE HANDICAP ROWS HOLD THE MAJORITY OF INCONSISTENCIES)
-- SEVERITY: MILD

SELECT PatientID, COUNT(DISTINCT Handicap) AS Handicap_Variations
FROM stg_appointments
GROUP BY PatientID
HAVING Handicap_Variations > 1
ORDER BY Handicap_Variations DESC;
-- RESULT: INCONSISTENCIES FOUND (12185 ROWS)

SELECT PatientID, COUNT(DISTINCT Gender) AS Gender_Variations
FROM stg_appointments
GROUP BY PatientID
HAVING Gender_Variations > 1
ORDER BY Gender_Variations DESC;
-- RESULT: NO INCONSISTENCY FOUND

SELECT PatientID, COUNT(DISTINCT Age) AS Age_Variations
FROM stg_appointments
GROUP BY PatientID
HAVING Age_Variations > 1
ORDER BY Age_Variations DESC;
-- RESULT: INCONSISTENCIES FOUND (1168 ROWS)

SELECT PatientID, COUNT(DISTINCT Neighbourhood) AS Neighbourhood_Variations
FROM stg_appointments
GROUP BY PatientID
HAVING Neighbourhood_Variations > 1
ORDER BY Neighbourhood_Variations DESC;
-- RESULT: NO INCONSISTENCY FOUND

SELECT PatientID, COUNT(DISTINCT SocialWelfare) AS SW_Variations
FROM stg_appointments
GROUP BY PatientID
HAVING SW_Variations > 1
ORDER BY SW_Variations DESC;
-- RESULT: NO INCONSISTENCY FOUND

SELECT COUNT(DISTINCT LocationKey) FROM appointments_fact;
-- RESULT: NO INCONSISTENCY FOUND

SELECT ld.Neighbourhood, COUNT(*) AS AppointmentCount
FROM appointments_fact af
JOIN location_dim ld ON af.LocationKey = ld.LocationKey
GROUP BY ld.Neighbourhood
ORDER BY AppointmentCount DESC;
-- RESULT: NO INCONSISTENCY FOUND

SELECT af.PatientID, 
       af.LocationKey AS Fact_LocationKey, pd.LocationKey AS Dim_LocationKey,
       pd.Gender, pd.SocialWelfare
FROM appointments_fact af
JOIN patient_dim pd ON af.PatientID = pd.PatientID
WHERE af.LocationKey <> pd.LocationKey;
-- RESULT: NO INCONSISTENCY FOUND

SELECT 
    af.AppointmentID,
    af.PatientID,
    l.LocationKey AS first_LocationKey,
    af.LocationKey AS second_LocationKey,
    s.Neighbourhood
FROM appointments_fact af
JOIN stg_appointments s ON af.AppointmentID = s.AppointmentID
JOIN location_dim l ON s.Neighbourhood = l.Neighbourhood
WHERE af.LocationKey <> l.LocationKey;
-- RESULT: NO INCONSISTENCY FOUND

-- 8. ⏳ Add indexes and constraints for referential integrity
	-- Some have been added already

CREATE INDEX idx_location_neighbourhood ON location_dim(Neighbourhood);
-- 0 row(s) affected, 1 warning(s): 1831 Duplicate index 'idx_location_neighbourhood' defined on the table 'healthsure_appointments.location_dim'.
-- This is deprecated and will be disallowed in a future release. Records: 0  Duplicates: 0  Warnings: 1

CREATE INDEX idx_fact_patientid ON appointments_fact(PatientID);
-- 0 row(s) affected Records: 0  Duplicates: 0  Warnings: 0

CREATE INDEX idx_fact_locationkey ON appointments_fact(LocationKey);
-- 0 row(s) affected Records: 0  Duplicates: 0  Warnings: 0

-- THE END
