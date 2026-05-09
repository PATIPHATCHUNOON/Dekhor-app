-- ===================================================
-- DekHor Database Schema
-- รัน: psql -U postgres -d dekhor_db -f schema.sql
-- ===================================================

-- สร้าง database (รันใน psql ก่อนถ้ายังไม่มี)
-- CREATE DATABASE dekhor_db;

-- ================================
-- TABLE: users
-- ================================
CREATE TABLE IF NOT EXISTS users (
    id              SERIAL PRIMARY KEY,
    username        VARCHAR(50)  UNIQUE NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   TEXT NOT NULL,
    pin_hash        TEXT,                            -- PIN 6 หลัก (optional)
    full_name       VARCHAR(100),
    avatar_url      TEXT,
    university      VARCHAR(255),
    dorm_name       VARCHAR(255),
    room_number     VARCHAR(20),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ================================
-- TABLE: schedules (ตารางเรียน)
-- ================================
CREATE TABLE IF NOT EXISTS schedules (
    id           SERIAL PRIMARY KEY,
    user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject      VARCHAR(255) NOT NULL,
    day_of_week  SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=อาทิตย์, 1=จันทร์, ..., 6=เสาร์
    start_time   TIME NOT NULL,
    end_time     TIME NOT NULL,
    room         VARCHAR(100),
    teacher      VARCHAR(100),
    color        VARCHAR(20) DEFAULT '#4F46E5',       -- สีแสดงใน UI
    semester     VARCHAR(20),                          -- เช่น "1/2567"
    note         TEXT,
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ================================
-- INDEX (เพิ่มความเร็วในการ query)
-- ================================
CREATE INDEX IF NOT EXISTS idx_schedules_user_id ON schedules(user_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- ================================
-- ทดสอบว่า schema ถูกต้อง
-- ================================
SELECT 'Schema created successfully! ✅' AS status;
