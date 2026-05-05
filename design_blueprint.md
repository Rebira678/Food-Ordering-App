# Food Ordering App: Technical & UX Blueprint

## 1. Core Product Vision
**Primary Use Case:** A multi-vendor, restaurant-first marketplace focused on high-quality local eateries, facilitating premium delivery and pickup experiences. Unlike aggressive aggregate platforms, this app gives restaurants power over their presentation and provides customers with a highly curated, fast, and reliable ordering experience.

**Key Value Propositions:**
*   **Customer:** Speed, trust, and premium discovery. A zero-friction ordering process with highly visual, appetizing menus, transparent pricing, and real-time tracking that builds confidence.
*   **Restaurant / Kitchen Operator:** Empowerment and efficiency. A streamlined tablet-first interface to manage incoming tickets natively, update item availability in one tap, and get actionable sales insights without being buried in dark UX patterns.
*   **Delivery / Logistics:** Predictability. Access to precise kitchen prep times and optimized routing to minimize wait times at the restaurant, leading to higher turnover and tips.

## 2. Core Features (Customer-First)

**Onboarding:**
*   **1-Tap Entry:** Apple/Google SSO and Phone Number (OTP). No forced password creation.
*   **Frictionless Setup:** Optional profile completion. Location auto-detection via GPS (with permission) for immediate address suggestions, saved securely upon first order.

**Discover & Browse:**
*   **Visual-First Feed:** High-resolution masonry or large-card layout emphasizing food over logos. Overlaid badges for rating, ETA, and distance.
*   **Smart GPS & Fast Filters:** 1-tap pills for "Offers", "Under 30 mins", "Vegan", "High Protein", and dynamic cuisine carousels.
*   **Global Search:** Typo-tolerant fuzzy search pulling dishes, restaurants, and categories simultaneously.

**Menu & Ordering:**
*   **Card-Style Menu:** Edge-to-edge food images where applicable, brief but evocative descriptions, and clear diet/allergen labels (e.g., 🌱, 🌶️, 🍞).
*   **Curated Sections:** Highlights like “Chef’s Picks” and “Today’s Deals” featured at the top to combat decision fatigue.
*   **Customization Flow:** Bottom-sheet modal for variants (size, spice) and add-ons. **Real-time price accumulation** at the bottom sticky button.
*   **Smart Cart:** Floating cart button with live item count and subtotal. In-cart intelligent upsell ("Add a drink for $2").

**Checkout & Payment:**
*   **One-Page Checkout:** Consolidated view of delivery address, drop-off instructions, and scheduled time.
*   **Frictionless Payment:** Native Apple Pay/Google Pay integration, saved cards via secure vault tokenization, and optional Cash/Terminal on Delivery.
*   **Friendly Summary:** Total breakdown prioritizing transparency (Tax, Delivery Fee, Tip) immediately before placing the order.

**Order Tracking & Status:**
*   **Live Timeline:** Clear visual states: Placed → Confirmed → Preparing (with estimated prep time) → Out for Delivery → Arrived.
*   **Animated Status Bar:** A dynamic progress bar or Lottie animation in the tracking center. Smooth map integration showing the driver's real-time location.
*   **Multichannel Alerts:** Non-intrusive push notifications with SMS fallback for critical updates ("Driver arriving in 2 mins").

**Post-Order & Loyalty:**
*   **Review & Tip:** Prompted gracefully upon next app open or via rich notification. Fast star rating with quick-tag feedback (e.g., "Hot food", "Great portion").
*   **Visual Loyalty:** A gamified "Stamps" or "Points" progress ring filling up visually after each purchase.
*   **Quick Re-Order:** A dedicated tab/section displaying previous meals with a 1-tap "Add all to cart" function.

## 3. Stand-Out UI / UX Guide

**Color Palette:**
*   **Primary:** Vibrant, appetizing **Saffron Orange** (`#FF7A00`) — stimulates appetite and draws attention to primary actions (Add to Cart, Checkout).
*   **Secondary:** **Deep Slate** (`#1E222B`) for prominent texts and dark mode backgrounds.
*   **Neutrals & Backgrounds:** **Off-White/Cream** (`#F7F8FA`) for app background to provide a softer, more organic feel than pure white.
*   **Success/Status:** Muted **Mint Green** (`#00A86B`) for active states and dietary tags.

**Typography System:**
*   **Headings:** *Outfit* or *Cabinet Grotesk* (Bold, rounded geometry for a friendly, modern touch).
*   **Body:** *Inter* (Highly legible, neutral, perfect for reading long menus).
*   **Numeric Labels/Prices:** *SF Pro Display/Roboto Mono-ish* variants for crisp, aligned structural numbers.

**Micro-interactions that Delight:**
*   **Add to Cart:** Instead of a simple toast, the food image shrinks and arcs across the screen into the floating cart icon, triggering a brief haptic bounce.
*   **Cart Badge:** A subtle "jump and scale-up" animation on the cart badge when its counter increments.
*   **Skeletons:** Shimmering, slightly rounded loading skeletons that mirror the exact layout of the arriving content to reduce perceived wait times.

**Layout Patterns:**
*   **Tab-Bottom Navigation:** Home, Search, Orders, Account. Clean iconography with active states highlighted by the primary color.
*   **Food Grid:** Vertical scrolling for categories, horizontal snapping carousels for premium items within sections.
*   **Sticky Checkout:** No matter where you scroll on the checkout page, the “Slide to Pay” or “Place Order - $XX.XX” bar stays anchored at the screen's bottom with a glassmorphic blur effect.

**Accessibility:**
*   Minimum contrast ratio of 4.5:1 on all text.
*   Touch targets strictly sized at 44x44pt minimum.
*   Dynamic Type support and proper `aria-labels` / VoiceOver tags for all non-text elements.

**Unique UI Touches:**
1.  **Immersive Hero Detail:** Tapping an item transitions seamlessly using shared-element routing; the image expands to the top edge, and a blurred, color-extracted background surrounds the content.
2.  **"Chef's Notes":** A hand-written aesthetic block quoting the chef about a signature dish to build a human connection.
3.  **Thematic Restaurant Banners:** Based on the cuisine type or time of day, subtle atmospheric animations play in the header (e.g., soft steam loops for hot food, crisp morning lighting for coffee spots).

## 4. Technical Architecture (Production-Ready)

**Frontend:**
*   **Framework:** **React Native** (using Expo for fast iteration and native module support). Ensures a single codebase for iOS and Android with near-native performance using the New Architecture (Fabric).
*   **State Management:** **Zustand** for lightweight, boilerplate-free global state (cart, current user). **React Query (TanStack)** for server state (caching menus, optimistic UI updates on add-to-cart).
*   **Component Structure:** Atomic design. Reusable elements like `<FoodCard />`, `<ModifierList />`, `<CartOverlay />`, `<AddressSelector />`. Strict separation of UI components from business logic hooks.

**Backend & API:**
*   **API Design:** **RESTful APIs** optimized with aggressive CDN caching for read-heavy operations (browsing menus). Use WebSockets or Server-Sent Events (SSE) for real-time order tracking.
*   **Endpoints (High-Level):**
    *   `POST /auth/login` (Sends OTP) / `POST /auth/verify` (Returns JWT tokens)
    *   `GET /restaurants/search?lat=x&lng=y` (Gets nearby restaurants)
    *   `GET /restaurants/:id/menu` (Fetches full categorized menu)
    *   `POST /cart/sync` (Validates cart totals server-side)
    *   `POST /orders/checkout` (Finalizes order, returns payment intent)
    *   `GET /orders/:id/status` (SSE connection for live updates)
*   **Authentication Strategy:** **JWT** (JSON Web Tokens) with short-lived access tokens (15m) and HTTP-only, secure, strict-samesite refresh tokens (7d). Rate-limiting on all auth and checkout endpoints.

**Database Schema (High-Level):**
*   **Relational Database (PostgreSQL):**
    *   `User`: id, phone, email, name, preferences.
    *   `Restaurant`: id, name, location (PostGIS point), status, open_hours.
    *   `MenuCategory`: id, restaurant_id, name, sequence.
    *   `MenuItem`: id, category_id, name, description, base_price, image_url.
    *   `ModifierGroup`: id, item_id, name, max_selections, min_selections (e.g., "Choose Size").
    *   `Order`: id, user_id, restaurant_id, total_amount, status, delivery_address, created_at.
    *   `OrderItem`: id, order_id, item_id, quantity, final_price, applied_modifiers_json.
    *   `Payment`: id, order_id, status, gateway_token.

**DevOps & Scalability:**
*   **Cloud Hosting:** **AWS** (Elastic Container Service - ECS or RDS for DB). Containerized Node.js/Go backend services.
*   **Peak Loads Strategy:**
    *   **Caching:** Redis for caching restaurant structures, menus, and user sessions.
    *   **Queues:** RabbitMQ or AWS SQS / EventBridge for uncoupling order processing. When an order is placed, it enters a queue -> Payment worker processes -> Restaurant notification worker processes.
    *   **Databases:** Main writer DB and auto-scaling Read-Replicas.
*   **Monitoring:** Sentry for crash/error tracking on frontend, Datadog or Prometheus/Grafana for backend APM, uptime, and database load monitoring.

## 5. Security & Compliance

*   **Data Protection:** PII (Personally Identifiable Information) like emails and addresses are encrypted at rest using AES-256. Passwords (if used) are hashed with Argon2id.
*   **Attack Mitigation:**
    *   Rate limiting via Redis (e.g., max 5 login attempts per minute).
    *   WAF (Web Application Firewall, like Cloudflare) to block volumetric DDoS, SQLi, and XSS.
    *   Helmet.js on Node to enforce strict Content Security Policies (CSP).
*   **GDPR / Privacy:** "Delete My Account" flow directly in the App Store compliance, granular cookie/tracking consents, and clear opt-ins for marketing communications.
*   **PCI-Compliance:** No raw card data touches the server. Implementation via **Stripe Elements / Braintree SDK**. The app only stores non-sensitive customer tokens and last 4 digits for UI reference.

## 6. Operational & Restaurant-Side Needs

**Admin & Kitchen Dashboard (Tablet-Optimized Web App / PWA):**
*   **Real-Time Order Feed:** A Kanban-style or chronological list of tickets incoming. High-contrast alerts with audible pings (configurable rings based on urgency) for new orders.
*   **Order Workflow:** Big, touch-friendly buttons to advance status: "Accept" -> "Mark Preparing" -> "Ready for Pickup/Delivery". Delay order features with predefined reasons ("Very Busy - Add 15 mins").
*   **Menu & Inventory Management:** 1-tap "86" (Out of Stock) toggle for items. Quick adjustments for temporary closures or pausing incoming orders ("Busy Mode").
*   **Reporting:** End-of-day summary dashboard: gross sales, popular items, cancelation rates.

**Notifications & Critical Alerts:**
*   Persistent rings for unaccepted orders after 3 minutes.
*   Automated escalation: Phone call via Twilio API to the restaurant if an order isn't accepted digitally within 5 minutes.
*   Cancellation alerts popping as high-priority modals disrupting any current view.

## 7. Figma-Style UI Overview (Text Reference)

**1. Home / Discovery Screen**
*   **Top Header:** User's delivery address (tappable down-arrow) and a minimalist, bold search icon.
*   **Hero Section:** A horizontal scrolling carousel of large, vivid banners ("20% off Sushi", "New: Joe's Burgers") with rounded corners and drop shadows.
*   **Quick Filters:** "Deals", "Healthy", "Fastest", horizontally scrollable pills.
*   **Feed:** Vertical list of wide restaurant cards. Each card has an edge-to-edge photo, name, subtle rating badge (★ 4.8), and "Delivery: 25-35 min • $2.99" text.

**2. Restaurant / Menu Detail**
*   **Header:** Sticky top area with the restaurant name blending over the dimmed header image. Left arrow to go back.
*   **Info Bar:** Time, distance, rating, and a "Group Order" plus icon.
*   **Categories:** A sticky horizontal scrollbar (Starters, Mains, Drinks) that stays at the top as the user scrolls down the page.
*   **Food Card Layout:** A dense grid or list showing a square thumbnail on the right, bold item name, 2-line description, and price on the left.
*   **Sticky Footer (if cart active):** A pill at the bottom center: "View Cart (3) - $34.50" in the primary orange color, floating smoothly with a blurred background.

**3. Cart & Checkout**
*   **Order List:** Clean list of items with native swipe-to-delete. Clean stepper (`-` `1` `+`) for quantity directly on the item.
*   **Upsell Strip:** "Goes well with your order:" highlighting 2-3 horizontally scrolling small cards (e.g., drinks, extra sauces) with an instant "+" button.
*   **Summary Box:** Subtotal, Delivery, Service Fee, Driver Tip (selectable 15%, 20%, Custom), Total.
*   **Sticky Footer:** A wide "Slide to Place Order / Pay $XX.XX" component (avoids accidental screen taps) spanning the bottom safe area.

**4. Order Tracking**
*   **Top Half:** A live map interface showing the route from the restaurant to the user. A car icon bouncing smoothly.
*   **Bottom Half (Drawer):** Pull-up drawer (BottomSheet) with a vertical timeline (Placed, Preparing, On the way).
*   **Driver Info:** Driver photo, name, rating, and quick action buttons to Call or Text.
*   **Status Headline:** Large, prominent typography: "John is arriving with your order in 3 minutes!"
