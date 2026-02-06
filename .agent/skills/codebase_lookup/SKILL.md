---
name: Codebase Lookup
description: Tools and metadata for quickly finding definitions and logic in the Balatro Odyssey mod.
---

# Codebase Lookup Skill

This skill provides a comprehensive index of all custom items in the Balatro Odyssey mod.

## Core Files
- **Jokers**: [jokers.lua](file:///c:/Users/Administrator/source/repos/BalatroOdyssey-not-mine.-fork-i-guess-/src/jokers.lua) (33k+ lines)
- **Consumables**: [consumables.lua](file:///c:/Users/Administrator/source/repos/BalatroOdyssey-not-mine.-fork-i-guess-/src/consumables.lua) (Planet & Spectral logic)
- **Hooks & Decks**: [hooks.lua](file:///c:/Users/Administrator/source/repos/BalatroOdyssey-not-mine.-fork-i-guess-/src/hooks.lua)
- **Localizations**: [localization/](file:///c:/Users/Administrator/source/repos/BalatroOdyssey-not-mine.-fork-i-guess-/localization/)

## Finding Logic (Where & When)
1. **Understand Execution Flow**: Consult [resources/hooks_reference.md](file:///c:/Users/Administrator/source/repos/BalatroOdyssey-not-mine.-fork-i-guess-/.agent/skills/codebase_lookup/resources/hooks_reference.md) to see global hooks in `hooks.lua` vs local logic in `jokers.lua`.
2. **Find Usage**: Use the `find_logic.py` script to find where an ID is defined and used.
   ```powershell
   py .agent/skills/codebase_lookup/scripts/find_logic.py <ID>
   ```
3. **Reference Vanilla Source**: If logic builds on vanilla functions, check the original source at:
   `C:\Users\Administrator\source\repos\Balatro_Source`

## Common Patterns
- **Jokers**: Search for `key = 'j_...`
- **Spectrals**: Search for `[ID] = function` in the `spectral_logic` table in `consumables.lua`.
- **Planets**: Search for `key = "planet_...` in `consumables.lua`.
