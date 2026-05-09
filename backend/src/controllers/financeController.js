// financeController.js — รายรับ-รายจ่าย, สรุปเดือน, หารบิล, คำนวณค่าไฟ

const { query } = require('../config/db');

// ========== TRANSACTIONS ==========

// ดูรายการทั้งหมด — filter ได้
const getTransactions = async (req, res, next) => {
    try {
        const { type, category, month, year } = req.query;

        let conditions = ['user_id = $1'];
        let params = [req.user.id];
        let idx = 2;

        if (type) {
            conditions.push(`type = $${idx++}`);
            params.push(type); // 'income' หรือ 'expense'
        }
        if (category) {
            conditions.push(`category = $${idx++}`);
            params.push(category);
        }
        if (month && year) {
            // filter เดือน-ปี
            conditions.push(`EXTRACT(MONTH FROM txn_date) = $${idx++}`);
            conditions.push(`EXTRACT(YEAR FROM txn_date) = $${idx++}`);
            params.push(month, year);
        }

        const result = await query(
            `SELECT id, type, amount, category, note, txn_date, receipt_url
       FROM transactions
       WHERE ${conditions.join(' AND ')}
       ORDER BY txn_date DESC`,
            params
        );

        res.json({ success: true, data: result.rows });
    } catch (err) { next(err); }
};

// สรุปรายเดือน — รายได้ รายจ่าย คงเหลือ แยก category
const getMonthlySummary = async (req, res, next) => {
    try {
        const { month, year } = req.params;

        // รายรับ-รายจ่ายรวม
        const totals = await query(
            `SELECT
         SUM(CASE WHEN type='income'  THEN amount ELSE 0 END) AS total_income,
         SUM(CASE WHEN type='expense' THEN amount ELSE 0 END) AS total_expense,
         SUM(CASE WHEN type='income'  THEN amount
                  WHEN type='expense' THEN -amount ELSE 0 END) AS balance
       FROM transactions
       WHERE user_id = $1
         AND EXTRACT(MONTH FROM txn_date) = $2
         AND EXTRACT(YEAR  FROM txn_date) = $3`,
            [req.user.id, month, year]
        );

        // รายจ่ายแยกตาม category
        const byCategory = await query(
            `SELECT category,
              SUM(amount)  AS total,
              COUNT(*)     AS count,
              -- % จากรายจ่ายทั้งหมด
              ROUND(SUM(amount) * 100.0 /
                NULLIF(SUM(SUM(amount)) OVER (), 0), 1) AS percentage
       FROM transactions
       WHERE user_id = $1
         AND type = 'expense'
         AND EXTRACT(MONTH FROM txn_date) = $2
         AND EXTRACT(YEAR  FROM txn_date) = $3
       GROUP BY category
       ORDER BY total DESC`,
            [req.user.id, month, year]
        );

        // เปรียบเทียบกับเดือนก่อนหน้า
        const prevMonth = month == 1 ? 12 : month - 1;
        const prevYear = month == 1 ? year - 1 : year;

        const prevTotals = await query(
            `SELECT SUM(CASE WHEN type='expense' THEN amount ELSE 0 END) AS total_expense
       FROM transactions
       WHERE user_id = $1
         AND EXTRACT(MONTH FROM txn_date) = $2
         AND EXTRACT(YEAR  FROM txn_date) = $3`,
            [req.user.id, prevMonth, prevYear]
        );

        const curr = parseFloat(totals.rows[0].total_expense) || 0;
        const prev = parseFloat(prevTotals.rows[0].total_expense) || 0;
        const diff_percent = prev > 0
            ? Math.round(((curr - prev) / prev) * 100)
            : null;

        res.json({
            success: true,
            data: {
                ...totals.rows[0],
                by_category: byCategory.rows,
                vs_last_month: {
                    amount: curr - prev,
                    percent: diff_percent,
                    // บอกว่าใช้มากขึ้นหรือน้อยลงเท่าไร
                    message: diff_percent === null ? null
                        : diff_percent > 0
                            ? `ใช้มากกว่าเดือนที่แล้ว ${diff_percent}%`
                            : `ใช้น้อยกว่าเดือนที่แล้ว ${Math.abs(diff_percent)}%`,
                },
            },
        });
    } catch (err) { next(err); }
};

const createTransaction = async (req, res, next) => {
    try {
        const { type, amount, category, note, txn_date, receipt_url } = req.body;

        if (!type || !amount || !category) {
            return res.status(400).json({
                success: false,
                message: 'กรุณากรอก type, amount และ category',
            });
        }

        const result = await query(
            `INSERT INTO transactions
         (user_id, type, amount, category, note, txn_date, receipt_url)
       VALUES ($1,$2,$3,$4,$5,$6,$7)
       RETURNING *`,
            [req.user.id, type, amount, category,
                note, txn_date || new Date(), receipt_url]
        );

        res.status(201).json({
            success: true, message: 'บันทึกรายการสำเร็จ', data: result.rows[0],
        });
    } catch (err) { next(err); }
};

const deleteTransaction = async (req, res, next) => {
    try {
        const result = await query(
            'DELETE FROM transactions WHERE id = $1 AND user_id = $2 RETURNING id',
            [req.params.id, req.user.id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบรายการนี้' });
        }
        res.json({ success: true, message: 'ลบสำเร็จ' });
    } catch (err) { next(err); }
};

// ========== SPLIT BILLS — หารค่าใช้จ่าย ==========

// คำนวณค่าไฟอัตโนมัติ
// อัตราค่าไฟแบบขั้นบันได (การไฟฟ้านครหลวง)
const calculateElectric = (units) => {
    const rates = [
        { limit: 15, rate: 2.3488 },
        { limit: 25, rate: 2.9882 },
        { limit: 35, rate: 3.2405 },
        { limit: 100, rate: 3.6237 },
        { limit: 150, rate: 3.7171 },
        { limit: 400, rate: 4.2218 },
        { limit: Infinity, rate: 4.4217 },
    ];

    let cost = 0;
    let prev = 0;

    for (const tier of rates) {
        if (units <= prev) break;
        const inTier = Math.min(units, tier.limit) - prev;
        cost += inTier * tier.rate;
        prev = tier.limit;
    }

    // บวกค่าบริการ 38.22 บาท
    return Math.round((cost + 38.22) * 100) / 100;
};

// ดู split bills ทั้งหมด
const getSplitBills = async (req, res, next) => {
    try {
        const result = await query(
            `SELECT sb.*,
              COUNT(sm.id)                                      AS member_count,
              SUM(CASE WHEN sm.is_paid THEN 1 ELSE 0 END)      AS paid_count
       FROM split_bills sb
       LEFT JOIN split_members sm ON sm.split_bill_id = sb.id
       WHERE sb.created_by = $1
       GROUP BY sb.id
       ORDER BY sb.bill_date DESC`,
            [req.user.id]
        );

        res.json({ success: true, data: result.rows });
    } catch (err) { next(err); }
};

// ดู split bill รายละเอียด พร้อมสมาชิก
const getSplitBillDetail = async (req, res, next) => {
    try {
        const { id } = req.params;

        const bill = await query(
            'SELECT * FROM split_bills WHERE id = $1 AND created_by = $2',
            [id, req.user.id]
        );

        if (bill.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบรายการนี้' });
        }

        const members = await query(
            `SELECT sm.*, u.username, u.avatar_url
       FROM split_members sm
       LEFT JOIN users u ON u.id = sm.user_id
       WHERE sm.split_bill_id = $1`,
            [id]
        );

        res.json({
            success: true,
            data: { ...bill.rows[0], members: members.rows },
        });
    } catch (err) { next(err); }
};

// สร้างบิลหาร
const createSplitBill = async (req, res, next) => {
    try {
        const {
            title, bill_type, bill_date, due_date,
            total_amount, units_used, rate_per_unit,
            members, // array: [{ user_id, display_name }]
        } = req.body;

        if (!title || !bill_date || !members || members.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'กรุณากรอก title, bill_date และ members',
            });
        }

        // คำนวณยอดรวมถ้าเป็นค่าไฟและมีหน่วย
        let finalAmount = total_amount;
        let finalRate = rate_per_unit;

        if (bill_type === 'electric' && units_used && !total_amount) {
            finalAmount = calculateElectric(units_used);
            finalRate = finalAmount / units_used;
        }

        if (!finalAmount) {
            return res.status(400).json({
                success: false,
                message: 'กรุณากรอก total_amount หรือ units_used (สำหรับค่าไฟ)',
            });
        }

        // หารเท่ากัน — แต่ละคนได้เท่าไร
        const shareAmount = Math.round((finalAmount / members.length) * 100) / 100;

        // BEGIN TRANSACTION — ทำทุกอย่างพร้อมกัน
        // ถ้าขั้นตอนไหน error ทุกอย่าง rollback หมด
        await query('BEGIN');

        const billResult = await query(
            `INSERT INTO split_bills
         (created_by, title, total_amount, bill_type, units_used,
          rate_per_unit, bill_date, due_date)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
       RETURNING *`,
            [req.user.id, title, finalAmount, bill_type || 'other',
                units_used, finalRate, bill_date, due_date]
        );

        const bill = billResult.rows[0];

        // เพิ่มสมาชิกทีละคน
        for (const member of members) {
            await query(
                `INSERT INTO split_members
           (split_bill_id, user_id, display_name, share_amount)
         VALUES ($1,$2,$3,$4)`,
                [bill.id, member.user_id || null, member.display_name, shareAmount]
            );
        }

        await query('COMMIT');

        res.status(201).json({
            success: true,
            message: `สร้างบิลสำเร็จ คนละ ${shareAmount.toLocaleString()} บาท`,
            data: { ...bill, share_per_person: shareAmount },
        });
    } catch (err) {
        await query('ROLLBACK'); // ถ้า error ยกเลิกทุกอย่าง
        next(err);
    }
};

// อัปเดตสถานะจ่ายเงิน
const markPaid = async (req, res, next) => {
    try {
        const { member_id } = req.params;

        const result = await query(
            `UPDATE split_members
       SET is_paid = TRUE, paid_at = NOW()
       WHERE id = $1
       RETURNING *`,
            [member_id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'ไม่พบสมาชิก' });
        }

        res.json({ success: true, message: 'บันทึกการจ่ายเงินสำเร็จ' });
    } catch (err) { next(err); }
};

// คำนวณค่าไฟ (แยก endpoint สำหรับ Flutter เรียกก่อนสร้างบิล)
const calcElectric = (req, res) => {
    const { units } = req.query;
    if (!units || isNaN(units)) {
        return res.status(400).json({ success: false, message: 'กรุณาระบุ units' });
    }

    const total = calculateElectric(parseFloat(units));

    res.json({
        success: true,
        data: {
            units: parseFloat(units),
            total_cost: total,
            message: `ค่าไฟ ${parseFloat(units)} หน่วย = ${total.toLocaleString()} บาท`,
        },
    });
};

module.exports = {
    getTransactions, getMonthlySummary,
    createTransaction, deleteTransaction,
    getSplitBills, getSplitBillDetail,
    createSplitBill, markPaid, calcElectric,
};