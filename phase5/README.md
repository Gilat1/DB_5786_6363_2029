# Phase 5 – Tour Guide Management System GUI

A full-stack graphical interface for the Tour Guide Management System (Phases 1–4).

## Tech Stack

- **Frontend**: React 18 + TypeScript + Vite + Tailwind CSS
- **Backend**: Node.js + Express + pg (PostgreSQL driver)
- **Database**: PostgreSQL (your existing DBsecret)

---

## Setup Instructions

### 1. Configure Database Connection

Copy the example env file and fill in your credentials:

```bash
cd backend
cp .env.example .env
```

Edit `.env`:
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=DBsecret
DB_USER=postgres
DB_PASSWORD=your_password
PORT=3001
```

### 2. Install Dependencies

```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install
```

### 3. Run the Application

Open **two terminal windows**:

**Terminal 1 – Backend:**
```bash
cd backend
npm start
# Server runs on http://localhost:3001
```

**Terminal 2 – Frontend:**
```bash
cd frontend
npm run dev
# App runs on http://localhost:5173
```

Open http://localhost:5173 in your browser.

---

## Features

### CRUD Operations (All Tables)
| Page | Tables | Operations |
|------|--------|-----------|
| Guides | GUIDE | Create, Read, Update, Delete |
| Routes | ROUTE, DIFFICULTYLEVEL | Create, Read, Update, Delete |
| Tours | GUIDEDTOUR, TOURSTATUS | Create, Read, Update, Delete |
| Customers | CUSTOMER | Create, Read, Update, Delete |
| Registrations | REGISTRATION, REGISTRATIONSTATUS | Create, Read, Update, Delete |
| Payments | PAYMENT, PAYMENTSTATUS | Create, Read, Delete |
| Locations | LOCATION | Create, Read, Update, Delete |

### Analytics (Phase 2 Queries)
- Query 1: High-Earning Guides by month
- Query 2: Monthly Revenue Analysis
- Query 3: VIP Customer Loyalty Program
- Query 4: Elite Guides (above-average rating)
- Query 5: Popular Routes

### Programs (Phase 4)
- **fn_calculate_customer_payment_status** – Customer financial status
- **fn_get_route_tour_details_by_difficulty** – Tours by difficulty (refcursor)
- **pr_assign_optimal_guide_to_tour** – Auto-assign best guide
- **pr_apply_discount_to_tour_participants** – Apply discount to tour
- **trg_update_registration_payment_status** – Auto-trigger on payment
- **trg_audit_tour_changes** – Audit trail for tour changes

### Design Features
- Dark themed, warm desert aesthetic
- Real-time search/filtering on all tables
- Auto-filled forms when editing (click any row)
- Foreign keys resolved to readable names everywhere
- Toast notifications for all operations
- Responsive layout with collapsible sidebar
- Loading states and error handling
