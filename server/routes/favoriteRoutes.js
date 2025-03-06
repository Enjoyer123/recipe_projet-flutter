const express = require('express');
const Favorite = require('../models/Favorite');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.post('/:mealId/:userId', async (req, res) => {
  const { mealId, userId } = req.params;
  const { note } = req.body;

  try {
    const favorite = await Favorite.findOne({ _id: mealId, userId: userId });

    if (!favorite) {
      return res.status(404).json({ message: "Favorite not found for this user" });
    }
    favorite.note.push(note);

    await favorite.save();

    res.json({ message: "Note added successfully", favorite });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});



router.put('/:mealId/:userId/note/:noteIndex', async (req, res) => {
  const { mealId, userId, noteIndex } = req.params;
  const { note: newNote } = req.body;

  try {
    const favorite = await Favorite.findOne({ _id: mealId, userId: userId });

    if (!favorite) {
      return res.status(404).json({ message: "Favorite not found for this user" });
    }

    if (noteIndex < 0 || noteIndex >= favorite.note.length) {
      return res.status(400).json({ message: "Invalid note index" });
    }

    favorite.note[noteIndex] = newNote;

    await favorite.save();

    res.json({ message: "Note updated successfully", favorite });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});


router.delete('/:mealId/:userId/note/:noteIndex', async (req, res) => {

  const { mealId, userId, noteIndex } = req.params;

  try {
    const favorite = await Favorite.findOne({ _id: mealId, userId: userId });

    if (!favorite) {
      return res.status(404).json({ message: "Favorite not found for this user" });
    }

    if (noteIndex < 0 || noteIndex >= favorite.note.length) {
      return res.status(400).json({ message: "Invalid note index" });
    }
    favorite.note.splice(noteIndex, 1);

    await favorite.save();

    res.json({ message: "Note deleted successfully", favorite });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

router.post('/', async (req, res) => {
  const { recipeId } = req.body;

  try {
    const existingFavorite = await Favorite.findOne({ recipeId });

    if (existingFavorite) {
      return res.status(200).json(existingFavorite);
    }

    const favorite = new Favorite(req.body);

    await favorite.save();

    res.status(201).json(favorite);

  } catch (error) {
    console.error("wewe", error);
    res.status(500).json({ message: 'Server Error' });
  }
});


router.get(`/:mealId/:userId`, async (req, res) => {
  const { mealId, userId } = req.params;

  try {

    const favorite = await Favorite.findOne({ _id: mealId, userId: userId });

    if (!favorite) {
      return res.status(500).json({ success: false });
    }

    return res.status(200).json({
      note: favorite.note
    });

  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false });
  }
});

router.get(`/`, authMiddleware, async (req, res) => {
  const favorites = await Favorite.find(req.query);

  try {
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



router.delete('/:id', async (req, res) => {
  try {
    const deletedFavorite = await Favorite.findByIdAndDelete(req.params.id);
    
    if (!deletedFavorite) {
      return res.status(404).json({ message: 'Favorite not found' });
    }

    res.json({ message: 'Deleted Successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
});

module.exports = router;
