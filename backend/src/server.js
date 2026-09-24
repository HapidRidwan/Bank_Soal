const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const pool = require('./db');
const authRoutes = require('./routes/auth.routes');
const studentRoutes = require('./routes/student.routes');
const adminRoutes = require('./routes/admin.routes');

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 3000);

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    return res.json({ status: 'ok', database: 'connected' });
  } catch (_error) {
    return res.status(503).json({ status: 'error', database: 'unavailable' });
  }
});

app.use('/api/auth', authRoutes);
app.use('/api/student', studentRoutes);
app.use('/api/admin', adminRoutes);

app.use((error, _req, res, _next) => {
  if (error.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({ message: 'Data sudah digunakan.' });
  }
  console.error(error);
  return res.status(error.status || 500).json({
    message: error.status ? error.message : 'Terjadi kesalahan pada server.',
  });
});

app.listen(port, () => {
  console.log(`Bank Soal API berjalan di http://localhost:${port}`);
});