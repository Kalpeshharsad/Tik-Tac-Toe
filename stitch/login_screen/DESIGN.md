# Design System Specification: Editorial Play

## 1. Overview & Creative North Star: "Kinetic Precision"
The "Kinetic Precision" North Star moves beyond the static nature of a traditional 3x3 grid. It treats the Tic Tac Toe board not as a table, but as a high-energy stage. By blending a deep, void-like background (`surface`) with hyper-saturated, "neon-organic" tokens (`primary`, `secondary`, `tertiary`), we create a sophisticated playground. 

The design breaks the "template" look through **intentional asymmetry**. Scoreboards aren't perfectly centered; they overlap the play area. Icons don't just sit in boxes; they float on layered "glass" pedestals. This system rejects the rigid 1px line in favor of **Tonal Depth**, making the app feel like a premium physical console rather than a flat digital interface.

---

## 2. Colors & Surface Philosophy
The palette is built on extreme contrast. The dark base creates a vacuum that allows the electric accent colors to "glow" with perceived luminosity.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning. 
*   **The Technique:** Define boundaries solely through background shifts. For example, a game-stat card should use `surface-container-low` sitting on a `surface` background. The change in hex value is the border. 
*   **Exception:** If accessibility requires a stroke, use the **Ghost Border** (see Section 4).

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers.
*   **Base Layer:** `surface` (#0c0e10) - The infinite floor.
*   **Sectioning:** `surface-container-low` (#111416) - Large layout blocks.
*   **Interaction Containers:** `surface-container-high` (#1d2022) - The actual Tic Tac Toe tiles.
*   **Active/Floating Elements:** `surface-bright` (#292c2f) - Modals or active player indicators.

### The "Glass & Gradient" Rule
To inject "soul," use subtle linear gradients. 
*   **Electric X:** Transition from `primary` (#81ecff) to `primary-container` (#00e3fd) at 45°.
*   **Vibrant O:** Transition from `secondary` (#fd9000) to `secondary-dim` (#ea8400).
*   **Glassmorphism:** For overlays, use `surface-variant` at 60% opacity with a `20px` backdrop-blur to create a "frosted glass" effect that retains the energy of the colors beneath.

---

## 3. Typography: Bold & Friendly Editorial
We utilize **Plus Jakarta Sans** for its geometric clarity and modern terminal cuts. It balances the "Playful" requirement with "High-End" precision.

*   **Display (The Score):** `display-lg` (3.5rem). Used for the match score. Use `primary` or `secondary` colors here to make numbers feel like trophies.
*   **Headline (Game State):** `headline-lg` (2.0rem). Used for "X’s Turn" or "Winner!". This should always be Bold.
*   **Title (Navigation):** `title-md` (1.125rem). Medium weight for menu items and button labels.
*   **Body (Instructional):** `body-md` (0.875rem). Use `on-surface-variant` to keep secondary information legible but recessed.

**Editorial Rule:** Never center-align everything. Use flush-left headlines with right-aligned metadata to create a dynamic, asymmetrical tension.

---

## 4. Elevation & Depth
Depth is achieved through **Tonal Layering** rather than structural scaffolding.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` section to create a soft, natural "recess" (perfect for the game board grid).
*   **Ambient Shadows:** For floating action buttons or winner modals, use a diffused shadow: `box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4)`. The shadow color is a dark tint of the background, never a generic grey.
*   **The Ghost Border:** For tiles or inputs, use `outline-variant` at **15% opacity**. It provides a "whisper" of a boundary that disappears into the dark background.
*   **Roundedness Scale:**
    *   **Tiles/Buttons:** `md` (1.5rem) - Friendly and tactile.
    *   **Modals/Cards:** `lg` (2rem) - Softens the high-contrast impact.
    *   **Chips/Indicators:** `full` (9999px) - To distinguish functional tags from layout blocks.

---

## 5. Components

### The Game Tile (The Core)
*   **State - Neutral:** `surface-container-high`, rounded `md`. No border.
*   **State - Active (X):** Inner glow using `primary` at 10% opacity. The "X" symbol is a `primary` to `primary-container` gradient.
*   **State - Active (O):** Inner glow using `secondary` at 10% opacity. The "O" symbol is a `secondary` to `secondary-dim` gradient.

### Buttons (The Action)
*   **Primary (New Game):** Background `tertiary` (#b5ffc2). Text `on-tertiary` (#006731). Rounded `md`. High-energy mint creates a distinct "Start" signal.
*   **Secondary (Settings):** Background `surface-bright`. Ghost border at 20%. No solid fill.

### Game Stats (The Info)
*   **Cards:** Use `surface-container-lowest`. Avoid dividers. Use `spacing-6` (2rem) as a vertical gutter to separate "Player 1" from "Player 2" data.
*   **Indicators:** Use a `tertiary-fixed` (#3fff8b) small dot to indicate "Online" status, placed asymmetrically on the avatar corner.

### Tooltips & Feedback
*   **Error State:** Use `error_container` (#9f0519) with `on_error_container` text. Apply a `0.5rem` (sm) corner radius to make it feel sharp and urgent.

---

## 6. Do's and Don'ts

### Do
*   **Do** use `spacing-10` and `spacing-12` to create "Luxurious Negative Space." High-end design breathes.
*   **Do** overlap elements. Let the "X" or "O" slightly break the container bounds of the tile during a win animation.
*   **Do** use `on_surface_variant` for labels to ensure the primary content (`on_surface`) pops.

### Don't
*   **Don't** use 100% white (#ffffff). Always use `on_background` (#eeeef0) to avoid "monitor glare" against the dark theme.
*   **Don't** use a standard 1px grid for the Tic Tac Toe board. Separate tiles using the `spacing-3` scale (1rem) so the background `surface` color acts as the "grid lines."
*   **Don't** use "Drop Shadows" on everything. Reserve them only for elements that physically move or float over the board.