// schedule.controller.js
const db = require('../config/db')
const { success, error } = require('../utils/response')

const getAll = async (req, res, next) => {
    try {
        const result = await db.query(
            `SELECT * FROM schedules
       WHERE user_id = $1
       ORDER BY day_of_week, start_time`,
            [req.userId]
        )
        return success(res, result.rows)
    } catch (err) { next(err) }
}

const create = async (req, res, next) => {
    try {
        const { subject, day_of_week, start_time, end_time, room, teacher, color, semester, note } = req.body

        if (!subject || day_of_week === undefined || !start_time || !end_time) {
            return error(res, 'กรุณากรอก subject, day_of_week, start_time, end_time', 400)
        }

        const result = await db.query(
            `INSERT INTO schedules
         (user_id, subject, day_of_week, start_time, end_time, room, teacher, color, semester, note)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
       RETURNING *`,
            [req.userId, subject, day_of_week, start_time, end_time, room, teacher, color, semester, note]
        )
        return success(res, result.rows[0], 'เพิ่มตารางเรียนสำเร็จ', 201)
    } catch (err) { next(err) }
}

const update = async (req, res, next) => {
    try {
        const { id } = req.params
        const { subject, day_of_week, start_time, end_time, room, teacher, color, semester, note } = req.body

        const result = await db.query(
            `UPDATE schedules
       SET subject=$1, day_of_week=$2, start_time=$3, end_time=$4,
           room=$5, teacher=$6, color=$7, semester=$8, note=$9
       WHERE id=$10 AND user_id=$11
       RETURNING *`,
            [subject, day_of_week, start_time, end_time, room, teacher, color, semester, note, id, req.userId]
        )

        if (result.rows.length === 0) {
            return error(res, 'ไม่พบรายการหรือไม่มีสิทธิ์แก้ไข', 404)
        }

        return success(res, result.rows[0], 'อัพเดทสำเร็จ')
    } catch (err) { next(err) }
}

const remove = async (req, res, next) => {
    try {
        const { id } = req.params

        const result = await db.query(
            'DELETE FROM schedules WHERE id=$1 AND user_id=$2 RETURNING id',
            [id, req.userId]
        )

        if (result.rows.length === 0) {
            return error(res, 'ไม่พบรายการหรือไม่มีสิทธิ์ลบ', 404)
        }

        return success(res, null, 'ลบสำเร็จ')
    } catch (err) { next(err) }
}

module.exports = { getAll, create, update, remove }