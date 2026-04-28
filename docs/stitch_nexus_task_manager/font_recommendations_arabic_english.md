# Typography Recommendations for Orbit (English & Arabic)

To maintain the premium, modern, and highly readable aesthetic of the Orbit Productivity App across both English and Arabic, the following font families are recommended.

## Primary Recommendation: IBM Plex Sans
IBM Plex is a global font family designed for clarity and a technical yet friendly feel. It is perfectly suited for complex productivity interfaces.

*   **English:** [IBM Plex Sans](https://fonts.google.com/specimen/IBM+Plex+Sans)
*   **Arabic:** [IBM Plex Sans Arabic](https://fonts.google.com/specimen/IBM+Plex+Sans+Arabic)
*   **Why it works:** The stroke weights and x-heights are mathematically balanced between the Latin and Arabic sets, ensuring that labels, headers, and body text look unified regardless of the language.

---

## Secondary Recommendation: Noto Sans
Noto's goal is "No more Tofu" (the little boxes that appear when a font doesn't support a character). It is the gold standard for multi-language support.

*   **English:** [Noto Sans](https://fonts.google.com/specimen/Noto+Sans)
*   **Arabic:** [Noto Sans Arabic](https://fonts.google.com/specimen/Noto+Sans+Arabic)
*   **Why it works:** It offers a very clean, neutral aesthetic that stays out of the way of the content, which is ideal for a "Linear-inspired" productivity tool.

---

## The "Modern Pair": Inter + Vazirmatn
If you want a slightly more "startup" or "tech-forward" feel, pairing a world-class Latin sans with a modern Arabic font is a great choice.

*   **English:** [Inter](https://rsms.me/inter/) (The font used by Figma and Linear)
*   **Arabic:** [Vazirmatn](https://fonts.google.com/specimen/Vazirmatn)
*   **Why it works:** Both fonts are designed specifically for screen readability and high-density UI. Vazirmatn's geometric qualities pair exceptionally well with Inter's tall x-height.

---

## Implementation Tips
1.  **Weight Mapping:** Ensure that `Bold` in English maps to `Bold` in Arabic. Some Arabic fonts appear lighter than their Latin counterparts, so you may need to adjust the weight by one level (e.g., Medium English with SemiBold Arabic).
2.  **Line Height:** Arabic script generally requires a larger line-height (leading) than English to prevent the ascenders and descenders from overlapping. A good rule of thumb is to increase line-height by 20-30% for Arabic text.
3.  **Font Fallbacks:** In your Flutter code, always define a list of fallbacks:
    ```dart
    fontFamily: 'IBMPlexSansArabic',
    fontFamilyFallback: ['IBMPlexSans', 'Arial'],
    ```