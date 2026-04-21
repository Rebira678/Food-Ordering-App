# 🥘 Coral Food — Food Ordering Platform

A production-grade, full-stack food ordering ecosystem built with React Native, Node.js, and a dedicated Admin Business Suite.

---

## 📸 Screenshots

> _Replace these placeholders with your actual app screenshots._

| Customer App | Restaurant View | Cart & Checkout |
|---|---|---|
| ![Home](./screenshots/home.png) | ![Restaurant](./screenshots/restaurant.png) | ![Cart](./screenshots/cart.png) |

| Admin — Dashboard | Admin — Menu Editor | Admin — Broadcasts |
|---|---|---|
| ![Dashboard](./screenshots/admin_dashboard.png) | ![Menu](./screenshots/admin_menu.png) | ![Broadcast](./screenshots/admin_broadcast.png) |

---

## 🧩 What Does It Do?

This platform connects **customers**, **restaurant owners**, and the **system admin** through three unified applications:

### 👤 Customer App (Mobile)
- Browse restaurants by category (Meat, Fast Food, Meals)
- View detailed menus, prices, and restaurant info
- Add items to cart and place orders
- Track order history in the Orders tab
- Manage personal profile — address, notifications, payment methods
- Earn referral codes and discounts on sign-up

### 🏢 Admin Business Suite (Web)
- Create and manage restaurant nodes (name, location, photo, description)
- Edit full menus for each restaurant (item name, price, category)
- Remove restaurants or menu items with a confirmation safeguard
- Send global broadcast announcements to all app users
- View network-wide metrics (total nodes, total items, growth)

### ⚙️ Backend API (Server)
- JWT-based authentication (Sign Up / Sign In)
- Restaurant discovery and search
- Menu retrieval by restaurant
- Order creation and tracking
- User profile management

---

## 🗂️ File Structure

```
Food Ordering App/
│
├── backend/                   # Node.js + Express API
│   ├── prisma/
│   │   ├── schema.prisma      # Database schema (User, Restaurant, Order, Menu)
│   │   └── dev.db             # Local SQLite database (auto-generated)
│   └── src/
│       ├── index.ts           # Entry point — Express server setup
│       └── routes/
│           ├── auth.ts        # POST /auth/register, POST /auth/login
│           ├── restaurants.ts # GET /restaurants, POST /restaurants, GET /menu/:id
│           └── orders.ts      # POST /orders, GET /orders
│
├── frontend/                  # React Native (Expo Router)
│   ├── app/
│   │   ├── auth.tsx           # Sign In / Sign Up screen
│   │   ├── cart.tsx           # Cart & Checkout screen
│   │   ├── restaurant/[id].tsx# Restaurant detail + menu
│   │   └── (tabs)/
│   │       ├── index.tsx      # Home — Restaurant feed
│   │       ├── orders.tsx     # Order history
│   │       └── profile.tsx    # User profile & settings
│   ├── store/
│   │   ├── useAuthStore.ts    # JWT token + user state (Zustand)
│   │   ├── useCartStore.ts    # Cart items (Zustand)
│   │   ├── useOrderStore.ts   # Placed orders (Zustand)
│   │   └── useRestaurantStore.ts # Restaurant data (Zustand)
│   └── constants/
│       ├── Colors.ts          # Brand color palette (Coral #FF5A5F)
│       └── Data.ts            # Seed restaurant & menu data
│
└── admin/                     # React + Vite Business Suite
    └── src/
        ├── App.tsx            # Full Admin suite (Dashboard, Nodes, Menus, Broadcast)
        └── index.css          # Tailwind CSS v4 imports
```

---

## 🚀 How to Run Locally

You need **three terminal windows** open simultaneously.

### Step 1 — Backend API

```bash
cd backend

# First run only: initialize the database
npx prisma db push
npx prisma generate

# Start the API server
npx ts-node src/index.ts
```

> Runs on **http://localhost:3000**

---

### Step 2 — Admin Business Suite

```bash
cd admin
npm install   # First run only
npm run dev
```

> Opens at **http://localhost:5173** (or next available port)

---

### Step 3 — Customer Mobile App

```bash
cd frontend
npm install   # First run only
npm start
```

> Scan the **QR code** in your terminal using the **Expo Go** app on your phone.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | React Native, Expo, Expo Router |
| State | Zustand + AsyncStorage |
| Admin Web | React, Vite, Tailwind CSS v4 |
| Backend | Node.js, Express |
| ORM | Prisma v5 |
| Database | SQLite (dev) |
| Auth | JWT + bcrypt |

---

## 🔍 Inspect the Database

To view database tables (users, restaurants, orders) in a visual UI:

```bash
cd backend
npx prisma studio
```

Opens Prisma Studio at **http://localhost:5555**

---

## 🌐 Environment

The backend API URL is set in `frontend/utils/api.ts`. Update the base URL if deploying to a remote server:

```ts
const BASE_URL = 'http://localhost:3000';
```

---

## 📄 License

Private project — All rights reserved © 2025 Coral Food.
