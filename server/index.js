require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const authRoutes = require("./middleware/auth");

const app = express();
app.use(express.json());
app.use(cors());
app.use("/api/auth", authRoutes);


const favoriteRoutes = require('./routes/favoriteRoutes');
const userRoutes = require('./routes/login');

app.use('/favorites', favoriteRoutes);
app.use('/user', userRoutes);


mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.log(err));


const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
