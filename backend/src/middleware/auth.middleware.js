// auth.middleware.js — ดักทุก request ที่ต้องการ login ก่อน
// ใส่ middleware นี้ที่ route ไหน = route นั้นต้องมี token ถึงเข้าได้

const { verifyToken } = require('../utils/jwt')
const { error } = require('../utils/response')

const authenticate = (req, res, next) => {
    // อ่าน token จาก header: Authorization: Bearer <token>
    const authHeader = req.headers['authorization']
    const token = authHeader && authHeader.split(' ')[1] // เอาแค่ส่วนหลัง "Bearer "

    if (!token) {
        return error(res, 'กรุณา login ก่อน', 401)
    }

    const decoded = verifyToken(token)

    if (!decoded) {
        return error(res, 'Token ไม่ถูกต้องหรือหมดอายุ กรุณา login ใหม่', 401)
    }

    // แนบ user object เข้า request — controller จะได้ใช้ req.user.id ได้
    req.user = { id: decoded.userId }
    req.userId = decoded.userId // สำรองเผื่อมีที่ไหนใช้
    next() // ผ่านไปยัง controller ต่อไป
}

module.exports = { authenticate }