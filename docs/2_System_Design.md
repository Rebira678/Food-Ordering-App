# 2. System Design Document

## 2.1 System Architecture

SaffronEats utilizes a modern, serverless mobile architecture to guarantee scalability and native performance.

```mermaid
graph TD
    subgraph Client [Frontend - Flutter]
        UI[UI Layer / Widgets]
        State[Provider / State Management]
        Router[GoRouter / Navigation]
        Storage[Shared Preferences / Cache]
        
        UI <--> State
        State <--> Router
        State <--> Storage
    end

    subgraph Backend [Backend - Supabase]
        Auth[Supabase Auth / JWT]
        DB[(PostgreSQL Database)]
        Realtime[Realtime Subscriptions]
        StorageS3[Supabase Storage]
        
        Auth <--> DB
        DB <--> Realtime
    end

    Client <==>|REST / WebSockets| Backend
```

### Architectural Choices:
1.  **Flutter:** Chosen for native compilation, smooth 60fps animations, and a unified codebase.
2.  **Provider:** Used for reactive state management (Cart, Auth, Orders) to decouple UI from business logic.
3.  **Supabase:** Provides PostgreSQL, out-of-the-box Authentication, and real-time WebSockets for live order tracking.

---

## 2.2 Database Schema (Entity Relationship Diagram)

```mermaid
erDiagram
    USERS {
        uuid id PK
        string email
        string full_name
        string role "customer, owner, admin"
        string phone
        datetime created_at
    }
    RESTAURANTS {
        uuid id PK
        uuid owner_id FK
        string name
        string description
        string address
        float rating
        boolean is_active
    }
    MENU_CATEGORIES {
        uuid id PK
        uuid restaurant_id FK
        string name
    }
    MENU_ITEMS {
        uuid id PK
        uuid category_id FK
        string name
        string description
        float price
        string image_url
        boolean is_available
    }
    ORDERS {
        uuid id PK
        uuid user_id FK
        uuid restaurant_id FK
        string status "pending, preparing, delivering, completed"
        float total_amount
        string delivery_address
        datetime created_at
    }
    ORDER_ITEMS {
        uuid id PK
        uuid order_id FK
        uuid menu_item_id FK
        int quantity
        float unit_price
    }

    USERS ||--o{ RESTAURANTS : "owns"
    USERS ||--o{ ORDERS : "places"
    RESTAURANTS ||--o{ MENU_CATEGORIES : "has"
    RESTAURANTS ||--o{ ORDERS : "receives"
    MENU_CATEGORIES ||--|{ MENU_ITEMS : "contains"
    ORDERS ||--|{ ORDER_ITEMS : "includes"
    MENU_ITEMS ||--o{ ORDER_ITEMS : "is part of"
```

---

## 2.3 UI/UX Design & Mockups

The system uses a highly modular UI component strategy:
*   **Color Palette:** Saffron Orange (Primary), Deep Slate (Text/Backgrounds), Off-White (Surfaces).
*   **Typography:** Outfit (Headings) and Inter (Body) for a modern, clean look.
*   **Mockups/Wireframes:** The UI was designed mobile-first. 
    *   *Home Screen:* Features a horizontal category chip bar (`CategoryFilterChip`) and a vertical scrolling list of `RestaurantCard` widgets.
    *   *Menu Screen:* Utilizes sticky headers and `MenuItemCard` with direct "Add" capabilities.
    *   *Cart:* A bottom-sheet style checkout summary with clear taxation and fee breakdowns.
    *   *Dashboards:* The owner dashboard uses `fl_chart` for visual data representation.

*(Note: Live screenshots of the implemented UI can be found in the root `README.md`)*

---

## 2.4 API Design

Since the application uses Supabase, traditional REST API endpoints are replaced with PostgREST queries and Realtime Subscriptions.

**Core Data Access Patterns:**
*   **Auth:** `supabase.auth.signInWithPassword()` / `signUp()`
*   **Fetch Restaurants:** `supabase.from('restaurants').select('*').eq('is_active', true)`
*   **Fetch Menu:** `supabase.from('menu_categories').select('*, menu_items(*)')`
*   **Place Order:** `supabase.from('orders').insert({...})` (Triggers a webhook/function to deduct inventory if necessary).
*   **Live Tracking:** `supabase.channel('public:orders').on('postgres_changes', ...).subscribe()`
