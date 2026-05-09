// examController.js — จัดการตารางสอบ

const { query } = require('../config/db');

// ดูตารางสอบทั้งหมด เรียงตามวันสอบ
const getExams = async (req, res, next) => {
    try {
        const result = await query(
            `SELECT id, subject, exam_date, start_time, end_time,
              location, note, remind_at
       FROM exams
       WHERE user_id = $1
       ORDER BY exam_date ASC, start_time ASC`,
            [req.user.id]
        );
        res.json({ success: true, data: result.rows });
    } catch (err) { next(err); }
};

// ดูสอบที่ใกล้จะถึง (7 วันข้างหน้า)
const getUpcomingExams = async (req, res, next) => {
    try {
        const days = parseInt(req.query.days) || 7;

        const result = await query(
            `SELECT id, subject, exam_date, start_time, location,
              -- คำนวณว่าเหลืออีกกี่วัน
              (exam_date - CURRENT_DATE) AS days_left
       FROM exams
       WHERE user_id = $1
         AND exam_date BETWEEN CURRENT_DATE AND CURRENT_DATE + $2
       ORDER BY exam_date ASC`,
            [req.user.id, days]
        );
        res.json({ success: true, data: result.rows });
    } catch (err) { next(err); }
};

const createExam = async (req, res, next) => {
    try {
        const { subject, exam_date, start_time, end_time,
            location, note, remind_at } = req.body;

        if (!subject || !exam_date) {
            return res.status(400).json({
                success: false,
                message: 'กรุณากรอก subject และ exam_date',
            });
        }

        const result = await query(
            `INSERT INTO exams
         (user_id, subject, exam_date, start_time, end_time, location, note, remind_at)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
       RETURNING *`,
            [req.user.id, subject, exam_date, start_time, end_time,
                location, note, remind_at]
        );

        res.status(201).json({
            success: true, message: 'เพิ่มตารางสอบสำเร็จ', data: result.rows[0],
        });
    } catch (err) { next(err); }
};

const updateExam = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { subject, exam_date, start_time, end_time,
            location, note, remind_at } = req.body;

        const result = await query(
            `UPDATE exams SET
         subject    = COALESCE($1, subject),
         exam_date  = COALESCE($2, exam_date),
         start_time = COALESCE($3, start_time),
         end_time   = COALESCE($4, end_time),
         location   = COALESCE($5, location),
         note       = COALESCE($6, note),
         remind_at  = COALESCE($7, remind_at)
       WHERE id = $8 AND user_id = $9
       RETURNING *`,
            [subject, exam_date, start_time, end_time,
                location, note, remind_at, id, req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบรายการนี้' });
        }

        res.json({ success: true, message: 'แก้ไขสำเร็จ', data: result.rows[0] });
    } catch (err) { next(err); }
};

const deleteExam = async (req, res, next) => {
    try {
        const result = await query(
            'DELETE FROM exams WHERE id = $1 AND user_id = $2 RETURNING id',
            [req.params.id, req.user.id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบรายการนี้' });
        }
        res.json({ success: true, message: 'ลบสำเร็จ' });
    } catch (err) { next(err); }
};

module.exports = { getExams, getUpcomingExams, createExam, updateExam, deleteExam };