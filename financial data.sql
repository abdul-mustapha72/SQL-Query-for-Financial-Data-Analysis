--Preview the data
SELECT 
  * 
FROM 
  Case_Data 

--To show all column names and data types
SELECT 
  COLUMN_NAME, 
  DATA_TYPE 
FROM 
  INFORMATION_SCHEMA.COLUMNS 
WHERE 
  TABLE_NAME = 'Case_Data' 
  
--Dropping columns with high percentage of missing data
ALTER TABLE 
  Case_Data 
DROP COLUMN 
  mths_since_last_major_derog, 
  annual_inc_joint, 
  dti_joint, 
  mths_since_last_delinq 
  
  --Dropping columns that won'b be useful for analysis which includes
  -- emp_title: lots of unique values
  -- issue_d: loans issued in 2015 only
  -- last_credit_pull_d:last credit pull  of 2016 only 
  -- last_pymnt_d: last payment date for 2015 and 2016 only
  -- next_pymnt_d
  -- id : Unique for each row and since there are no join operations for this analysis, it is not useful
  -- Member id: Same reason above
  -- purpose: Same as title, Title seems a bit more detailed
ALTER TABLE 
  Case_Data 
DROP COLUMN 
  emp_title, 
  issue_d, 
  last_credit_pull_d, 
  last_pymnt_d, 
  next_pymnt_d, 
  id, 
  member_id, 
  purpose 
  
  --Preview Columns left
SELECT 
  TOP 1000 * 
FROM 
  Case_Data 
  
 -- update the employment lenght column to only include digits 
UPDATE 
  Case_Data 
SET 
  emp_length = LEFT(emp_length, 
    CHARINDEX(' ', emp_length + ' ') -1) 
WHERE 
  CHARINDEX(' ', emp_length + ' ') > 0;

UPDATE 
  Case_Data 
SET 
  emp_length = REPLACE(emp_length, '<', '<1') 
WHERE 
  CHARINDEX('<', emp_length) > 0;
-- Change initial list status column to a  more understanble form
UPDATE 
  Case_Data 
SET 
  initial_list_status = CASE 
	WHEN initial_list_status = 'w' THEN 'whole' 
	WHEN initial_list_status = 'f' THEN 'fractional' 
	ELSE 'No Status' 
END;
  
  -- Check for values that does not correlate or match other values in the column
SELECT 
  DISTINCT emp_length 
FROM 
  Case_Data 
    -- Delete rows that has different values from the listed ones below as it affects other columns too
DELETE FROM 
  Case_Data 
WHERE 
  emp_length NOT IN (
    '1', '2', '3', '4', '5', '6', '7', '8', 
    '9', '10', '10+', '<1') 

SELECT 
  DISTINCT home_ownership, 
  count (*) 
FROM 
  Case_Data 
GROUP BY 
  home_ownership 

SELECT 
  DISTINCT verification_status 
FROM 
  Case_Data 

SELECT 
  DISTINCT loan_status 
FROM 
  Case_Data 

SELECT 
  DISTINCT title, 
  COUNT(*) 
FROM 
  Case_Data 
GROUP BY 
  title 

DELETE FROM 
  Case_Data 
WHERE 
  title NOT IN (
    'Debt consolidation', 'Credit card refinancing', 
    'Business', 'Home improvement', 
    'Other', 'Vacation', 'Green loan', 
    'Medical expenses', 'Major purchase', 
    'Home buying', 'Moving and relocation', 
    'Car financing') 
SELECT 
  DISTINCT initial_list_status 
FROM 
  Case_Data 

SELECT 
  DISTINCT application_type 
FROM 
  Case_Data 

SELECT 
  DISTINCT total_rec_late_fee 
FROM 
  Case_Data 
SELECT 
  * 
FROM 
  Case_Data

--Extract the year from earliest_cr_line column

ALTER TABLE Case_Data
ADD Year_of_earliest_cr_line INT;

UPDATE Case_Data
SET Year_of_earliest_cr_line = TRY_CAST(RIGHT(earliest_cr_line, 2) AS INT)
WHERE CHARINDEX('-', earliest_cr_line) > 0;

--Convert to standard year format i.e. YYYY
UPDATE Case_Data
SET Year_of_earliest_cr_line = 
    CASE 
        WHEN Year_of_earliest_cr_line BETWEEN 25 AND 99 THEN CONCAT('19', Year_of_earliest_cr_line)
        ELSE CONCAT('200', Year_of_earliest_cr_line)
    END;
--Remove additional Zero from the 2012, 2011 and 2010
UPDATE Case_Data
SET Year_of_earliest_cr_line = 
    CASE 
		WHEN Year_of_earliest_cr_line = '20012' THEN '2012'
		WHEN Year_of_earliest_cr_line = '20011' THEN '2011'
		WHEN Year_of_earliest_cr_line = '20010' THEN '2010'
        ELSE Year_of_earliest_cr_line
    END;
--Preview Changes
	SELECT DISTINCT Year_of_earliest_cr_line
	FROM Case_Data
	ORDER BY 1 DESC

	SELECT *
	FROM Case_Data