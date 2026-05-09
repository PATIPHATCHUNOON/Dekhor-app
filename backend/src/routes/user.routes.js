// user.routes.js
const express = require('express')
const router = express.Router()
const userCtrl = require('../controllers/user.controller')
const { authenticate } = require('../middleware/auth.middleware')

// ทุก route ต้อง login ก่อน จึงใส่ authenticate ไว้บน router ทั้งหมด
router.use(authenticate)

router.get('/me', userCtrl.getMe)          // GET  /api/users/me
router.put('/me', userCtrl.updateMe)        // PUT  /api/users/me
router.put('/me/avatar', userCtrl.updateAvatar)    // PUT  /api/users/me/avatar

module.exports = router