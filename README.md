# Tour Guide Management System  
---

## Cover Page

**Submitted by:**  
Gilat Malka – 213196363  
Shirel Ankawa – 209692029  

**System Name:**  
Tour Guide Management System  

**Selected Unit:**  
Guided Tour Management  

---

## Table of Contents
1. Introduction  
2. System Screens (AI)  
3. ERD Diagram  
4. DSD Diagram  
5. Design Decisions  
6. Data Insertion  
7. Backup and Restore  

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

A full backup of the database was performed.

📌 The following should be added:
- Screenshot of the backup operation  
- Backup file  
- Screenshot of the data restore process  

**Purpose of the backup:**

- Restoring data in case of failure  
- Preserving the system state  

---

##  Summary

At this stage, the following were completed:

- System characterization  
- Construction of ERD and DSD diagrams  
- Database creation  
- Data insertion using three methods  
- Performing backup and restore  

The system constitutes a stable foundation for continued development in the next stages.
