const express = require('express');
const router = express.Router();
const { authenticate: auth } = require('../middleware/auth.middleware');
const {
    getTodos, getDueSoon, createTodo,
    updateTodo, toggleDone, deleteTodo,
} = require('../controllers/todoController');

router.use(auth);

router.get('/', getTodos);      // ?is_done=false&priority=high
router.get('/due-soon', getDueSoon);   // ?hours=24
router.post('/', createTodo);
router.put('/:id', updateTodo);
router.patch('/:id/toggle', toggleDone);   // PATCH = แก้แค่บางส่วน
router.delete('/:id', deleteTodo);

module.exports = router;