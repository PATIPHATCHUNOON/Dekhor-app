// user.controller.js
const db = require('../config/db')
const { success, error } = require('../utils/response')

const getMe = async (req, res, next) => {
    try {
        const result = await db.query(
            `SELECT id, username, email, full_name, avatar_url,
              university, dorm_name, room_number, created_at
       FROM users WHERE id = $1`,
            [req.userId]
        )

        if (result.rows.length === 0) {
            return error(res, 'ไม่พบผู้ใช้', 404)
        }

        return success(res, result.rows[0])
    } catch (err) {
        next(err)
    }
}

const updateMe = async (req, res, next) => {
    try {
        const { full_name, university, dorm_name, room_number } = req.body

        const result = await db.query(
            `UPDATE users
       SET full_name = COALESCE($1, full_name),
           university = COALESCE($2, university),
           dorm_name = COALESCE($3, dorm_name),
           room_number = COALESCE($4, room_number),
           updated_at = NOW()
       WHERE id = $5
       RETURNING id, username, email, full_name, university, dorm_name, room_number`,
            [full_name, university, dorm_name, room_number, req.userId]
        )

        return success(res, result.rows[0], 'อัพเดทข้อมูลสำเร็จ')
    } catch (err) {
        next(err)
    }
}

const updateAvatar = async (req, res, next) => {
    try {
        const { avatar_url } = req.body

        await db.query(
            'UPDATE users SET avatar_url = $1, updated_at = NOW() WHERE id = $2',
            [avatar_url, req.userId]
        )

        return success(res, { avatar_url }, 'อัพเดทรูปโปรไฟล์สำเร็จ')
    } catch (err) {
        next(err)
    }
}

module.exports = { getMe, updateMe, updateAvatar }