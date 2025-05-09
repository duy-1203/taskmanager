const jwt = require('jsonwebtoken');
const User = require('../models/user.model'); // Import model User

exports.authenticate = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (authHeader) {
        const token = authHeader.split(' ')[1]; // Bearer <token>

        jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => { // Đổi 'user' thành 'decoded'
            if (err) {
                return res.sendStatus(403); // Forbidden (token không hợp lệ)
            }

            try {
                const user = await User.findOne({ id: decoded.userId });
                if (!user) {
                    return res.status(401).json({ message: 'Không tìm thấy người dùng.' });
                }
                req.userId = decoded.userId; // Lưu ID người dùng vào request
                req.isAdmin = user.isAdmin; // Gán isAdmin vào request
                req.user = user; // Gán toàn bộ thông tin user (tùy chọn, nhưng có thể hữu ích)
                next();
            } catch (error) {
                console.error('Lỗi khi xác thực người dùng:', error);
                return res.sendStatus(500); // Internal Server Error
            }
        });
    } else {
        res.sendStatus(401); // Unauthorized (không có token)
    }
};