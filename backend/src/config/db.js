// db.js — จัดการ connection pool กับ PostgreSQL
// Pool คือการเปิด connection ไว้หลายอันพร้อมกัน
// แทนที่จะเปิด-ปิดทุกครั้งที่มี request (ช้ากว่ามาก)

const { Pool } = require('pg')

const pool = new Pool({
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT, 10),  // ต้องเป็น number
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: String(process.env.DB_PASSWORD), // ต้องเป็น string เสมอ
    // max connections ที่เปิดพร้อมกันได้
    max: 10,
    // ปิด connection ที่ไม่ได้ใช้นานกว่า 30 วินาที
    idleTimeoutMillis: 30000,
    // timeout ถ้าต่อไม่ติดภายใน 2 วินาที
    connectionTimeoutMillis: 2000,
})

// ทดสอบเชื่อมต่อตอน server เริ่มทำงาน
pool.connect((err, client, release) => {
    if (err) {
        console.error('❌ ต่อ Database ไม่ได้:', err.message)
        return
    }
    release() // คืน connection กลับ pool
    console.log('✅ เชื่อมต่อ PostgreSQL สำเร็จ')
})

// helper function สำหรับ query ทั่วไป
// ใช้แบบ: const result = await db.query('SELECT * FROM users WHERE id = $1', [id])
const query = (text, params) => pool.query(text, params)

// helper สำหรับ transaction (หลาย query ต้องสำเร็จพร้อมกัน)
const getClient = () => pool.connect()

module.exports = { query, getClient, pool }