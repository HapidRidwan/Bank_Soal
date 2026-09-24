const express = require('express');
const pool = require('../db');
const { authenticate } = require('../middleware');

const router = express.Router();

/**
 * GET /api/student/dashboard
 * Data lengkap dashboard siswa: mata pelajaran, paket soal, dan statistik
 * Requires: Bearer token (accessToken)
 */
router.get('/dashboard', authenticate, async (req, res, next) => {
  try {
    const userId = req.auth.sub;

    // 1. Ambil data user yang login
    const [userRows] = await pool.execute(
      'SELECT id, username, email, full_name, role, avatar_url FROM users WHERE id = :id AND is_active = TRUE LIMIT 1',
      { id: userId },
    );
    if (!userRows[0]) {
      return res.status(404).json({ message: 'User tidak ditemukan.' });
    }
    const user = userRows[0];

    // 2. Ambil semua mata pelajaran beserta paket soal yang tersedia
    let subjects = [];
    let totalSoal = 0;
    let totalPaket = 0;

    try {
      const [subjectRows] = await pool.execute(
        `SELECT s.id, s.name, s.description, s.icon, s.color
         FROM subjects s
         WHERE s.is_active = TRUE
         ORDER BY s.name ASC`,
      );

      for (const subject of subjectRows) {
        const [paketRows] = await pool.execute(
          `SELECT p.id, p.name, p.description, p.duration_minutes,
                  COUNT(q.id) AS total_soal
           FROM exam_packages p
           LEFT JOIN questions q ON q.package_id = p.id
           WHERE p.subject_id = :subjectId AND p.is_active = TRUE
           GROUP BY p.id, p.name, p.description, p.duration_minutes
           ORDER BY p.name ASC`,
          { subjectId: subject.id },
        );

        totalSoal += paketRows.reduce((sum, p) => sum + Number(p.total_soal), 0);
        totalPaket += paketRows.length;

        subjects.push({
          id: subject.id,
          name: subject.name,
          description: subject.description,
          icon: subject.icon,
          color: subject.color,
          paket: paketRows.map((p) => ({
            id: p.id,
            name: p.name,
            description: p.description,
            durationMinutes: p.duration_minutes,
            totalSoal: Number(p.total_soal),
          })),
        });
      }
    } catch (_tableError) {
      // Jika tabel subjects/exam_packages belum ada, gunakan data fallback
      subjects = _getFallbackSubjects();
      totalSoal = subjects.reduce(
        (sum, s) => sum + s.paket.reduce((ps, p) => ps + p.totalSoal, 0), 0,
      );
      totalPaket = subjects.reduce((sum, s) => sum + s.paket.length, 0);
    }

    // 3. Statistik hasil ujian siswa (jika tabel exam_results ada)
    let stats = { totalExams: 0, avgScore: 0, bestScore: 0, rank: null };
    try {
      const [statsRows] = await pool.execute(
        `SELECT COUNT(*) AS total_exams,
                ROUND(AVG(score), 1) AS avg_score,
                MAX(score) AS best_score
         FROM exam_results
         WHERE user_id = :userId`,
        { userId },
      );
      if (statsRows[0]) {
        stats = {
          totalExams: Number(statsRows[0].total_exams),
          avgScore: Number(statsRows[0].avg_score || 0),
          bestScore: Number(statsRows[0].best_score || 0),
          rank: null,
        };
      }
    } catch (_e) {
      // Tabel exam_results belum ada, stats tetap default
    }

    return res.json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        fullName: user.full_name,
        avatarUrl: user.avatar_url,
      },
      stats,
      subjects,
      meta: {
        totalSubjects: subjects.length,
        totalPaket,
        totalSoal,
      },
    });
  } catch (error) {
    return next(error);
  }
});

/**
 * GET /api/student/subjects
 * Daftar semua mata pelajaran dengan paket soalnya
 */
router.get('/subjects', authenticate, async (req, res, next) => {
  try {
    let subjects = [];

    try {
      const [subjectRows] = await pool.execute(
        `SELECT s.id, s.name, s.description, s.icon, s.color
         FROM subjects s
         WHERE s.is_active = TRUE
         ORDER BY s.name ASC`,
      );

      for (const subject of subjectRows) {
        const [paketRows] = await pool.execute(
          `SELECT p.id, p.name, p.description, p.duration_minutes,
                  COUNT(q.id) AS total_soal
           FROM exam_packages p
           LEFT JOIN questions q ON q.package_id = p.id
           WHERE p.subject_id = :subjectId AND p.is_active = TRUE
           GROUP BY p.id
           ORDER BY p.name ASC`,
          { subjectId: subject.id },
        );

        subjects.push({
          id: subject.id,
          name: subject.name,
          description: subject.description,
          icon: subject.icon,
          color: subject.color,
          paket: paketRows.map((p) => ({
            id: p.id,
            name: p.name,
            description: p.description,
            durationMinutes: p.duration_minutes,
            totalSoal: Number(p.total_soal),
          })),
        });
      }
    } catch (_e) {
      subjects = _getFallbackSubjects();
    }

    return res.json({ subjects });
  } catch (error) {
    return next(error);
  }
});

/**
 * Data fallback jika tabel subjects/exam_packages belum tersedia di DB
 */
function _getFallbackSubjects() {
  return [
    {
      id: 1,
      name: 'IPA',
      description: 'Ilmu Pengetahuan Alam',
      icon: 'science',
      color: '#10B981',
      paket: [
        { id: 1, name: 'Paket A', description: 'Latihan Soal IPA 1', durationMinutes: 60, totalSoal: 20 },
        { id: 2, name: 'Paket B', description: 'Latihan Soal IPA 2', durationMinutes: 60, totalSoal: 25 },
      ],
    },
    {
      id: 2,
      name: 'IPS',
      description: 'Ilmu Pengetahuan Sosial',
      icon: 'public',
      color: '#F59E0B',
      paket: [
        { id: 3, name: 'Paket A', description: 'Latihan Soal IPS 1', durationMinutes: 45, totalSoal: 15 },
      ],
    },
    {
      id: 3,
      name: 'Matematika',
      description: 'Matematika Dasar & Lanjutan',
      icon: 'calculate',
      color: '#3B82F6',
      paket: [
        { id: 4, name: 'Paket A', description: 'Aljabar & Aritmetika', durationMinutes: 90, totalSoal: 30 },
        { id: 5, name: 'Paket B', description: 'Geometri & Statistika', durationMinutes: 90, totalSoal: 30 },
      ],
    },
    {
      id: 4,
      name: 'Bahasa Indonesia',
      description: 'Tata Bahasa & Sastra',
      icon: 'menu_book',
      color: '#8B5CF6',
      paket: [
        { id: 6, name: 'Paket A', description: 'Teks & Pemahaman', durationMinutes: 60, totalSoal: 25 },
      ],
    },
  ];
}

module.exports = router;
