
-- Data validation: total admissions and coverage period
SELECT
  COUNT(*) AS total_admissions,
  MIN(admission_date) AS first_admission,
  MAX(admission_date) AS last_admission
FROM admissions;

-- Data quality check: discharge date should not be before admission date
SELECT *
FROM admissions
WHERE discharge_date < admission_date;


-- Hospital utilization by admission type
SELECT
  admission_type,
  COUNT(*) AS total_admissions
FROM admissions
GROUP BY admission_type
ORDER BY total_admissions DESC;


-- Average length of stay by admission type
SELECT
  admission_type,
  AVG(discharge_date - admission_date) AS avg_los
FROM admissions
WHERE discharge_date IS NOT NULL
GROUP BY admission_type
ORDER BY avg_los DESC;





-- Monthly admission trends
SELECT
  DATE_TRUNC('month', admission_date) AS month,
  COUNT(*) AS total_admissions
FROM admissions
GROUP BY month
ORDER BY month;





-- Admission type distribution as percentage
SELECT
  admission_type,
  COUNT(*) AS admissions,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
  ) AS percentage
FROM staging_hospital_data
GROUP BY admission_type;




-- Admissions with longest length of stay
SELECT
  name,
  medical_condition,
  (discharge_date - admission_date) AS los_days
FROM staging_hospital_data
ORDER BY los_days DESC
LIMIT 10;



-- Admissions by age group
SELECT
  CASE
    WHEN age < 18 THEN '0-17'
    WHEN age BETWEEN 18 AND 40 THEN '18-40'
    WHEN age BETWEEN 41 AND 60 THEN '41-60'
    ELSE '60+'
  END AS age_group,
  COUNT(*) AS admissions
FROM staging_hospital_data
GROUP BY age_group
ORDER BY admissions DESC;





-- Disease distribution across age groups
SELECT
  medical_condition,
  CASE
    WHEN age < 18 THEN '0-17'
    WHEN age BETWEEN 18 AND 40 THEN '18-40'
    WHEN age BETWEEN 41 AND 60 THEN '41-60'
    ELSE '60+'
  END AS age_group,
  COUNT(*) AS admissions
FROM staging_hospital_data
GROUP BY medical_condition, age_group
ORDER BY medical_condition, admissions DESC;







-- Most frequent diagnoses by admission volume
SELECT
  d.diagnosis_name,
  COUNT(*) AS admission_count
FROM diagnoses d
JOIN admissions a
ON d.admission_id = a.admission_id
GROUP BY d.diagnosis_name
ORDER BY admission_count DESC;





-- Admission distribution by gender and age group
SELECT
  p.gender,
  CASE
    WHEN p.age < 19 THEN '0-18'
    WHEN p.age BETWEEN 19 AND 40 THEN '19-40'
    WHEN p.age BETWEEN 41 AND 60 THEN '41-60'
    ELSE '60+'
  END AS age_group,
  COUNT(*) AS admissions
FROM patients p
JOIN admissions a
ON p.patient_id = a.patient_id
GROUP BY p.gender, age_group
ORDER BY age_group;



-- Patients with multiple admissions (readmission proxy)
SELECT
  p.patient_name,
  COUNT(a.admission_id) AS admission_count
FROM patients p
JOIN admissions a
ON p.patient_id = a.patient_id
GROUP BY p.patient_name
HAVING COUNT(a.admission_id) > 1
ORDER BY admission_count DESC;




-- Medication usage patterns by medical condition
SELECT
  medical_condition,
  medication,
  COUNT(*) AS usage_count
FROM staging_hospital_data
GROUP BY medical_condition, medication
ORDER BY usage_count DESC;



-- Distribution of diagnostic test results
SELECT
  test_results,
  COUNT(*) AS result_count
FROM staging_hospital_data
GROUP BY test_results
ORDER BY result_count DESC;



--Data Quality & Integrity Checks
-- Check duplicate primary keys
SELECT encounter_id, COUNT(*)
FROM encounters
GROUP BY encounter_id
HAVING COUNT(*) > 1;

-- Missing patient link in encounters
SELECT COUNT(*) AS missing_patient_links
FROM encounters
WHERE patient_id IS NULL;

-- Invalid encounter duration
SELECT *
FROM encounters
WHERE stop_time < start_time;

-- Conditions without encounter link
SELECT COUNT(*) AS conditions_without_encounter
FROM conditions c
LEFT JOIN encounters e
	ON c.encounter_id = e.encounter_id
WHERE e.encounter_id IS NULL;

-- Medications without encounter link
SELECT COUNT(*) AS meds_without_encounter
FROM medications m
LEFT JOIN encounters e
	ON m.encounter_id = e.encounter_id
WHERE e.encounter_id IS NULL;

-- Procedures without encounter link
SELECT COUNT(*) AS procedures_without_encounter
FROM procedures p
LEFT JOIN encounters e
	ON p.encounter_id = e.encounter_id
WHERE e.encounter_id IS NULL;

--Patient Demographics & Population Overview

-- Alive vs deceased patients
SELECT
	COUNT(*) FILTER (WHERE deathdate IS NULL) AS alive_patients,
	COUNT(*) FILTER (WHERE deathdate IS NOT NULL) AS deceased_patients
FROM patients;

-- Gender distribution
SELECT gender, COUNT(*) AS patient_count
FROM patients
GROUP BY gender
ORDER BY patient_count DESC;

-- Age group distribution
SELECT
	CASE
		WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) < 18 THEN 'Child'
		WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 18 AND 35 THEN 'Young Adult'
		WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 36 AND 55 THEN 'Adult'
		ELSE 'Senior'
	END AS age_group,
	COUNT(*) AS patient_count
FROM patients
WHERE birthdate IS NOT NULL
GROUP BY age_group
ORDER BY patient_count DESC;

--Utilization & Patient Visit Behavior

-- Top 10 most frequent visitors
SELECT patient_id, COUNT(*) AS visit_count
FROM encounters
GROUP BY patient_id
ORDER BY visit_count DESC
LIMIT 10;

-- Average visits per patient
SELECT ROUND(AVG(visit_count), 2) AS avg_visits_per_patient
FROM (
	SELECT patient_id, COUNT(*) AS visit_count
	FROM encounters
	GROUP BY patient_id
) t;

-- Patient utilization segmentation
SELECT utilization_group, COUNT(*) AS patient_count
FROM (
	SELECT
		patient_id,
		CASE
			WHEN COUNT(*) <= 10 THEN 'Low'
			WHEN COUNT(*) <= 50 THEN 'Medium'
			WHEN COUNT(*) <= 200 THEN 'High'
			ELSE 'Super Utilizer'
		END AS utilization_group
	FROM encounters
	GROUP BY patient_id
) t
GROUP BY utilization_group
ORDER BY patient_count DESC;

-- Avg visits by age group

WITH visits AS (
	SELECT patient_id, COUNT(*) AS visit_count
	FROM encounters
	GROUP BY patient_id
),
ages AS (
	SELECT
		patient_id,
		CASE
			WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) < 18 THEN 'Child'
			WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) <= 35 THEN 'Young Adult'
			WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) <= 55 THEN 'Adult'
			ELSE 'Senior'
		END AS age_group
	FROM patients
	WHERE birthdate IS NOT NULL
)
SELECT
	a.age_group,
	ROUND(AVG(v.visit_count), 1) AS avg_visits
FROM visits v
JOIN ages a USING(patient_id)
GROUP BY a.age_group
ORDER BY avg_visits DESC;

--Disease Burden & Clinical Insights

-- Top 10 most common diagnoses
SELECT description, COUNT(*) AS diagnosis_count
FROM conditions
GROUP BY description
ORDER BY diagnosis_count DESC
LIMIT 10;

-- Multimorbidity patients (3+ conditions)
SELECT patient,
	COUNT(DISTINCT code) AS condition_count
FROM conditions
GROUP BY patient
HAVING COUNT(DISTINCT code) >= 3
ORDER BY condition_count DESC;

-- Condition burden by age group
WITH age_table AS (
	SELECT
		patient_id,
		CASE
			WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) < 18 THEN 'Child'
			WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 18 AND 35 THEN 'Young Adult'
			WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 36 AND 60 THEN 'Adult'
			ELSE 'Senior'
		END AS age_group
	FROM patients
	WHERE birthdate IS NOT NULL
)
SELECT
	a.age_group,
	c.description AS condition,
	COUNT(*) AS condition_events
FROM conditions c
JOIN age_table a
	ON c.patient = a.patient_id
GROUP BY a.age_group, c.description
ORDER BY condition_events DESC
LIMIT 15;

--Financial & Claims Cost Analysis

-- Top 10 most expensive conditions (avg cost)
SELECT
	c.description AS condition,
	ROUND(AVG(e.total_claim_cost)::numeric, 2) AS avg_claim_cost,
	COUNT(*) AS total_encounters
FROM conditions c
JOIN encounters e
	ON c.encounter_id = e.encounter_id
GROUP BY c.description
HAVING COUNT(*) >= 50
ORDER BY avg_claim_cost DESC
LIMIT 10;


-- Total cost and coverage by payer
SELECT
	payer,
	ROUND(SUM(total_claim_cost)::numeric, 2) AS total_cost,
	ROUND(SUM(payer_coverage)::numeric, 2) AS covered_amount,
	ROUND(
		SUM(payer_coverage) / NULLIF(SUM(total_claim_cost), 0) * 100
	, 2) AS coverage_percent
FROM encounters
GROUP BY payer
ORDER BY total_cost DESC;

-- High cost frequent patients (risk population)
SELECT
	patient_id,
	COUNT(*) AS visit_count,
	ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_cost
FROM encounters
GROUP BY patient_id
HAVING COUNT(*) > 5
	AND AVG(total_claim_cost) > 10000
ORDER BY avg_cost DESC
LIMIT 10;

--Provider Performance & Resource Utilization

-- Top providers by encounter volume
SELECT
	provider,
	COUNT(*) AS total_encounters,
	ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_claim_cost
FROM encounters
GROUP BY provider
ORDER BY total_encounters DESC
LIMIT 10;
-- Provider cost ranking
SELECT
	provider,
	COUNT(*) AS total_encounters,
	ROUND(SUM(total_claim_cost)::numeric, 2) AS total_cost,
	ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_cost
FROM encounters
GROUP BY provider
ORDER BY total_cost DESC
LIMIT 10;

--Length of Stay (LOS) & Operational Efficiency

-- Average LOS overall
SELECT
	ROUND(AVG(EXTRACT(EPOCH FROM (stop_time - start_time))/3600)::numeric, 2) AS avg_los_hours
FROM encounters
WHERE stop_time IS NOT NULL;

-- LOS by encounter type
SELECT
	encounter_type,
	ROUND(AVG(EXTRACT(EPOCH FROM (stop_time - start_time))/3600)::numeric, 2) AS avg_los_hours
FROM encounters
WHERE stop_time IS NOT NULL
GROUP BY encounter_type
ORDER BY avg_los_hours DESC;

-- LOS by provider (resource efficiency signal)
SELECT
	provider,
	COUNT(*) AS encounters,
	ROUND(AVG(EXTRACT(EPOCH FROM (stop_time - start_time))/3600)::numeric, 2) AS avg_los_hours
FROM encounters
WHERE stop_time IS NOT NULL
GROUP BY provider
ORDER BY avg_los_hours DESC
LIMIT 10;


--Readmission / Revisit Risk (30-Day Window)

-- Visits with <=30 days gap (possible readmission indicator)
WITH visit_gaps AS (
	SELECT
		patient_id,
		start_time,
		LAG(start_time) OVER(
			PARTITION BY patient_id
			ORDER BY start_time
		) AS previous_visit
	FROM encounters
)
SELECT
	patient_id,
	start_time,
	previous_visit,
	start_time - previous_visit AS gap_between_visits
FROM visit_gaps
WHERE previous_visit IS NOT NULL
	AND start_time - previous_visit <= INTERVAL '30 days'
ORDER BY gap_between_visits;

--Patients with multiple readmission-like events
WITH visit_gaps AS (
	SELECT
		patient_id,
		start_time,
		LAG(start_time) OVER(
			PARTITION BY patient_id
			ORDER BY start_time
		) AS previous_visit
	FROM encounters
)
SELECT
	patient_id,
	COUNT(*) AS revisit_events_30_days
FROM visit_gaps
WHERE previous_visit IS NOT NULL
	AND start_time - previous_visit <= INTERVAL '30 days'
GROUP BY patient_id
ORDER BY revisit_events_30_days DESC
LIMIT 10;

-- Medication & Procedure Burden (Clinical Workload)

-- Most common medications
SELECT description, COUNT(*) AS rx_count
FROM medications
GROUP BY description
ORDER BY rx_count DESC
LIMIT 15;

-- Polypharmacy patients
SELECT patient, COUNT(*) AS med_count
FROM medications
GROUP BY patient
ORDER BY med_count DESC
LIMIT 10;

--Most common procedures
SELECT description, COUNT(*) AS procedure_count
FROM procedures
GROUP BY description
ORDER BY procedure_count DESC
LIMIT 15;

--Condition → medication workload relationship
SELECT
	c.description AS condition,
	COUNT(m.code) AS medication_orders,
	COUNT(DISTINCT c.encounter_id) AS encounters_with_condition
FROM conditions c
JOIN medications m
	ON c.encounter_id = m.encounter_id
GROUP BY c.description
HAVING COUNT(m.code) >= 100
ORDER BY medication_orders DESC
LIMIT 10;


-- Condition → procedure workload relationship
SELECT
	c.description AS condition,
	COUNT(p.code) AS procedure_count,
	COUNT(DISTINCT c.encounter_id) AS encounters_with_condition
FROM conditions c
JOIN procedures p
	ON c.encounter_id = p.encounter_id
GROUP BY c.description
HAVING COUNT(p.code) >= 50
ORDER BY procedure_count DESC
LIMIT 10;

--Patient demographics age + gender

CREATE OR REPLACE VIEW vw_patient_demographics AS
SELECT
    patient_id,
    gender,
    race,
    ethnicity,
    birthdate,
    CASE
        WHEN birthdate IS NULL THEN NULL
        ELSE EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate))
    END AS age,
    CASE
        WHEN birthdate IS NULL THEN 'Unknown'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) < 18 THEN 'Child'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) BETWEEN 36 AND 55 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,
    CASE
        WHEN deathdate IS NULL THEN 'Alive'
        ELSE 'Deceased'
    END AS vital_status
FROM patients;


--Encounter Summary (LOS + Cost)
CREATE OR REPLACE VIEW vw_encounter_summary AS
SELECT
    encounter_id,
    patient_id,
    provider,
    payer,
    encounter_type,
    start_time,
    stop_time,
    description AS encounter_description,
    total_claim_cost,
    payer_coverage,
    (total_claim_cost - payer_coverage) AS patient_out_of_pocket,
    CASE
        WHEN stop_time IS NULL OR start_time IS NULL THEN NULL
        WHEN stop_time < start_time THEN NULL
        ELSE ROUND(EXTRACT(EPOCH FROM (stop_time - start_time)) / 3600, 2)
    END AS los_hours
FROM encounters;



--Monthly Encounter Trends
CREATE OR REPLACE VIEW vw_monthly_encounters AS
SELECT
    DATE_TRUNC('month', start_time) AS month,
    COUNT(*) AS total_encounters,
    ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_claim_cost,
    ROUND(SUM(total_claim_cost)::numeric, 2) AS total_claim_cost
FROM encounters
GROUP BY DATE_TRUNC('month', start_time)
ORDER BY month;


--Patient Utilization (Visits per Patient)
CREATE OR REPLACE VIEW vw_patient_utilization AS
SELECT
    patient_id,
    COUNT(*) AS visit_count,
    ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_claim_cost,
    ROUND(SUM(total_claim_cost)::numeric, 2) AS total_claim_cost
FROM encounters
GROUP BY patient_id;

-- Utilization Segmentation (Low / Medium / High)
CREATE OR REPLACE VIEW vw_utilization_segments AS
SELECT
    patient_id,
    COUNT(*) AS visit_count,
    CASE
        WHEN COUNT(*) <= 10 THEN 'Low'
        WHEN COUNT(*) <= 50 THEN 'Medium'
        WHEN COUNT(*) <= 200 THEN 'High'
        ELSE 'Super Utilizer'
    END AS utilization_group
FROM encounters
GROUP BY patient_id;



--Diagnosis Frequency (Disease Burden)
CREATE OR REPLACE VIEW vw_top_conditions AS
SELECT
    description AS condition,
    COUNT(*) AS condition_events,
    COUNT(DISTINCT patient) AS patient_count
FROM conditions
GROUP BY description;


--Cost by Condition (Most Expensive Diagnoses)
CREATE OR REPLACE VIEW vw_condition_cost AS
SELECT
    c.description AS condition,
    COUNT(*) AS total_encounters,
    ROUND(AVG(e.total_claim_cost)::numeric, 2) AS avg_claim_cost,
    ROUND(SUM(e.total_claim_cost)::numeric, 2) AS total_claim_cost
FROM conditions c
JOIN encounters e
    ON c.encounter_id = e.encounter_id
GROUP BY c.description;



-- Provider Performance (Volume + Cost)
CREATE OR REPLACE VIEW vw_provider_performance AS
SELECT
    provider,
    COUNT(*) AS total_encounters,
    ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_claim_cost,
    ROUND(SUM(total_claim_cost)::numeric, 2) AS total_claim_cost
FROM encounters
GROUP BY provider;


--Payer Coverage Analysis
CREATE OR REPLACE VIEW vw_payer_coverage AS
SELECT
    payer,
    COUNT(*) AS total_encounters,
    ROUND(SUM(total_claim_cost)::numeric, 2) AS total_claim_cost,
    ROUND(SUM(payer_coverage)::numeric, 2) AS total_covered,
    ROUND(
        SUM(payer_coverage) / NULLIF(SUM(total_claim_cost), 0) * 100
    , 2) AS coverage_percent
FROM encounters
GROUP BY payer;


--Length of Stay by Encounter Type

CREATE OR REPLACE VIEW vw_los_by_encounter_type AS
SELECT
    encounter_type,
    COUNT(*) AS total_encounters,
    ROUND(AVG(EXTRACT(EPOCH FROM (stop_time - start_time)) / 3600)::numeric, 2) AS avg_los_hours
FROM encounters
WHERE stop_time IS NOT NULL
  AND stop_time >= start_time
GROUP BY encounter_type;


-- Readmission / Revisit within 30 days

CREATE OR REPLACE VIEW vw_revisit_30_days AS
WITH visit_gaps AS (
    SELECT
        patient_id,
        encounter_id,
        start_time,
        LAG(start_time) OVER (
            PARTITION BY patient_id
            ORDER BY start_time
        ) AS previous_visit
    FROM encounters
)
SELECT
    patient_id,
    encounter_id,
    start_time,
    previous_visit,
    (start_time - previous_visit) AS gap_between_visits,
    CASE
        WHEN previous_visit IS NOT NULL
         AND start_time - previous_visit <= INTERVAL '30 days'
        THEN 1 ELSE 0
    END AS revisit_30_flag
FROM visit_gaps;




-- Polypharmacy Patients

CREATE OR REPLACE VIEW vw_polypharmacy AS
SELECT
    patient,
    COUNT(*) AS medication_count,
    COUNT(DISTINCT encounter_id) AS encounter_count
FROM medications
GROUP BY patient;



-- Procedure Volume by Type

CREATE OR REPLACE VIEW vw_procedure_volume AS
SELECT
    description AS procedure,
    COUNT(*) AS procedure_count,
    ROUND(AVG(base_cost)::numeric, 2) AS avg_base_cost,
    ROUND(SUM(base_cost)::numeric, 2) AS total_base_cost
FROM procedures
GROUP BY description;
