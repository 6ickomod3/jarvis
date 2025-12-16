# Jarvis Design Guidelines

This document serves as the single source of truth for the **Jarvis** iOS application's design system. All future changes must adhere to these principles to maintain a cohesive, professional, and modern aesthetic.

## 1. Aesthetic Philosophy

**"Nordic Soft Minimalism"**

-   **Bright but Desaturated**: High lightness, low-to-mid saturation. Avoid harsh neons or pure blacks (except for high contrast text).
-   **Clean & Airy**: generous whitespace (padding/margins), rounded corners, and subtle shadows.
-   **Professional**: Cohesive, uniform, and purposeful.

## 2. Color System

We use a semantic color system defined in `AppColors.swift`. **Do not use hardcoded hex values or system colors (e.g., `.blue`, `.red`) directly in views.**

### Core Palette

| Semantic Token | Light Mode | Dark Mode | Usage |
| :--- | :--- | :--- | :--- |
| **`brandPrimary`** | **Muted Slate Blue** (`#5D7B93`) | **Lighter Slate** (`#8DA9C4`) | Primary buttons, active states, icons, accent text. |
| **`brandSecondary`** | **Soft Grey** (`#E0E0E0`) | **Dark Grey** (`#3A3A3A`) | Secondary buttons, borders, dividers. |
| **`surfaceBackground`**| **Off-white** (`#F5F7FA`) | **Soft Black** (`#121212`) | The main background of the app (behind cards). |
| **`cardBackground`** | **Pure White** (`#FFFFFF`) | **Charcoal** (`#2C2C2C`) | Cards, list items, floating elements. |

### Functional Accents

| Token | Usage |
| :--- | :--- |
| **`accentSuccess`** | **Muted Sage** (`#7BAE7F`). Use for completions, checks, positive trends. |
| **`accentWarning`** | **Muted Orange** (`#E1B16F`). Use for alerts, medium priority. |
| **`accentError`** | **Soft Red** (`#C0392B`). Use for deletions, critical errors, negative trends. |

## 3. Typography

-   **Font**: System Standard (San Francisco) is preferred for native feel, but strictly use weight hierarchy.
    -   **Headers**: `.largeTitle`, `.title` (Weights: `.bold` or `.heavy`).
    -   **Subheaders**: `.headline` (Weight: `.semibold`).
    -   **Body**: `.body` (Weight: `.regular`).
-   **Color**: Always use `Color.primaryText` (Dark Slate / Off-white) for readability. Never use pure black/white directly.

## 4. UI Components

### Cards
-   **Shape**: Rounded Rectangle with corner radius `20` (or `16` for smaller items).
-   **Shadow**: Subtle, diffuse shadow (`Color.black.opacity(0.1)`, radius: 5-10).
-   **Background**: Always `Color.cardBackground`.

### Buttons
-   **Primary**: `Color.brandPrimary` background, White text.
-   **Secondary**: `Color.brandSecondary` background, Primary text.

## 5. Development Rules (Do's & Don'ts)

-   ✅ **DO** use `Color.brandPrimary` for main interactions.
-   ✅ **DO** use `Color.surfaceBackground` for screen backgrounds (`.ignoresSafeArea()`).
-   ❌ **DON'T** use `Color.blue`, `Color.green`, etc. standard SwiftUI colors.
-   ❌ **DON'T** use hardcoded HEX values in Views. Add them to `AppColors.swift` if a new color is strictly needed.
