# Jarvis

**Jarvis** is a multipurpose iOS assistant application designed to streamline daily life, initially evolving from a "LifeLogger" concept. It follows a "Nordic Soft Minimalist" design aesthetic and currently features modules for **Food Tracking** and **Travel Packing**.

## Features

### 1. Dashboard
-   **Central Hub**: A clean, card-based dashboard for easy navigation to different modules.
-   **Nordic Theme**: Implements a consistent, professional design system (`DESIGN_GUIDELINES.md`) with Semantic Colors (Slate Blue, Sage, Off-White) and Light/Dark mode support.

### 2. Travel Packing
-   **Trip Management**: Create and track upcoming and past trips.
-   **Global Packing Pool**: Manage a master list of categories (e.g., Hygiene, Tech) and items.
-   **Smart Packing**: "Add from Pool" feature allows quick selection of items for specific trips.
-   **Reordering**: Drag-and-drop support for packing lists.
-   **Progress Tracking**: Visual progress bar for each trip's packing status.

### 3. Food Tracking
-   **Calorie Ring**: Visual breakdown of daily calories, protein, carbs, and fat.
-   **Meal Logging**: Track daily meals with nutritional data.

## Project Structure

-   `LifeLoggerApp.swift`: App entry point and logic for seeding default data (e.g., Nordic packing categories).
-   `Modules/`: Contains feature-specific views (Dashboard, Travel, Food).
-   `Core/`: Shared resources, Models (`TripModels`), and Design System (`AppColors`).

## Tech Stack

-   **SwiftUI**: User Interface.
-   **SwiftData**: Local persistence for Trips, Packing Items, and Food logs.
