const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
});

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/api/ventas', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM venta LIMIT 5');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const PORT = process.env.BACKEND_PORT || 3000;
app.listen(PORT, () => console.log(`Servidor en puerto ${PORT}`));
