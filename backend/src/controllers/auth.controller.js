// auth.controller.js — logic ทั้งหมดของ register/login
const bcrypt = require('bcryptjs')
const db = require('../config/db')
const { generateToken, generatePinToken } = require('../utils/jwt')
const { success, error } = require('../utils/response')

// --- REGISTER ---
const register = async (req, res, next) => {
    try {
        const { username, email, password, full_name, university, dorm_name, room_number } = req.body

        // ตรวจว่าส่งข้อมูลครบไหม
        if (!username || !email || !password) {
            return error(res, 'กรุณากรอก username, email และ password', 400)
        }

        // ตรวจความยาว password
        if (password.length < 8) {
            return error(res, 'password ต้องมีอย่างน้อย 8 ตัวอักษร', 400)
        }

        // เข้ารหัส password — 10 คือ salt rounds (ยิ่งมากยิ่งปลอดภัย แต่ช้ากว่า)
        const password_hash = await bcrypt.hash(password, 10)

        // INSERT เข้า database
        const result = await db.query(
            `INSERT INTO users
         (username, email, password_hash, full_name, university, dorm_name, room_number)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, username, email, full_name, university, dorm_name, room_number, created_at`,
            [username, email, password_hash, full_name, university, dorm_name, room_number]
        )

        const newUser = result.rows[0]

        // สร้าง token ให้เลย (ไม่ต้อง login อีกรอบ)
        const token = generateToken(newUser.id)

        return success(res, { token, user: newUser }, 'สมัครสมาชิกสำเร็จ', 201)

    } catch (err) {
        next(err) // โยนไปให้ errorHandler จัดการ (email/username ซ้ำจะ catch ได้)
    }
}

// --- LOGIN ---
const login = async (req, res, next) => {
    try {
        const { email, password } = req.body

        if (!email || !password) {
            return error(res, 'กรุณากรอก email และ password', 400)
        }

        // หา user จาก email
        const result = await db.query(
            'SELECT * FROM users WHERE email = $1 AND is_active = TRUE',
            [email]
        )

        if (result.rows.length === 0) {
            // บอกแค่ว่า email/password ไม่ถูก ไม่บอกว่าอันไหนผิด (security best practice)
            return error(res, 'email หรือ password ไม่ถูกต้อง', 401)
        }

        const user = result.rows[0]

        // เปรียบเทียบ password กับ hash ใน database
        const isMatch = await bcrypt.compare(password, user.password_hash)

        if (!isMatch) {
            return error(res, 'email หรือ password ไม่ถูกต้อง', 401)
        }

        // สร้าง token
        const token = generateToken(user.id)

        // ส่งข้อมูล user กลับ แต่ไม่ส่ง password_hash
        const { password_hash, pin_hash, ...safeUser } = user

        return success(res, { token, user: safeUser }, 'เข้าสู่ระบบสำเร็จ')

    } catch (err) {
        next(err)
    }
}

// --- SETUP PIN ---
const setupPin = async (req, res, next) => {
    try {
        const { pin } = req.body

        if (!pin || pin.length !== 6 || !/^\d{6}$/.test(pin)) {
            return error(res, 'PIN ต้องเป็นตัวเลข 6 หลัก', 400)
        }

        const pin_hash = await bcrypt.hash(pin, 10)

        await db.query(
            'UPDATE users SET pin_hash = $1, updated_at = NOW() WHERE id = $2',
            [pin_hash, req.userId]
        )

        return success(res, null, 'ตั้ง PIN สำเร็จ')
    } catch (err) {
        next(err)
    }
}

// --- VERIFY PIN ---
const verifyPin = async (req, res, next) => {
    try {
        const { pin } = req.body

        const result = await db.query(
            'SELECT pin_hash FROM users WHERE id = $1',
            [req.userId]
        )

        const user = result.rows[0]

        if (!user.pin_hash) {
            return error(res, 'ยังไม่ได้ตั้ง PIN', 400)
        }

        const isMatch = await bcrypt.compare(pin, user.pin_hash)

        if (!isMatch) {
            return error(res, 'PIN ไม่ถูกต้อง', 401)
        }

        const pinToken = generatePinToken(req.userId)

        return success(res, { pinToken }, 'ยืนยัน PIN สำเร็จ')
    } catch (err) {
        next(err)
    }
}

// --- LOGOUT ---
const logout = async (req, res) => {
    // JWT เป็น stateless — server ไม่เก็บ token
    // แค่บอก client ให้ลบ token ออกจาก storage
    return success(res, null, 'ออกจากระบบสำเร็จ')
}

module.exports = { register, login, setupPin, verifyPin, logout }