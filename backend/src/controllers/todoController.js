// todoController.js — จัดการ To-do และเตือนส่งงาน

const { query } = require('../config/db');

// ดู todo ทั้งหมด — filter ได้ด้วย query string
// เช่น ?is_done=false&priority=high
const getTodos = async (req, res, next) => {
    try {
        const { is_done, priority } = req.query;

        // สร้าง WHERE clause แบบ dynamic
        let conditions = ['user_id = $1'];
        let params = [req.user.id];
        let idx = 2; // index ของ param ถัดไป

        if (is_done !== undefined) {
            conditions.push(`is_done = $${idx++}`);
            params.push(is_done === 'true');
        }
        if (priority) {
            conditions.push(`priority = $${idx++}`);
            params.push(priority);
        }

        const result = await query(
            `SELECT id, title, subject, due_date, is_done, priority, remind_at, completed_at
       FROM todos
       WHERE ${conditions.join(' AND ')}
       ORDER BY
         CASE priority WHEN 'high' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END,
         due_date ASC NULLS LAST`,
            params
        );

        res.json({ success: true, data: result.rows });
    } catch (err) { next(err); }
};

// ดู todo ที่ใกล้ due (เตือนส่งงาน)
const getDueSoon = async (req, res, next) => {
    try {
        const hours = parseInt(req.query.hours) || 24;

        const result = await query(
            `SELECT id, title, subject, due_date, priority
       FROM todos
       WHERE user_id = $1
         AND is_done = FALSE
         AND due_date IS NOT NULL
         AND due_date <= NOW() + ($2 || ' hours')::INTERVAL
         AND due_date >= NOW()
       ORDER BY due_date ASC`,
            [req.user.id, hours]
        );

        res.json({ success: true, data: result.rows });
    } catch (err) { next(err); }
};

const createTodo = async (req, res, next) => {
    try {
        const { title, subject, due_date, priority, remind_at } = req.body;

        if (!title) {
            return res.status(400).json({ success: false, message: 'กรุณากรอก title' });
        }

        const result = await query(
            `INSERT INTO todos (user_id, title, subject, due_date, priority, remind_at)
       VALUES ($1,$2,$3,$4,$5,$6)
       RETURNING *`,
            [req.user.id, title, subject, due_date,
            priority || 'medium', remind_at]
        );

        res.status(201).json({
            success: true, message: 'เพิ่ม todo สำเร็จ', data: result.rows[0],
        });
    } catch (err) { next(err); }
};

const updateTodo = async (req, res, next) => {
    try {
        const { id } = req.params;
        const { title, subject, due_date, priority, remind_at } = req.body;

        const result = await query(
            `UPDATE todos SET
         title      = COALESCE($1, title),
         subject    = COALESCE($2, subject),
         due_date   = COALESCE($3, due_date),
         priority   = COALESCE($4, priority),
         remind_at  = COALESCE($5, remind_at)
       WHERE id = $6 AND user_id = $7
       RETURNING *`,
            [title, subject, due_date, priority, remind_at, id, req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบรายการนี้' });
        }

        res.json({ success: true, message: 'แก้ไขสำเร็จ', data: result.rows[0] });
    } catch (err) { next(err); }
};

// toggle done — กดติ๊กถูก/ยกเลิก
const toggleDone = async (req, res, next) => {
    try {
        const { id } = req.params;

        // ดึงสถานะปัจจุบันก่อน แล้วกลับค่า
        const current = await query(
            'SELECT is_done FROM todos WHERE id = $1 AND user_id = $2',
            [id, req.user.id]
        );

        if (current.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบรายการนี้' });
        }

        const newDone = !current.rows[0].is_done;

        const result = await query(
            `UPDATE todos SET
         is_done      = $1,
         completed_at = $2   -- บันทึกเวลาที่ทำเสร็จ
       WHERE id = $3 AND user_id = $4
       RETURNING *`,
            [newDone, newDone ? new Date() : null, id, req.user.id]
        );

        res.json({
            success: true,
            message: newDone ? 'เสร็จแล้ว! 🎉' : 'ยกเลิกสถานะสำเร็จ',
            data: result.rows[0],
        });
    } catch (err) { next(err); }
};

const deleteTodo = async (req, res, next) => {
    try {
        const result = await query(
            'DELETE FROM todos WHERE id = $1 AND user_id = $2 RETURNING id',
            [req.params.id, req.user.id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบรายการนี้' });
        }
        res.json({ success: true, message: 'ลบสำเร็จ' });
    } catch (err) { next(err); }
};

module.exports = {
    getTodos, getDueSoon, createTodo,
    updateTodo, toggleDone, deleteTodo,
};