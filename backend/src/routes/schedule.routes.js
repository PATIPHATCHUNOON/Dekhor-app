// schedule.routes.js
const express      = require('express')
const router       = express.Router()
const scheduleCtrl = require('../controllers/schedule.controller')
const { authenticate } = require('../middleware/auth.middleware')

router.use(authenticate)

router.get('/',       scheduleCtrl.getAll)    // GET    /api/schedules
router.post('/',      scheduleCtrl.create)    // POST   /api/schedules
router.put('/:id',    scheduleCtrl.update)    // PUT    /api/schedules/:id
router.delete('/:id', scheduleCtrl.remove)    // DELETE /api/schedules/:id

module.exports = router
