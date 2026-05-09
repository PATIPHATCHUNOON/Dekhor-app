// scheduleController.js — CRUD ตารางเรียน
// C = Create, R = Read, U = Update, D = Delete

const { query } = require('../config/db');

// ========== GET ALL — ดูตารางเรียนทั้งหมด ==========
const getSchedules = async (req, res, next) => {
    try {
        // req.user.id มาจาก auth middleware
        // เรียงตามวันและเวลา เพื่อแสดงเป็น timetable
        const result = await query(
            `SELECT id, subject, day_of_week, start_time, end_time,
              room, teacher, color, semester, note
       FROM schedules
       WHERE user_id = $1
       ORDER BY day_of_week, start_time`,
            [req.user.id]
        );

        res.json({ success: true, data: result.rows });
    } catch (err) {
        next(err);
    }
};

// ========== GET BY SEMESTER — ดูตามภาคเรียน ==========
const getSchedulesBySemester = async (req, res, next) => {
    try {
        const { semester } = req.params;

        const result = await query(
            `SELECT * FROM schedules
       WHERE user_id = $1 AND semester = $2
       ORDER BY day_of_week, start_time`,
            [req.user.id, semester]
        );

        res.json({ success: true, data: result.rows });
    } catch (err) {
        next(err);
    }
};

// ========== CREATE — เพิ่มวิชา ==========
const createSchedule = async (req, res, next) => {
    try {
        const { subject, day_of_week, start_time, end_time,
            room, teacher, color, semester, note } = req.body;

        // ตรวจ field จำเป็น
        if (!subject || day_of_week === undefined || !start_time || !end_time) {
            return res.status(400).json({
                success: false,
                message: 'กรุณากรอก subject, day_of_week, start_time, end_time',
            });
        }

        // ตรวจว่าเวลาซ้อนทับกันไหมในวันเดียวกัน
        const conflict = await query(
            `SELECT id, subject FROM schedules
       WHERE user_id = $1
         AND day_of_week = $2
         AND semester = $3
         AND (
           (start_time < $5 AND end_time > $4)
         )`,
            [req.user.id, day_of_week, semester || null, start_time, end_time]
        );

        if (conflict.rows.length > 0) {
            return res.status(409).json({
                success: false,
                message: `เวลาซ้อนทับกับวิชา "${conflict.rows[0].subject}"`,
            });
        }

        const result = await query(
            `INSERT INTO schedules
         (user_id, subject, day_of_week, start_time, end_time,
          room, teacher, color, semester, note)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
       RETURNING *`,
            [req.user.id, subject, day_of_week, start_time, end_time,
                room, teacher, color || '#7F77DD', semester, note]
        );

        res.status(201).json({
            success: true,
            message: 'เพิ่มวิชาสำเร็จ',
            data: result.rows[0],
        });
    } catch (err) {
        next(err);
    }
};

// ========== UPDATE — แก้ไขวิชา ==========
const updateSchedule = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { subject, day_of_week, start_time, end_time,
            room, teacher, color, semester, note } = req.body;

        // ตรวจว่าเป็นของ user คนนี้จริง
        const own = await query(
            'SELECT id FROM schedules WHERE id = $1 AND user_id = $2',
            [id, req.user.id]
        );
        if (own.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบรายการนี้' });
        }

        const result = await query(
            `UPDATE schedules SET
         subject     = COALESCE($1, subject),
         day_of_week = COALESCE($2, day_of_week),
         start_time  = COALESCE($3, start_time),
         end_time    = COALESCE($4, end_time),
         room        = COALESCE($5, room),
         teacher     = COALESCE($6, teacher),
         color       = COALESCE($7, color),
         semester    = COALESCE($8, semester),
         note        = COALESCE($9, note)
       WHERE id = $10 AND user_id = $11
       RETURNING *`,
            [subject, day_of_week, start_time, end_time,
                room, teacher, color, semester, note, id, req.user.id]
        );

        res.json({ success: true, message: 'แก้ไขสำเร็จ', data: result.rows[0] });
    } catch (err) {
        next(err);
    }
};

// ========== DELETE — ลบวิชา ==========
const deleteSchedule = async (req, res, next) => {
    try {
        const { id } = req.params;

        const result = await query(
            'DELETE FROM schedules WHERE id = $1 AND user_id = $2 RETURNING id',
            [id, req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบรายการนี้' });
        }

        res.json({ success: true, message: 'ลบวิชาสำเร็จ' });
    } catch (err) {
        next(err);
    }
};

// ========== SHARE — แชร์ตารางเรียน ==========
// ส่งกลับข้อมูลแบบ public (ไม่ต้อง auth) เพื่อให้คนอื่น view ได้
const shareSchedule = async (req, res, next) => {
    try {
        const { user_id, semester } = req.params;

        const result = await query(
            `SELECT s.subject, s.day_of_week, s.start_time, s.end_time,
              s.room, s.color, s.semester,
              u.username, u.university
       FROM schedules s
       JOIN users u ON u.id = s.user_id
       WHERE s.user_id = $1 AND s.semester = $2
       ORDER BY s.day_of_week, s.start_time`,
            [user_id, semester]
        );

        res.json({ success: true, data: result.rows });
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getSchedules, getSchedulesBySemester,
    createSchedule, updateSchedule, deleteSchedule, shareSchedule,
};