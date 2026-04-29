import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';

const router = Router();
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'secret';

// Middleware to authenticate user
const authenticate = (req: any, res: any, next: any) => {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.status(401).json({ error: 'No token provided' });
    const token = authHeader.split(' ')[1];
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        res.status(401).json({ error: 'Invalid token' });
    }
};

// Place order
router.post('/checkout', authenticate, async (req: any, res: any) => {
    try {
        const { restaurantId, items, deliveryAddress, totalAmount } = req.body;
        const userId = req.user.userId;

        const order = await prisma.order.create({
            data: {
                userId,
                restaurantId,
                totalAmount,
                deliveryAddress,
                items: {
                    create: items.map((item: any) => ({
                        itemId: item.id,
                        quantity: item.quantity,
                        finalPrice: item.finalPrice,
                        appliedModifiersJson: JSON.stringify(item.modifiers || [])
                    }))
                }
            },
            include: { items: true }
        });

        res.json({ message: 'Order placed successfully', order });
    } catch (error) {
        res.status(500).json({ error: 'Server error during checkout' });
    }
});

// Get order status
router.get('/:id/status', authenticate, async (req: any, res: any) => {
    try {
        const { id } = req.params;
        const order = await prisma.order.findUnique({
            where: { id: parseInt(id, 10) }
        });

        if (!order) {
            return res.status(404).json({ error: 'Order not found' });
        }

        res.json({ status: order.status, updatedAt: order.updatedAt });
    } catch (error) {
        res.status(500).json({ error: 'Server error fetching exact status' });
    }
});

export default router;
