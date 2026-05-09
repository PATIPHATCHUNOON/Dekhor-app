// auth.routes.js — กำหนด endpoint ของ auth
// แค่รับ request แล้วโยนต่อให้ controller ทำงาน

const express = require('express')
const router = express.Router()
const authCtrl = require('../controllers/auth.controller')
const { authenticate } = require('../middleware/auth.middleware')

// POST /api/auth/register — สมัครสมาชิก
router.post('/register', authCtrl.register)

// POST /api/auth/login — เข้าสู่ระบบ
router.post('/login', authCtrl.login)

// POST /api/auth/pin/setup — ตั้ง PIN (ต้อง login ก่อน)
router.post('/pin/setup', authenticate, authCtrl.setupPin)

// POST /api/auth/pin/verify — ยืนยัน PIN
router.post('/pin/verify', authenticate, authCtrl.verifyPin)

// POST /api/auth/logout — logout (แค่แจ้ง client ให้ลบ token)
router.post('/logout', authenticate, authCtrl.logout)

module.exports = router