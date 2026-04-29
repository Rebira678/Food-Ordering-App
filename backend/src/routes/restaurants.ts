import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Get nearby restaurants (mocked GPS filter for MVP)
router.get('/search', async (req, res) => {
    try {
        const restaurants = await prisma.restaurant.findMany();
        res.json(restaurants);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Get restaurant menu
router.get('/:id/menu', async (req, res) => {
    try {
        const { id } = req.params;
        const menuCategories = await prisma.menuCategory.findMany({
            where: { restaurantId: parseInt(id, 10) },
            include: {
                items: {
                    include: {
                        modifierGroups: true
                    }
                }
            },
            orderBy: { sequence: 'asc' }
        });
        res.json(menuCategories);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Create a new restaurant
router.post('/', async (req, res) => {
    try {
        const { name, location, status, openHours } = req.body;
        const restaurant = await prisma.restaurant.create({
            data: {
                name,
                location,
                status: status || 'OPEN',
                openHours: openHours || '9 AM - 10 PM'
            }
        });
        res.status(201).json(restaurant);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

export default router;
