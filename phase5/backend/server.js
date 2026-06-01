const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3001;

// הגדרת החיבור ל-PostgreSQL
const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'TourGuide',
    user: process.env.DB_USER || 'shirelnk',
    password: process.env.DB_PASSWORD || 'smnk12018'
});

app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// בדיקת תקינות החיבור
app.get('/api/test', async (req, res) => {
    try {
        const result = await pool.query('SELECT NOW()');
        res.json({ success: true, time: result.rows[0].now });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// =======================================================
// 1. ניהול מדריכים - GUIDE CRUD
// =======================================================

// שליפת כל המדריכים
app.get('/api/guides', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT guideid AS "guideid", 
                   CONCAT(firstname, ' ', lastname) AS "fullname", 
                   email AS "email", 
                   phone AS "phone", 
                   dailyrate AS "dailyrate", 
                   rating AS "rating", 
                   experienceyears AS "experienceyears" 
            FROM guide
            ORDER BY guideid;
        `);
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// שליפת מדריך ספציפי לפי מפתח (Autofill)
app.get('/api/guides/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT guideid, firstname, lastname, email, phone, dailyrate, rating, experienceyears FROM guide WHERE guideid = $1', [id]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Guide not found" });
        }
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// הוספת מדריך חדש
app.post('/api/guides', async (req, res) => {
    try {
        const { guideid, firstname, lastname, email, phone, dailyrate, rating, experienceyears } = req.body;
        const result = await pool.query(`
            INSERT INTO guide (guideid, firstname, lastname, email, phone, dailyrate, rating, experienceyears) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
            [guideid, firstname, lastname, email, phone, dailyrate, rating || 5.0, experienceyears || 0]
        );
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// עדכון פרטי מדריך קיים
app.put('/api/guides/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { firstname, lastname, email, phone, dailyrate, rating, experienceyears } = req.body;
        const result = await pool.query(`
            UPDATE guide 
            SET firstname = $1, lastname = $2, email = $3, phone = $4, dailyrate = $5, rating = $6, experienceyears = $7 
            WHERE guideid = $8 RETURNING *`,
            [firstname, lastname, email, phone, dailyrate, rating, experienceyears, id]
        );
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// מחיקת מדריך
app.delete('/api/guides/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM guide WHERE guideid = $1', [id]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// =======================================================
// 2. ניהול סיורים - GUIDED TOUR CRUD
// =======================================================

// שליפת כל הטיולים (התאמה מלאה ל-Front-end ולשמות השדות ב-DB)
app.get('/api/guided-tours', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT gt.tourid AS "tourid", 
                   r.name AS "routename", 
                   CONCAT(g.firstname, ' ', g.lastname) AS "guidename", 
                   gt.startdate AS "startdate", 
                   gt.enddate AS "enddate", 
                   gt.maxparticipants AS "maxspots"
            FROM guidedtour gt
            LEFT JOIN route r ON gt.routeid = r.routeid
            LEFT JOIN guide g ON gt.guideid = g.guideid
            ORDER BY gt.tourid;
        `);
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// מחיקת סיור קיים
app.delete('/api/tours/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM guidedtour WHERE tourid = $1', [id]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// =======================================================
// 3. שאילתות מורכבות ופרוצדורות (דרישות שלב ב' ו-ד')
// =======================================================

// שאילתה 1 (שלב ב') - ניתוח הכנסות לפי מסלול וסטטוס תשלום מה-View
app.get('/api/analytics/revenue', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT routename AS "routename",
                   paymentstatus AS "paymentstatus",
                   COUNT(paymentid) AS "numberofpayments",
                   SUM(amount) AS "totalamount"
            FROM vw_payment_summary_details
            GROUP BY routename, paymentstatus
            ORDER BY totalamount DESC;
        `);
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// שאילתה 2 (שלב ב') - מדריכים מובילים וכמות הטיולים המשויכים אליהם
app.get('/api/analytics/top-guides', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT CONCAT(g.firstname, ' ', g.lastname) AS "guidename",
                   g.rating AS "rating",
                   COUNT(gt.tourid) AS "totaltours"
            FROM guide g
            LEFT JOIN guidedtour gt ON g.guideid = gt.guideid
            GROUP BY g.guideid, g.firstname, g.lastname, g.rating
            ORDER BY g.rating DESC, totaltours DESC;
        `);
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// תת תוכנית 1 (פרוצדורה משלב ד') - עדכון אחוז הנחה לטיול
app.post('/api/procedures/set-discount', async (req, res) => {
    try {
        const { tour_id, discount_percentage } = req.body;
        await pool.query('CALL set_tour_discount($1, $2)', [tour_id, discount_percentage]);
        res.json({ success: true, message: 'הפרוצדורה רצה בהצלחה! עודכן גובה ההנחה בבסיס הנתונים.' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// תת תוכנית 2 (פונקציה משלב ד') - חישוב סך רווחים שהניב מדריך מסוים
app.get('/api/functions/guide-revenue/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query('SELECT get_guide_total_revenue($1) AS "total"', [id]);
        res.json({ success: true, total: result.rows[0].total || 0 });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});