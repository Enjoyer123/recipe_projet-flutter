const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
    const token = req.headers["authorization"];

    if (!token) return res.status(401).json({ error: "Unauthorized" });

    const bearerToken = token.split(" ")[1]; 

    if (!bearerToken) return res.status(401).json({ error: "Unauthorized" });

    try {
        const decoded = jwt.verify(bearerToken, process.env.SECRET_KEY);
        req.user = decoded;
        next();
    } catch (error) {
        res.status(401).json({ error: "Invalid token" });
    }
};

module.exports = authMiddleware;
