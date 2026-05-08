# SaffronEats — Full SDLC Documentation
### Mobile Food Ordering Application | Adama Science and Technology University

**Course:** Mobile Application Development  

   **Team Members:**
    *   Iftu Chala (UGR/ 34654/16)
    *   Yididya Shimelis (UGR/ 35654/16)
    *   Petros Sisay (UGR/ 31111/15)
    *   Natnael Esayas (UGR/ 35126/16)
    *   Rebira Adugna (UGR/ 35240/16)


**Platform:** Flutter (Android + Web)  
**Backend:** Supabase (PostgreSQL + Realtime + Auth + Storage)  
**Version Control:** Git / GitHub — `Rebira678/Food-Ordering-App`

---

## Table of Contents

1. [Phase 1 — Deep Study & Analysis](#phase-1--deep-study--analysis)
2. [Phase 2 — Requirement Specification](#phase-2--requirement-specification)
3. [Phase 3 — System Design](#phase-3--system-design)
4. [Phase 4 — Development](#phase-4--development)
5. [Phase 5 — Testing Documentation](#phase-5--testing-documentation)
6. [Innovation & Additional Features](#innovation--additional-features)
7. [Team Contribution Breakdown](#team-contribution-breakdown)

---

## Phase 1 — Deep Study & Analysis

### 1.1 Problem Statement

Food ordering in Adama, Ethiopia, is dominated by walk-in or phone-based ordering systems. Restaurant owners have no centralised way to manage orders, track revenue, or communicate delivery status to customers in real time. Customers face uncertainty about order status, long wait times on calls, and no digital payment confirmation trail.

**SaffronEats** was created to bridge this gap — a digital, mobile-first food ordering platform connecting customers to local restaurants with real-time order tracking, digital payment receipts, and a live restaurant owner dashboard.

---

### 1.2 User Research

#### Survey Findings (Simulated — 30 respondents in Adama)

| Question | Result |
|---|---|
| Do you currently order food by phone? | 73% Yes |
| Have you experienced wrong/late orders? | 68% Yes |
| Would you use a mobile app to order food? | 90% Yes |
| Do you want real-time status updates? | 95% Yes |
| Is digital payment receipt important to you? | 81% Yes |

#### User Interviews — Key Pain Points

**Customer — Abel Tesfaye (University Student):**
> "I call the restaurant and they say '30 minutes' but it arrives after 1.5 hours. I have no way of knowing if they even received my order."

**Restaurant Owner — Meron Haile (Kenbon Restaurant):**
> "Orders come by phone, I write them on paper. I lose track of who paid what. At the end of the day the numbers don't match."

**New Customer — Tigist Bekele (Working professional):**
> "I visited a restaurant once and didn't know their menu prices before going. I want to browse the menu and order from home."

---

### 1.3 Real-World Scenarios (Minimum 5)

**Scenario 1 — The Busy Student**
Abel opens the app, browses Kenbon Restaurant's menu, adds a Chicken Burger and a Mango Juice to his cart. He uploads his telebirr payment screenshot and places the order. He watches the status change from "Placed" → "Preparing" → "Out for Delivery" and taps "Confirm Received" when the food arrives.

**Scenario 2 — The Lunch Rush (Restaurant Owner)**
Meron logs into the Partner Hub at 12:00 PM. Three new orders appear simultaneously (real-time). She accepts each one, assigns them to her kitchen, marks each as "Out for Delivery" as they leave, and sees the customer confirm receipt. Her revenue stat updates automatically.

**Scenario 3 — The First-Time User**
Tigist downloads the app, registers with her email and home address. She browses two restaurants, compares menus and prices, and places her first order. She adds her phone number in Settings so the delivery driver can call her.

**Scenario 4 — Multi-Restaurant Cart**
Dawit adds items from both Kenbon Restaurant and YegnawBet. The cart separates them into two groups, each requiring its own payment receipt. Both orders are placed simultaneously and appear on their respective owner dashboards.

**Scenario 5 — The Returning Customer**
Sara placed 3 orders last week and logs out when lending her phone to a friend. When she logs back in, all her past orders and their final delivery statuses are still visible in her Orders screen — nothing was lost.

---

### 1.4 As-Is Workflow Analysis

```
CURRENT (Before SaffronEats)
─────────────────────────────
Customer                Restaurant
   │                        │
   ├── Calls restaurant ──► │
   │                        ├── Takes order on paper
   │◄── "30 min" (verbal) ──┤
   │                        ├── Prepares food
   │   [No status updates]  │
   │                        ├── Assigns delivery
   │◄── Food arrives ────── │
   │                        │
   ├── Pays cash            │
   │                        ├── Manual revenue tracking
```

```
TO-BE (With SaffronEats)
────────────────────────
Customer App              Supabase DB          Owner App
   │                          │                    │
   ├── Browses menu ─────────►│                    │
   ├── Adds to cart           │                    │
   ├── Uploads receipt ──────►│                    │
   ├── Places order ─────────►├── Realtime ───────►│ (NEW ORDER alert)
   │                          │                    ├── Accepts order
   │◄── "Preparing" ─────────┤◄── Status update ──┤
   │◄── "Out for Delivery" ──┤◄── Status update ──┤
   ├── "Confirm Received" ───►│                    │
   │                          ├── Realtime ───────►│ (Delivered ✓)
   │   [History preserved]    │   [Revenue updated]│
```

---

## Phase 2 — Requirement Specification

### 2.1 Functional Requirements

| ID | Requirement | Priority |
|---|---|---|
| FR-01 | Customers can register and log in with email and password | High |
| FR-02 | Customers can browse restaurants with images, ratings, and delivery time | High |
| FR-03 | Customers can browse categorised menus with prices and photos | High |
| FR-04 | Customers can add items from multiple restaurants to a cart | High |
| FR-05 | Cart groups items by restaurant and shows per-restaurant totals | High |
| FR-06 | Customers can upload a payment screenshot as proof of payment | High |
| FR-07 | Orders are saved to the database with status `pending` on placement | High |
| FR-08 | Customers can view real-time order status on the Orders screen | High |
| FR-09 | When status is `delivering`, customer sees a "Confirm Received" button | High |
| FR-10 | Order history persists across logout/login sessions | High |
| FR-11 | Restaurant owners log in to a separate Partner Hub portal | High |
| FR-12 | Owners see all incoming orders for their restaurant in real time | High |
| FR-13 | Owners can Accept, Decline, mark "Out for Delivery", or mark "Delivered" | High |
| FR-14 | Owners can view customer name, phone number, and payment screenshot | High |
| FR-15 | Owners can manage their menu (add items, edit prices, toggle availability) | Medium |
| FR-16 | Owner dashboard shows revenue analytics and popular items | Medium |
| FR-17 | Customers can manage their profile: name, phone, address, avatar | Medium |
| FR-18 | Admin can view all restaurants, users, and approve owner applications | Medium |
| FR-19 | Dark mode / Light mode toggle available in settings | Low |
| FR-20 | Restaurant owners can apply to join the platform via a form | Low |

### 2.2 Non-Functional Requirements

| ID | Requirement | Metric |
|---|---|---|
| NFR-01 | App must work on Android 8.0+ and modern web browsers | Tested on Chrome, Firefox |
| NFR-02 | Order placement must complete in under 3 seconds on 4G | < 3s response time |
| NFR-03 | Real-time status updates must propagate within 2 seconds | < 2s via Supabase Realtime |
| NFR-04 | All user data must be stored securely in Supabase (RLS enabled) | Row Level Security on all tables |
| NFR-05 | App UI must be responsive on screen widths from 360px to 1440px | Tested on mobile + desktop web |
| NFR-06 | The system must support at least 4 simultaneous restaurant accounts | Confirmed with seed data |
| NFR-07 | Payment screenshots must be stored in Supabase Storage | Bucket: `orders/payments/` |
| NFR-08 | App must function correctly after user logout and re-login | Orders persist via DB fetch |

### 2.3 User Stories

- **As a customer**, I want to browse restaurant menus so I can decide what to order before committing.
- **As a customer**, I want to upload my payment receipt so the restaurant can verify I have paid.
- **As a customer**, I want to track my order in real time so I know when my food will arrive.
- **As a customer**, I want to confirm when my food is received so the delivery is officially closed.
- **As a restaurant owner**, I want to see new orders immediately so I can start preparing food quickly.
- **As a restaurant owner**, I want to see the customer's phone number so I can call them if needed.
- **As a restaurant owner**, I want to update order status so the customer is kept informed.
- **As an admin**, I want to oversee all restaurants and approve new partner applications.

### 2.4 Use Cases

**UC-01: Place an Order**
- Actor: Customer
- Precondition: Customer is logged in and has items in cart
- Steps: Browse → Add to Cart → Upload Receipt → Place Order
- Postcondition: Order saved in DB with status `pending`; owner sees new order in real time

**UC-02: Manage Order Status**
- Actor: Restaurant Owner
- Precondition: Owner is logged in and an order exists for their restaurant
- Steps: View order → Accept → Preparing → Out for Delivery → (Customer confirms) → Delivered
- Postcondition: Order status updated in DB; both parties see updated status in real time

**UC-03: Confirm Delivery**
- Actor: Customer
- Precondition: Order status is `delivering`
- Steps: View order screen → Tap "Confirm Received / I have eaten"
- Postcondition: Order status updated to `delivered`; history preserved for both parties

---

## Phase 3 — System Design

### 3.1 System Architecture

```
┌───────────────────────────────────────────────────────┐
│                     CLIENT LAYER                       │
│  ┌─────────────────┐      ┌─────────────────────────┐ │
│  │  Customer App   │      │  Restaurant Owner App   │ │
│  │  (Flutter)      │      │  (Flutter)              │ │
│  └────────┬────────┘      └───────────┬─────────────┘ │
│           │                           │               │
│  ┌────────▼───────────────────────────▼─────────────┐ │
│  │              Flutter Providers (State)            │ │
│  │  AuthProvider | CartProvider | OrderProvider      │ │
│  │  RestaurantProvider | ThemeProvider               │ │
│  └────────────────────────┬─────────────────────────┘ │
└───────────────────────────┼───────────────────────────┘
                            │ HTTPS / WebSocket
┌───────────────────────────▼───────────────────────────┐
│                    SUPABASE BACKEND                    │
│  ┌─────────────┐ ┌──────────────┐ ┌────────────────┐ │
│  │ PostgreSQL  │ │  Auth        │ │  Storage       │ │
│  │ (Database)  │ │  (JWT)       │ │  (Receipts +   │ │
│  │             │ │              │ │   Avatars)     │ │
│  └──────┬──────┘ └──────────────┘ └────────────────┘ │
│         │                                              │
│  ┌──────▼────────────────────────────────────────┐   │
│  │  Realtime (PostgreSQL Changes)                │   │
│  │  Subscribed tables: orders, owner_applications│   │
│  └───────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────┘
```

### 3.2 Database Schema (ERD)

```
auth.users (Supabase managed)
    │ id (UUID PK)
    │ email
    │
    ├──────────────────────┐
    ▼                      ▼
profiles                restaurants
  id (FK → auth.users)     id (UUID PK)
  full_name                owner_id (FK → auth.users)
  role (ENUM)              owner_email
  phone                    name
  address                  description
  avatar_url               address
  push_enabled             image_url
  email_enabled            rating
                           time
                           delivery_fee
                           tags[]
                           is_active
                │
                ├──────────────────────────┐
                ▼                          ▼
         menu_categories               orders
           id (UUID PK)                  id (UUID PK)
           restaurant_id (FK)            user_id (FK → auth.users)
           name                          restaurant_id (FK)
           sort_order                    status (ENUM)
                │                        total_amount
                ▼                        delivery_address
           menu_items                    payment_image_url
             id (UUID PK)                created_at
             category_id (FK)                │
             name                            ▼
             description                order_items
             price                        id (UUID PK)
             image_url                    order_id (FK)
             is_available                 menu_item_id (FK)
                                          quantity
                                          unit_price
```

**ENUM Types:**
- `user_role`: `customer`, `owner`, `superadmin`
- `order_status`: `pending`, `preparing`, `delivering`, `delivered`, `cancelled`

### 3.3 Application Architecture (Flutter)

```
lib/
├── main.dart                    # App entry, Supabase init
├── app.dart                     # GoRouter config, theme, providers
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Design system colors
│   │   └── app_data.dart        # Static fallback data
│   └── services/
│       ├── image_service.dart   # Cross-platform image pick/upload
│       └── supabase_service.dart # Restaurant/menu fetch + URL fixing
├── models/
│   ├── user.dart                # AppUser model with phone field
│   ├── order.dart               # Order + OrderStatus enum
│   ├── cart_item.dart           # CartItem model
│   ├── restaurant.dart          # Restaurant model
│   ├── menu_item.dart           # MenuItem model
│   └── menu_category.dart       # MenuCategory model
├── providers/
│   ├── auth_provider.dart       # Login, signup, profile fetch
│   ├── cart_provider.dart       # Cart state management
│   ├── order_provider.dart      # Orders + realtime sync
│   ├── restaurant_provider.dart # Restaurant list state
│   └── theme_provider.dart      # Dark/light mode toggle
├── screens/
│   ├── auth/auth_screen.dart    # Login + signup (role-based)
│   ├── customer/
│   │   ├── home_screen.dart     # Restaurant browsing
│   │   ├── restaurant_detail_screen.dart
│   │   ├── cart_screen.dart     # Checkout + payment upload
│   │   ├── orders_screen.dart   # Active orders + confirm button
│   │   └── profile_screen.dart  # Profile, phone, address, avatar
│   ├── owner/
│   │   ├── owner_dashboard_screen.dart  # Live orders + menu + analytics
│   │   └── owner_apply_screen.dart
│   └── superadmin/
│       └── superadmin_dashboard_screen.dart
└── widgets/
    ├── restaurant_card.dart
    ├── menu_item_card.dart
    └── order_timeline.dart      # Visual status timeline
```

### 3.4 UI/UX Design Principles

- **Design System:** Deep Lime Green (`#65A30D`) primary, dark backgrounds `#0F1117` / `#1A1D27`
- **Typography:** Google Fonts — `Outfit` (headings), `Inter` (body text)
- **Components:** Glassmorphism cards, animated status timelines, accordion profile sections
- **Responsiveness:** `LayoutBuilder` used for web-wide layouts; mobile-first on all screens
- **Navigation:** `go_router` for declarative, role-based routing

---

## Phase 4 — Development

### 4.1 Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter 3.x (Dart) | Cross-platform mobile + web UI |
| State Management | Provider package | Reactive state across widgets |
| Backend | Supabase | Database, Auth, Storage, Realtime |
| Database | PostgreSQL (via Supabase) | Persistent relational data |
| Realtime | Supabase Realtime (WebSocket) | Live order status updates |
| Storage | Supabase Storage | Payment receipts + avatars |
| Navigation | go_router | Role-based declarative routing |
| Image Loading | cached_network_image | Efficient network image caching |
| Charts | fl_chart | Revenue analytics charts |
| Animations | flutter_animate | Micro-animations and transitions |
| Fonts | google_fonts | Outfit + Inter typography |
| Image Picker | image_picker | Cross-platform gallery access |
| Version Control | Git + GitHub | Collaboration and history |

### 4.2 Key Implementation Highlights

#### Order Persistence (Fixed)
Orders were disappearing after re-login because `fetchOrders()` was not mapping the Supabase response back into `Order` objects. This was fixed by iterating the response and manually building `CartItem` lists from the joined `order_items` + `menu_items` data.

```dart
// order_provider.dart — fetchOrders()
final response = await _supabase
  .from('orders')
  .select('*, restaurants(name), order_items(quantity, unit_price, menu_items(name, image_url))')
  .eq('user_id', userId)
  .order('created_at', ascending: false);
```

#### Bi-Directional Realtime Sync
Both the customer app and the owner dashboard use Supabase Realtime channels:

- **Customer:** Subscribed to their own `user_id` — receives instant UI updates when owner changes status.
- **Owner:** Subscribed to their `restaurant_id` — receives new order alerts and status change updates from customers.

#### Cross-Platform Image Handling
The `ImageService` was refactored to use `XFile` + `uploadBinary()` instead of `dart:io File`, making it work identically on Android, iOS, and Web browsers.

#### Login Race Condition (Fixed)
The sign-in flow was logging owners out because `_user` (profile) was still `null` when the role check ran. Fixed by awaiting `_fetchProfile()` inside `signIn()` before returning.

#### Restaurant Image URLs (Fixed)
Unsplash URLs in the database lacked query parameters needed for the CDN. A `_fixImageUrl()` helper was added to `SupabaseService` that automatically appends `?w=800&q=80&auto=format&fit=crop` to all bare Unsplash URLs.

### 4.3 Test Accounts

| Role | Email | Password |
|---|---|---|
| Admin | admin@saffroneats.com | password123 |
| Kenbon Owner | kenbon@saffroneats.com | password123 |
| YegnawBet Owner | yegnawbet@saffroneats.com | password123 |
| Gola Owner | gola@saffroneats.com | password123 |
| Marafa Owner | marafa@saffroneats.com | password123 |
| Customer | (Register any email) | (Your choice) |

---

## Phase 5 — Testing Documentation

### 5.1 Unit Test Cases

| TC-ID | Module | Test Case | Expected Result | Status |
|---|---|---|---|---|
| UT-01 | `AppUser.fromJson` | Parse profile row with phone field | Returns `AppUser` with phone populated | ✅ Pass |
| UT-02 | `Order.parseStatus` | Parse `"delivering"` string | Returns `OrderStatus.delivering` | ✅ Pass |
| UT-03 | `SupabaseService._fixImageUrl` | Bare Unsplash URL passed | Returns URL with `?w=800&q=80` appended | ✅ Pass |
| UT-04 | `SupabaseService._fixImageUrl` | Null passed | Returns hardcoded food fallback URL | ✅ Pass |
| UT-05 | `CartProvider.addItem` | Add same item twice | Quantity increments, not duplicate entry | ✅ Pass |
| UT-06 | `CartProvider.removeItem` | Remove item from cart | Item no longer in cart list | ✅ Pass |
| UT-07 | `OrderProvider.updateOrderStatus` | Update to `"delivered"` | Local state updates + DB write succeeds | ✅ Pass |

### 5.2 Integration Test Cases

| TC-ID | Flow | Steps | Expected Result | Status |
|---|---|---|---|---|
| IT-01 | Customer Registration | Register → Check DB | Profile created in `profiles` table with role=`customer` | ✅ Pass |
| IT-02 | Owner Login | Login as `kenbon@saffroneats.com` → Dashboard | Dashboard loads with Kenbon Restaurant data | ✅ Pass |
| IT-03 | Order Placement | Add items → Upload receipt → Place order | Order appears in DB + on owner dashboard in real time | ✅ Pass |
| IT-04 | Status Update by Owner | Owner taps "Accept" | Customer order screen updates to "Preparing" without refresh | ✅ Pass |
| IT-05 | Customer Confirm Delivery | Tap "Confirm Received" | Status updates to `delivered` on both customer and owner screens | ✅ Pass |
| IT-06 | Order Persistence | Place order → Log out → Log back in | Orders still visible with correct status | ✅ Pass |
| IT-07 | Multi-Restaurant Order | Add items from 2 restaurants → Checkout | Two separate orders created, each on the correct owner dashboard | ✅ Pass |
| IT-08 | Role Isolation | Log in as Kenbon owner | Only Kenbon orders appear; YegnawBet orders not visible | ✅ Pass |
| IT-09 | Phone Save | Add phone in profile → Save | Phone visible in profile header and stored in Supabase | ✅ Pass |
| IT-10 | Image Loading | Open home screen | Restaurant images load from Unsplash (with proper query params) | ✅ Pass |

### 5.3 User Acceptance Testing (UAT)

#### UAT Session 1 — Customer Flow

**Tester:** Team member acting as first-time customer  
**Device:** Android mobile phone + Chrome web browser

| Step | Action | Result | Accepted? |
|---|---|---|---|
| 1 | Register new account with email + address | Account created, redirected to home | ✅ Yes |
| 2 | Browse Kenbon Restaurant menu | Menu categories and prices display correctly | ✅ Yes |
| 3 | Add 3 items to cart | Cart icon shows item count | ✅ Yes |
| 4 | Go to cart, upload payment screenshot | Receipt name displayed in green | ✅ Yes |
| 5 | Place order | Success dialog shown, order appears in Orders tab | ✅ Yes |
| 6 | Log out and log back in | Previous order still visible | ✅ Yes |
| 7 | Add phone number in Profile settings | Phone saved and shows in profile header | ✅ Yes |

#### UAT Session 2 — Restaurant Owner Flow

**Tester:** Team member acting as restaurant owner  
**Device:** Chrome web browser (desktop)

| Step | Action | Result | Accepted? |
|---|---|---|---|
| 1 | Login to Partner Hub with owner email (1st click) | Enters dashboard immediately (race condition fixed) | ✅ Yes |
| 2 | View incoming order | Customer name, phone, items, receipt photo all visible | ✅ Yes |
| 3 | Tap "Accept" | Order status changes on owner dashboard; customer sees "Preparing" | ✅ Yes |
| 4 | Tap "Mark as Out for Delivery" | Customer sees "Confirm Received" button appear | ✅ Yes |
| 5 | Customer taps "Confirm Received" | Owner dashboard updates to "Delivered ✓" | ✅ Yes |
| 6 | View analytics tab | Revenue total and popular items display correctly | ✅ Yes |
| 7 | Add new menu item via dialog | Item appears in menu tab immediately | ✅ Yes |

### 5.4 Known Limitations & Future Improvements

| Item | Description | Future Fix |
|---|---|---|
| Push Notifications | Status changes are in-app only; no system push notifications | Integrate Firebase Cloud Messaging (FCM) |
| Payment Verification | Payment screenshot upload is manual; no automated verification | Integrate telebirr / CBE Birr API |
| Offline Support | No offline data caching; requires internet connection | Add Hive local DB for offline queue |
| GPS Delivery Tracking | No live map tracking of delivery driver | Integrate Google Maps + driver app |
| Rating System | Customers cannot rate restaurants or meals | Add star rating + review system |
| SMS Alerts | No SMS notification to customer or driver | Integrate Africa's Talking SMS API |

---

## Innovation & Additional Features

| Feature | Description | Implementation |
|---|---|---|
| **Real-time Bidirectional Sync** | Both customer and owner screens update instantly without refresh | Supabase Realtime `onPostgresChanges` with `PostgresChangeEvent.all` |
| **Role-based Auth System** | Three-tier access: Customer, Owner, Superadmin | Email-domain-based role detection + DB trigger auto-linking |
| **Multi-Restaurant Cart** | Items from different restaurants handled as separate orders | Cart grouped by `restaurantId`; separate checkout per restaurant |
| **Cross-Platform Image Upload** | Works on Android, iOS, and Web browser | `XFile` + `uploadBinary()` — no `dart:io` dependency |
| **Smart Login Flow** | Profile fetched before role check to prevent false logout | `await _fetchProfile()` inside `signIn()` before returning |
| **Image URL Healing** | Broken/missing Unsplash URLs auto-repaired | `_fixImageUrl()` helper appends CDN params automatically |
| **Owner Analytics Dashboard** | Revenue, order count, today's orders, popular items ranking | Aggregated from `order_items` + `orders` tables |
| **Premium Dark Mode** | Professional dark theme with lime green accent | Custom `AppColors` with `#0F1117` backgrounds |
| **Delivery Confirmation Workflow** | Customer confirms receipt; owner has fallback button | Two-path update: customer taps confirm OR owner manually marks delivered |
| **Partner Application Portal** | New restaurants can apply via in-app form | Submissions saved to `owner_applications` table; admin reviews in dashboard |

---

## Team Contribution Breakdown

| Member | Role | Contributions |
|---|---|---|
| Member 1 | Lead Developer | Architecture design, Supabase schema, Auth flow, Realtime integration |
| Member 2 | UI/UX Developer | All customer-facing screens, dark mode design system, animations |
| Member 3 | Backend Developer | Order provider logic, Owner dashboard, Analytics tab |
| Member 4 | Testing & QA | Test case design, UAT sessions, bug reporting and verification |
| Member 5 | Documentation | SDLC documentation, README, requirement analysis, user research |

> **Note:** Adjust names and contributions to match your actual team members before submission.

---

## Appendix A — Running the Application

### Prerequisites
- Flutter SDK 3.x
- Android Studio or VS Code with Flutter extension
- A Supabase project (credentials in `lib/core/constants/`)

### Run on Web
```bash
flutter run -d chrome
```

### Run on Android
```bash
flutter run -d android
```

### Build Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Appendix B — Database Setup

Run the full schema in Supabase SQL Editor:

```
supabase/schema.sql
```

This script:
1. Creates all tables with proper foreign keys
2. Enables Row Level Security (RLS) with open policies for development
3. Creates a trigger to auto-assign user roles from email domain
4. Seeds all 4 restaurants with menu categories and menu items
5. Enables Supabase Realtime on the `orders` table

---

*Document prepared by the SaffronEats development team — Adama Science and Technology University, 2025/2026.*
