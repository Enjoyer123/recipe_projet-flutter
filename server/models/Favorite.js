const mongoose = require('mongoose');

const FavoriteSchema = new mongoose.Schema({
    recipeId: {
        type: String,
        required: true
    },
    title: {
        type: String,
        required: true
    },
    ingredients: [
        {
            type: String,
            required: true
        }
    ],
    instructions: {
        type: String,
        required: true
    },
    imageUrl: {
        type: String,
        required: true
    },
    area: {
        type: String,
        required: true
    },
    videoUrl: {
        type: String,
    },
    category: {
        type: String,
        required: true
    },
    note: [
        {
            type: String
        }
    ],
    email: {
        type: String,
        required: true
    },
    userId: {
        type: String,
        required: true
    },

    createdAt: {
        type: Date,
        default: Date.now
    },
});

module.exports = mongoose.model('Favorite', FavoriteSchema);
