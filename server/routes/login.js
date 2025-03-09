const express = require('express');
const User = require('../models/User');
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const router = express.Router();

router.post("/register", async (req, res) => {
    const { name, email, password } = req.body;
    console.log(req.body)
    try {
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ error: "Email already exists" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        console.log("hashedPassword", hashedPassword)

        const newUser = await User.create({ name, email, password: hashedPassword });
        console.log("new", newUser)

        res.json({ message: "User registered successfully" });
    } catch (error) {
        console.error("Error during registration:", error);

        res.status(500).json({ error: "Server error" });
    }
});

router.post("/login", async (req, res) => {
    const { email, password } = req.body;
    
    try {
        const user = await User.findOne({ email });
        if (!user) return res.status(400).json({ error: "Invalid credentials" });

        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) return res.status(400).json({ error: "Invalid credentials" });

        const token = jwt.sign({ userId: user._id, email: user.email }, process.env.SECRET_KEY, { expiresIn: "3h" });

        res.json({ token, user: { email: user.email, name: user.name, _id: user._id } });
    } catch (error) {
        res.status(500).json({ error: "Server error" });
    }
});


router.get(`/`, async (req, res) => {
    const userList = await User.find();

    if (!userList) {
        res.status(500).json({ success: false })
    }
    res.send(userList);
})

module.exports = router;