const mongoose = require('mongoose');

const FavoriteSchema = new mongoose.Schema({
    recipeId: { type: String, required: true },  
    title: { type: String, required: true },     
    description: { type: String, required: true },  
    imageUrl: { type: String, required: true },  
    email:{
        type:String,
        required:true
    },
    createdAt: { type: Date, default: Date.now },  
});

module.exports = mongoose.model('Favorite', FavoriteSchema);
