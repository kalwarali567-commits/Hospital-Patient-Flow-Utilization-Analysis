CREATE TABLE staging_hospital_data (
	name TEXT,
	age INT,
	gender TEXT,
	blood_type TEXT,
	medical_condition TEXT,
	admission_date DATE,
	doctor TEXT,
	hospital TEXT,
	admission_type TEXT,
	discharge_date DATE,
	medication TEXT,
	test_results TEXT
);


CREATE TABLE patients (
patient_id SERIAL PRIMARY KEY,
patient_name TEXT,
age INT,
gender TEXT,
blood_type TEXT
);

CREATE TABLE admissions (
admission_id SERIAL PRIMARY KEY,
patient_id INT,
admission_date DATE,
discharge_date DATE,
admission_type TEXT,
hospital TEXT,
doctor TEXT,
FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

CREATE TABLE diagnoses (
diagnosis_id SERIAL PRIMARY KEY,
admission_id INT,
diagnosis_name TEXT,
medication TEXT,
test_results TEXT,
FOREIGN KEY (admission_id) REFERENCES admissions(admission_id)
);

INSERT INTO patients (patient_name, age, gender, blood_type)
SELECT DISTINCT
	name,
	age,
	gender,
	blood_type
FROM staging_hospital_data;

INSERT INTO admissions (
	patient_id,
	admission_date,
	discharge_date,
	admission_type,
	hospital,
	doctor
)
SELECT
	p.patient_id,
	s.admission_date,
	s.discharge_date,
	s.admission_type,
	s.hospital,
	s.doctor
FROM staging_hospital_data s
JOIN patients p
ON s.name = p.patient_name;
	
INSERT INTO diagnoses (
	admission_id,
	diagnosis_name,
	medication,
	test_results
)
SELECT 
	a.admission_id,
	s.medical_condition,
	s.medication,
	s.test_results
FROM staging_hospital_data s
JOIN patients p ON s.name = p.patient_name
JOIN admissions a ON p.patient_id = a.patient_id
AND s.admission_date = a.admission_date;

INSERT INTO patients (patient_name, age, gender, blood_type)
SELECT DISTINCT
	name,
	age,
	gender,
	blood_type
FROM staging_hospital_data;

INSERT INTO admissions (
	patient_id,
	admission_date,
	discharge_date,
	admission_type,
	hospital,
	doctor
)
SELECT
	p.patient_id,
	s.admission_date,
	s.discharge_date,
	s.admission_type,
	s.hospital,
	s.doctor
FROM staging_hospital_data s
JOIN patients p
ON s.name = p.patient_name;
	
INSERT INTO diagnoses (
	admission_id,
	diagnosis_name,
	medication,
	test_results
)
SELECT 
	a.admission_id,
	s.medical_condition,
	s.medication,
	s.test_results
FROM staging_hospital_data s
JOIN patients p ON s.name = p.patient_name
JOIN admissions a ON p.patient_id = a.patient_id
AND s.admission_date = a.admission_date;

CREATE TABLE patients (
    patient_id TEXT PRIMARY KEY,
    birthdate DATE,
    deathdate DATE,
    ssn TEXT,
    drivers TEXT,
    passport TEXT,
    prefix TEXT,
    first TEXT,
    last TEXT,
    suffix TEXT,
    maiden TEXT,
    marital TEXT,
    race TEXT,
    ethnicity TEXT,
    gender TEXT,
    birthplace TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    zip TEXT,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    healthcare_expenses NUMERIC,
    healthcare_coverage NUMERIC
);




CREATE TABLE providers (
    id TEXT PRIMARY KEY,
    organization TEXT,
    name TEXT,
    gender TEXT,
    speciality TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip TEXT,
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION,
    utilization INTEGER
);


CREATE TABLE encounters (
    encounter_id TEXT PRIMARY KEY,
    start_time TIMESTAMPTZ,
    stop_time TIMESTAMPTZ,
    patient_id TEXT,
    organization TEXT,
    provider TEXT,
    payer TEXT,
    encounter_type TEXT,
    code TEXT,
    description TEXT,
    base_encounter_cost NUMERIC,
    total_claim_cost NUMERIC,
    payer_coverage NUMERIC,
    reasoncode TEXT,
	reasondescription TEXT
);



CREATE TABLE conditions (
	start TIMESTAMPTZ,
	stop TIMESTAMPTZ,
	patient TEXT,
	encounter_id TEXT,
	code TEXT,
	description TEXT
);

CREATE TABLE medications (
	start TIMESTAMPTZ,
	stop TIMESTAMPTZ,
	patient TEXT,
	payer TEXT,
	encounter_id TEXT,
	code TEXT,
	description TEXT,
	base_cost NUMERIC,
	payer_coverage NUMERIC,
	dispenses INTEGER,
	totalcost NUMERIC,
	reasoncode TEXT,
	reasondescription TEXT
);

CREATE TABLE procedures (
	start TIMESTAMPTZ,
	stop TIMESTAMPTZ,
	patient TEXT,
	encounter_id TEXT,
	code TEXT,
	description TEXT,
	base_cost NUMERIC,
	reasoncode TEXT,
	reasondescription TEXT
);

CREATE TABLE observations (
	obs_time TIMESTAMPTZ,
	patient TEXT,
	encounter_id TEXT,
	category TEXT,
	code TEXT,
	description TEXT,
	value TEXT,
	units TEXT,
	type TEXT
);


CREATE TABLE claims (
	id TEXT PRIMARY KEY,
	patientid TEXT,
	providerid TEXT,
	primarypatientinsuranceid TEXT,
	secondarypatientinsuranceid TEXT,
	departmentid TEXT,
	patientdepartmentid TEXT,
	diagnosis1 TEXT,
	diagnosis2 TEXT,
	diagnosis3 TEXT,
	diagnosis4 TEXT,
	diagnosis5 TEXT,
	diagnosis6 TEXT,
	diagnosis7 TEXT,
	diagnosis8 TEXT,
	referringproviderid	TEXT,
	appointmentid TEXT,
	currentillnessdate DATE,
	servicedate DATE,
	supervisingproviderid TEXT,
	status1 TEXT,
	status2 TEXT,
	statusp TEXT,
	outstanding1 NUMERIC,
	outstanding2 NUMERIC,
	outstandingp NUMERIC,
	lastbilleddate1 DATE,
	lastbilleddate2 DATE,
	lastbilleddatep DATE,
	healthcareclaimtypeid1 TEXT,
	healthcareclaimtypeid2 TEXT	
);
