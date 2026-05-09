const express = require('express');
const router = express.Router();
const { authenticate: auth } = require('../middleware/auth.middleware');
const {
    getTransactions, getMonthlySummary,
    createTransaction, deleteTransaction,
    getSplitBills, getSplitBillDetail,
    createSplitBill, markPaid, calcElectric,
} = require('../controllers/financeController');

router.use(auth);

// --- Transactions ---
router.get('/transactions', getTransactions);
router.get('/summary/:year/:month', getMonthlySummary);
router.post('/transactions', createTransaction);
router.delete('/transactions/:id', deleteTransaction);

// --- Split Bills ---
router.get('/splits', getSplitBills);
router.get('/splits/:id', getSplitBillDetail);
router.post('/splits', createSplitBill);
router.patch('/splits/members/:member_id/pay', markPaid);

// --- คำนวณค่าไฟ (ไม่ต้อง body) ---
router.get('/calc/electric', calcElectric); // ?units=89.5

module.exports = router;