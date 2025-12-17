# Jarvis

**Jarvis** is a multipurpose iOS assistant application designed to streamline daily life, initially evolving from a "LifeLogger" concept. It follows a "Nordic Soft Minimalist" design aesthetic and currently focuses on **Travel Packing**.

## Features

### 1. Dashboard
-   **Central Hub**: A clean, card-based dashboard.
-   **Nordic Theme**: Implements a consistent, professional design system (`DESIGN_GUIDELINES.md`) with Semantic Colors (Slate Blue, Sage, Off-White) and Light/Dark mode support.

### 2. Travel Packing
-   **Trip Management**: Create and track upcoming and past trips.
-   **Global Packing Pool**: Manage a master list of categories (e.g., Hygiene, Tech) and items.
    -   **Editable**: Swipe to rename categories/items.
    -   **Flexible**: No forced capitalization.
-   **Smart Packing**: "Add from Pool" feature allows quick selection of items for specific trips.
-   **Item Quantities**: Support for specific quantities (e.g., "3x T-Shirts"), editable via tap.
-   **Reordering**: Drag-and-drop support for packing lists.
-   **Progress Tracking**: Visual progress bar for each trip's packing status.

## Project Structure

-   `LifeLoggerApp.swift`: App entry point and logic for seeding default data (e.g., Nordic packing categories).
-   `Modules/`: Contains feature-specific views (Dashboard, Travel).
-   `Core/`: Shared resources, Models (`TripModels`), and Design System (`AppColors`).

## Tech Stack

-   **SwiftUI**: User Interface.
-   **SwiftData**: Local persistence for Trips and Packing Items.
