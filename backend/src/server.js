// server.js — รัน server จริง
// แยกจาก app.js เพื่อให้ทดสอบ app ได้โดยไม่ต้องเปิด port จริง

require('dotenv').config() // โหลด .env ก่อนทุกอย่าง

const app = require('./app')

const PORT = process.env.PORT || 3000

app.listen(PORT, () => {
    console.log('================================')
    console.log(`🏠 DekHor API`)
    console.log(`🚀 Server: http://localhost:${PORT}`)
    console.log(`🔍 Health: http://localhost:${PORT}/health`)
    console.log(`🌍 Mode: ${process.env.NODE_ENV}`)
    console.log('================================')
})