const BASE = '/api';

async function request<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Request failed');
  return data as T;
}

// ── GUIDES ──────────────────────────────────────────────────────────────────
export const getGuides = () => request<Guide[]>('/guides');
export const getGuide = (id: number) => request<Guide>(`/guides/${id}`);
export const createGuide = (body: Partial<Guide>) => request<Guide>('/guides', { method: 'POST', body: JSON.stringify(body) });
export const updateGuide = (id: number, body: Partial<Guide>) => request<Guide>(`/guides/${id}`, { method: 'PUT', body: JSON.stringify(body) });
export const deleteGuide = (id: number) => request<{ message: string }>(`/guides/${id}`, { method: 'DELETE' });

// ── ROUTES ───────────────────────────────────────────────────────────────────
export const getRoutes = () => request<Route[]>('/routes');
export const getRoute = (id: number) => request<Route>(`/routes/${id}`);
export const createRoute = (body: Partial<Route>) => request<Route>('/routes', { method: 'POST', body: JSON.stringify(body) });
export const updateRoute = (id: number, body: Partial<Route>) => request<Route>(`/routes/${id}`, { method: 'PUT', body: JSON.stringify(body) });
export const deleteRoute = (id: number) => request<{ message: string }>(`/routes/${id}`, { method: 'DELETE' });

// ── TOURS ────────────────────────────────────────────────────────────────────
export const getTours = () => request<Tour[]>('/tours');
export const getTour = (id: number) => request<Tour>(`/tours/${id}`);
export const createTour = (body: Partial<Tour>) => request<Tour>('/tours', { method: 'POST', body: JSON.stringify(body) });
export const updateTour = (id: number, body: Partial<Tour>) => request<Tour>(`/tours/${id}`, { method: 'PUT', body: JSON.stringify(body) });
export const deleteTour = (id: number) => request<{ message: string }>(`/tours/${id}`, { method: 'DELETE' });

// ── CUSTOMERS ────────────────────────────────────────────────────────────────
export const getCustomers = () => request<Customer[]>('/customers');
export const getCustomer = (id: number) => request<Customer>(`/customers/${id}`);
export const createCustomer = (body: Partial<Customer>) => request<Customer>('/customers', { method: 'POST', body: JSON.stringify(body) });
export const updateCustomer = (id: number, body: Partial<Customer>) => request<Customer>(`/customers/${id}`, { method: 'PUT', body: JSON.stringify(body) });
export const deleteCustomer = (id: number) => request<{ message: string }>(`/customers/${id}`, { method: 'DELETE' });

// ── REGISTRATIONS ────────────────────────────────────────────────────────────
export const getRegistrations = () => request<Registration[]>('/registrations');
export const getRegistration = (id: number) => request<Registration>(`/registrations/${id}`);
export const createRegistration = (body: Partial<Registration>) => request<Registration>('/registrations', { method: 'POST', body: JSON.stringify(body) });
export const updateRegistration = (id: number, body: Partial<Registration>) => request<Registration>(`/registrations/${id}`, { method: 'PUT', body: JSON.stringify(body) });
export const deleteRegistration = (id: number) => request<{ message: string }>(`/registrations/${id}`, { method: 'DELETE' });

// ── PAYMENTS ─────────────────────────────────────────────────────────────────
export const getPayments = () => request<Payment[]>('/payments');
export const createPayment = (body: Partial<Payment>) => request<Payment>('/payments', { method: 'POST', body: JSON.stringify(body) });
export const deletePayment = (id: number) => request<{ message: string }>(`/payments/${id}`, { method: 'DELETE' });

// ── LOCATIONS ────────────────────────────────────────────────────────────────
export const getLocations = () => request<Location[]>('/locations');
export const createLocation = (body: Partial<Location>) => request<Location>('/locations', { method: 'POST', body: JSON.stringify(body) });
export const updateLocation = (id: number, body: Partial<Location>) => request<Location>(`/locations/${id}`, { method: 'PUT', body: JSON.stringify(body) });
export const deleteLocation = (id: number) => request<{ message: string }>(`/locations/${id}`, { method: 'DELETE' });

// ── LOOKUPS ──────────────────────────────────────────────────────────────────
export const getDifficulty = () => request<DifficultyLevel[]>('/lookup/difficulty');
export const getTourStatus = () => request<TourStatus[]>('/lookup/tourstatus');
export const getRegistrationStatus = () => request<RegistrationStatus[]>('/lookup/registrationstatus');
export const getPaymentStatus = () => request<PaymentStatus[]>('/lookup/paymentstatus');

// ── DASHBOARD ────────────────────────────────────────────────────────────────
export const getDashboard = () => request<DashboardStats>('/dashboard');

// ── QUERIES (Phase 2) ─────────────────────────────────────────────────────────
export const queryHighEarningGuides = (month: number, year: number) =>
  request<HighEarningGuide[]>(`/queries/high-earning-guides?month=${month}&year=${year}`);
export const queryMonthlyRevenue = (year: number) =>
  request<MonthlyRevenue[]>(`/queries/monthly-revenue?year=${year}`);
export const queryVIPCustomers = () => request<VIPCustomer[]>('/queries/vip-customers');
export const queryEliteGuides = () => request<EliteGuide[]>('/queries/elite-guides');
export const queryPopularRoutes = () => request<PopularRoute[]>('/queries/popular-routes');

// ── FUNCTIONS & PROCEDURES (Phase 4) ─────────────────────────────────────────
export const fnCustomerPaymentStatus = (customer_id: number) =>
  request<CustomerPaymentStatus>('/functions/customer-payment-status', { method: 'POST', body: JSON.stringify({ customer_id }) });
export const fnToursByDifficulty = (difficulty_name: string) =>
  request<TourByDifficulty[]>('/functions/tours-by-difficulty', { method: 'POST', body: JSON.stringify({ difficulty_name }) });
export const procAssignGuide = (tour_id: number, expertise: string) =>
  request<{ message: string; tour: Tour }>('/procedures/assign-guide', { method: 'POST', body: JSON.stringify({ tour_id, expertise }) });
export const procApplyDiscount = (tour_id: number, discount_percent: number) =>
  request<{ message: string }>('/procedures/apply-discount', { method: 'POST', body: JSON.stringify({ tour_id, discount_percent }) });

// ── TYPES ─────────────────────────────────────────────────────────────────────
export interface Guide {
  guideid: number;
  firstname: string;
  lastname: string;
  email: string;
  phone: string;
  dailyrate: number;
  rating: number;
  experienceyears: number;
  expertise: string;
  isactive: boolean;
}

export interface Route {
  routeid: number;
  name: string;
  description: string;
  region: string;
  estimatedlength: number;
  estimatedduration: number;
  difficultyid: number;
  difficultyname: string;
}

export interface Tour {
  tourid: number;
  routeid: number;
  guideid: number;
  startdate: string;
  enddate: string;
  maxparticipants: number;
  meetingpoint: string;
  price: number;
  tourstatusid: number;
  routename: string;
  guidename: string;
  tourstatus: string;
}

export interface Customer {
  customerid: number;
  fullname: string;
  email: string;
  phone: string;
  joindate: string;
}

export interface Registration {
  registrationid: number;
  customerid: number;
  tourid: number;
  registrationdate: string;
  amounttopay: number;
  notes: string;
  registrationstatusid: number;
  customername: string;
  routename: string;
  registrationstatus: string;
}

export interface Payment {
  paymentid: number;
  registrationid: number;
  amount: number;
  paymentdate: string;
  paymentstatusid: number;
  customername: string;
  paymentstatus: string;
}

export interface Location {
  locationid: number;
  locationname: string;
  category: string;
  description: string;
}

export interface DifficultyLevel { difficultyid: number; difficultyname: string; }
export interface TourStatus { tourstatusid: number; statusname: string; }
export interface RegistrationStatus { registrationstatusid: number; statusname: string; }
export interface PaymentStatus { paymentstatusid: number; statusname: string; }

export interface DashboardStats {
  activeGuides: number;
  activeTours: number;
  totalCustomers: number;
  yearRevenue: number;
  upcomingTours: { tourid: number; routename: string; startdate: string; guidename: string; maxparticipants: number }[];
}

export interface HighEarningGuide { guidename: string; email: string; paymentmonth: number; totalearned: number; }
export interface MonthlyRevenue { year: number; month: number; monthlyincome: number; transactioncount: number; }
export interface VIPCustomer { fullname: string; email: string; totalspent: number; lastpayment: string; }
export interface EliteGuide { firstname: string; lastname: string; rating: number; tourcount: number; expertise: string; }
export interface PopularRoute { name: string; totalcapacity: number; occurrences: number; }
export interface CustomerPaymentStatus {
  o_customer_name: string;
  o_total_registered: number;
  o_total_paid: number;
  o_debt: number;
  o_status_description: string;
}
export interface TourByDifficulty {
  tourid: number;
  routename: string;
  startdate: string;
  meetingpoint: string;
  price: number;
  maxparticipants: number;
  assignedguide: string;
}
