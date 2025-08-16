# HealthSure Clinics – Reducing Appointment No-Shows

Analyzing **110K+ healthcare appointments** to uncover the drivers of missed visits and deliver **actionable strategies** to improve attendance.  
This project shows a **real-world analytics engagement** — from database design to a **stakeholder-ready deliverable** — demonstrating both **technical execution** and **business impact**.

---

## 📌 Table of Contents
1. [Background and Project Context](#1-background-and-project-context)
2. [Business Problem](#2-data-structure-overview)
3. [Executive Summary](#3-executive-summary)
4. [Insights Deep Dive](#4-insights-deep-dive)
5. [Recommendations](#5-recommendations)
6. [Key Visuals](#6-key-visuals-insert-screenshots)
7. [Technical Implementation](#7-technical-implementation)
8. [Caveats & Assumptions](#8-caveats--assumptions)
9. [Business Impact](#9-business-impact)

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
  - `date_dim` – Calendar and time-based attributes  

> ![HealthSure Appointments ERD](ERD_HealthSure_Appointments_Dashboard_PNG.png)

---

## 3. Executive Summary
After peaking in late 2022, attendance rates remain critically low (~20%).  

**Key Findings:**  
- **Geographic Hotspots:** Santa Martha (84.2% no-show), Tabuazeiro (81.7%)  
- **Demographic Risks:** Older patients (60–79) → 85% miss rate; diabetic/hypertensive patients → 82%+ miss rate  
- **Time-of-Day Effect:** Mornings (7–9 a.m.) → ~83% miss rate; evenings → ~70%  
- **Wait Time Effect:** No-shows wait ~9 days longer on average  
- **Loyalty Gap:** Only 39% return for repeat visits  
- **Reminder Weakness:** Single SMS reminders have minimal effect; multiple touchpoints perform better  

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
1. **Target Top 3 Neighbourhoods** – Transport support, flexible scheduling, multi-touch reminders.  
2. **Condition-Specific Outreach** – Pre-book follow-ups for older/chronic patients before they leave the clinic.  
3. **Rebalance Appointment Slots** – Move ~15% of morning slots to evening.  
4. **Reduce Wait Times** – Cap at 14 days for high-risk groups.  
5. **Build a Loyalty Program** – Priority booking & follow-up for returning patients.  
6. **Redesign Reminders** – Test frequency, timing, and format to boost attendance.  

---

## 6. Key Visuals *(insert screenshots)*
- Attendance by Neighbourhood – High-risk hotspot map  
- No-Show Trends by Time of Day – AM vs PM performance  
- Wait Time Impact – Scatterplot of lead days vs attendance  
- Demographic Breakdown – Age, gender, chronic conditions  

> *(Add actual screenshots in `assets/` folder and link here)*

---

## 7. Technical Implementation
- **SQL (MySQL):** Data cleaning, indexing, star schema design  
- **Data Enrichment:** Mapping locations to regions, zones, and socioeconomic classes  
- **Power BI:** Branded dashboard with mobile-friendly navigation  
- **Storytelling Framework:** AND–BUT–THEREFORE applied for insight presentation  

> *(Insert link to live Power BI dashboard if available)*

---

## 8. Caveats & Assumptions
- Data is historical and may not reflect recent operational changes  
- Some patient data (e.g., chronic conditions) is self-reported  
- Socioeconomic levels based on neighbourhood averages  

---

## 9. Business Impact
Implementing these changes could:  
- Recover **thousands of missed visits annually**  
- Improve **operational efficiency & staff utilisation**  
- Enhance **equity outcomes** in underserved communities  
