# Hospital-Patient-Flow-Utilization-Analysis

# 🏥 Hospital Patient Flow & Utilization Analysis (SQL + Power BI)

## 📌 Project Overview

This project analyzes hospital admission and utilization data to understand patient flow, resource usage, and cost patterns.

The goal is to identify operational trends that can help hospital management improve workload distribution, control costs, and optimize patient care.

This project combines admission-level data with encounter-level utilization data to simulate real-world healthcare analytics work.

---

## 🎯 Business Problem

Hospitals need to manage patient volume, resource utilization, and financial performance efficiently.

Key questions addressed in this project:

- Which admission types result in longer hospital stays?
- What factors are driving higher hospital costs?
- Are there signs of inefficiencies in patient care (e.g., revisits)?
- Which conditions contribute most to hospital workload?

---

## 🧠 Business Objectives

- Analyze patient admissions and trends over time  
- Evaluate length of stay (LOS) across admission types  
- Understand encounter types and their impact on resources  
- Identify cost drivers using claim data  
- Monitor 30-day revisit cases as a quality indicator  
- Detect basic data quality issues affecting analysis  

---

## 🗂️ Dataset Overview

The project uses two main datasets:

### 1. Admission Data
### 2. Utilization / Encounter Data


👉 Used to analyze cost and resource utilization.

---

## 🛠️ Tools & Technologies

- **PostgreSQL (SQL)** – Data cleaning, transformation, and analysis  
- **Power BI** – Dashboard creation and visualization  
- **Python (basic)** – Data validation (optional)  
- **GitHub** – Project documentation  

---

## 🧹 Data Cleaning & Validation

To ensure reliable analysis, the following steps were performed:

- Handled missing values (NULLs) in key fields  
- Detected and removed duplicate records  
- Identified invalid dates (e.g., discharge before admission)  
- Standardized categorical values (e.g., admission types)  

These steps helped improve data accuracy before analysis.

---

## 📊 Key Metrics & Visuals

The dashboard focuses on a small set of high-impact visuals:

- Patient volume by department  
- Monthly admission trends  
- Average length of stay (LOS)  
- Encounter type distribution (inpatient vs outpatient)  
- Total claim cost (monthly trend)  
- KPI cards:
  - Total encounters  
  - 30-day revisit rate  

---

## 🔍 Key Insights

- Patient admissions are unevenly distributed, with certain encounter_type handling higher workload, indicating the need for better resource allocation.  

- Some admission types have longer average length of stay, suggesting higher resource consumption and possible operational inefficiencies.  

- Total claim costs tend to increase with higher patient volume and longer stays, showing that both demand and treatment duration are key cost drivers.  

- Inpatient encounters contribute more to hospital resource usage compared to outpatient visits.  

- The presence of 30-day revisit cases may indicate gaps in treatment effectiveness or discharge planning.  

---

## 🧠 Conclusion

This project demonstrates how combining admission data with utilization data can provide a more complete view of hospital operations.

By analyzing patient flow, length of stay, and cost patterns, hospitals can identify areas for improving efficiency, reducing costs, and enhancing patient care.

---

## 🚀 Future Improvements

- Add department-level cost vs LOS comparison  
- Improve readmission analysis with more precise logic  
- Include provider-level performance insights  
- Enhance dashboard interactivity  

---

## 👤 Author

**Ali**  
Healthcare Data Analyst (SQL | Power BI | Healthcare Analytics)
