// error.middleware.js — รับ error ทุกอย่างที่ throw มา
// ไม่ต้องเขียน try-catch ซ้ำซ้อนในทุก controller

const errorHandler = (err, req, res, next) => {
  console.error('🔴 Error:', err.message)

  // PostgreSQL duplicate key (เช่น email ซ้ำ)
  if (err.code === '23505') {
    return res.status(409).json({
      success: false,
      message: 'ข้อมูลนี้มีอยู่แล้วในระบบ',
    })
  }

  // PostgreSQL foreign key violation
  if (err.code === '23503') {
    return res.status(400).json({
      success: false,
      message: 'ข้อมูลอ้างอิงไม่ถูกต้อง',
    })
  }

  // error ทั่วไป
  return res.status(err.status || 500).json({
    success: false,
    message: err.message || 'เกิดข้อผิดพลาดในระบบ',
  })
}

module.exports = { errorHandler }
