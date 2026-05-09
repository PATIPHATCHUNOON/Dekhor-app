// response.js — ทุก API ใช้ format นี้เหมือนกันหมด
// Flutter จะได้ parse ง่าย ไม่งง

const success = (res, data = null, message = 'success', statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  })
}

const error = (res, message = 'เกิดข้อผิดพลาด', statusCode = 500, errors = null) => {
  return res.status(statusCode).json({
    success: false,
    message,
    errors, // validation errors (ถ้ามี)
  })
}

// ตัวอย่าง response ที่ Flutter จะได้รับ:
// success: { success: true, message: "login สำเร็จ", data: { token: "...", user: {...} } }
// error:   { success: false, message: "password ไม่ถูกต้อง", errors: null }

module.exports = { success, error }
