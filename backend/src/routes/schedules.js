const express = require('express');
const router = express.Router();
const { authenticate: auth } = require('../middleware/auth.middleware');
const {
    getSchedules, getSchedulesBySemester,
    createSchedule, updateSchedule, deleteSchedule, shareSchedule,
} = require('../controllers/scheduleController');

router.use(auth); // ทุก route ต้อง login

router.get('/', getSchedules);
router.get('/semester/:semester', getSchedulesBySemester);
router.post('/', createSchedule);
router.put('/:id', updateSchedule);
router.delete('/:id', deleteSchedule);

// route นี้ไม่ต้อง auth — ใช้แชร์ให้คนอื่นดู
router.get('/share/:user_id/:semester', (req, res, next) => {
    shareSchedule(req, res, next);
});

module.exports = router;