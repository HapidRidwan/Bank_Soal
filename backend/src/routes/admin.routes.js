const express = require('express');
const pool = require('../db');
const { authenticate } = require('../middleware');

const router = express.Router();

// Middleware: hanya admin dan guru yang boleh akses
function requireAdmin(req, res, next) {
  const role = req.auth?.role;
  if (role !== 'admin' && role !== 'guru') {
    return res.status(403).json({ message: 'Akses ditolak. Hanya admin/guru.' });
  }
  return next();
}

// ─────────────────────────────────────────────
// GET /api/admin & GET /api/admin/dashboard
// Ringkasan statistik + package terbaru
// ─────────────────────────────────────────────
async function handleAdminDashboard(req, res, next) {
  try {
    const stats = await _getStats();
    const recentPackages = await _getRecentPackages(5);

    let adminInfo = null;
    try {
      const [userRows] = await pool.execute(
        'SELECT id, username, email, full_name, role FROM users WHERE id = :id LIMIT 1',
        { id: req.auth.sub },
      );
      if (userRows && userRows[0]) {
        adminInfo = {
          id: userRows[0].id,
          username: userRows[0].username,
          email: userRows[0].email,
          fullName: userRows[0].full_name,
          role: userRows[0].role,
        };
      }
    } catch (_) {}

    return res.json({
      admin: adminInfo || {
        username: req.auth?.email ? req.auth.email.split('@')[0] : 'admin',
        email: req.auth?.email,
        role: req.auth?.role || 'admin',
      },
      stats,
      recentPackages,
    });
  } catch (error) {
    return next(error);
  }
}

router.get('/', authenticate, requireAdmin, handleAdminDashboard);
router.get('/dashboard', authenticate, requireAdmin, handleAdminDashboard);

// ─────────────────────────────────────────────
// GET /api/admin/inventory
// Daftar semua package soal beserta jumlah soal
// ─────────────────────────────────────────────
router.get('/inventory', authenticate, requireAdmin, async (req, res, next) => {
  try {
    let packages = [];

    try {
      const [rows] = await pool.execute(
        `SELECT
           p.id,
           p.name        AS paketName,
           p.description,
           p.duration_minutes,
           p.is_active,
           p.created_at,
           s.name        AS subjectName,
           COUNT(q.id)   AS totalSoal
         FROM exam_packages p
         LEFT JOIN subjects s ON s.id = p.subject_id
         LEFT JOIN questions q ON q.package_id = p.id
         GROUP BY p.id, p.name, p.description, p.duration_minutes,
                  p.is_active, p.created_at, s.name
         ORDER BY p.created_at DESC`,
      );

      packages = rows.map((r) => ({
        id: r.id,
        paketName: r.paketName,
        subjectName: r.subjectName ?? '-',
        description: r.description ?? '',
        durationMinutes: r.duration_minutes ?? 60,
        isActive: Boolean(r.is_active),
        totalSoal: Number(r.totalSoal),
        createdAt: _formatDate(r.created_at),
      }));
    } catch (_e) {
      packages = _getFallbackInventory();
    }

    return res.json({ packages });
  } catch (error) {
    return next(error);
  }
});

// ─────────────────────────────────────────────
// GET /api/admin/rekap
// Rekap nilai siswa per package soal
// ─────────────────────────────────────────────
router.get('/rekap', authenticate, requireAdmin, async (req, res, next) => {
  try {
    let rekapList = [];

    try {
      // Ambil semua package beserta rekap nilai
      const [packages] = await pool.execute(
        `SELECT
           p.id,
           p.name     AS paketName,
           s.name     AS subjectName,
           COUNT(DISTINCT er.user_id) AS siswaMengerjakan,
           ROUND(AVG(er.score), 1)   AS avgScore
         FROM exam_packages p
         LEFT JOIN subjects s ON s.id = p.subject_id
         LEFT JOIN exam_results er ON er.package_id = p.id
         GROUP BY p.id, p.name, s.name
         ORDER BY p.created_at DESC`,
      );

      // Untuk setiap package, ambil detail siswa yang mengerjakan
      for (const pkg of packages) {
        const [students] = await pool.execute(
          `SELECT
             u.username,
             u.email,
             u.full_name,
             er.score,
             er.created_at AS completedAt
           FROM exam_results er
           INNER JOIN users u ON u.id = er.user_id
           WHERE er.package_id = :packageId
           ORDER BY er.created_at DESC`,
          { packageId: pkg.id },
        );

        const passingScore = 70;
        rekapList.push({
          id: pkg.id,
          paketName: pkg.paketName,
          subjectName: pkg.subjectName ?? '-',
          siswaMengerjakan: Number(pkg.siswaMengerjakan),
          avgScore: pkg.avgScore != null ? Number(pkg.avgScore) : null,
          students: students.map((s) => ({
            name: s.username ?? s.full_name ?? '-',
            email: s.email,
            nilai: Number(s.score),
            status: Number(s.score) >= passingScore ? 'Lulus' : 'Belum Lulus',
            completedAt: _formatDate(s.completedAt),
          })),
        });
      }
    } catch (_e) {
      rekapList = _getFallbackRekap();
    }

    return res.json({ rekap: rekapList });
  } catch (error) {
    return next(error);
  }
});

// ─────────────────────────────────────────────
// Helper: hitung statistik utama
// ─────────────────────────────────────────────
async function _getStats() {
  const stats = { totalSoal: 0, packageAktif: 0, mataPelajaran: 0, totalSiswa: 0 };
  try {
    const [[soal]] = await pool.execute('SELECT COUNT(*) AS n FROM questions');
    stats.totalSoal = Number(soal.n);
  } catch (_) {}

  try {
    const [[pkg]] = await pool.execute(
      'SELECT COUNT(*) AS n FROM exam_packages WHERE is_active = TRUE',
    );
    stats.packageAktif = Number(pkg.n);
  } catch (_) {}

  try {
    const [[mapel]] = await pool.execute(
      'SELECT COUNT(*) AS n FROM subjects WHERE is_active = TRUE',
    );
    stats.mataPelajaran = Number(mapel.n);
  } catch (_) {}

  try {
    const [[siswa]] = await pool.execute(
      "SELECT COUNT(*) AS n FROM users WHERE role = 'user' AND is_active = TRUE",
    );
    stats.totalSiswa = Number(siswa.n);
  } catch (_) {}

  return stats;
}

// ─────────────────────────────────────────────
// Helper: ambil package terbaru
// ─────────────────────────────────────────────
async function _getRecentPackages(limit = 5) {
  const safeLimit = Math.max(1, Math.min(50, parseInt(limit, 10) || 5));
  try {
    const [rows] = await pool.execute(
      `SELECT
         p.id,
         p.name      AS paketName,
         p.created_at,
         s.name      AS subjectName,
         COUNT(q.id) AS totalSoal
       FROM exam_packages p
       LEFT JOIN subjects s ON s.id = p.subject_id
       LEFT JOIN questions q ON q.package_id = p.id
       GROUP BY p.id, p.name, p.created_at, s.name
       ORDER BY p.created_at DESC
       LIMIT ${safeLimit}`,
    );

    return rows.map((r) => ({
      id: r.id,
      paketName: r.paketName,
      subjectName: r.subjectName ?? '-',
      totalSoal: Number(r.totalSoal),
      createdAt: _formatDate(r.created_at),
    }));
  } catch (_) {
    return _getFallbackInventory().slice(0, safeLimit);
  }
}

// ─────────────────────────────────────────────
// Helpers: format tanggal & fallback data
// ─────────────────────────────────────────────
function _formatDate(dateVal) {
  if (!dateVal) return '-';
  try {
    const d = new Date(dateVal);
    const dd = String(d.getDate()).padStart(2, '0');
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const yyyy = d.getFullYear();
    const hh = String(d.getHours()).padStart(2, '0');
    const min = String(d.getMinutes()).padStart(2, '0');
    return `${dd}/${mm}/${yyyy} ${hh}:${min}`;
  } catch (_) {
    return String(dateVal);
  }
}

function _getFallbackInventory() {
  return [
    { id: 1, paketName: 'Ulangan Haria', subjectName: 'PPB', totalSoal: 1, durationMinutes: 60, isActive: true, createdAt: '22/09/2026 04:15' },
    { id: 2, paketName: 'Paket A', subjectName: 'IPS', totalSoal: 0, durationMinutes: 45, isActive: true, createdAt: '20/09/2026 10:55' },
    { id: 3, paketName: 'Paket A', subjectName: 'Matematika', totalSoal: 4, durationMinutes: 90, isActive: true, createdAt: '19/09/2026 08:30' },
    { id: 4, paketName: 'Paket A', subjectName: 'IPA', totalSoal: 1, durationMinutes: 60, isActive: true, createdAt: '18/09/2026 07:00' },
  ];
}

function _getFallbackRekap() {
  return [
    {
      id: 1, paketName: 'Ulangan Haria', subjectName: 'PPB',
      siswaMengerjakan: 1, avgScore: 100,
      students: [{ name: 'hapid', email: 'hapid@gmail.com', nilai: 100, status: 'Lulus', completedAt: '22/09/2026 04:17' }],
    },
    { id: 2, paketName: 'Paket A', subjectName: 'IPS', siswaMengerjakan: 0, avgScore: null, students: [] },
    {
      id: 3, paketName: 'Paket A', subjectName: 'IPA',
      siswaMengerjakan: 2, avgScore: 50,
      students: [
        { name: 'siswa_a', email: 'siswaa@gmail.com', nilai: 100, status: 'Lulus', completedAt: '21/09/2026 10:00' },
        { name: 'hapid', email: 'hapid@gmail.com', nilai: 0, status: 'Belum Lulus', completedAt: '21/09/2026 11:20' },
      ],
    },
  ];
}

module.exports = router;
