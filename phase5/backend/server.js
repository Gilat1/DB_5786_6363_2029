require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'DBsecret',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
});

pool.connect((err) => {
  if (err) {
    console.error('Database connection error:', err.message);
  } else {
    console.log('Connected to PostgreSQL database');
  }
});

// HEALTH CHECK
app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', message: 'Database connected' });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

// GUIDES CRUD
app.get('/api/guides', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        g.guideid, g.firstname, g.lastname, g.email, g.phone,
        g.dailyrate, g.rating, g.experienceyears, g.expertise,
        true AS isactive
      FROM guide g
      ORDER BY g.guideid
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/guides/:id', async (req, res) => {
  try {
    const result = await pool.query(`SELECT * FROM guide WHERE guideid = $1`, [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Guide not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/guides', async (req, res) => {
  const { FirstName, LastName, Email, Phone, DailyRate, Rating, ExperienceYears, Expertise } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO guide (firstname, lastname, email, phone, dailyrate, rating, experienceyears, expertise)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
      [FirstName, LastName, Email, Phone, DailyRate, Rating, ExperienceYears, Expertise]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/guides/:id', async (req, res) => {
  const { FirstName, LastName, Email, Phone, DailyRate, Rating, ExperienceYears, Expertise } = req.body;
  try {
    const result = await pool.query(
      `UPDATE guide SET firstname=$1, lastname=$2, email=$3, phone=$4, dailyrate=$5, rating=$6, experienceyears=$7, expertise=$8
       WHERE guideid=$9 RETURNING *`,
      [FirstName, LastName, Email, Phone, DailyRate, Rating, ExperienceYears, Expertise, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Guide not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/guides/:id', async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM guide WHERE guideid=$1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Guide not found' });
    res.json({ message: 'Guide deleted', guide: result.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ROUTES CRUD
app.get('/api/routes', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
      r.routeid, r.name, r.description,
        r.estimatedlength, r.estimatedduration,
        dl.difficultyname
      FROM route r
      LEFT JOIN difficultylevel dl ON r.difficultyid = dl.difficultyid
      ORDER BY r.routeid
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/routes/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT r.*, dl.difficultyname FROM route r
       LEFT JOIN difficultylevel dl ON r.difficultyid = dl.difficultyid
       WHERE r.routeid = $1`, [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Route not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/routes', async (req, res) => {
  const { Name, Description, Region, EstimatedLength, EstimatedDuration, DifficultyID } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO route (name, description, estimatedlength, estimatedduration, difficultyid)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [Name, Description, EstimatedLength, EstimatedDuration, DifficultyID]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/routes/:id', async (req, res) => {
  const { Name, Description, Region, EstimatedLength, EstimatedDuration, DifficultyID } = req.body;
  try {
    const result = await pool.query(
      `UPDATE route SET name=$1, description=$2, estimatedlength=$3, estimatedduration=$4, difficultyid=$5
       WHERE routeid=$6 RETURNING *`,
      [Name, Description, EstimatedLength, EstimatedDuration, DifficultyID, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Route not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/routes/:id', async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM route WHERE routeid=$1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Route not found' });
    res.json({ message: 'Route deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GUIDED TOURS CRUD
app.get('/api/tours', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        gt.tourid, gt.startdate, gt.enddate, gt.maxparticipants,
        gt.meetingpoint, gt.price, gt.routeid, gt.guideid, gt.tourstatusid,
        r.name AS routename,
        g.firstname || ' ' || g.lastname AS guidename,
        ts.statusname AS tourstatus
      FROM guidedtour gt
      LEFT JOIN route r ON gt.routeid = r.routeid
      LEFT JOIN guide g ON gt.guideid = g.guideid
      LEFT JOIN tourstatus ts ON gt.tourstatusid = ts.tourstatusid
      ORDER BY gt.startdate DESC
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/tours/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT gt.*, r.name AS routename, g.firstname || ' ' || g.lastname AS guidename,
              ts.statusname AS tourstatus
       FROM guidedtour gt
       LEFT JOIN route r ON gt.routeid = r.routeid
       LEFT JOIN guide g ON gt.guideid = g.guideid
       LEFT JOIN tourstatus ts ON gt.tourstatusid = ts.tourstatusid
       WHERE gt.tourid = $1`, [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Tour not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/tours', async (req, res) => {
  const { RouteID, GuideID, StartDate, EndDate, MaxParticipants, MeetingPoint, Price, TourStatusID } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO guidedtour (routeid, guideid, startdate, enddate, maxparticipants, meetingpoint, price, tourstatusid)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
      [RouteID, GuideID, StartDate, EndDate, MaxParticipants, MeetingPoint, Price, TourStatusID || 1]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/tours/:id', async (req, res) => {
  const { RouteID, GuideID, StartDate, EndDate, MaxParticipants, MeetingPoint, Price, TourStatusID } = req.body;
  try {
    const result = await pool.query(
      `UPDATE guidedtour SET routeid=$1, guideid=$2, startdate=$3, enddate=$4,
       maxparticipants=$5, meetingpoint=$6, price=$7, tourstatusid=$8
       WHERE tourid=$9 RETURNING *`,
      [RouteID, GuideID, StartDate, EndDate, MaxParticipants, MeetingPoint, Price, TourStatusID, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Tour not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/tours/:id', async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM guidedtour WHERE tourid=$1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Tour not found' });
    res.json({ message: 'Tour deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// CUSTOMERS CRUD
app.get('/api/customers', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT customerid, fullname, email, phone, joindate
      FROM customer
      ORDER BY customerid
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/customers/:id', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM customer WHERE customerid=$1', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Customer not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/customers', async (req, res) => {
  const { FullName, Email, Phone, JoinDate } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO customer (fullname, email, phone, joindate) VALUES ($1,$2,$3,$4) RETURNING *`,
      [FullName, Email, Phone, JoinDate || new Date().toISOString().split('T')[0]]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/customers/:id', async (req, res) => {
  const { FullName, Email, Phone } = req.body;
  try {
    const result = await pool.query(
      `UPDATE customer SET fullname=$1, email=$2, phone=$3 WHERE customerid=$4 RETURNING *`,
      [FullName, Email, Phone, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Customer not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/customers/:id', async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM customer WHERE customerid=$1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Customer not found' });
    res.json({ message: 'Customer deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// REGISTRATIONS CRUD
app.get('/api/registrations', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        r.registrationid, r.registrationdate, r.amounttopay, r.notes,
        r.customerid, r.tourid, r.registrationstatusid,
        c.fullname AS customername,
        rt.name AS routename,
        rs.statusname AS registrationstatus
      FROM registration r
      LEFT JOIN customer c ON r.customerid = c.customerid
      LEFT JOIN guidedtour gt ON r.tourid = gt.tourid
      LEFT JOIN route rt ON gt.routeid = rt.routeid
      LEFT JOIN registrationstatus rs ON r.registrationstatusid = rs.registrationstatusid
      ORDER BY r.registrationdate DESC
      LIMIT 200
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/registrations/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT r.*, c.fullname AS customername, rs.statusname AS registrationstatus
       FROM registration r
       LEFT JOIN customer c ON r.customerid = c.customerid
       LEFT JOIN registrationstatus rs ON r.registrationstatusid = rs.registrationstatusid
       WHERE r.registrationid = $1`, [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Registration not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/registrations', async (req, res) => {
  const { CustomerID, TourID, AmountToPay, Notes, RegistrationStatusID } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO registration (customerid, tourid, registrationdate, amounttopay, notes, registrationstatusid)
       VALUES ($1,$2,CURRENT_DATE,$3,$4,$5) RETURNING *`,
      [CustomerID, TourID, AmountToPay, Notes, RegistrationStatusID || 1]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/registrations/:id', async (req, res) => {
  const { AmountToPay, Notes, RegistrationStatusID } = req.body;
  try {
    const result = await pool.query(
      `UPDATE registration SET amounttopay=$1, notes=$2, registrationstatusid=$3
       WHERE registrationid=$4 RETURNING *`,
      [AmountToPay, Notes, RegistrationStatusID, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Registration not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/registrations/:id', async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM registration WHERE registrationid=$1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Registration not found' });
    res.json({ message: 'Registration deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PAYMENTS CRUD
app.get('/api/payments', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        p.paymentid, p.amount, p.paymentdate, p.registrationid, p.paymentstatusid,
        c.fullname AS customername,
        ps.statusname AS paymentstatus
      FROM payment p
      LEFT JOIN registration r ON p.registrationid = r.registrationid
      LEFT JOIN customer c ON r.customerid = c.customerid
      LEFT JOIN paymentstatus ps ON p.paymentstatusid = ps.paymentstatusid
      ORDER BY p.paymentdate DESC
      LIMIT 200
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/payments', async (req, res) => {
  const { RegistrationID, Amount, PaymentStatusID } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO payment (registrationid, amount, paymentdate, paymentstatusid, paymentmethod)
       VALUES ($1,$2,CURRENT_DATE,$3,$4) RETURNING *`,
      [RegistrationID, Amount, PaymentStatusID || 3, 'Cash']
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/payments/:id', async (req, res) => {
  try {
    const result = await pool.query('DELETE FROM payment WHERE paymentid=$1 RETURNING *', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Payment not found' });
    res.json({ message: 'Payment deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// LOCATIONS CRUD
app.get('/api/locations', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM location ORDER BY locationid');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/locations', async (req, res) => {
  const { LocationName, Category, Description } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO location (locationname, category) VALUES ($1,$2) RETURNING *`,
      [LocationName, Category]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/locations/:id', async (req, res) => {
  const { LocationName, Category, Description } = req.body;
  try {
    const result = await pool.query(
      `UPDATE location SET locationname=$1, category=$2 WHERE locationid=$3 RETURNING *`,
      [LocationName, Category, req.params.id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/locations/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM location WHERE locationid=$1', [req.params.id]);
    res.json({ message: 'Location deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// LOOKUP DATA
app.get('/api/lookup/difficulty', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM difficultylevel ORDER BY difficultyid');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/lookup/tourstatus', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM tourstatus ORDER BY tourstatusid');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/lookup/registrationstatus', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM registrationstatus ORDER BY registrationstatusid');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/lookup/paymentstatus', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM paymentstatus ORDER BY paymentstatusid');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DASHBOARD STATS
app.get('/api/dashboard', async (req, res) => {
  try {
    const [guides, tours, customers, revenue, upcoming] = await Promise.all([
      pool.query(`SELECT COUNT(*) AS count FROM guide`),
      pool.query(`SELECT COUNT(*) AS count FROM guidedtour WHERE tourstatusid != (SELECT tourstatusid FROM tourstatus WHERE statusname='Completed' LIMIT 1)`),
      pool.query(`SELECT COUNT(*) AS count FROM customer`),
      pool.query(`SELECT COALESCE(SUM(amount),0) AS total FROM payment WHERE EXTRACT(YEAR FROM paymentdate)=EXTRACT(YEAR FROM CURRENT_DATE)`),
      pool.query(`SELECT gt.tourid, r.name AS routename, gt.startdate, g.firstname||' '||g.lastname AS guidename, gt.maxparticipants
                  FROM guidedtour gt
                  LEFT JOIN route r ON gt.routeid=r.routeid
                  LEFT JOIN guide g ON gt.guideid=g.guideid
                  WHERE gt.startdate >= CURRENT_DATE ORDER BY gt.startdate LIMIT 5`)
    ]);
    res.json({
      activeGuides: parseInt(guides.rows[0].count),
      activeTours: parseInt(tours.rows[0].count),
      totalCustomers: parseInt(customers.rows[0].count),
      yearRevenue: parseFloat(revenue.rows[0].total),
      upcomingTours: upcoming.rows
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PHASE 2 QUERIES
app.get('/api/queries/high-earning-guides', async (req, res) => {
  const { month, year } = req.query;
  try {
    const result = await pool.query(`
      SELECT 
        CONCAT(g.firstname, ' ', g.lastname) AS guidename,
        g.email,
        EXTRACT(MONTH FROM p.paymentdate) AS paymentmonth,
        SUM(p.amount) AS totalearned
      FROM guide g
      JOIN guidedtour gt ON g.guideid = gt.guideid
      JOIN registration r ON gt.tourid = r.tourid
      JOIN payment p ON r.registrationid = p.registrationid
      WHERE EXTRACT(YEAR FROM p.paymentdate) = $1
        AND EXTRACT(MONTH FROM p.paymentdate) = $2
      GROUP BY g.guideid, g.firstname, g.lastname, g.email, EXTRACT(MONTH FROM p.paymentdate)
      HAVING SUM(p.amount) > 5000
      ORDER BY totalearned DESC
    `, [year || 2026, month || 3]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/queries/monthly-revenue', async (req, res) => {
  const { year } = req.query;
  try {
    const result = await pool.query(`
      SELECT 
        EXTRACT(YEAR FROM paymentdate) AS year,
        EXTRACT(MONTH FROM paymentdate) AS month, 
        SUM(amount) AS monthlyincome,
        COUNT(paymentid) AS transactioncount
      FROM payment
      WHERE EXTRACT(YEAR FROM paymentdate) = $1
      GROUP BY EXTRACT(YEAR FROM paymentdate), EXTRACT(MONTH FROM paymentdate)
      ORDER BY month
    `, [year || 2026]);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/queries/vip-customers', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        c.fullname, c.email, 
        SUM(p.amount) AS totalspent,
        MAX(p.paymentdate) AS lastpayment
      FROM customer c
      JOIN registration r ON c.customerid = r.customerid
      JOIN payment p ON r.registrationid = p.registrationid
      WHERE p.paymentdate >= CURRENT_DATE - INTERVAL '1 year'
      GROUP BY c.customerid, c.fullname, c.email
      HAVING SUM(p.amount) > 2000
      ORDER BY totalspent DESC
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/queries/elite-guides', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT g.firstname, g.lastname, g.rating, COUNT(gt.tourid) AS tourcount, g.expertise
      FROM guide g
      JOIN guidedtour gt ON g.guideid = gt.guideid
      GROUP BY g.guideid, g.firstname, g.lastname, g.rating, g.expertise
      HAVING COUNT(gt.tourid) > 3 
         AND g.rating > (SELECT AVG(rating) FROM guide)
      ORDER BY g.rating DESC
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/queries/popular-routes', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        r.name, 
        SUM(gt.maxparticipants) AS totalcapacity,
        COUNT(gt.tourid) AS occurrences
      FROM route r
      JOIN guidedtour gt ON r.routeid = gt.routeid
      GROUP BY r.routeid, r.name
      HAVING COUNT(gt.tourid) >= 2
      ORDER BY totalcapacity DESC
    `);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PHASE 4 - FUNCTIONS & PROCEDURES
app.post('/api/functions/customer-payment-status', async (req, res) => {
  const { customer_id } = req.body;
  try {
    const result = await pool.query(`SELECT * FROM fn_calculate_customer_payment_status($1)`, [customer_id]);
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/functions/tours-by-difficulty', async (req, res) => {
  const { difficulty_name } = req.body;
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    await client.query(`SELECT fn_get_route_tour_details_by_difficulty($1)`, [difficulty_name]);
    const result = await client.query(`FETCH ALL FROM tours_cursor`);
    await client.query('COMMIT');
    res.json(result.rows);
  } catch (err) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
});

app.post('/api/procedures/assign-guide', async (req, res) => {
  const { tour_id, expertise } = req.body;
  try {
    await pool.query(`CALL pr_assign_optimal_guide_to_tour($1, $2)`, [tour_id, expertise]);
    const tour = await pool.query(
      `SELECT gt.*, g.firstname||' '||g.lastname AS guidename FROM guidedtour gt
       LEFT JOIN guide g ON gt.guideid=g.guideid WHERE gt.tourid=$1`, [tour_id]
    );
    res.json({ message: 'Guide assigned successfully', tour: tour.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/procedures/apply-discount', async (req, res) => {
  const { tour_id, discount_percent } = req.body;
  try {
    await pool.query(`CALL pr_apply_discount_to_tour_participants($1, $2)`, [tour_id, discount_percent]);
    res.json({ message: `Discount of ${discount_percent}% applied to tour ${tour_id}` });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Tour Guide Management Server running on port ${PORT}`);
});
