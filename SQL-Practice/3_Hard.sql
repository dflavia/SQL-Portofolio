-- Show all of the patients grouped into weight groups.
-- Show the total amount of patients in each weight group.
-- Order the list by the weight group decending.
-- For example, if they weight 100 to 109 they are placed in the 100 weight group, 110-119 = 110 weight group, etc.

SELECT
	COUNT(*) AS patient_no,
	FLOOR(weight/10) * 10 AS weight_group
FROM patients
GROUP BY weight_group
ORDER BY weight_group DESC


-- Show patient_id, weight, height, isObese from the patients table.
-- Display isObese as a boolean 0 or 1.
-- Obese is defined as weight(kg)/(height(m)2) >= 30.
-- weight is in units kg.
-- height is in units cm.

SELECT
	patient_id,
    weight,
    height,
    CASE
    	WHEN weight/POWER(height/100.0,2) >= 30 THEN 1
        ELSE 0
    END AS IsObese
FROM patients


-- Show patient_id, first_name, last_name, and attending doctor's specialty.
-- Show only the patients who has a diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'
-- Check patients, admissions, and doctors tables for required information.

SELECT
	p.patient_id,
    p.first_name,
    p.last_name,
    d.specialty
FROM patients p
INNER JOIN admissions a ON p.patient_id = a.patient_id
INNER JOIN doctors d ON a.attending_doctor_id = d.doctor_id
WHERE d.first_name = 'Lisa'
AND a.diagnosis = 'Epilepsy'


-- All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
-- The password must be the following, in order:
-- 1. patient_id
-- 2. the numerical length of patient's last_name
-- 3. year of patient's birth_date

SELECT
	DISTINCT a.patient_id,
    CONCAT(a.patient_id, LENGTH(p.last_name), YEAR(p.birth_date)) AS temp_password
FROM patients p
INNER JOIN admissions a ON p.patient_id = a.patient_id


-- Each admission costs $50 for patients without insurance, and $10 for patients with insurance. All patients with an even patient_id have insurance.
-- Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.

SELECT
	has_insurance,
    SUM(cost) AS cost_after_insurance
FROM (
      SELECT
          CASE
              WHEN MOD(patient_id,2) = 0 THEN 'Yes'
              ELSE 'No'
          END AS has_insurance,

          CASE
              WHEN MOD(patient_id,2) = 0 THEN '10'
              ELSE '50'
          END AS cost
      FROM admissions
  	) t
GROUP BY has_insurance


-- Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name

SELECT
	province_name
FROM (
      SELECT
          province_name,
          SUM(CASE
              WHEN gender = 'M' THEN 1
              ELSE NULL
          END) AS gender_M,

          SUM(CASE
              WHEN gender = 'F' THEN 1
              ELSE NULL
          END) AS gender_F
      FROM patients p
      INNER JOIN province_names pr ON p.province_id = pr.province_id
      GROUP BY province_name
  	)
WHERE gender_m > gender_F

-- OR

SELECT
	province_name
FROM patients p
INNER JOIN province_names pr ON p.province_id = pr.province_id
GROUP BY province_name
HAVING
		SUM(CASE WHEN gender = 'M' THEN 1 ELSE NULL END) 
       		>
       	SUM(CASE WHEN gender = 'F' THEN 1 ELSE NULL END)
    

-- We are looking for a specific patient. Pull all columns for the patient who matches the following criteria:
-- First_name contains an 'r' after the first two letters.
-- Identifies their gender as 'F'
-- Born in February, May, or December
-- Their weight would be between 60kg and 80kg
-- Their patient_id is an odd number
-- They are from the city 'Kingston'

SELECT *
FROM patients
WHERE 1=1
	AND first_name LIKE '__r%'
    AND gender = 'F'
    AND MONTH(birth_date) IN (2,5,12)
    AND weight BETWEEN 60 AND 80
    AND MOD(patient_id,2) <> 0
    AND city = 'Kingston'


-- Show the percent of patients that have 'M' as their gender. Round the answer to the nearest hundreth number and in percent form.

SELECT
	CONCAT(ROUND(100.0* COUNT(CASE WHEN gender = 'M' THEN 1 ELSE NULL END) / COUNT(*),2),'%') as percent_of_male_patients
FROM patients


-- For each day display the total amount of admissions on that day. Display the amount changed from the previous date.

SELECT
    admission_date,
    COUNT(*) AS admission_day,
  	COUNT(*) - LAG(COUNT(*)) OVER (PARTITION BY NULL ORDER BY admission_date)
FROM admissions
GROUP BY admission_date


-- Sort the province names in ascending order in such a way that the province 'Ontario' is always on top.

SELECT
	province_name
FROM province_names
ORDER BY (CASE WHEN province_name = 'Ontario' THEN 0 ELSE 1 END), province_name


-- We need a breakdown for the total amount of admissions each doctor has started each year. Show the doctor_id, doctor_full_name, specialty, year, total_admissions for that year.

SELECT
	d.doctor_id,
    CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
    specialty,
    YEAR(admission_date),
    COUNT(*)
FROM admissions a
INNER JOIN doctors d ON a.attending_doctor_id = d.doctor_id
GROUP BY d.doctor_id, YEAR(admission_date)
  	 