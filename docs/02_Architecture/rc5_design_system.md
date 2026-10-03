# Grow~ RC5 Design System

RC5 uses modern soft neo-brutalism: bright, friendly, professional, and playful, with white-first surfaces, purple/pink accents, strong black typography, compact motion, and tactile controls.

---

## 1. Design System Tokens

### 1.1 Color Palette
- **Background**: `#FFFFFF`
- **Surface**: `#F8F7FF`
- **Surface Alt**: `#F3F4F6`
- **Primary**: `#7C3AED`
- **Primary End (Gradient)**: `#A855F7`
- **Accent**: `#EC4899`
- **Text Primary**: `#09090B`
- **Text Secondary**: `#71717A`
- **Border**: `#E4E4E7`
- **Success**: `#10B981`
- **Warning**: `#F59E0B`
- **Error**: `#EF4444`

### 1.2 Spacing & Corners
- **Spacing Scale**: 4, 8, 12, 16, 24, 32 px.
- **Corner Radii**: Small = 8px, Card = 12px, Large = 16px, Pills = fully rounded.
- **Shadows**: 3px hard black shadow (`#000000`) with no blur for cards.

### 1.3 Typography
- **Headlines**: Space Grotesk
- **Body**: DM Sans

---

## 2. Interface Transitions & Motion

- **Allowed Motion**: Fade, slide, scale, spring, and pill expansion.
- **Motion Durations**: Fast = 120ms, Base = 200ms, Slow = 300ms.
- **Avoid**: Heavy blurs, parallax effects, and staggered chains.

---

## 3. Media Upload Parameters

- **Avatars**: max 2 MB
- **Event posters**: max 5 MB
- **Project media**: max 8 MB
- **Article covers**: max 4 MB
- **Allowed MIME types**: `image/jpeg`, `image/png`, `image/webp`. Images are compressed client-side before upload where practical.
