# 1. Analysis & Requirements Document

## 1.1 User Interviews & Surveys
Prior to developing **SaffronEats**, we conducted formal surveys and informal interviews with 50+ university students, office workers, and 5 local restaurant owners in Adama, Ethiopia. 

**Key Interview Findings:**
*   **Customers (Students/Workers):** 75% complained about the unreliability of current food delivery options. They often call restaurants directly but face busy lines or misheard orders.
*   **Restaurant Owners:** 4 out of 5 rely on manual pen-and-paper tracking. They find aggregators take too high of a commission and offer poor analytics. They struggle to update menus when items run out.

## 1.2 Identified Pain Points
1.  **High Friction Ordering:** Customers have to call, explain locations repeatedly, and guess prices.
2.  **Lack of Transparency:** Customers do not know if their food is being prepared or is on the way.
3.  **Poor Restaurant Tools:** Owners lack a digital dashboard to track daily revenue, manage incoming orders, and instantly mark items as "Out of Stock."
4.  **Inefficient Delivery Routing:** Drivers spend too much time locating customers without GPS pins.

## 1.3 Real-World Scenarios (Use Cases)

*   **Scenario 1 (The Busy Student):** Rebira is studying late for exams. He opens SaffronEats, filters by "Fast Food", and orders a burger. He tracks the order status in real-time, knowing exactly when to go downstairs to meet the delivery driver.
*   **Scenario 2 (The Restaurant Owner):** A restaurant runs out of chicken. The owner opens the SaffronEats Owner Dashboard on their tablet, toggles the "Chicken Wrap" to inactive, instantly removing it from the customer app without needing to call technical support.
*   **Scenario 3 (The Superadmin):** A new restaurant applies to join the platform. The superadmin logs into the admin panel, reviews the restaurant's details and menu, and approves the application, instantly making it live on the network.

## 1.4 Workflow Analysis

### **As-Is Workflow (Current State)**
1. Customer finds a restaurant phone number.
2. Customer calls; the line might be busy.
3. Customer asks what is available.
4. Restaurant staff writes the order on paper.
5. Delivery driver calls the customer 3 times to find the location.
6. Cash payment is made without a clear receipt.

### **To-Be Workflow (SaffronEats System)**
1. Customer opens the Flutter app and views live menus.
2. Customer adds items to the cart and confirms exact GPS location.
3. Order is pushed to Supabase; the Restaurant Owner Dashboard rings immediately.
4. Owner taps "Accept" → order status updates to "Preparing" on customer's phone.
5. Driver uses in-app map to deliver directly to the pin.
6. Seamless digital or cash-on-delivery payment with detailed electronic receipts.

## 1.5 Functional Requirements
*   **FR-1 (Auth):** The system must allow users to register and login securely.
*   **FR-2 (Browsing):** Customers must be able to view restaurants, filter categories, and see items.
*   **FR-3 (Cart & Checkout):** Customers must be able to add multiple items, calculate totals, and place orders.
*   **FR-4 (Owner Panel):** Restaurant owners must see a live feed of incoming orders and analytics.
*   **FR-5 (Admin Panel):** Superadmins must have oversight over all users and restaurants.

## 1.6 Non-Functional Requirements
*   **NFR-1 (Performance):** App must load menus in under 2 seconds. State must update instantly without page refreshes.
*   **NFR-2 (Cross-Platform):** The app must run natively on Android, iOS, and Web using a single Flutter codebase.
*   **NFR-3 (Usability):** The UI must support a dark mode and follow Material Design 3 guidelines for high accessibility.
*   **NFR-4 (Security):** All passwords must be hashed, and API access must be secured via Supabase Row Level Security (RLS).
