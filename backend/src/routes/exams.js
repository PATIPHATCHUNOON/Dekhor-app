const express = require('express');
const router = express.Router();
const { authenticate: auth } = require('../middleware/auth.middleware');
const { getExams, getUpcomingExams, createExam, updateExam, deleteExam }
    = require('../controllers/examController');

router.use(auth);

router.get('/', getExams);
router.get('/upcoming', getUpcomingExams);  // ?days=7
router.post('/', createExam);
router.put('/:id', updateExam);
router.delete('/:id', deleteExam);

module.exports = router;