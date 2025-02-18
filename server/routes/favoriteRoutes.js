const express = require('express');
const Favorite = require('../models/Favorite');
const authMiddleware = require('../middleware/auth'); 

const router = express.Router();

router.post('/', async (req, res) => {
  try {
    const { recipeId } = req.body;

    const existingFavorite = await Favorite.findOne({ recipeId });

    if (existingFavorite) {
      return res.status(200).json(existingFavorite);
    }

    const favorite = new Favorite(req.body);
    await favorite.save();
    res.status(201).json(favorite);
  } catch (error) {
    console.error("wewe",error);
    res.status(500).json({ message: 'Server Error' });
  }
});



router.get(`/`, authMiddleware, async (req, res) => {
  try {
    const favorites = await Favorite.find(req.query);

    if (!favorites) {
      return res.status(500).json({ success: false });
    }

    return res.status(200).json({
      data: favorites
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false });
  }
});



router.get('/:recipeId', async (req, res) => {
  const { recipeId } = req.params;

  try {
    const favorite = await Favorite.findOne({ recipeId: recipeId });

    if (favorite) {
      return res.json({ data: favorite });
    } else {
      return res.json({ data: null });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error checking favorite in MongoDB', error: error });
  }
});


router.put('/:id', async (req, res) => {
  const updatedFavorite = await Favorite.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json(updatedFavorite);
});

router.delete('/:id', async (req, res) => {
  await Favorite.findByIdAndDelete(req.params.id);
  res.json({ message: 'Deleted Successfully' });
});



module.exports = router;
