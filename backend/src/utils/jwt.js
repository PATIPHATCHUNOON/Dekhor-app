// jwt.js — จัดการ token ทั้งหมด
const jwt = require('jsonwebtoken')

// สร้าง token หลัง login สำเร็จ
const generateToken = (userId) => {
  return jwt.sign(
    { userId },                      // ข้อมูลที่ฝังใน token
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN } // หมดอายุใน 7 วัน
  )
}

// ตรวจ token ว่า valid ไหม
const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET)
  } catch (err) {
    return null // token ผิดหรือหมดอายุ
  }
}

// สร้าง PIN token (อายุสั้นกว่า)
const generatePinToken = (userId) => {
  return jwt.sign(
    { userId, type: 'pin' },
    process.env.PIN_JWT_SECRET,
    { expiresIn: process.env.PIN_JWT_EXPIRES_IN }
  )
}

module.exports = { generateToken, verifyToken, generatePinToken }
