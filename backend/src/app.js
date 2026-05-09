// app.js — ประกอบร่าง Express ทั้งหมด
const express = require('express')
const cors = require('cors')
const helmet = require('helmet')

// โหลด routes
const authRoutes = require('./routes/auth.routes')
const userRoutes = require('./routes/user.routes')
const scheduleRoutes = require('./routes/schedule.routes')
const financeRoutes = require('./routes/finance')
const todoRoutes = require('./routes/todos')

const { errorHandler } = require('./middleware/error.middleware')

const app = express()

// --- Security & Parsing middleware ---
app.use(helmet())           // เพิ่ม security headers อัตโนมัติ
app.use(cors({
  origin: '*',              // development: อนุญาตทุก origin
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}))
app.use(express.json())           // รับ JSON body
app.use(express.urlencoded({ extended: true })) // รับ form data

// --- Health check (ทดสอบว่า server ทำงานอยู่) ---
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'DekHor API is running 🏠',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  })
})

// --- Routes ทั้งหมด ---
app.use('/api/auth', authRoutes)
app.use('/api/users', userRoutes)
app.use('/api/schedules', scheduleRoutes)
app.use('/api/finance', financeRoutes)
app.use('/api/todos', todoRoutes)

// --- 404 handler ---
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `ไม่พบ endpoint: ${req.method} ${req.url}`,
  })
})

// --- Error handler (ต้องอยู่ท้ายสุดเสมอ) ---
app.use(errorHandler)

module.exports = app
