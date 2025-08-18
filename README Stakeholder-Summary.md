# HealthSure Clinics – Reducing Appointment No-Shows

*An end-to-end BI project analyzing 110K+ healthcare appointments in Brazil, built with Excel, MySQL, and Power BI to uncover the drivers of missed visits and recommend operational fixes.*

![SQL](https://img.shields.io/badge/SQL-MySQL-blue?logo=mysql&logoColor=white)  ![Excel](https://img.shields.io/badge/Excel-Data%20Preparation-217346?logo=microsoft-excel&logoColor=white)  ![Power BI](https://img.shields.io/badge/BI-PowerBI-F2C811?logo=powerbi&logoColor=black)  ![Data Modeling](https://img.shields.io/badge/Model-Star%20Schema-orange)  ![Status](https://img.shields.io/badge/Project-Completed-brightgreen)
![HealthSure Appointments Dashboard](Project%20Files/HealthSure%20Appointments%20Dashboard%20PNG.png)

Click below to view the Live report

[![View Dashboard](https://img.shields.io/badge/Power%20BI-View%20Report-F2C811?logo=powerbi&logoColor=black)](https://app.powerbi.com/view?r=eyJrIjoiNWU5OGFhMDUtYmYyOS00ZDA3LWFkMDUtYzU0ZDllMDQ0Zjk1IiwidCI6IjNjMzJjMjljLTg1YmEtNDVlZi05YTA2LTkyZmNkNjEwYThkMiJ9)


---

## 📌 Table of Contents
1. [Background and Project Context](#1-background-and-project-context)
2. [Business Problem](#2-data-structure-overview)
3. [Executive Summary](#3-executive-summary)
4. [Insights Deep Dive](#4-insights-deep-dive)
5. [Recommendations](#5-recommendations)
6. [Technical Implementation](#6-technical-implementation)
7. [Caveats & Assumptions](#7-caveats--assumptions)
8. [Business Impact](#8-business-impact)

---

## 1. Background and Project Context
**Company:** HealthSure Clinics (Brazil outpatient network)  
**Stakeholder:** Head of Operations  
**Challenge:** High no-show rates (~80%) are creating operational strain and lost revenue, with attendance stuck near 20%.  
**Goal:** Identify **who**, **where**, and **when** no-shows happen; recommend targeted actions to improve attendance, efficiency, and equity.  

---

## 2. Data Structure Overview
Analysis powered by **110,527 appointment records** enriched with geographic & socioeconomic data.  

**Star Schema Model:**  
- **Fact Table:** `appointments_fact` – Appointment-level data (dates, patient, conditions, attendance status)  
- **Dimensions:**  
  - `patient_dim` – Demographics, social welfare status  
  - `location_dim` – Neighbourhood, administrative region, zone, socioeconomic status  

> ![HealthSure Appointments ERD](Project%20Files/ERD_HealthSure_Appointments_Dashboard_PNG.png)

---

## 3. Executive Summary  

HealthSure Clinics faces a **critical no-show problem**: nearly **8 in 10 appointments are missed**, costing the clinic lost revenue and reducing patient access to care.  

**Key Insights:**  
- 📍 **Geographic Hotspots:** Santa Martha (84.2%) and Tabuazeiro (81.7%) show the worst attendance.  
- 👥 **Demographic Risks:** Older patients (60–79) and those with diabetes/hypertension are most at risk (>82% miss rates).  
- ⏰ **Time-of-Day Effect:** Mornings (7–9 a.m.) show ~83% no-shows; evenings perform better (~70%) but are underutilized.  
- 🕒 **Wait Time Effect:** No-shows waited ~9 days longer (21.5 vs 12.3 days).  
- 🔄 **Loyalty Gap:** Only 39% of patients return for repeat visits.  
- 📲 **Reminder Weakness:** Single SMS reminders are ineffective; multiple touchpoints deliver better results.  

---

## 4. Insights Deep Dive

| Insight | What We Found | Why It Matters |
| --- | --- | --- |
| High-Risk Neighbourhoods | Santa Martha, Tabuazeiro, Jardim da Penha lead in no-show volume & rate | Targeting these 3 could recover **8K+ visits annually** |
| Older Patients | 85% miss rate for 60–79 age group | Age-specific barriers need to be addressed |
| Chronic Conditions | Diabetes: 82.7% miss, Hypertension: 82.6% | These patients often need ongoing follow-up |
| Time-of-Day Effect | AM slots: ~83% miss; PM slots: ~70% miss | Shifting capacity could improve utilisation |
| Wait Time Impact | No-shows wait 21.5 days; attendees wait 12.3 days | Shorter waits = higher attendance |
| Retention | Only 4 in 10 return | Loyalty programs are underused |

---

## 5. Recommendations  

To address these challenges, we recommend a **5-point action plan**:  

1. **Neighborhood Targeting** – Focus first on Santa Martha, Tabuazeiro, and Jardim da Penha with **transport support, flexible scheduling, and multi-touch reminders**.  
2. **Condition-Specific Outreach** – Pre-book follow-ups for older patients and those with chronic illnesses before they leave the clinic.  
3. **Rebalance Appointment Slots** – Shift **~15% of morning slots to evenings** to improve utilization.  
4. **Reduce Wait Times** – Cap waits at **≤14 days** for high-risk patients.  
5. **Build Loyalty & Improve Reminders** – Launch a **priority rebooking program** for past attendees and test **multi-touch reminder strategies** (e.g., SMS + calls).  

*⚡ **Impact:** Implementing these changes could recover **thousands of missed visits annually**, improve operational efficiency, and strengthen equity for vulnerable patient groups.*

---

## 6. Technical Implementation
- **SQL (MySQL):** Data cleaning, indexing, star schema design
- **Data Enrichment:** Mapping locations to regions, zones, and socioeconomic classes
- **Power BI:** Branded dashboard with mobile-friendly navigation
- **Storytelling Framework:** WHAT WE FOUND–WHAT TO DO applied for insight presentation

---

## 7. Caveats & Assumptions
- Data is historical and may not reflect recent operational changes
- Some patient data (e.g., chronic conditions) is self-reported
- Socioeconomic levels based on neighbourhood averages

---

## 8. Business Impact
Implementing these changes could:  
- Recover **thousands of missed visits annually**  
- Improve **operational efficiency & staff utilisation**  
- Enhance **equity outcomes** in underserved communities  
