# Tour Guide Management System  
---

## Cover Page

**Submitted by:**  
Gilat Malka – 213196363  
Shirel Nkaoua – 209692029  

**System Name:**  
Tour Guide Management System  

**Selected Unit:**  
Guided Tour Management  

---

## Table of Contents

- [Phase 1: Design and Build the Database](#phase-1-design-and-build-the-database)
  - [Introduction](#introduction)
  - [System Screens (AI)](#system-screens-ai)
  - [ERD Diagram](#erd-diagram)
  - [DSD Diagram](#dsd-diagram)
  - [Design Decisions](#design-decisions)
  - [Data Insertion](#data-insertion)
  - [Backup and Restore](#backup-and-restore)
  - [Summary](#summary)

- [Phase 2: Advanced SQL and Data Manipulation](#phase-2-advanced-sql-and-data-manipulation)
  - [Introduction](#introduction-1)
  - [Complex SELECT Queries](#complex-select-queries)
  - [Additional SELECT Queries](#additional-select-queries)
  - [DELETE Operations](#delete-operations)
  - [UPDATE Operations](#update-operations)
  - [Constraints using ALTER TABLE](#constraints-using-alter-table)
  - [Transactions: COMMIT and ROLLBACK](#transactions-commit-and-rollback)
  - [Indexes and Performance Analysis](#indexes-and-performance-analysis)
  - [Backup File (Phase 2)](#backup-file-phase-2)
  
- [Phase 3 – Integration and Views](#phase-3--integration-and-views)
  - [Project: Tour Guide Management System](#project-tour-guide-management-system)
  - [1. Introduction](#1-introduction)
  - [2. Received Database Import](#2-received-database-import)
  - [3. Received Department – DSD Diagram](#3-received-department--dsd-diagram)
  - [4. Reverse Engineering Algorithm](#4-reverse-engineering-algorithm)
  - [5. Received Department – ERD Diagram](#5-received-department--erd-diagram)
  - [6. Original Department – ERD Diagram](#6-original-department--erd-diagram)
  - [7. Unified ERD Diagram After Integration](#7-unified-erd-diagram-after-integration)
  - [8. DSD Diagram After Integration](#8-dsd-diagram-after-integration)
  - [9. Integration Decisions](#9-integration-decisions)
    - [9.1 PARTICIPANT Was Merged Into CUSTOMER](#91-participant-was-merged-into-customer)
    - [9.2 TRIP Was Merged Into GUIDEDTOUR](#92-trip-was-merged-into-guidedtour)
    - [9.3 TripID Was Mapped to TourID](#93-tripid-was-mapped-to-tourid)
    - [9.4 BOOKING Was Merged Into REGISTRATION](#94-booking-was-merged-into-registration)
    - [9.5 Payment Records Were Derived From BOOKING](#95-payment-records-were-derived-from-booking)
    - [9.6 Expertise Was Added to GUIDE](#96-expertise-was-added-to-guide)
    - [9.7 LOCATION and LOCATED_IN Were Added](#97-location-and-located_in-were-added)
    - [9.8 Handling Empty PASSES_THROUGH Data](#98-handling-empty-passes_through-data)
    - [9.9 Avoiding Primary Key Conflicts](#99-avoiding-primary-key-conflicts)
    - [9.10 Handling Email Conflicts](#910-handling-email-conflicts)
  - [10. Integration SQL File](#10-integration-sql-file)
  - [11. Main Integration Commands](#11-main-integration-commands)
    - [11.1 Adding Expertise to GUIDE](#111-adding-expertise-to-guide)
    - [11.2 Creating LOCATION](#112-creating-location)
    - [11.3 Creating LOCATED_IN](#113-creating-located_in)
    - [11.4 Inserting Missing Difficulty Levels](#114-inserting-missing-difficulty-levels)
    - [11.5 Merging Received Guides](#115-merging-received-guides)
    - [11.6 Merging Received Routes](#116-merging-received-routes)
    - [11.7 Merging Received Locations](#117-merging-received-locations)
    - [11.8 Creating Route-Location Connections](#118-creating-route-location-connections)
    - [11.9 Merging Received Participants Into CUSTOMER](#119-merging-received-participants-into-customer)
    - [11.10 Merging Received Trips Into GUIDEDTOUR](#1110-merging-received-trips-into-guidedtour)
    - [11.11 Merging Received Bookings Into REGISTRATION](#1111-merging-received-bookings-into-registration)
    - [11.12 Creating Payments From Received Bookings](#1112-creating-payments-from-received-bookings)
  - [12. Integration Verification](#12-integration-verification)
    - [12.1 Row Count Verification](#121-row-count-verification)
    - [12.2 Full Integration Query](#122-full-integration-query)
  - [13. Views](#13-views)
  - [14. View 1 – Tour Guide Department View](#14-view-1--tour-guide-department-view)
    - [14.1 View Description](#141-view-description)
    - [14.2 View Creation](#142-view-creation)
    - [14.3 Select From View 1](#143-select-from-view-1)
    - [14.4 Query 1.1 – Tours With Available Seats](#144-query-11--tours-with-available-seats)
    - [14.5 Query 1.2 – Most Popular Guided Tours](#145-query-12--most-popular-guided-tours)
  - [15. View 2 – Route Management Department View](#15-view-2--route-management-department-view)
    - [15.1 View Description](#151-view-description)
    - [15.2 View Creation](#152-view-creation)
    - [15.3 Select From View 2](#153-select-from-view-2)
    - [15.4 Query 2.1 – Most Active Routes](#154-query-21--most-active-routes)
    - [15.5 Query 2.2 – Long or Expensive Routes](#155-query-22--long-or-expensive-routes)
  - [16. Updated Backup File](#16-updated-backup-file)
  - [17. Summary](#17-summary)
  
- [Phase 4: Programming with PL/pgSQL](#phase-4-programming-with-plpgsql)
  - [1. Function: fn_calculate_customer_payment_status](#1-function-fn_calculate_customer_payment_status)
    - [Description](#description)
    - [Features used](#features-used)
  - [2. Function: fn_get_route_tour_details_by_difficulty](#2-function-fn_get_route_tour_details_by_difficulty)
    - [Description](#description-1)
    - [Features used](#features-used-1)
  - [3. Procedure: pr_assign_optimal_guide_to_tour](#3-procedure-pr_assign_optimal_guide_to_tour)
    - [Description](#description-2)
    - [Features used](#features-used-2)
  - [4. Procedure: pr_apply_discount_to_tour_participants](#4-procedure-pr_apply_discount_to_tour_participants)
    - [Description](#description-3)
    - [Features used](#features-used-3)
  - [5. Trigger: trg_update_registration_payment_status](#5-trigger-trg_update_registration_payment_status)
    - [Description](#description-4)
    - [Features used](#features-used-4)
  - [6. Trigger: trg_audit_tour_changes](#6-trigger-trg_audit_tour_changes)
    - [Description](#description-5)
    - [Features used](#features-used-5)
  - [7. Main Block 1: financials_and_discounts](#7-main-block-1-financials_and_discounts)
    - [Description](#description-6)
    - [Invokes](#invokes)
  - [8. Main Block 2: mainProgram2](#8-main-block-2-mainprogram2)
    - [Description](#description-7)
    - [Invokes](#invokes-1)
  - [9. Alter Table / Additional Table](#9-alter-table--additional-table)
    - [Description](#description-8)
  - [Backup File (Phase 4)](#backup-file-phase-4)
    - [Contents](#contents)
    - [Purpose](#purpose)
  - [Summary](#summary-1)

- [Stage 5 – Full Stack Web Application & Database Integration](#stage-5--full-stack-web-application--database-integration)
  - [Overview](#overview)
  - [Technologies Used](#technologies-used)
    - [Frontend](#frontend)
    - [Backend](#backend)
    - [Database](#database)
  - [Main System Features](#main-system-features)
    - [Dashboard](#dashboard)
      - [Features](#features)
    - [Guides Management](#guides-management)
      - [Features](#features-1)
      - [Create Guide](#create-guide)
    - [Routes Management](#routes-management)
      - [Features](#features-2)
      - [Create Route](#create-route)
    - [Tours Management](#tours-management)
      - [Features](#features-3)
      - [Create Tour](#create-tour)
    - [Customers Management](#customers-management)
      - [Features](#features-4)
      - [Create Customer](#create-customer)
    - [Registrations Management](#registrations-management)
      - [Features](#features-5)
      - [Create Registration](#create-registration)
    - [Payments Management](#payments-management)
      - [Features](#features-6)
      - [Record Payment](#record-payment)
      - [Trigger Integration](#trigger-integration)
    - [Locations Management](#locations-management)
      - [Features](#features-7)
      - [Create Location](#create-location)
    - [Analytics Module](#analytics-module)
      - [Features](#features-8)
      - [Query 1 – High-Earning Guides](#query-1--high-earning-guides)
      - [Query 2 – Monthly Revenue Analysis](#query-2--monthly-revenue-analysis)
      - [Query 3 – VIP Customer Loyalty](#query-3--vip-customer-loyalty)
      - [Query 4 – Elite Guides](#query-4--elite-guides)
      - [Query 5 – Popular Routes](#query-5--popular-routes)
    - [Programs Module](#programs-module)
      - [Included Objects](#included-objects)
      - [Function 1 – fn_calculate_customer_payment_status](#function-1)
      - [Function 2 – fn_get_route_tour_details_by_difficulty](#function-2)
      - [Procedure 1 – pr_assign_optimal_guide_to_tour](#procedure-1)
      - [Procedure 2 – pr_apply_discount_to_tour_participants](#procedure-2)
      - [Active Triggers](#active-triggers)
        - [Trigger 1 – trg_update_registration_payment_status](#trigger-1)
        - [Trigger 2 – trg_audit_tour_changes](#trigger-2)
  - [Database Integration](#database-integration)
    - [Supported Operations](#supported-operations)
    - [Advanced Features](#advanced-features)
  - [Conclusion](#conclusion)

  - [How to Run the Project](#how-to-run-the-project)
    - [Requirements](#requirements)
    - [Clone the Repository](#clone-the-repository)
    - [Run the System](#run-the-system)
    - [Verify Running Containers](#verify-running-containers)
    - [Access the Application](#access-the-application)
    - [Stop the System](#stop-the-system)
    - [Notes](#notes)
---

##  Introduction

**System Purpose:**  
The system is intended for the full operational management of a tour company. It serves as a central working tool for company managers, enabling them to manage the human resource aspect (guides), the product aspect (tour routes), the sales aspect (customer registrations), as well as the financial and feedback aspects.

**Data Stored in the System:**  
• **Guides:** Personal information, contact details, languages, professional specializations, quality rating, and daily salary.  
• **Routes:** Geographical definitions (region), difficulty level, estimated length, and a list of Points of Interest (POI) that make up the route.  
• **Tours:** Specific instances of routes on certain dates, including guide assignment, participant limit, and real-time occupancy tracking.  
• **Customers & Registrations:** Customer database and their linkage to specific tours, including payment status tracking and number of reserved seats.  
• **Payments & Feedback:** Documentation of financial transactions and collection of traveler reviews for service improvement.  

**Main Functionalities:**  
• **Tour Lifecycle Management:** From creating the route, through scheduling the tour and assigning a guide, to customer registration and payment collection.  
• **Data Analysis (Analytics):** A dashboard displaying revenues, occupancy rates in tours, and guide availability.  
• **Advanced Search and Filtering:** Ability to locate guides by language or region, and routes by difficulty level or length.  
• **Status Management:** Dynamic tracking of guide status (active/inactive) and tour status (planned/completed/canceled).  

The purpose of the system is to enable efficient, organized, and data-driven management of guided tour operations.

---

## System Screens (AI)

The system was characterized using a Top-Down approach with the help of AI tools for generating initial screens.
The prototype of the system was developed using Google AI Studio as part of the Top-Down characterization process.  
It can be accessed here: https://ai.studio/apps/cd7c04a5-8c88-45ec-b967-1ed674755d64

### Navigation Menu

The system includes a side menu that allows quick and convenient access to all parts of the system:

- Dashboard  
- Guides  
- Tours  
- Routes  
- Customers  
- Registrations  
- Assignments  
- Payments  
- Feedback  
- Reports  
- Settings  

<img width="396" height="676" alt="image" src="https://github.com/user-attachments/assets/f64f9c91-c484-461d-9275-a512ecf5469a" />

<img width="394" height="660" alt="image" src="https://github.com/user-attachments/assets/53b42abd-c6bf-468f-ab38-a9045648fd3a" />

<img width="390" height="675" alt="image" src="https://github.com/user-attachments/assets/a04710bf-ad0a-4e03-9391-d036e1f1d3ea" />

---

### Dashboard

The home screen of the system presenting key data:

- Number of active guides  
- Upcoming tours  
- Open registrations  
- Total revenues  
- Graphs showing activity trends  

<img width="1494" height="723" alt="image" src="https://github.com/user-attachments/assets/1878516d-bc31-4c6c-b319-ba34a8015e04" />

<img width="1493" height="724" alt="image" src="https://github.com/user-attachments/assets/2676ce0b-bf04-4acd-9516-6963edd3e2ec" />

<img width="1489" height="721" alt="image" src="https://github.com/user-attachments/assets/e59abd5f-0781-405e-bf2a-01afe28c837e" />

---

### Guide Management

A module for managing tour guides:

- Guide list  
- Guide details  
- Add and edit guides  

<img width="1491" height="734" alt="image" src="https://github.com/user-attachments/assets/9c8fd7cf-76b8-41d1-8aa9-3e4a4d76c267" />

---

### Route Management

Management of routes including Points of Interest (POI):

- Route list  
- Route description  
- Points of Interest  
- Create and edit routes  

<img width="1492" height="724" alt="image" src="https://github.com/user-attachments/assets/45f53d88-2999-4893-a680-dfac11fecaa9" />

---

###  Tour Management

The operational core of the system:

- Tour list  
- Tour details  
- Create a new tour  
- Assign a guide  

<img width="1478" height="716" alt="image" src="https://github.com/user-attachments/assets/997e7d5a-51f4-4a75-91c7-bd39d9314cbd" />

---

###  Customers and Registrations

Managing customers and their participation in tours:

- Customer database  
- Tour registrations  
- Payment status
- 
<img width="1491" height="718" alt="image" src="https://github.com/user-attachments/assets/e5eb7872-7f00-4849-be71-1e149961fe6a" />

<img width="1488" height="732" alt="image" src="https://github.com/user-attachments/assets/d8bc9be3-ec0e-4a39-aed4-0485b3a1bd0e" />

---

### 🔄Assignments

A dedicated screen for assigning guides to tours.

<img width="1473" height="706" alt="image" src="https://github.com/user-attachments/assets/d4a666a3-2eed-4b7d-9707-e5fca52e8d86" />

<img width="1490" height="791" alt="image" src="https://github.com/user-attachments/assets/7b00f63d-dcbd-4aac-90f7-9fba82924bbf" />

---

###  Payments and Feedback

- Payment tracking  
- Customer feedback  
<img width="1487" height="720" alt="image" src="https://github.com/user-attachments/assets/520da0b6-2a7b-44c8-bfda-2e3159f5dc2e" />

<img width="1473" height="717" alt="image" src="https://github.com/user-attachments/assets/b8269322-6041-4f3c-8063-628a3d1d51b5" />

<img width="1468" height="719" alt="image" src="https://github.com/user-attachments/assets/2eeaaf07-e7db-4c66-8d1c-332062a14931" />

---

###  Settings

Management of business details and general system settings.

<img width="1484" height="707" alt="image" src="https://github.com/user-attachments/assets/45f9c33a-bf52-44f8-95d1-d094ae4191a9" />
<img width="1491" height="729" alt="image" src="https://github.com/user-attachments/assets/7239ab39-62df-4035-94be-d2efc0a9230c" />


---

##  ERD Diagram

The ERD diagram presents the entities in the system and the relationships between them.

<img width="4704" height="1908" alt="ERD" src="https://github.com/user-attachments/assets/417feaee-2e51-488f-9660-7ecac34a407d" />

---

##  DSD Diagram

The DSD diagram presents the actual structure of the database:

- Tables  
- Primary keys  
- Foreign keys  
- Constraints  

<img width="4704" height="1908" alt="DSD" src="https://github.com/user-attachments/assets/e9172dae-f240-4b32-80da-083fa8224ce0" />

---

##  Design Decisions

During the construction of the system, several design and architectural decisions were made in order to improve efficiency and stability:

**A. Transition from a "Sites" model to a "Points of Interest" model:**  
• **The decision:** We canceled the independent "Site" entity and replaced it with an array of text strings inside the Route entity.  
• **The reason:** Flexibility and simplicity. In tour management, sometimes the stopping point is "a viewpoint under the oak tree" or "a historic street corner," which does not always justify creating a full entity in the database with address and images. The new model allows the tour manager to build a dynamic and fast route without dependence on a rigid site repository.  

**B. Separation between "Route" and "Tour":**  
• **The decision:** A complete separation between the route definition and the calendar event.  
• **The reason:** Reusability of data. A route is a company asset that does not change often. A tour is its specific instance. This separation makes it possible to run the same route dozens of times with different guides and on different dates without duplicating the route data itself.  

**C. Use of Enums for status management:**  
• **The decision:** Defining fixed statuses (such as TourStatus, PaymentStatus).  
• **The reason:** Preventing human error and ensuring Data Integrity. Using fixed values ensures that the business logic (for example: "it is not possible to register a customer for a canceled tour") works consistently throughout all parts of the system.  

**D. Dashboard-First interface design based on cards and tables:**  
• **The decision:** Using Tailwind CSS to create a clean interface with emphasis on a visual dashboard.  
• **The reason:** User Experience (UX). Operations managers need fast, scannable information. The statistic cards at the top of the page allow business decisions to be made within seconds, while the detailed tables allow deeper examination of the data when needed.  

**E. Centralizing logic in ScreenRenderer:**  
• **The decision:** Managing navigation and screen display through one central component that manages the state.  
• **The reason:** Simplicity of maintenance. Since מדובר in a Single Page Application (SPA), managing navigation in this way enables smooth transitions between screens without page refresh, and preserves full synchronization between the global search and the information displayed on the current screen.  

---

##  Data Insertion

Data insertion into the system was carried out using three methods:

### Method 1 – Manual Data Insertion (SQL)
![generateData](https://github.com/user-attachments/assets/c0abb5ce-6324-4495-a401-c8321b2fdd1b)

---

### Method 2 – Using CSV / Mockaroo Files
![mockotoo](https://github.com/user-attachments/assets/051b5030-e6d1-4728-a691-3ca3442cfc4d)

---

### Method 3 – Creating Data Through Code
![ai_studio](https://github.com/user-attachments/assets/a45370d9-ab88-45fb-8e56-12bf5b36c443)

---

##  Backup and Restore

## 🔹 Backup File
A backup of the database "DBsecret" was created using pgAdmin.

The backup file was saved as:
backup_12_04_2026.sql

The backup was created in Plain format.
<img width="1914" height="1079" alt="image" src="https://github.com/user-attachments/assets/dd89766b-5b51-4fb6-9bea-d6dddf4b261f" />


## 🔹 Restore

To verify the backup file, a restore process was performed.

A new database named "DBsecret_restore" was created on another machine.

The backup file was executed using the pgAdmin Query Tool.

After execution:
- All tables were recreated successfully
- All data was restored

Verification was performed by running SELECT queries and checking:
- 500 rows in regular tables
- 20,000 rows in large tables (REGISTRATION, PAYMENT)

<img width="1111" height="828" alt="WhatsApp Image 2026-05-05 at 10 47 30" src="https://github.com/user-attachments/assets/29aa8bf0-fb89-4486-a192-7bbbb9593daa" />

This confirms that the backup file is valid and working correctly.

##  Summary

At this stage, the following were completed:

- System characterization  
- Construction of ERD and DSD diagrams  
- Database creation  
- Data insertion using three methods  
- Performing backup and restore  

The system constitutes a stable foundation for continued development in the next stages.
---

# Phase 2: Advanced SQL and Data Manipulation

---

## Introduction

In this phase, we expanded the system by implementing advanced SQL capabilities.

The main goals of this phase were:

- Writing complex SELECT queries  
- Performing UPDATE and DELETE operations  
- Adding constraints using ALTER TABLE  
- Demonstrating transaction control (ROLLBACK & COMMIT)  
- Improving performance using indexes  
- Creating an updated backup of the system  

This phase strengthens the database logic, ensures data integrity, and improves performance.

---

## Complex SELECT Queries

Each query below includes:

A description in English
A screenshot of the query execution in pgAdmin
A screenshot showing the result (only 5 rows maximum per screenshot)

---

### Query 1 – High-Earning Guides Report

#### Description
This query finds guides who generated high revenue during March 2026.  
It connects guides, guided tours, registrations, and payments, and calculates the total revenue generated by each guide.

#### Option A – JOIN (Efficient)

```sql
SELECT 
    CONCAT(g.FirstName, ' ', g.LastName) AS GuideName,
    g.Email,
    EXTRACT(MONTH FROM p.PaymentDate) AS PaymentMonth,
    SUM(p.Amount) AS TotalEarned
FROM GUIDE g
JOIN GUIDEDTOUR gt ON g.GuideID = gt.GuideID
JOIN REGISTRATION r ON gt.TourID = r.TourID
JOIN PAYMENT p ON r.RegistrationID = p.RegistrationID
WHERE EXTRACT(YEAR FROM p.PaymentDate) = 2026
  AND EXTRACT(MONTH FROM p.PaymentDate) = 3
GROUP BY g.GuideID, g.FirstName, g.LastName, g.Email, EXTRACT(MONTH FROM p.PaymentDate)
HAVING SUM(p.Amount) > 5000
ORDER BY TotalEarned DESC;
```

📸 
<img width="546" height="634" alt="image" src="https://github.com/user-attachments/assets/467a2537-8097-4b86-beab-110160acf181" />

---

#### Option B – Nested IN

```sql
SELECT CONCAT(FirstName, ' ', LastName) AS GuideName 
FROM GUIDE
WHERE GuideID IN (
    SELECT GuideID FROM GUIDEDTOUR WHERE TourID IN (
        SELECT TourID FROM REGISTRATION WHERE RegistrationID IN (
            SELECT RegistrationID FROM PAYMENT
            WHERE EXTRACT(MONTH FROM PaymentDate) = 3 
              AND EXTRACT(YEAR FROM PaymentDate) = 2026
        )
    )
);
```

📸
<img width="418" height="603" alt="image" src="https://github.com/user-attachments/assets/396994c5-db15-446a-88ac-f3ea82db7b18" />


#### Explanation
Option A is more efficient because it uses JOIN operations directly between related tables. This allows the database optimizer to build a better execution plan.  
Option B uses nested IN subqueries, which are harder to read and may require more internal filtering.

---

### Query 2 – Monthly Revenue Analysis for 2026

#### Description
This query calculates the total monthly revenue for the year 2026 and counts the number of payment transactions in each month.

#### Option A – GROUP BY

```sql
SELECT 
    EXTRACT(YEAR FROM PaymentDate) AS Year,
    EXTRACT(MONTH FROM PaymentDate) AS Month, 
    SUM(Amount) AS MonthlyIncome,
    COUNT(PaymentID) AS TransactionCount
FROM PAYMENT
WHERE EXTRACT(YEAR FROM PaymentDate) = 2026
GROUP BY EXTRACT(YEAR FROM PaymentDate), EXTRACT(MONTH FROM PaymentDate)
ORDER BY Month;
```

📸
<img width="474" height="268" alt="image" src="https://github.com/user-attachments/assets/8d9431f8-f300-498c-9630-36c7344fefd2" />

---

#### Option B – Subquery

```sql
SELECT Month, SUM(Amount) AS Total 
FROM (
    SELECT EXTRACT(MONTH FROM PaymentDate) AS Month, Amount
    FROM PAYMENT
    WHERE EXTRACT(YEAR FROM PaymentDate) = 2026
) AS MonthlyStats 
GROUP BY Month
ORDER BY Month;
```

📸
<img width="819" height="211" alt="image" src="https://github.com/user-attachments/assets/2f575731-7424-4268-86df-d7ca5f4f7616" />



#### Explanation
Option A is more efficient because it performs the aggregation directly on the PAYMENT table.  
Option B first creates an intermediate result and then groups it, which makes the query less direct.

---

### Query 3 – Debtors List: Jerusalem Tours with Pending Payments

#### Description
This query finds customers registered for Jerusalem-related tours whose registration status is still pending.  
It helps the company identify customers who may still need payment follow-up.

#### Option A – JOIN

```sql
SELECT DISTINCT c.FullName, c.Phone, r.RegistrationID, rt.Name AS RouteName
FROM CUSTOMER c
JOIN REGISTRATION r ON c.CustomerID = r.CustomerID
JOIN GUIDEDTOUR gt ON r.TourID = gt.TourID
JOIN ROUTE rt ON gt.RouteID = rt.RouteID
WHERE rt.Description LIKE '%Jerusalem%' 
  AND r.RegistrationStatusID = (
      SELECT RegistrationStatusID
      FROM REGISTRATIONSTATUS
      WHERE StatusName = 'Pending'
  );
```
📸
<img width="1333" height="891" alt="image" src="https://github.com/user-attachments/assets/c9704752-ba62-4b7e-aa73-b4e5eb781680" />

---

#### Option B – EXISTS

```sql
SELECT FullName, Phone
FROM CUSTOMER c
WHERE EXISTS (
    SELECT 1
    FROM REGISTRATION r 
    JOIN GUIDEDTOUR gt ON r.TourID = gt.TourID
    JOIN ROUTE rt ON gt.RouteID = rt.RouteID
    WHERE r.CustomerID = c.CustomerID 
      AND rt.Description LIKE '%Jerusalem%' 
      AND r.RegistrationStatusID = (
          SELECT RegistrationStatusID
          FROM REGISTRATIONSTATUS
          WHERE StatusName = 'Pending'
      )
);
```
📸 
<img width="1332" height="883" alt="image" src="https://github.com/user-attachments/assets/67965c9c-ba60-4b04-ab2a-3fa80d32061b" />



#### Explanation
Option A is better when we want to display detailed information from several tables, such as registration ID and route name.  
Option B is useful when we only need to check whether a matching record exists.

---

### Query 4 – Elite Guides: Above Average Rating and High Activity

#### Description
This query identifies guides who are highly active and have a rating above the average guide rating.  
It helps the company locate strong guides who may be suitable for important tours.

#### Option A – HAVING with Scalar Subquery

```sql
SELECT g.FirstName, g.LastName, g.Rating, COUNT(gt.TourID) AS TourCount
FROM GUIDE g
JOIN GUIDEDTOUR gt ON g.GuideID = gt.GuideID
GROUP BY g.GuideID, g.FirstName, g.LastName, g.Rating
HAVING COUNT(gt.TourID) > 3 
   AND g.Rating > (SELECT AVG(Rating) FROM GUIDE);
```

📸 
<img width="717" height="412" alt="image" src="https://github.com/user-attachments/assets/53a16e60-1595-4bf4-b260-99659814f886" />


---

#### Option B – Inline View

```sql
SELECT g.FirstName, g.LastName, TCounts.cnt
FROM GUIDE g
JOIN (
    SELECT GuideID, COUNT(*) AS cnt
    FROM GUIDEDTOUR
    GROUP BY GuideID
) TCounts ON g.GuideID = TCounts.GuideID
WHERE TCounts.cnt > 3
  AND g.Rating > (SELECT AVG(Rating) FROM GUIDE);
```

📸
<img width="813" height="304" alt="image" src="https://github.com/user-attachments/assets/d682b415-3608-4be9-b221-d9fb356e365d" />


#### Explanation
Option A is simpler because the aggregation and filtering are performed in one query using GROUP BY and HAVING.  
Option B separates the counting logic into an inline view, which can be useful when the aggregated result needs to be reused.

---

## Additional SELECT Queries

---

### Query 5 – Real-Time Availability: Tours in the Next 7 Days

#### Description
This query shows tours scheduled for the next seven days and calculates how many available places remain for each tour.

```sql
SELECT 
    gt.TourID, 
    rt.Name AS RouteName, 
    gt.StartDate AS Starting,
    gt.MaxParticipants,
    (gt.MaxParticipants - (
        SELECT COUNT(*)
        FROM REGISTRATION r
        WHERE r.TourID = gt.TourID
    )) AS AvailableSlots
FROM GUIDEDTOUR gt
JOIN ROUTE rt ON gt.RouteID = rt.RouteID
WHERE gt.StartDate BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY gt.StartDate;
```

📸
<img width="1057" height="432" alt="image" src="https://github.com/user-attachments/assets/a11182f9-c769-402d-a528-49e8e7f579b0" />


---

### Query 6 – VIP Customer Loyalty Program

#### Description
This query finds customers who spent more than 2000 during the last year.  
It can be used to identify loyal customers for discounts, benefits, or marketing campaigns.

```sql
SELECT 
    c.FullName, 
    c.Email, 
    SUM(p.Amount) AS TotalSpent,
    MAX(p.PaymentDate) AS LastPayment
FROM CUSTOMER c
JOIN REGISTRATION r ON c.CustomerID = r.CustomerID
JOIN PAYMENT p ON r.RegistrationID = p.RegistrationID
WHERE p.PaymentDate >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY c.CustomerID, c.FullName, c.Email
HAVING SUM(p.Amount) > 2000;
```

📸
<img width="387" height="574" alt="image" src="https://github.com/user-attachments/assets/a200165e-ac81-43c8-ae03-91a858429a85" />


---

### Query 7 – Popular Routes Analysis

#### Description
This query analyzes popular routes by counting how many guided tours were created for each route and calculating the total capacity.

```sql
SELECT 
    r.Name, 
    SUM(gt.MaxParticipants) AS TotalCapacity,
    COUNT(gt.TourID) AS Occurrences
FROM ROUTE r
JOIN GUIDEDTOUR gt ON r.RouteID = gt.RouteID
GROUP BY r.RouteID, r.Name
HAVING COUNT(gt.TourID) >= 2
ORDER BY TotalCapacity DESC;
```

📸 
<img width="309" height="262" alt="image" src="https://github.com/user-attachments/assets/688516e8-08a9-42f4-a6ea-c54bfaafd0aa" />

---

### Query 8 – Quality Control: Low Experience Feedback

#### Description
This query displays feedback connected to tours guided by guides with less than two years of experience.  
It supports quality control and helps management review cases that may require improvement.

```sql
SELECT 
    CONCAT(g.FirstName, ' ', g.LastName) AS GuideName,
    g.ExperienceYears,
    rt.Name AS RouteName,
    r.Notes AS Feedback
FROM REGISTRATION r
JOIN GUIDEDTOUR gt ON r.TourID = gt.TourID
JOIN GUIDE g ON gt.GuideID = g.GuideID
JOIN ROUTE rt ON gt.RouteID = rt.RouteID
WHERE g.ExperienceYears < 2
  AND r.Notes IS NOT NULL;
```

📸
<img width="678" height="826" alt="image" src="https://github.com/user-attachments/assets/5c4dafe5-fec4-41c4-9376-028d49929515" />

---

## DELETE Operations

Each DELETE operation includes a short description, the SQL command, a screenshot before execution, a screenshot of the execution, and a screenshot after execution.

---

### Delete 1 – Remove Customers with No Activity in 3 Years

#### Description
This query removes customers who have not registered for any tour during the last three years.  
It helps keep the customer table clean and removes inactive records.

```sql
DELETE FROM CUSTOMER
WHERE CustomerID NOT IN (
    SELECT DISTINCT CustomerID FROM REGISTRATION 
    WHERE RegistrationDate > CURRENT_DATE - INTERVAL '3 years'
);
```

📸 Before execution:
<img width="1321" height="891" alt="delete1_before_stage2 png" src="https://github.com/user-attachments/assets/5c2a4bec-5ea6-46d0-8101-1a1954ff1640" />

📸 Delete execution:
<img width="1311" height="879" alt="delete1_stage2 png" src="https://github.com/user-attachments/assets/de2e5b52-8bd5-411e-84b0-494de71cc105" />

📸 After execution:
<img width="1318" height="875" alt="delete1_after_stage2 png" src="https://github.com/user-attachments/assets/59dff830-2c10-4f1f-b7dc-7fb3e52ccd41" />

---

### Delete 2 – Delete Payments Older Than 5 Years

#### Description
This query removes old payment records that are more than five years old.  
It supports data retention and keeps the payment table focused on relevant financial history.

```sql
DELETE FROM PAYMENT
WHERE PaymentDate < CURRENT_DATE - INTERVAL '5 years';
```

📸 Before execution:
<img width="1330" height="887" alt="delete2_before_stage2 png" src="https://github.com/user-attachments/assets/aae9ed8e-ce59-47d0-91c4-678b9e38b76a" />


📸 Delete execution:
<img width="1336" height="885" alt="delete2_stage2 png" src="https://github.com/user-attachments/assets/dd05e9cc-a4a2-4a34-a87d-d20c8cdcc811" />

📸 After execution:
<img width="1342" height="888" alt="delete2_after_stage2 png" src="https://github.com/user-attachments/assets/feef4039-de5d-4ba4-9a0f-2351605eac83" />

---

### Delete 3 – Delete Routes That Were Never Assigned to a Tour

#### Description
This query deletes routes that were never used in any guided tour.  
It helps remove unused route definitions from the system.

```sql
DELETE FROM ROUTE
WHERE RouteID NOT IN (
    SELECT DISTINCT RouteID FROM GUIDEDTOUR
);
```

📸 Before execution:
<img width="1324" height="893" alt="delete3_before_stage2 png" src="https://github.com/user-attachments/assets/d466f20f-2dc8-443b-9acd-c73776133c4a" />


📸 Delete execution:
<img width="1343" height="895" alt="delete3_stage2" src="https://github.com/user-attachments/assets/c65ba6a1-e566-48cc-8c4e-739735104ef5" />


📸 After execution:
<img width="1324" height="877" alt="delete3_after_stage2" src="https://github.com/user-attachments/assets/08cbef32-f199-4e11-9dd7-5fe950869201" />

---

## UPDATE Operations

Each UPDATE operation includes a short description, the SQL command, a screenshot before execution, a screenshot of the execution, and a screenshot after execution.

---

### Update 1 – Incentive: 10% Raise for Top Guides

#### Description
This query increases the daily rate of highly rated and experienced guides by 10%.  
It rewards guides with excellent performance and long-term experience.

```sql
UPDATE GUIDE
SET DailyRate = DailyRate * 1.10
WHERE Rating > 4.8 AND ExperienceYears > 5;
```
📸 Before execution:
<img width="1334" height="892" alt="update1_before_stage2" src="https://github.com/user-attachments/assets/b5baf601-0383-46cf-abab-eb9ee88ec0de" />

📸 Update execution:
<img width="1337" height="890" alt="update1_stage2" src="https://github.com/user-attachments/assets/f1fd8a80-3a29-4811-8721-c95361340666" />

📸 After execution:
<img width="1337" height="885" alt="update1_after_stage2" src="https://github.com/user-attachments/assets/12aabb1c-234b-4874-90a1-bf7b39ef2c37" />

### Update 2 – Maintenance: Auto-Complete Past Tours

#### Description

This query updates all tours that have already ended and marks them as 'Completed'.
It ensures that the system reflects the correct status of past tours.

```sql
UPDATE GUIDEDTOUR
SET TourStatusID = (
    SELECT TourStatusID 
    FROM TOURSTATUS 
    WHERE StatusName = 'Completed'
)
WHERE EndDate < CURRENT_DATE 
  AND TourStatusID != (
    SELECT TourStatusID 
    FROM TOURSTATUS 
    WHERE StatusName = 'Completed'
);
```
📸 Before execution:
<img width="1345" height="902" alt="update2_before_stage2" src="https://github.com/user-attachments/assets/c4a17990-1801-4a97-b2c2-8fd0c480d048" />

📸 Update execution:
<img width="1340" height="893" alt="update2_stage2" src="https://github.com/user-attachments/assets/3324f73c-913e-499e-be82-a440f5bfc6a4" />

📸 After execution:
<img width="1337" height="885" alt="update2_after_stage2" src="https://github.com/user-attachments/assets/0f994349-88c1-47bd-b061-2ece5eee4f6b" />

### Update 3 – Data Standardization: Israeli Phone Format

#### Description

This query standardizes phone numbers to the Israeli international format (+972).
It converts numbers starting with '0' into the international format.

```sql
UPDATE CUSTOMER
SET Phone = CONCAT('+972', SUBSTRING(Phone, 2))
WHERE Phone LIKE '0%';
```

📸 Before execution:
<img width="1332" height="884" alt="update3_before_stage2" src="https://github.com/user-attachments/assets/d4e781fe-2f34-4aa0-8d70-e72a2bf9919f" />

📸 Update execution:
<img width="1337" height="889" alt="update3_stage2" src="https://github.com/user-attachments/assets/562a803e-41f5-4497-ad65-b67f8fbad2fc" />

📸 After execution:
<img width="1346" height="889" alt="update3_after_stage2" src="https://github.com/user-attachments/assets/c7c45cde-eff9-4c44-8a7b-521c466f8f6f" />

---

## Constraints using ALTER TABLE

Each constraint includes a description, the ALTER TABLE command, a violation test, and screenshots showing both the constraint creation and the error.

---

### Constraint 1 – Guide Rating Validation

#### Description
This constraint ensures that every guide rating is between 0 and 5.  
It prevents invalid rating values such as negative ratings or ratings higher than 5.

```sql
ALTER TABLE GUIDE 
ADD CONSTRAINT chk_guide_rating 
CHECK (Rating >= 0 AND Rating <= 5);
```

📸 Constraint added:
<img width="1340" height="887" alt="constraint1_stage2" src="https://github.com/user-attachments/assets/9f32bbfd-8112-4135-91cf-88268d05bb90" />

#### Violation Test
```sql
INSERT INTO GUIDE 
(GuideID, FirstName, LastName, Email, Phone, DailyRate, Rating, ExperienceYears)
VALUES 
(99999, 'Test', 'Guide', 'testguide99999@test.com', '0500000000', 500, 6, 3);
```
📸 Error result:
<img width="1348" height="888" alt="constraint1_error_stage2" src="https://github.com/user-attachments/assets/ce5331c7-e0c2-4a96-96ed-182fb3f896e3" />

---

### Constraint 2 – Unique Customer Email

#### Description

This constraint ensures that each customer email appears only once in the CUSTOMER table.
It prevents duplicate customer records with the same email address.

```sql
ALTER TABLE CUSTOMER 
ADD CONSTRAINT uni_cust_email 
UNIQUE (Email);
```
📸 Constraint added:
<img width="1334" height="884" alt="constraint2_stage2" src="https://github.com/user-attachments/assets/71460040-c5b5-4f00-b745-c0e56f0b1ee6" />

#### Violation Test

First, we checked an existing email:

```sql
SELECT CustomerID, FullName, Email
FROM CUSTOMER
LIMIT 1;
```
📸 Existing email:
<img width="1339" height="883" alt="constraint2_existing_email_stage2" src="https://github.com/user-attachments/assets/5aaeb1ab-658e-4599-8d0f-b1de95234125" />

Then we tried to insert a new customer with the same email:

```sql
INSERT INTO CUSTOMER 
(CustomerID, FullName, Phone, Email, JoinDate)
VALUES 
(99998, 'Duplicate Email Customer', '0501111111', 'customer1@mail.com', CURRENT_DATE);
```
📸 Error result:
<img width="1328" height="887" alt="constraint2_error_stage2" src="https://github.com/user-attachments/assets/31b3e29d-5244-4b8a-8471-f599d3bbfd20" />

---

### Constraint 3 – Tour Date Consistency

#### Description

This constraint ensures that a guided tour cannot end before it starts.
It protects the system from invalid tour dates.

```sql
ALTER TABLE GUIDEDTOUR 
ADD CONSTRAINT chk_tour_dates 
CHECK (EndDate >= StartDate);
```
📸 Constraint added:
<img width="1343" height="886" alt="constraint3_stage2" src="https://github.com/user-attachments/assets/0514dd5f-e4ee-4543-b60f-1d9dfe9893a9" />

#### Violation Test

```sql
INSERT INTO GUIDEDTOUR
(TourID, RouteID, GuideID, StartDate, EndDate, MaxParticipants, TourStatusID, MeetingPoint)
VALUES
(99997, 1, 1, CURRENT_DATE, CURRENT_DATE - INTERVAL '1 day', 20, 1, 'Test');
```

📸 Error result:
<img width="1350" height="894" alt="constraint3_error_stage2" src="https://github.com/user-attachments/assets/84509312-1882-42e9-b8be-509401224550" />

---

## Transactions: COMMIT and ROLLBACK

Each scenario demonstrates transaction control using BEGIN, COMMIT, and ROLLBACK.  
Screenshots show the database state at each stage.

---

### Scenario 1 – Accidental Update and ROLLBACK

#### Description
This scenario demonstrates how an incorrect update can be reverted using ROLLBACK.

---

#### Step 1 – View current data

```sql
SELECT GuideID, FirstName, Rating 
FROM GUIDE 
LIMIT 5;
```

📸 Before update:
<img width="1360" height="881" src="https://github.com/user-attachments/assets/0e88ae32-552e-4ed5-978c-81f4737c7f93" />

#### Step 2 – Start transaction and perform incorrect update

```sql
BEGIN;
UPDATE GUIDE 
SET Rating = 5.0;
```

📸 Update executed:
<img width="1341" height="880" src="https://github.com/user-attachments/assets/7105a432-0a47-4eb8-8075-36b8bd679f31" />

#### Step 3 – Verify the mistake

```sql
SELECT GuideID, FirstName, Rating 
FROM GUIDE 
LIMIT 5;
```

📸 After wrong update (all ratings = 5):
<img width="1328" height="894" src="https://github.com/user-attachments/assets/a4e6fb10-95a0-41a5-a389-115c0522ec5a" />

#### Step 4 – Rollback changes

```sql
ROLLBACK;
```

📸 Rollback executed:
<img width="1320" height="883" src="https://github.com/user-attachments/assets/9c505495-6416-4615-8b9f-daa1ef94f58e" />

#### Step 5 – Verify restoration

```sql
SELECT GuideID, FirstName, Rating 
FROM GUIDE 
LIMIT 5;
```

📸 After rollback (original values restored):
<img width="1358" height="895" src="https://github.com/user-attachments/assets/82f64553-3ec4-47d9-87f3-7e0d2c8588aa" />

---

### Scenario 2 – Valid Update and COMMIT

#### Description

This scenario demonstrates how a correct update is permanently saved using COMMIT.

#### Step 1 – View current data

```sql
SELECT FullName, Email 
FROM CUSTOMER 
WHERE CustomerID = 1;
```

📸 Before update:
<img width="1329" height="898" src="https://github.com/user-attachments/assets/ed372269-6099-447e-8618-b15eac3eca5d" />

#### Step 2 – Start transaction and update data

```sql
BEGIN;

UPDATE CUSTOMER 
SET Email = 'new_email@gmail.com' 
WHERE CustomerID = 1;
```

📸 Update executed:
<img width="1325" height="886" src="https://github.com/user-attachments/assets/b9e007e4-b523-4d07-907a-e5437b5d3158" />

#### Step 3 – Commit changes

```sql
COMMIT;
```

📸 Commit executed:
<img width="1333" height="891" src="https://github.com/user-attachments/assets/d1a16c2b-d36f-4350-93ab-332ae091ea0d" />

#### Step 4 – Verify persistence

```sql
SELECT FullName, Email 
FROM CUSTOMER 
WHERE CustomerID = 1;
```

📸 After commit (new email saved):
<img width="1334" height="893" src="https://github.com/user-attachments/assets/80ad4a68-66fa-41d9-b8c3-c976e057d3e5" />

---

## Indexes and Performance Analysis

Each index is evaluated by measuring query runtime before and after its creation.  
The execution time is obtained using `EXPLAIN ANALYZE`.

---

### Index 1 – PaymentDate Optimization

#### Description
This index improves performance for queries that filter payments by date range.

#### Query BEFORE index

```sql
EXPLAIN ANALYZE
SELECT *
FROM PAYMENT
WHERE PaymentDate BETWEEN '2026-01-01' AND '2026-12-31';
```

📸 Before index:

<img width="1335" height="874" src="https://github.com/user-attachments/assets/4e43432a-7ee0-43f7-8e70-c31ab6afb689" />

⏱ Execution Time: 12.3 ms

#### Create Index

```sql
CREATE INDEX idx_payment_paymentdate
ON PAYMENT (PaymentDate);
```

📸 Index creation:

<img width="1341" height="878" src="https://github.com/user-attachments/assets/ae9fcff0-a8fd-491c-b77a-91b5f1f848c1" />

#### Query AFTER index

```sql
EXPLAIN ANALYZE
SELECT *
FROM PAYMENT
WHERE PaymentDate BETWEEN '2026-01-01' AND '2026-12-31';
```

📸 After index:

<img width="1353" height="908" src="https://github.com/user-attachments/assets/a44d75a2-a877-487a-82d9-9db8b4ef0a5f" />

⏱ Execution Time: 0.008 ms

#### Analysis
Before the index, PostgreSQL used a sequential scan and checked many rows.  
After creating the index, PostgreSQL used an index scan, significantly improving performance.

---

### Index 2 – Registration by TourID

#### Description
This index improves performance when retrieving registrations for a specific tour.

#### Query BEFORE index

```sql
EXPLAIN ANALYZE
SELECT *
FROM REGISTRATION
WHERE TourID = 1;
```

📸 Before index:

<img width="1333" height="893" src="https://github.com/user-attachments/assets/fe71c596-3cbe-4abb-888c-e0bf3d4ffdaf" />

⏱ Execution Time: 9.896 ms

#### Create Index

```sql
CREATE INDEX idx_registration_tourid
ON REGISTRATION (TourID);
```

📸 Index creation:

<img width="1340" height="884" src="https://github.com/user-attachments/assets/4afec164-b6b5-4856-9735-39b1e640cb12" />

#### Query AFTER index

```sql
EXPLAIN ANALYZE
SELECT *
FROM REGISTRATION
WHERE TourID = 1;
```

📸 After index:

<img width="1345" height="880" src="https://github.com/user-attachments/assets/b21ada0f-7b08-4885-9620-31fa799e0aa9" />

⏱ Execution Time: 0.134 ms

#### Analysis
Before the index, PostgreSQL performed a full table scan.  
After adding the index, PostgreSQL directly accessed the relevant rows using the index.

---

### Index 3 – GuidedTour by RouteID

#### Description
This index improves performance when searching for tours by route.

#### Query BEFORE index

```sql
EXPLAIN ANALYZE
SELECT *
FROM GUIDEDTOUR
WHERE RouteID = 1;
```

📸 Before index:

<img width="1355" height="889" src="https://github.com/user-attachments/assets/c88b7649-eef6-4806-9702-7133ff7fbfb2" />

⏱ Execution Time: 0.062 ms

#### Create Index

```sql
CREATE INDEX idx_guidedtour_routeid
ON GUIDEDTOUR (RouteID);
```

📸 Index creation:

<img width="1340" height="892" src="https://github.com/user-attachments/assets/cf6fea0f-4cd3-4da8-8c56-f6b08cf75dce" />

#### Query AFTER index

```sql
EXPLAIN ANALYZE
SELECT *
FROM GUIDEDTOUR
WHERE RouteID = 1;
```

📸 After index:

<img width="1349" height="912" src="https://github.com/user-attachments/assets/29778291-4021-475b-ada6-0564fe3c69a7" />

⏱ Execution Time: 0.050 ms

#### Analysis
The improvement is small because the table is relatively small.  
However, the index will provide greater benefit as the dataset grows.

---

## Backup File (Phase 2)

A full backup of the database after completing Phase 2 is included.

📁 Location:

```
backups/backup_04_05_2026.sql
```

#### Contents
- All tables (schema)
- All data (records)
- Constraints
- Indexes

#### Purpose
This backup allows full restoration of the database state after Phase 2.

---

# Phase 3 – Integration and Views

## Project: Tour Guide Management System  
## Integrated With: Route Management System

---

## 1. Introduction

In Phase 3, we performed an integration between two database systems:

1. **Tour Guide Management System** – our original database system.
2. **Route Management System** – the received database system from another team.

The goal of this phase was to combine both systems into one unified database while preserving data integrity, avoiding duplicate entities, and adapting the existing database according to the final integrated ERD.

According to the assignment requirements, we used **Integration Method A**.

This means:

- We did **not** recreate all existing tables.
- We used the existing database as the base database.
- We changed existing tables using `ALTER TABLE`.
- We created only new tables that did not exist in the original system.
- We imported the received backup into a separate schema named `received`.
- We inserted all received data from the `received` schema into the final integrated schema.
- We documented the design decisions made during the integration process.
- We verified that the integrated database works correctly.
- We created two views and meaningful queries on each view.

---

## 2. Received Database Import

Before performing the actual integration, the received database backup was imported into the same PostgreSQL database under a separate schema:

```text
received
```

This allowed us to keep the received system separate from our original `public` schema while preparing the integration.

The received backup included the following tables:

```text
received.booking
received.guide
received.location
received.participant
received.passes_through
received.route
received.trip
```

The received backup was imported using PostgreSQL tools inside Docker.

After importing the received backup, we verified that the schema and tables were created correctly using the following query:

```sql
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'received'
ORDER BY table_name;
```
<img width="1343" height="890" alt="צילום מסך 2026-06-07 165058" src="https://github.com/user-attachments/assets/8f1272ab-82c3-42d9-aea4-2bbcf5756798" />


We also verified the amount of data imported from the received system:

```sql
SELECT 'received.guide' AS table_name, COUNT(*) AS row_count FROM received.guide
UNION ALL
SELECT 'received.route', COUNT(*) FROM received.route
UNION ALL
SELECT 'received.trip', COUNT(*) FROM received.trip
UNION ALL
SELECT 'received.participant', COUNT(*) FROM received.participant
UNION ALL
SELECT 'received.booking', COUNT(*) FROM received.booking
UNION ALL
SELECT 'received.location', COUNT(*) FROM received.location
UNION ALL
SELECT 'received.passes_through', COUNT(*) FROM received.passes_through;
```

The received data counts were:

```text
received.guide           503
received.route           503
received.trip            503
received.participant     20005
received.booking         20003
received.location        505
received.passes_through  0
```

The table `received.passes_through` existed in the received schema, but it contained no rows.

Because of that, the integration file includes a fallback step that creates valid route-location connections in the final `LOCATED_IN` table.
<img width="1340" height="889" alt="צילום מסך 2026-06-07 165111" src="https://github.com/user-attachments/assets/2d729865-b047-4a73-b659-f0e4a42dfdac" />

---

## 3. Received Department – DSD Diagram

The following diagram presents the DSD of the received Route Management System before integration.
<img width="3744" height="1365" alt="image" src="https://github.com/user-attachments/assets/d01fc9b4-290d-4edd-ab54-9847983a3d9d" />


---

## 4. Reverse Engineering Algorithm

As required, we performed reverse engineering from the received database schema in order to build the ERD of the received department.

The reverse engineering process was performed according to the following algorithm:

1. **Identify all tables**  
   We reviewed all tables in the received database schema.

2. **Identify primary keys**  
   For each table, we identified the primary key.  
   Tables with their own primary key were treated as entity tables.

3. **Identify foreign keys**  
   Foreign keys were used to understand the relationships between tables.

4. **Classify tables**  
   We classified the tables into:
   - Entity tables
   - Lookup tables
   - Relationship tables

5. **Detect many-to-many relationships**  
   Tables that contained mainly foreign keys and a composite primary key were classified as junction tables.

6. **Convert tables into ERD entities**  
   Main tables were converted into entities in the ERD.

7. **Convert columns into attributes**  
   Regular columns were converted into attributes of the relevant entity.

8. **Convert foreign keys into relationships**  
   Each foreign key was translated into a relationship between entities.

9. **Determine cardinality**  
   Cardinality was determined according to the foreign key structure:
   - One-to-many when one table references another table.
   - Many-to-many when a junction table connects two tables.

10. **Build the ERD in ERDPlus**  
    After completing the analysis, we created the ERD of the received system using ERDPlus.

---

## 5. Received Department – ERD Diagram

The following ERD represents the received Route Management System after performing reverse engineering from the received DSD.
<img width="1024" height="373" alt="image" src="https://github.com/user-attachments/assets/4e0f6d0e-6e81-4355-9784-ee0faeba318a" />


---

## 6. Original Department – ERD Diagram

The following ERD represents our original Tour Guide Management System before integration.
<img width="4704" height="1908" alt="image" src="https://github.com/user-attachments/assets/6f165fdc-d2c1-465e-ae1d-1bbc108e82dd" />


---

## 7. Unified ERD Diagram After Integration

After comparing both ERDs, we created one unified ERD that combines both systems.

The unified ERD includes entities from our original system and relevant entities from the received Route Management System.

The final integrated ERD includes the following main entities:

- `CUSTOMER`
- `GUIDE`
- `GUIDEDTOUR`
- `ROUTE`
- `LOCATION`
- `LOCATED_IN`
- `REGISTRATION`
- `PAYMENT`
- `DIFFICULTYLEVEL`
- `TOURSTATUS`
- `REGISTRATIONSTATUS`
- `PAYMENTSTATUS`

<img width="3720" height="1476" alt="image" src="https://github.com/user-attachments/assets/f62b0adc-0312-45b7-b81d-91726ada82f0" />


---

## 8. DSD Diagram After Integration

After designing the unified ERD, we updated the database schema accordingly.

The following DSD represents the final integrated database structure after applying the integration commands.
<img width="3720" height="1476" alt="image" src="https://github.com/user-attachments/assets/2fbf0c72-5f7f-45cc-a016-263d5ee4e323" />


---

## 9. Integration Decisions

During the integration process, we compared both systems and made several design decisions.

---

### 9.1 PARTICIPANT Was Merged Into CUSTOMER

The received system included an entity named:

```text
PARTICIPANT
```

In our original system, the equivalent entity was:

```text
CUSTOMER
```

Both entities represent the same business concept: a person who registers for a guided tour.

Therefore, we decided not to create a separate `PARTICIPANT` table in the integrated schema.

Instead, received participant data was inserted into the existing `CUSTOMER` table.

Final mapping:

```text
PARTICIPANT → CUSTOMER
```

---

### 9.2 TRIP Was Merged Into GUIDEDTOUR

The received system used a table named:

```text
TRIP
```

Our original system used:

```text
GUIDEDTOUR
```

Both represent scheduled guided tours.

Therefore, the received `TRIP` records were inserted into the existing `GUIDEDTOUR` table.

Final mapping:

```text
TRIP → GUIDEDTOUR
```

---

### 9.3 TripID Was Mapped to TourID

The received system used:

```text
TripID
```

Our original system used:

```text
TourID
```

Both fields represent the identifier of a guided tour.

Therefore, in the final integrated schema we chose the name used in our original system:

```text
TourID
```

Final mapping:

```text
TripID → TourID
```

---

### 9.4 BOOKING Was Merged Into REGISTRATION

The received system included a table named:

```text
BOOKING
```

Our original system included a table named:

```text
REGISTRATION
```

Both tables represent the action of a customer or participant registering for a tour.

Therefore, received booking records were inserted into the existing `REGISTRATION` table.

Final mapping:

```text
BOOKING → REGISTRATION
```

---

### 9.5 Payment Records Were Derived From BOOKING

The received Route Management System did not include a separate payment table in the same structure as our original system.

Our original system included:

```text
PAYMENT
```

Therefore, payment records were created from the received booking data.

Each received booking was used to create a matching payment record in the final `PAYMENT` table.

Final mapping:

```text
BOOKING → PAYMENT
```

---

### 9.6 Expertise Was Added to GUIDE

The received system included guide expertise information.

Our original `GUIDE` table did not include this field.

Therefore, we added the following attribute to the existing `GUIDE` table:

```text
Expertise
```

This was done using `ALTER TABLE`, without recreating the table.

---

### 9.7 LOCATION and LOCATED_IN Were Added

The received system included route-location management.

Our original system did not include location management.

Therefore, we added two new tables:

```text
LOCATION
LOCATED_IN
```

`LOCATION` stores information about locations.

`LOCATED_IN` is a junction table that connects routes and locations.

This design allows:

- One route to be connected to several locations.
- One location to be connected to several routes.

---

### 9.8 Handling Empty PASSES_THROUGH Data

The received backup included a table named:

```text
passes_through
```

However, this table contained zero rows.

Since the final integrated schema requires a relationship between routes and locations, we added a fallback integration step.

If `received.passes_through` is empty, the integration script creates deterministic route-location connections between received routes and received locations.

This ensures that the final `LOCATED_IN` table contains valid data and supports the integrated views.

---

### 9.9 Avoiding Primary Key Conflicts

The original database already contained records with IDs such as `1–20`.

To avoid primary key conflicts, records from the received system were inserted using shifted IDs.

The received IDs were shifted by:

```text
+100000
```

For example:

```text
received.guide.guideid + 100000 → GUIDE.GuideID
received.route.routeid + 100000 → ROUTE.RouteID
received.trip.tripid + 100000 → GUIDEDTOUR.TourID
received.participant.participantid + 100000 → CUSTOMER.CustomerID
received.booking.bookingid + 100000 → REGISTRATION.RegistrationID
received.location.locationid + 100000 → LOCATION.LocationID
```

Payment IDs were shifted by:

```text
+200000
```

For example:

```text
received.booking.bookingid + 200000 → PAYMENT.PaymentID
```

This preserved data integrity and prevented duplicate primary key errors.

---

### 9.10 Handling Email Conflicts

The `CUSTOMER.Email` field is unique in the original schema.

Because the received participant data could contain duplicate or conflicting emails, the integration script generates safe emails for received participants.

Example:

```text
received_participant_1001@example.com
```

This prevents `UNIQUE` constraint errors during integration.

The same idea was used for received guides.

Example:

```text
received_guide_1001@example.com
```

---

## 10. Integration SQL File

The integration commands are stored in:

```text
Integrate.sql
```

The file does not recreate all existing original tables.

Instead, it modifies the existing database according to the final integrated ERD.

The file includes:

- Adding the `Expertise` column to `GUIDE`
- Creating `LOCATION`
- Creating `LOCATED_IN`
- Inserting missing difficulty levels from the received system
- Inserting all received guides into `GUIDE`
- Inserting all received routes into `ROUTE`
- Inserting all received locations into `LOCATION`
- Creating route-location connections in `LOCATED_IN`
- Merging all received participants into `CUSTOMER`
- Merging all received trips into `GUIDEDTOUR`
- Merging all received bookings into `REGISTRATION`
- Creating payment records from received bookings
- Running verification queries

---

## 11. Main Integration Commands

### 11.1 Adding Expertise to GUIDE

```sql
ALTER TABLE GUIDE
ADD COLUMN IF NOT EXISTS Expertise VARCHAR(100);
```
<img width="1351" height="888" alt="צילום מסך 2026-06-07 165243" src="https://github.com/user-attachments/assets/76575282-89cd-4754-892d-bce0fda9774b" />


---

### 11.2 Creating LOCATION

```sql
CREATE TABLE IF NOT EXISTS LOCATION
(
    LocationID INT NOT NULL,
    LocationName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    PRIMARY KEY (LocationID)
);
```
<img width="1353" height="881" alt="צילום מסך 2026-06-07 165252" src="https://github.com/user-attachments/assets/094a8146-24d7-4c0d-98f3-ef2d530faf04" />


---

### 11.3 Creating LOCATED_IN

```sql
CREATE TABLE IF NOT EXISTS LOCATED_IN
(
    RouteID INT NOT NULL,
    LocationID INT NOT NULL,
    PRIMARY KEY (RouteID, LocationID),
    FOREIGN KEY (RouteID) REFERENCES ROUTE(RouteID),
    FOREIGN KEY (LocationID) REFERENCES LOCATION(LocationID)
);
```
<img width="1379" height="892" alt="צילום מסך 2026-06-07 165303" src="https://github.com/user-attachments/assets/9502124f-6831-4d8a-9ec1-2ac250c173ff" />


---

### 11.4 Inserting Missing Difficulty Levels

```sql
INSERT INTO DIFFICULTYLEVEL (DifficultyID, DifficultyName)
SELECT
    COALESCE((SELECT MAX(DifficultyID) FROM DIFFICULTYLEVEL), 0)
    + ROW_NUMBER() OVER (ORDER BY d.difficulty) AS DifficultyID,
    d.difficulty AS DifficultyName
FROM (
    SELECT DISTINCT difficulty
    FROM received.route
) d
WHERE NOT EXISTS (
    SELECT 1
    FROM DIFFICULTYLEVEL dl
    WHERE LOWER(dl.DifficultyName) = LOWER(d.difficulty)
);
```
<img width="1341" height="895" alt="image" src="https://github.com/user-attachments/assets/28491287-775d-4ac1-ac3a-9dc15756ecd2" />


---

### 11.5 Merging Received Guides

```sql
INSERT INTO GUIDE
(
    GuideID,
    FirstName,
    LastName,
    Phone,
    Email,
    BirthDate,
    JoinDate,
    DailyRate,
    ExperienceYears,
    Rating,
    Address,
    Notes,
    Expertise
)
SELECT
    rg.guideid + 100000 AS GuideID,
    rg.firstname AS FirstName,
    rg.lastname AS LastName,
    rg.phone AS Phone,
    'received_guide_' || rg.guideid || '@example.com' AS Email,
    NULL AS BirthDate,
    NULL AS JoinDate,
    NULL AS DailyRate,
    NULL AS ExperienceYears,
    NULL AS Rating,
    NULL AS Address,
    'Received from Route Management System' AS Notes,
    rg.expertise AS Expertise
FROM received.guide rg
ON CONFLICT (GuideID) DO NOTHING;
```
<img width="1327" height="880" alt="image" src="https://github.com/user-attachments/assets/c34d542d-e3d6-462f-86ac-eaa5ae3911c4" />


---

### 11.6 Merging Received Routes

```sql
INSERT INTO ROUTE
(
    RouteID,
    Name,
    EstimatedLength,
    EstimatedDuration,
    Description,
    DifficultyID
)
SELECT
    rr.routeid + 100000 AS RouteID,
    rr.routename AS Name,
    NULL AS EstimatedLength,
    rr.duration AS EstimatedDuration,
    'Received from Route Management System' AS Description,
    dl.DifficultyID AS DifficultyID
FROM received.route rr
JOIN DIFFICULTYLEVEL dl
    ON LOWER(dl.DifficultyName) = LOWER(rr.difficulty)
ON CONFLICT (RouteID) DO NOTHING;
```
<img width="1334" height="892" alt="image" src="https://github.com/user-attachments/assets/4d0e7254-cd3d-4892-8585-d0c015c53b24" />


---

### 11.7 Merging Received Locations

```sql
INSERT INTO LOCATION
(
    LocationID,
    LocationName,
    Category
)
SELECT
    rl.locationid + 100000 AS LocationID,
    rl.locationname AS LocationName,
    rl.category AS Category
FROM received.location rl
ON CONFLICT (LocationID) DO NOTHING;
```
<img width="1323" height="898" alt="image" src="https://github.com/user-attachments/assets/bc973563-fe72-4564-b419-77a265ab6d12" />


---

### 11.8 Creating Route-Location Connections

```sql
INSERT INTO LOCATED_IN
(
    RouteID,
    LocationID
)
SELECT
    rpt.routeid + 100000 AS RouteID,
    rpt.locationid + 100000 AS LocationID
FROM received.passes_through rpt
ON CONFLICT (RouteID, LocationID) DO NOTHING;
```

Since `received.passes_through` was empty, the script also includes a fallback step:

```sql
INSERT INTO LOCATED_IN
(
    RouteID,
    LocationID
)
SELECT
    r.routeid + 100000 AS RouteID,
    l.locationid + 100000 AS LocationID
FROM (
    SELECT routeid, ROW_NUMBER() OVER (ORDER BY routeid) AS rn
    FROM received.route
) r
JOIN (
    SELECT locationid, ROW_NUMBER() OVER (ORDER BY locationid) AS rn
    FROM received.location
) l
    ON r.rn = l.rn
WHERE NOT EXISTS (
    SELECT 1
    FROM LOCATED_IN
)
ON CONFLICT (RouteID, LocationID) DO NOTHING;
```
<img width="1322" height="887" alt="image" src="https://github.com/user-attachments/assets/92c2fd06-eac4-4ca9-841e-85dfb48cf980" />



---

### 11.9 Merging Received Participants Into CUSTOMER

```sql
INSERT INTO CUSTOMER
(
    CustomerID,
    FullName,
    Phone,
    Email,
    JoinDate
)
SELECT
    rp.participantid + 100000 AS CustomerID,
    rp.fullname AS FullName,
    rp.phone AS Phone,
    'received_participant_' || rp.participantid || '@example.com' AS Email,
    NULL AS JoinDate
FROM received.participant rp
ON CONFLICT (CustomerID) DO NOTHING;
```
<img width="1335" height="903" alt="image" src="https://github.com/user-attachments/assets/7145626b-657e-42dc-b32c-25883ba4755c" />


---

### 11.10 Merging Received Trips Into GUIDEDTOUR

```sql
INSERT INTO GUIDEDTOUR
(
    TourID,
    StartDate,
    EndDate,
    StartTime,
    EndTime,
    MeetingPoint,
    Price,
    MaxParticipants,
    Notes,
    TourStatusID,
    GuideID,
    RouteID
)
SELECT
    rt.tripid + 100000 AS TourID,
    rt.departuredate AS StartDate,
    NULL AS EndDate,
    NULL AS StartTime,
    NULL AS EndTime,
    'Received system meeting point' AS MeetingPoint,
    rt.price AS Price,
    rt.maxcapacity AS MaxParticipants,
    'Received trip merged into GUIDEDTOUR' AS Notes,
    1 AS TourStatusID,
    rt.guideid + 100000 AS GuideID,
    rt.routeid + 100000 AS RouteID
FROM received.trip rt
ON CONFLICT (TourID) DO NOTHING;
```
<img width="1330" height="878" alt="image" src="https://github.com/user-attachments/assets/5d94a7a3-fbe0-4444-83ed-5810f6fd8783" />


---

### 11.11 Merging Received Bookings Into REGISTRATION

```sql
INSERT INTO REGISTRATION
(
    RegistrationID,
    RegistrationDate,
    AmountToPay,
    Notes,
    TourID,
    RegistrationStatusID,
    CustomerID
)
SELECT
    rb.bookingid + 100000 AS RegistrationID,
    rb.bookingdate AS RegistrationDate,
    rt.price AS AmountToPay,
    'Received booking status: ' || rb.status AS Notes,
    rb.tripid + 100000 AS TourID,
    CASE
        WHEN LOWER(rb.status) = 'cancelled' THEN 4
        WHEN LOWER(rb.status) = 'refunded' THEN 5
        WHEN LOWER(rb.status) = 'pending' THEN 7
        ELSE 2
    END AS RegistrationStatusID,
    rb.participantid + 100000 AS CustomerID
FROM received.booking rb
JOIN received.trip rt
    ON rb.tripid = rt.tripid
ON CONFLICT (RegistrationID) DO NOTHING;
```
<img width="1351" height="887" alt="image" src="https://github.com/user-attachments/assets/542ce4aa-de16-4dbb-add1-fbbfa609a0cd" />


---

### 11.12 Creating Payments From Received Bookings

```sql
INSERT INTO PAYMENT
(
    PaymentID,
    PaymentDate,
    Amount,
    Notes,
    PaymentMethod,
    ReferenceNumber,
    RegistrationID,
    PaymentStatusID
)
SELECT
    rb.bookingid + 200000 AS PaymentID,
    rb.bookingdate AS PaymentDate,
    rt.price AS Amount,
    'Payment derived from received booking status: ' || rb.status AS Notes,
    'Unknown' AS PaymentMethod,
    'RCV-' || rb.bookingid AS ReferenceNumber,
    rb.bookingid + 100000 AS RegistrationID,
    CASE
        WHEN LOWER(rb.status) = 'paid' THEN 3
        WHEN LOWER(rb.status) = 'refunded' THEN 4
        WHEN LOWER(rb.status) = 'cancelled' THEN 5
        ELSE 1
    END AS PaymentStatusID
FROM received.booking rb
JOIN received.trip rt
    ON rb.tripid = rt.tripid
ON CONFLICT (PaymentID) DO NOTHING;
```
<img width="1333" height="889" alt="image" src="https://github.com/user-attachments/assets/4568b4b5-cb59-47bb-ba60-3459551a5353" />


---

## 12. Integration Verification

After running `Integrate.sql`, we verified that the database contains data from both systems.

---

### 12.1 Row Count Verification

```sql
SELECT 'CUSTOMER' AS table_name, COUNT(*) AS row_count FROM CUSTOMER
UNION ALL
SELECT 'GUIDE', COUNT(*) FROM GUIDE
UNION ALL
SELECT 'ROUTE', COUNT(*) FROM ROUTE
UNION ALL
SELECT 'GUIDEDTOUR', COUNT(*) FROM GUIDEDTOUR
UNION ALL
SELECT 'REGISTRATION', COUNT(*) FROM REGISTRATION
UNION ALL
SELECT 'PAYMENT', COUNT(*) FROM PAYMENT
UNION ALL
SELECT 'LOCATION', COUNT(*) FROM LOCATION
UNION ALL
SELECT 'LOCATED_IN', COUNT(*) FROM LOCATED_IN
ORDER BY table_name;
```

Expected result after a clean integration run:

```text
CUSTOMER       20025
GUIDE          523
GUIDEDTOUR     523
LOCATION       505
LOCATED_IN     503
PAYMENT        20023
REGISTRATION   20023
ROUTE          523
```
<img width="1339" height="886" alt="image" src="https://github.com/user-attachments/assets/4993d935-e8ce-4f2c-94c6-35a915a2535c" />


---

### 12.2 Full Integration Query

```sql
SELECT
    c.CustomerID,
    c.FullName AS CustomerName,
    gt.TourID,
    gt.StartDate,
    r.Name AS RouteName,
    l.LocationName,
    g.GuideID,
    g.FirstName AS GuideFirstName,
    g.LastName AS GuideLastName,
    g.Expertise,
    p.Amount,
    p.PaymentMethod
FROM CUSTOMER c
JOIN REGISTRATION reg
    ON c.CustomerID = reg.CustomerID
JOIN GUIDEDTOUR gt
    ON reg.TourID = gt.TourID
JOIN ROUTE r
    ON gt.RouteID = r.RouteID
LEFT JOIN LOCATED_IN li
    ON r.RouteID = li.RouteID
LEFT JOIN LOCATION l
    ON li.LocationID = l.LocationID
JOIN GUIDE g
    ON gt.GuideID = g.GuideID
LEFT JOIN PAYMENT p
    ON reg.RegistrationID = p.RegistrationID
ORDER BY c.CustomerID, gt.TourID
LIMIT 100;
```

This query proves the full integrated flow:

```text
CUSTOMER → REGISTRATION → GUIDEDTOUR → ROUTE → LOCATED_IN → LOCATION
```

It also proves the connection between:

```text
GUIDEDTOUR → GUIDE
REGISTRATION → PAYMENT
```
<img width="1332" height="894" alt="image" src="https://github.com/user-attachments/assets/b746facc-1b80-4217-beec-b5544188d15b" />

---

## 13. Views

The views are stored in:

```text
Views.sql
```

The file contains two views:

1. `vw_tour_guide_department_view`  
   View from the original Tour Guide Management System point of view.

2. `vw_route_management_department_view`  
   View from the received Route Management System point of view.

Each view combines several tables and supports meaningful queries.

---

## 14. View 1 – Tour Guide Department View

### 14.1 View Description

The first view represents the point of view of our original department: the Tour Guide Management System.

The view combines:

- `GUIDEDTOUR`
- `GUIDE`
- `ROUTE`
- `DIFFICULTYLEVEL`
- `LOCATION`
- `LOCATED_IN`
- `REGISTRATION`

The purpose of this view is to provide operational information about guided tours, guides, routes, locations, and number of registrations.

---

### 14.2 View Creation

```sql
CREATE OR REPLACE VIEW vw_tour_guide_department_view AS
SELECT
    gt.TourID,
    gt.StartDate,
    gt.EndDate,
    gt.StartTime,
    gt.EndTime,
    gt.MeetingPoint,
    gt.Price,
    gt.MaxParticipants,
    gt.Notes AS TourNotes,
    g.GuideID,
    g.FirstName AS GuideFirstName,
    g.LastName AS GuideLastName,
    g.Phone AS GuidePhone,
    g.Email AS GuideEmail,
    r.RouteID,
    r.Name AS RouteName,
    dl.DifficultyName,
    l.LocationName,
    COUNT(reg.RegistrationID) AS NumberOfRegistrations
FROM GUIDEDTOUR gt
JOIN GUIDE g ON gt.GuideID = g.GuideID
JOIN ROUTE r ON gt.RouteID = r.RouteID
JOIN DIFFICULTYLEVEL dl ON r.DifficultyID = dl.DifficultyID
LEFT JOIN LOCATED_IN li ON r.RouteID = li.RouteID
LEFT JOIN LOCATION l ON li.LocationID = l.LocationID
LEFT JOIN REGISTRATION reg ON gt.TourID = reg.TourID
GROUP BY
    gt.TourID,
    gt.StartDate,
    gt.EndDate,
    gt.StartTime,
    gt.EndTime,
    gt.MeetingPoint,
    gt.Price,
    gt.MaxParticipants,
    gt.Notes,
    g.GuideID,
    g.FirstName,
    g.LastName,
    g.Phone,
    g.Email,
    r.RouteID,
    r.Name,
    dl.DifficultyName,
    l.LocationName;
```
<img width="1344" height="893" alt="image" src="https://github.com/user-attachments/assets/6f769f3c-cb4d-4f51-8bf6-3538ee41c192" />


---

### 14.3 Select From View 1

```sql
SELECT *
FROM vw_tour_guide_department_view
LIMIT 10;
```
<img width="1338" height="892" alt="image" src="https://github.com/user-attachments/assets/0216baef-4ff3-4f69-ab82-34732bc07b4c" />


---

### 14.4 Query 1.1 – Tours With Available Seats

```sql
SELECT
    TourID,
    RouteName,
    LocationName,
    GuideFirstName,
    GuideLastName,
    StartDate,
    MaxParticipants,
    NumberOfRegistrations,
    (MaxParticipants - NumberOfRegistrations) AS AvailableSeats
FROM vw_tour_guide_department_view
WHERE NumberOfRegistrations < MaxParticipants
ORDER BY AvailableSeats DESC;
```

#### Explanation

This query displays tours that still have available seats for additional customers.

It is useful for the Tour Guide Management department because it helps identify which tours can still accept new registrations.

<img width="1343" height="815" alt="image" src="https://github.com/user-attachments/assets/972f440b-1c52-40ce-b34b-0699d0e4e648" />


---

### 14.5 Query 1.2 – Most Popular Guided Tours

```sql
SELECT
    TourID,
    RouteName,
    DifficultyName,
    LocationName,
    StartDate,
    Price,
    NumberOfRegistrations
FROM vw_tour_guide_department_view
WHERE NumberOfRegistrations > 0
ORDER BY NumberOfRegistrations DESC, StartDate;
```

#### Explanation

This query displays the most popular guided tours according to the number of registrations.

It helps the department understand customer demand and identify active tours.
<img width="1345" height="885" alt="image" src="https://github.com/user-attachments/assets/bf84686c-5a3d-4e2b-8360-73998514e3b8" />


---

## 15. View 2 – Route Management Department View

### 15.1 View Description

The second view represents the point of view of the received department: the Route Management System.

The view combines:

- `ROUTE`
- `DIFFICULTYLEVEL`
- `LOCATION`
- `LOCATED_IN`
- `GUIDEDTOUR`

The purpose of this view is to support route analysis, route planning, and operational decision-making.

---

### 15.2 View Creation

```sql
CREATE OR REPLACE VIEW vw_route_management_department_view AS
SELECT
    r.RouteID,
    r.Name AS RouteName,
    r.Description AS RouteDescription,
    r.EstimatedLength,
    r.EstimatedDuration,
    dl.DifficultyName,
    l.LocationID,
    l.LocationName,
    l.Category AS LocationCategory,
    COUNT(gt.TourID) AS NumberOfGuidedTours,
    AVG(gt.Price) AS AverageTourPrice
FROM ROUTE r
JOIN DIFFICULTYLEVEL dl ON r.DifficultyID = dl.DifficultyID
LEFT JOIN LOCATED_IN li ON r.RouteID = li.RouteID
LEFT JOIN LOCATION l ON li.LocationID = l.LocationID
LEFT JOIN GUIDEDTOUR gt ON r.RouteID = gt.RouteID
GROUP BY
    r.RouteID,
    r.Name,
    r.Description,
    r.EstimatedLength,
    r.EstimatedDuration,
    dl.DifficultyName,
    l.LocationID,
    l.LocationName,
    l.Category;
```
<img width="1329" height="890" alt="image" src="https://github.com/user-attachments/assets/a006728f-e020-4bb1-a829-a277b1bbb704" />


---

### 15.3 Select From View 2

```sql
SELECT *
FROM vw_route_management_department_view
LIMIT 10;
```
<img width="1334" height="898" alt="image" src="https://github.com/user-attachments/assets/1cb031ca-4da9-4520-acad-a7a0397b2820" />


---

### 15.4 Query 2.1 – Most Active Routes

```sql
SELECT
    RouteID,
    RouteName,
    LocationName,
    DifficultyName,
    NumberOfGuidedTours
FROM vw_route_management_department_view
WHERE NumberOfGuidedTours > 0
ORDER BY NumberOfGuidedTours DESC, RouteName;
```

#### Explanation

This query displays the routes with the highest number of guided tours.

It is useful for the Route Management department because it helps identify the most active and important routes.
<img width="1349" height="881" alt="image" src="https://github.com/user-attachments/assets/031acf60-a294-472f-b48a-e5a6eab99484" />


---

### 15.5 Query 2.2 – Long or Expensive Routes

```sql
SELECT
    RouteID,
    RouteName,
    LocationName,
    DifficultyName,
    EstimatedLength,
    EstimatedDuration,
    ROUND(AverageTourPrice, 2) AS AverageTourPrice
FROM vw_route_management_department_view
WHERE EstimatedLength >= 5
   OR AverageTourPrice >= 150
ORDER BY EstimatedLength DESC, AverageTourPrice DESC;
```

#### Explanation

This query displays routes that are either long or have a high average tour price.

It helps the Route Management department identify routes that may require more planning, resources, or pricing attention.
<img width="1331" height="911" alt="image" src="https://github.com/user-attachments/assets/159704e3-0291-4328-8825-7dff1cdab3e1" />

---

## 16. Updated Backup File

After completing the integration, an updated backup file was created:

```text
backup3
```

The backup contains:

- Original tables
- Integrated tables
- Updated schema
- Foreign keys
- Constraints
- Views
- Data from both systems
<img width="1335" height="874" alt="image" src="https://github.com/user-attachments/assets/2ba7bf49-bd4c-44b0-bf58-56a4da77544b" />

---

## 17. Summary

In Phase 3, we successfully integrated the Tour Guide Management System with the received Route Management System.

The integration included:

- Importing the received backup into a separate schema named `received`
- Reverse engineering of the received database
- Creating an ERD for the received system
- Designing a unified ERD
- Updating the database schema according to the unified ERD
- Adding the `Expertise` attribute to `GUIDE`
- Adding `LOCATION` and `LOCATED_IN`
- Merging `PARTICIPANT` into `CUSTOMER`
- Merging `TRIP` into `GUIDEDTOUR`
- Merging `BOOKING` into `REGISTRATION`
- Creating `PAYMENT` records from received bookings
- Preserving referential integrity
- Avoiding primary key conflicts by shifting received IDs
- Creating two views
- Writing two meaningful queries for each view
- Creating an updated backup file named `backup3`

The final database is a unified integrated database that contains data from both systems and supports both the original Tour Guide department and the received Route Management department.
---

# Phase 4: Programming with PL/pgSQL

This phase focuses on writing PL/pgSQL functions, procedures, triggers, and main programs based on the integrated tour guide and route management database.

The goal is to demonstrate advanced server-side programming logic using:

- Explicit and implicit cursors
- Returning refcursors
- DML operations
- Conditionals
- Loops
- Exception handling
- Records

We implemented:

- 2 Functions
- 2 Procedures
- 2 Triggers
- 2 Main test blocks, each invoking one function and one procedure
- 1 Additional table for audit tracking

---

# 1. Function: fn_calculate_customer_payment_status

## Description

Calculates the financial payment status of a specific customer.

The function receives a customer ID and returns the customer name, total registered amount, total paid amount, remaining debt, and a textual status description.

It checks whether the customer exists, calculates the total cost of all registrations, calculates the total paid amount, and classifies the customer as fully paid, partially paid, critical debt, no activity, or error.

## Features used

- OUT parameters
- SELECT INTO
- RECORD
- Aggregate calculations
- Conditionals
- Exception handling
- RAISE NOTICE

```sql
CREATE OR REPLACE FUNCTION fn_calculate_customer_payment_status(
    p_customer_id INT,
    OUT o_customer_name VARCHAR,
    OUT o_total_registered NUMERIC(10,2),
    OUT o_total_paid NUMERIC(10,2),
    OUT o_debt NUMERIC(10,2),
    OUT o_status_description VARCHAR
)
AS $$
DECLARE
    v_financials RECORD;
    v_phone VARCHAR;
BEGIN
    RAISE NOTICE '--- Starting fn_calculate_customer_payment_status for Customer ID: % ---', p_customer_id;

    SELECT FullName, Phone INTO o_customer_name, v_phone
    FROM CUSTOMER
    WHERE CustomerID = p_customer_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Error: Customer ID % not found!', p_customer_id
            USING ERRCODE = 'no_data_found';
    END IF;

    SELECT 
        COALESCE(SUM(reg.AmountToPay), 0.00) AS total_fees,
        COALESCE(SUM(
            (SELECT SUM(p.Amount) 
             FROM PAYMENT p 
             JOIN PAYMENTSTATUS ps ON p.PaymentStatusID = ps.PaymentStatusID
             WHERE p.RegistrationID = reg.RegistrationID 
               AND ps.StatusName = 'Paid In Full')
        ), 0.00) AS total_payments
    INTO v_financials
    FROM REGISTRATION reg
    WHERE reg.CustomerID = p_customer_id;

    o_total_registered := v_financials.total_fees;
    o_total_paid := v_financials.total_payments;
    o_debt := o_total_registered - o_total_paid;

    IF o_total_registered = 0.00 THEN
        o_status_description := 'NO ACTIVITY (No registered tours found)';
    ELSIF o_debt <= 0.00 THEN
        o_status_description := 'SETTLED (Fully paid)';
    ELSIF o_debt > 1000.00 THEN
        o_status_description := 'CRITICAL DEBT (High debt detected! Contact customer immediately at ' || v_phone || ')';
    ELSIF o_debt > 0.00 AND o_debt <= 1000.00 THEN
        o_status_description := 'PARTIALLY PAID (Outstanding minor debt remaining)';
    ELSE
        o_status_description := 'REVIEW REQUIRED';
    END IF;

    RAISE NOTICE 'Customer Name: %, Phone: %', o_customer_name, v_phone;
    RAISE NOTICE 'Total Cost: %, Total Paid: %, Debt Remaining: %', o_total_registered, o_total_paid, o_debt;

EXCEPTION
    WHEN no_data_found THEN
        RAISE NOTICE 'Exception: Customer ID does not exist in the database.';
        o_customer_name := 'N/A';
        o_total_registered := 0.00;
        o_total_paid := 0.00;
        o_debt := 0.00;
        o_status_description := 'ERROR: CUSTOMER NOT FOUND';
    WHEN OTHERS THEN
        RAISE NOTICE 'General exception caught in customer function: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
        RAISE;
END;
$$ LANGUAGE plpgsql;
```

Screenshot of result:
<img width="345" height="91" alt="image" src="https://github.com/user-attachments/assets/447a7c64-1cf5-4c63-afa7-3e29abff3a90" />


---

# 2. Function: fn_get_route_tour_details_by_difficulty

## Description

Returns a refcursor with guided tour details according to a given difficulty level.

The function first validates that the difficulty exists, then uses cursors to calculate summary information such as total tours, average price, and maximum revenue potential. Finally, it returns a refcursor containing the matching tours.

## Features used

- Explicit cursor
- Refcursor
- RECORD
- LOOP
- Conditionals
- Exception handling
- RAISE NOTICE

```sql
CREATE OR REPLACE FUNCTION fn_get_route_tour_details_by_difficulty(
    p_difficulty_name VARCHAR
)
RETURNS refcursor AS $$
DECLARE
    ref_result refcursor := 'tours_cursor';
    
    cur_difficulty CURSOR FOR 
        SELECT DifficultyID 
        FROM DIFFICULTYLEVEL 
        WHERE LOWER(DifficultyName) = LOWER(p_difficulty_name);
        
    cur_tour_summary CURSOR FOR
        SELECT gt.Price, gt.MaxParticipants
        FROM GUIDEDTOUR gt
        JOIN ROUTE r ON gt.RouteID = r.RouteID
        JOIN DIFFICULTYLEVEL dl ON r.DifficultyID = dl.DifficultyID
        WHERE LOWER(dl.DifficultyName) = LOWER(p_difficulty_name);
        
    v_difficulty_id INT;
    v_tour_record RECORD;
    v_tour_count INT := 0;
    v_total_price NUMERIC(12,2) := 0.00;
    v_avg_price NUMERIC(10,2) := 0.00;
    v_max_revenue_potential NUMERIC(12,2) := 0.00;
BEGIN
    RAISE NOTICE '--- Starting fn_get_route_tour_details_by_difficulty for: % ---', p_difficulty_name;

    OPEN cur_difficulty;
    FETCH cur_difficulty INTO v_difficulty_id;
    
    IF NOT FOUND THEN
        CLOSE cur_difficulty;
        RAISE EXCEPTION 'Error: Difficulty level (%) not found!', p_difficulty_name
            USING ERRCODE = 'invalid_parameter_value';
    END IF;
    CLOSE cur_difficulty;

    OPEN cur_tour_summary;
    LOOP
        FETCH cur_tour_summary INTO v_tour_record;
        EXIT WHEN NOT FOUND;
        
        v_tour_count := v_tour_count + 1;
        v_total_price := v_total_price + v_tour_record.Price;
        v_max_revenue_potential := v_max_revenue_potential + (v_tour_record.Price * v_tour_record.MaxParticipants);
    END LOOP;
    CLOSE cur_tour_summary;

    IF v_tour_count > 0 THEN
        v_avg_price := v_total_price / v_tour_count;
    ELSE
        v_avg_price := 0.00;
    END IF;

    RAISE NOTICE 'Difficulty Name: % (ID: %)', p_difficulty_name, v_difficulty_id;
    RAISE NOTICE 'Total Tours Found: %', v_tour_count;
    RAISE NOTICE 'Average Tour Price: %', v_avg_price;
    RAISE NOTICE 'Max Revenue Potential: %', v_max_revenue_potential;

    OPEN ref_result FOR
        SELECT 
            gt.TourID,
            r.Name AS RouteName,
            gt.StartDate,
            gt.MeetingPoint,
            gt.Price,
            gt.MaxParticipants,
            g.FirstName || ' ' || g.LastName AS AssignedGuide
        FROM GUIDEDTOUR gt
        JOIN ROUTE r ON gt.RouteID = r.RouteID
        JOIN DIFFICULTYLEVEL dl ON r.DifficultyID = dl.DifficultyID
        JOIN GUIDE g ON gt.GuideID = g.GuideID
        WHERE LOWER(dl.DifficultyName) = LOWER(p_difficulty_name)
        ORDER BY gt.StartDate;
        
    RETURN ref_result;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Exception caught in fn_get_route_tour_details_by_difficulty: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
        RAISE;
END;
$$ LANGUAGE plpgsql;
```

Screenshot of result:
<img width="343" height="76" alt="image" src="https://github.com/user-attachments/assets/4335a56b-7e35-4d38-abab-83de8da486d4" />

---

# 3. Procedure: pr_assign_optimal_guide_to_tour

## Description

Automatically assigns the best available guide to a tour according to the requested expertise.

The procedure checks the tour dates, searches for available guides with the correct expertise and rating of at least 4.0, and assigns the best guide based on rating and experience.

## Features used

- Explicit cursor with parameters
- RECORD
- Conditionals
- UPDATE statement
- NOT EXISTS
- Exception handling
- RAISE NOTICE

```sql
-- Code is located in:
-- phase4/scripts/procedures/auto_assign_guide.sql
```

Screenshot of result:
<img width="317" height="77" alt="image" src="https://github.com/user-attachments/assets/da70037c-c5b2-4228-b674-7ea79402cab7" />

---

# 4. Procedure: pr_apply_discount_to_tour_participants

## Description

Applies a discount to all registrations of a specific guided tour.

The procedure receives a tour ID and a discount percentage. It validates the discount value, checks that the tour exists, loops over all registrations of the tour, updates the amount to pay, and appends a note describing the discount.

## Features used

- Explicit cursor
- LOOP
- RECORD
- UPDATE statement
- Conditionals
- Exception handling
- RAISE NOTICE

```sql
-- Code is located in:
-- phase4/scripts/procedures/set_tour_discount.sql
```

Screenshot of result:
<img width="305" height="83" alt="image" src="https://github.com/user-attachments/assets/eb54156b-d367-4f5f-b2ca-af5a14c432c7" />

---

# 5. Trigger: trg_update_registration_payment_status

## Description

Automatically updates the registration status whenever a payment is inserted or updated.

The trigger calculates the total paid amount for the registration and updates the registration status according to the payment situation.

This trigger runs after INSERT or UPDATE on the PAYMENT table.

## Features used

- AFTER INSERT trigger
- AFTER UPDATE trigger
- DML operation
- Conditionals
- Trigger function
- Automatic status update

```sql
CREATE OR REPLACE FUNCTION fn_trg_update_registration_payment_status()
RETURNS TRIGGER AS $$
DECLARE
    v_amount_to_pay NUMERIC(10,2);
    v_total_paid NUMERIC(10,2) := 0.00;
    v_new_status_id INT;
BEGIN
    SELECT AmountToPay INTO v_amount_to_pay
    FROM REGISTRATION
    WHERE RegistrationID = NEW.RegistrationID;
    
    IF NOT FOUND THEN
        RETURN NEW;
    END IF;

    SELECT COALESCE(SUM(Amount), 0.00) INTO v_total_paid
    FROM PAYMENT
    WHERE RegistrationID = NEW.RegistrationID
      AND PaymentStatusID = 3;

    IF v_total_paid >= v_amount_to_pay AND v_amount_to_pay > 0.00 THEN
        v_new_status_id := 2;
    ELSIF v_total_paid > 0.00 AND v_total_paid < v_amount_to_pay THEN
        v_new_status_id := 8;
    ELSE
        v_new_status_id := 7;
    END IF;

    UPDATE REGISTRATION
    SET RegistrationStatusID = v_new_status_id
    WHERE RegistrationID = NEW.RegistrationID;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_registration_payment_status ON PAYMENT;
CREATE TRIGGER trg_update_registration_payment_status
AFTER INSERT OR UPDATE OF PaymentStatusID, Amount
ON PAYMENT
FOR EACH ROW
EXECUTE FUNCTION fn_trg_update_registration_payment_status();
```

Screenshot of result:
<img width="921" height="304" alt="image" src="https://github.com/user-attachments/assets/c9edd199-ac3b-4644-a8ab-2ac81eee6361" />

---

# 6. Trigger: trg_audit_tour_changes

## Description

Tracks changes made to the GUIDEDTOUR table.

The trigger writes audit records into the TOUR_AUDIT table whenever a guided tour is inserted, updated, or deleted. For UPDATE operations, it stores changes in price or assigned guide.

This trigger satisfies the requirement for an UPDATE trigger.

## Features used

- AFTER INSERT trigger
- AFTER UPDATE trigger
- AFTER DELETE trigger
- Audit table
- OLD and NEW records
- INSERT DML operation
- Trigger function

```sql
CREATE OR REPLACE FUNCTION fn_trg_audit_tour_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF (OLD.Price IS DISTINCT FROM NEW.Price OR OLD.GuideID IS DISTINCT FROM NEW.GuideID) THEN
            INSERT INTO TOUR_AUDIT (TourID, Action, OldPrice, NewPrice, OldGuideID, NewGuideID)
            VALUES (NEW.TourID, 'UPDATE', OLD.Price, NEW.Price, OLD.GuideID, NEW.GuideID);
        END IF;
        RETURN NEW;

    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO TOUR_AUDIT (TourID, Action, NewPrice, NewGuideID)
        VALUES (NEW.TourID, 'INSERT', NEW.Price, NEW.GuideID);
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO TOUR_AUDIT (TourID, Action, OldPrice, OldGuideID)
        VALUES (OLD.TourID, 'DELETE', OLD.Price, OLD.GuideID);
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_tour_changes ON GUIDEDTOUR;
CREATE TRIGGER trg_audit_tour_changes
AFTER INSERT OR UPDATE OR DELETE
ON GUIDEDTOUR
FOR EACH ROW
EXECUTE FUNCTION fn_trg_audit_tour_changes();
```

Screenshot of result:
<img width="1125" height="272" alt="image" src="https://github.com/user-attachments/assets/a36a7d72-4d5d-402a-b1b1-491c88bebe5f" />

---

# 7. Main Block 1: financials_and_discounts

## Description

Demonstrates the customer financial status function and the discount procedure.

The program first checks the customer’s financial status, then applies a discount to a selected tour, and finally checks the customer’s financial status again after the update.

It also tests exception handling by trying to apply an invalid discount.

## Invokes

- Function: `fn_calculate_customer_payment_status`
- Procedure: `pr_apply_discount_to_tour_participants`

```sql
-- Code is located in:
-- phase4/scripts/main/financials_and_discounts.sql
```

Screenshot of result:
<img width="774" height="656" alt="image" src="https://github.com/user-attachments/assets/e6676c01-71f3-4cca-b495-9517f32ec221" />

---

# 8. Main Block 2: mainProgram2

## Description

Demonstrates the route difficulty refcursor function and the automatic guide assignment procedure.

The program fetches tours according to a selected difficulty level, prints the tours using a loop over the refcursor, assigns an optimal guide to a tour, and tests exception handling with a non-existing tour ID.

## Invokes

- Function: `fn_get_route_tour_details_by_difficulty`
- Procedure: `pr_assign_optimal_guide_to_tour`

```sql
-- Code is located in:
-- phase4/scripts/main/mainProgram2.sql
```

Screenshot of result:
<img width="775" height="583" alt="image" src="https://github.com/user-attachments/assets/db625de2-f7d3-4cc3-a258-89874dc11d8b" />

---

# 9. Alter Table / Additional Table

## Description

An additional audit table was created in order to support the tour audit trigger.

The table stores changes made to guided tours, including price changes, guide changes, the user who made the change, and the timestamp of the change.

```sql
CREATE TABLE IF NOT EXISTS TOUR_AUDIT (
    AuditID SERIAL PRIMARY KEY,
    TourID INT NOT NULL,
    Action VARCHAR(10) NOT NULL,
    OldPrice NUMERIC(10,2),
    NewPrice NUMERIC(10,2),
    OldGuideID INT,
    NewGuideID INT,
    ChangedBy VARCHAR(100) DEFAULT CURRENT_USER,
    ChangedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE TOUR_AUDIT IS 'Audit table for tracking DML actions on the guided tours table';
```

Screenshot of result:
<img width="1334" height="887" alt="image" src="https://github.com/user-attachments/assets/7d351b56-fe60-41b4-9e08-de0533bcf626" />

---
# Backup File (Phase 4)

A full backup of the database after completing Phase 4 is included.

📁 Location:

```text
backups/backup4.sql
```

<img width="1375" height="896" alt="image" src="https://github.com/user-attachments/assets/f2c47078-09c7-49ba-b398-df0f22faa817" />

## Contents

- All tables (schema)
- All records (data)
- Functions
- Procedures
- Triggers
- Constraints
- Indexes
- Audit table
- PL/pgSQL programs

## Purpose

This backup allows full restoration of the database state after completing Phase 4, including all PL/pgSQL programming components and trigger logic.

---
# Summary

All Phase 4 programs were implemented and tested successfully.

This phase includes:

- Two PL/pgSQL functions
- Two PL/pgSQL procedures
- Two triggers
- Two main programs
- One audit table

The programs demonstrate advanced PL/pgSQL features such as cursors, refcursors, DML operations, conditionals, loops, exception handling, records, and triggers.

The screenshots above prove that each program executed successfully and performed its intended database operation.
---

# Stage 5 – Full Stack Web Application & Database Integration

## Overview

Stage 5 presents the complete implementation of the Tour Guide Management System as a full-stack web application connected directly to the PostgreSQL database developed throughout the previous stages.

The system provides a modern administrative interface for managing guides, routes, tours, customers, registrations, payments, locations, analytical queries, functions, procedures, and triggers.

Unlike previous stages that focused primarily on database design and SQL development, this stage demonstrates the integration of all database components into a real-world management application.

---

# Technologies Used

## Frontend

- React
- TypeScript
- Tailwind CSS
- Shadcn UI
- Lucide Icons

## Backend

- Node.js
- Express.js

## Database

- PostgreSQL
- PL/pgSQL
- Views
- Functions
- Procedures
- Triggers

---

# Main System Features

---

# Dashboard

The Dashboard serves as the central hub of the system and provides administrators with quick access to all modules and system statistics.

## Features

- Overview of system activity
- Quick navigation to all modules
- Live database connection indicator
- Upcoming tours section
- Shortcuts for analytics and programs
- Responsive dark-gold interface

<img width="956" height="445" alt="stage5_dashboard_overview1" src="https://github.com/user-attachments/assets/e535586b-b5a8-4320-8507-5fe6488d8b14" />

<img width="956" height="450" alt="stage5_dashboard_overview2" src="https://github.com/user-attachments/assets/48b73275-0d1a-4e9d-a736-d7c932379690" />

<img width="183" height="441" alt="stage5_sidebar_navigation" src="https://github.com/user-attachments/assets/84b0ca56-b520-459c-a350-02d02d8729c1" />

---

# Guides Management

The Guides module manages all tour guides stored in the system.

## Features

- View all guides
- Create guides
- Edit guide information
- Delete guides
- Manage expertise levels
- Manage guide ratings

## Database Objects Used

- GUIDE

<img width="958" height="445" alt="צילום מסך 2026-06-17 130802" src="https://github.com/user-attachments/assets/9e14b028-7dec-442e-95ef-0678bdbdcbe0" />

---

## Create Guide

Administrators can add new guides through the interface.

### Features

- Guide information
- Expertise level
- Contact details
- Rating information

<img width="955" height="448" alt="צילום מסך 2026-06-17 130815" src="https://github.com/user-attachments/assets/c613f7ff-795b-487b-883f-8d6dbd0ae3c6" />

---

# Routes Management

The Routes module manages available tour routes and difficulty levels.

## Features

- View routes
- Create routes
- Edit routes
- Delete routes
- Assign difficulty levels

## Database Objects Used

- ROUTE
- DIFFICULTYLEVEL

<img width="951" height="448" alt="צילום מסך 2026-06-17 130824" src="https://github.com/user-attachments/assets/de7dae20-c4be-41bf-baa0-d649c58908fb" />

---

## Create Route

Administrators can add new routes.

### Features

- Route information
- Difficulty level
- Route description

<img width="958" height="446" alt="צילום מסך 2026-06-17 130832" src="https://github.com/user-attachments/assets/c5d82985-ff08-4295-bbaf-5889c7347726" />

---

# Tours Management

The Tours module manages scheduled guided tours.

## Features

- View tours
- Create tours
- Update tours
- Delete tours
- Assign routes
- Assign guides

## Database Objects Used

- GUIDEDTOUR
- GUIDE
- ROUTE

<img width="956" height="446" alt="צילום מסך 2026-06-17 130841" src="https://github.com/user-attachments/assets/d1a67917-3f57-4a6a-93f3-328e07233751" />

---

## Create Tour

Administrators can schedule new tours.

### Features

- Route selection
- Guide assignment
- Tour date
- Capacity management

<img width="956" height="450" alt="צילום מסך 2026-06-17 130853" src="https://github.com/user-attachments/assets/1933c6d5-0d8d-47ed-b6d1-d83fb209751a" />

---

# Customers Management

The Customers module manages customer information.

## Features

- View customers
- Create customers
- Update customer information
- Delete customers

## Database Objects Used

- CUSTOMER

<img width="956" height="449" alt="צילום מסך 2026-06-17 130902" src="https://github.com/user-attachments/assets/d90a13dc-9ab0-43ac-999d-7b882da264d1" />

---

## Create Customer

Administrators can register new customers.

### Features

- Customer details
- Contact information

<img width="959" height="448" alt="צילום מסך 2026-06-17 130909" src="https://github.com/user-attachments/assets/5414b531-8cbc-463c-81cf-c2b28de27f39" />

---

# Registrations Management

The Registrations module allows administrators to manage customer registrations for guided tours.

## Features

- View all registrations
- Create registrations
- Update registrations
- Delete registrations
- Connect customers to tours
- Assign registration statuses

## Database Objects Used

- CUSTOMER
- GUIDEDTOUR
- REGISTRATION
- REGISTRATIONSTATUS

<img width="956" height="448" alt="צילום מסך 2026-06-17 130918" src="https://github.com/user-attachments/assets/5b07a330-afda-4cac-8502-efd2c63d33bc" />

---

## Create Registration

Administrators can register customers for available tours.

### Features

- Customer selection
- Tour selection
- Payment amount
- Registration status
- Notes

## Database Objects Used

- REGISTRATION
- CUSTOMER
- GUIDEDTOUR

<img width="958" height="443" alt="צילום מסך 2026-06-17 130926" src="https://github.com/user-attachments/assets/c116eea5-a9be-4f79-892b-8810ef9dfa3d" />

---

# Payments Management

The Payments module demonstrates the integration between application logic and database triggers.

## Features

- View payments
- Record payments
- Delete payments
- Monitor payment status
- Trigger automatic registration updates

## Database Objects Used

- PAYMENT
- REGISTRATION

<img width="956" height="449" alt="צילום מסך 2026-06-17 130935" src="https://github.com/user-attachments/assets/2d3cd7c1-df3f-41b5-83fa-a516ed13ea5e" />

---

## Record Payment

A new payment can be recorded directly through the interface.

### Features

- Registration selection
- Amount entry
- Payment status selection

## Database Objects Used

- PAYMENT

<img width="958" height="449" alt="צילום מסך 2026-06-17 130943" src="https://github.com/user-attachments/assets/14e99378-a0db-461f-ad4d-020c835af950" />

---

## Trigger Integration

When a payment is inserted or updated, the trigger below is executed automatically:

```sql
trg_update_registration_payment_status
```

This trigger updates the registration status according to the payment status.

### Demonstrated Concepts

- AFTER INSERT Trigger
- AFTER UPDATE Trigger
- Automatic database actions
- Business rule enforcement

<img width="756" height="104" alt="image" src="https://github.com/user-attachments/assets/b1378561-b9fc-42c9-b8b7-9eafe3af02f2" />

---

# Locations Management

The Locations module manages geographical locations associated with routes.

## Features

- Create locations
- Update locations
- Delete locations
- Search locations

## Database Objects Used

- LOCATION

<img width="959" height="445" alt="צילום מסך 2026-06-17 130950" src="https://github.com/user-attachments/assets/b7ae3694-3c7a-4712-bdb6-ec8662b33839" />

---

## Create Location

Administrators can add new locations.

### Features

- Location name
- Category
- Description

## Database Objects Used

- LOCATION

<img width="958" height="445" alt="צילום מסך 2026-06-17 130959" src="https://github.com/user-attachments/assets/0b2de5f4-3797-413c-afeb-dac3f13db50d" />

---

# Analytics Module

The Analytics module executes advanced SQL queries developed during Stage 2.

All queries are executed directly against the PostgreSQL database.

## Features

- Dynamic query execution
- Real-time results
- Parameterized queries
- Database reporting

<img width="956" height="441" alt="צילום מסך 2026-06-17 131011" src="https://github.com/user-attachments/assets/41a76d11-5886-4f7a-8972-afbeb676c253" />

---

## Query 1 – High-Earning Guides

Identifies guides who generated the highest revenue during a selected month.

### Database Concepts

- JOIN
- GROUP BY
- Aggregation Functions

### Database Objects Used

- GUIDE
- GUIDEDTOUR
- PAYMENT
- REGISTRATION

<img width="953" height="448" alt="image" src="https://github.com/user-attachments/assets/498cb37e-59ea-4da2-b79b-ddd348109bd6" />

---

## Query 2 – Monthly Revenue Analysis

Calculates total revenue and transaction volume for a selected year.

### Database Concepts

- Aggregation
- Date Functions
- Reporting

<img width="955" height="442" alt="image" src="https://github.com/user-attachments/assets/54c9810f-0cb8-4b15-a491-28f3984719e6" />

---

## Query 3 – VIP Customer Loyalty

Identifies customers whose spending exceeds ₪2,000 during the last year.

### Database Concepts

- Aggregation
- Filtering
- Customer Segmentation

<img width="956" height="440" alt="image" src="https://github.com/user-attachments/assets/a80860a6-c55e-4b66-8e3e-706a7f415f6c" />

---

## Query 4 – Elite Guides

Identifies guides who meet performance requirements.

### Database Concepts

- Subqueries
- AVG
- HAVING

<img width="956" height="445" alt="image" src="https://github.com/user-attachments/assets/fb595889-268d-4a68-87cf-c863d536009e" />

---

## Query 5 – Popular Routes

Displays routes used in multiple guided tours and ranks them according to popularity.

### Database Concepts

- Ranking
- Aggregation
- JOIN Operations

<img width="957" height="443" alt="image" src="https://github.com/user-attachments/assets/c96b1fa3-3581-48d5-8993-8a34ced1b766" />

---

# Programs Module

The Programs module demonstrates all PL/pgSQL objects implemented during Stage 4.

## Included Objects

- Functions
- Refcursor Functions
- Procedures
- Triggers

<img width="959" height="449" alt="image" src="https://github.com/user-attachments/assets/aed0b166-2d5a-4410-87fc-6cfd97a39ac9" />

---

# Function 1

## fn_calculate_customer_payment_status

Calculates the complete financial status of a customer.

### Input

```text
Customer ID
```

### Output

- Total Cost
- Total Paid
- Remaining Debt
- Payment Classification

<img width="956" height="451" alt="image" src="https://github.com/user-attachments/assets/dea020bb-b769-4973-be2f-edd51827b5fc" />

---

# Function 2

## fn_get_route_tour_details_by_difficulty

Returns guided tour details according to difficulty level using a refcursor.

### Input

```text
Difficulty Name
```

### Output

- Route Information
- Guide Information
- Tour Details
- Summary Statistics

<img width="953" height="442" alt="image" src="https://github.com/user-attachments/assets/3b43580e-ad5a-4e9f-9afd-3f9b9dcf7f76" />

---

# Procedure 1

## pr_assign_optimal_guide_to_tour

Automatically assigns the most suitable guide to a tour.

### Selection Criteria

- Expertise
- Rating
- Availability

<img width="953" height="443" alt="image" src="https://github.com/user-attachments/assets/53f7dade-d8b1-4c87-b964-a7863ec951c9" />

---

# Procedure 2

## pr_apply_discount_to_tour_participants

Applies a discount to all registrations associated with a selected tour.

### Input

```text
Tour ID
Discount Percentage
```

<img width="956" height="445" alt="image" src="https://github.com/user-attachments/assets/e397b674-ebb5-4683-9cc4-6d3661cf9748" />

---

# Active Triggers

## Trigger 1

### trg_update_registration_payment_status

Automatically updates registration status whenever a payment is inserted or modified.

### Events

```text
AFTER INSERT
AFTER UPDATE
```

### Table

```text
PAYMENT
```

<img width="377" height="144" alt="image" src="https://github.com/user-attachments/assets/5c00e5c4-fecb-447c-b33c-9e0187586c3b" />

---

## Trigger 2

### trg_audit_tour_changes

Logs all modifications performed on guided tours.

### Events

```text
AFTER INSERT
AFTER UPDATE
AFTER DELETE
```

### Table

```text
GUIDEDTOUR
```

### Audit Information

- Previous values
- New values
- Timestamp
- Operation type

<img width="364" height="148" alt="image" src="https://github.com/user-attachments/assets/2d04106d-e0e8-40bc-afdc-9f3554c35d3a" />

---

# Database Integration

The application communicates directly with PostgreSQL.

## Supported Operations

- SELECT
- INSERT
- UPDATE
- DELETE

## Advanced Features

- Views
- Functions
- Procedures
- Triggers
- Transactions
- Refcursors

---

# Conclusion

Stage 5 successfully integrates all database components developed throughout the project into a complete full-stack web application.

The final system demonstrates:

- Database Design
- SQL Development
- Advanced Queries
- Views
- Functions
- Procedures
- Triggers
- Full CRUD Operations
- Backend Integration
- Frontend Development
- Real-Time Database Interaction

This stage represents the complete implementation of the Tour Guide Management System and showcases the practical use of PostgreSQL technologies within a production-style application.

---

# How to Run the Project

## Requirements

Before running the project, make sure the following software is installed:

- Docker Desktop
- Docker Compose (included with Docker Desktop)
- Git

---

## Clone the Repository

```bash
git clone https://github.com/GilatKedem/DB_5786_6363_2029.git
cd DB_5786_6363_2029
```

---

## Run the System

Open a terminal in the project's root directory and run:

```bash
docker-compose up -d
```

This command automatically starts all required containers:

- PostgreSQL Database
- Backend Server
- Frontend Application
- pgAdmin

---

## Verify Running Containers

To verify that all containers are running successfully:

```bash
docker ps
```

You should see the following containers:

- PostgreSQL_DB
- TourGuide_Backend
- TourGuide_Frontend
- pgadminApp

---

## Access the Application

After all containers are running, open the browser and access:

```text
Frontend:
http://localhost:5173

Backend API:
http://localhost:3000

pgAdmin:
http://localhost:8080
```

---

## Stop the System

To stop all running containers:

```bash
docker-compose down
```

---

## Notes

- The project is fully containerized using Docker.
- No manual database installation is required.
- No manual PostgreSQL configuration is required.
- All services communicate automatically through Docker Compose.
- The application connects directly to the PostgreSQL database.
- All CRUD operations, analytics queries, functions, procedures, triggers, and views are available through the graphical user interface.
