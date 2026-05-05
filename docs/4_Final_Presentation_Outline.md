# 4. Final Presentation Outline

This document outlines the slide structure for the final project presentation.

## Slide 1: Title Slide
*   **Project Title:** SaffronEats — Multi-Platform Food Delivery
*   **Course:** Multi-Platform Software Development
*   **Team Members:**
    *   Iftu Chala (UGR/ 34654/16)
    *   Yididya Shimelis (UGR/ 35654/16)
    *   Petros Sisay (UGR/ 31111/15)
    *   Natnael Esayas (UGR/ 35126/16)
    *   Rebira Adugna (UGR/ 35240/16)

## Slide 2: Problem Statement & Analysis
*   **The Problem:** Disjointed communication between customers and restaurants in Adama. Lack of digital menus, hard-to-track orders, and high aggregator commissions.
*   **Research Findings:** Surveys showed 75% of users hate phone-ordering friction. Owners need better, cheaper management tools.

## Slide 3: The Solution (SaffronEats)
*   A unified, multi-platform app built with **Flutter**.
*   Three distinct experiences in one app:
    1.  Customer App (Order & Track)
    2.  Restaurant Partner Hub (Manage & Analyze)
    3.  Superadmin Panel (Network Oversight)

## Slide 4: System Architecture & Tech Stack
*   **Frontend:** Flutter (Dart), Provider for State Management, GoRouter.
*   **Backend:** Supabase (PostgreSQL, Auth, Realtime).
*   *(Include the Architecture Diagram from `2_System_Design.md`)*

## Slide 5: Innovation & Additional Features 🌟
*Highlighting how we exceeded basic requirements:*
1.  **Advanced Analytics:** Implemented native, interactive data visualization for restaurant owners using `fl_chart`.
2.  **Fluid Animations:** Integrated `flutter_animate` for micro-interactions, making the UI feel premium.
3.  **Local Caching:** Utilized `shared_preferences` for session persistence and fast loads.
4.  **Role-Based Dynamic Routing:** The app intelligently routes users to entirely different UI shells based on their backend role.

## Slide 6: Live Demonstration
*   **Flow 1:** Rebira (Customer) opens app, browses a restaurant, adds to cart, and checks out.
*   **Flow 2:** Iftu (Owner) receives the order on the Owner Dashboard and views the revenue chart.
*   **Flow 3:** Yididya (Admin) views the global network statistics.

## Slide 7: Testing & QA
*   Derived test cases directly from user scenarios.
*   Conducted Unit Testing on Providers.
*   Performed UAT (User Acceptance Testing) to refine UI/UX (e.g., adding dark mode for better outdoor visibility).

## Slide 8: Team Contribution Breakdown
*   **Iftu Chala:** UI/UX Design System, Theming, and Owner Dashboard Implementation.
*   **Yididya Shimelis:** System Architecture, Database Schema (Supabase), and Admin Dashboard.
*   **Petros Sisay:** Requirements Analysis, User Interviews, and Testing/QA Documentation.
*   **Natnael Esayas:** Provider State Management (Auth, Cart), and App Routing (`go_router`).
*   **Rebira Adugna:** Customer App UI (Home, Restaurant Details), Cart Logic, and Project Integration.

## Slide 9: Q&A
*   Thank you! Any questions?
