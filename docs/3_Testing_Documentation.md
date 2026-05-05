# 3. Testing Documentation

## 3.1 Test Cases (Derived from Scenarios)

| Test ID | Module | Scenario / Description | Pre-conditions | Expected Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Auth | User attempts to login with valid credentials. | User exists in DB. | Navigates to Home Screen, `AuthProvider` updates state. | Pass |
| **TC-02** | Auth | User attempts login with wrong password. | None. | Shows error SnackBar. Remains on Auth Screen. | Pass |
| **TC-03** | Menu | User adds an item to the cart. | Logged in as customer. | Floating cart badge updates count from 0 to 1. | Pass |
| **TC-04** | Cart | User increases item quantity in cart. | Cart has 1 item. | Item subtotal and cart Grand Total update instantly. | Pass |
| **TC-05** | Order | Customer places an order successfully. | Cart > 0, Address filled. | Cart is cleared, redirected to Orders screen showing "Pending". | Pass |
| **TC-06** | Owner | Owner views dashboard. | Logged in as owner. | Dashboard renders revenue chart (`fl_chart`) and active order list. | Pass |
| **TC-07** | Admin | Admin views network stats. | Logged in as admin. | Sees total users, total restaurants, and global revenue. | Pass |

## 3.2 Unit & Integration Testing Strategy

*   **Unit Tests:** Tested individual Dart model serializations (e.g., `MenuItem.fromJson` and `MenuItem.toJson`) to ensure database data maps correctly to Dart objects.
*   **Provider Tests:** Mocked `ChangeNotifier` state updates. Verified that calling `CartProvider.addItem()` correctly calculates the total price and updates listeners without needing UI rendering.
*   **Widget Testing (Integration):** Used Flutter's testing framework to ensure that tapping the "Add to Cart" button triggers the Provider and physically updates the `CartIconBadge` widget on screen.

## 3.3 User Acceptance Testing (UAT) Results

We conducted UAT with a small group of 5 peers acting in different roles (3 customers, 1 restaurant owner, 1 admin).

**Feedback & Resolutions:**
1.  **Feedback (Customer):** "I wasn't sure if my order went through because it loaded too fast."
    *   **Fix:** Added a `flutter_animate` success confirmation animation and a 1-second artificial delay during the checkout process to provide psychological assurance.
2.  **Feedback (Owner):** "The dashboard is hard to read in bright sunlight."
    *   **Fix:** Implemented a pure Black/White high-contrast Dark Mode (`AppTheme.darkTheme`) that can be toggled.
3.  **Feedback (Admin):** "I need to see which restaurants are new."
    *   **Fix:** Added an "Approval Pending" list specifically for the Superadmin dashboard.

**UAT Sign-off:** All critical flows (Ordering, Dashboard Viewing, Menu Browsing) passed without application crashes on Android and Web targets.
