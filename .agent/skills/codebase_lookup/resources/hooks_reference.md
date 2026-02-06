# Balatro Odyssey Hooks Reference

This document maps the custom logic in `src/hooks.lua` to the vanilla Balatro functions they override. Use this to understand *when* specific effects are triggered.

**Vanilla Source Path**: `C:\Users\Administrator\source\repos\Balatro_Source` (Use this to check original function logic)

## Global Hooks (src/hooks.lua)

| Hooked Function | Purpose in Odyssey | Key Decks/Jokers Involved |
| :--- | :--- | :--- |
| `Card:calculate_joker` | **Core Scoring Logic**. Merges Deck effects into joker calculation context. | `quasar`, `ascensao`, `queda`, `order`, `timeline`, `sloth`, `mirror` (etc.) |
| `Card:start_dissolve` | Triggers effects when cards are destroyed. | `event_horizon` (+0.5 Mult per destroy) |
| `G.FUNCS.play_cards` | **Before Hand Scored**. Tracks cards played, debuffs hands, gives money. | `timeline` (chips snapshot), `wrath`, `volcanic`, `frozen` |
| `G.FUNCS.draw_from_play_to_discard` | **After Hand Scored**. Calculates score diff, triggers post-hand effects. | `timeline` (store score), `fractal` (clone), `ghost` (return), `vampire` (destroy+mult), `volcanic` (discard hand) |
| `G.FUNCS.end_round` | **End of Round**. Resets or triggers round-end effects. | `supernova_deck` (reset money), `avareza`, `mutant` (suit change), `radioactive` (rank decay) |
| `G.FUNCS.skip_blind` | **Blind Skip**. Adds tags or effects on skip. | `wormhole` (Double Tag) |
| `poll_edition` | **Card Generation**. Modifies probability of editions. | `dark_energy` (Negative chance) |
| `G.FUNCS.reroll_shop` | **Shop Interaction**. Blocks or modifies rerolls. | `vacuum` (No rerolls) |
| `find_joker` | **Joker Searching**. Fakes joker presence for logic checks. | `string_theory` (Fakes 'Shortcut') |
| `get_blind_amount` | **Scaling**. Modifies Blind size calculation. | `paradox`, `ascensao`, `queda`, `lucky_ii`, `unlucky` |
| `Card:calculate_seal` | **Retriggers**. Adds repetition to cards. | `gravitational` (Retrigger first played) |
| `Card:can_sell_card` | **Selling Interaction**. Blocks selling. | `kraken` (Cannot sell Jokers) |
| `Blind:debuff_card` | **Blind Rules**. Prevents debuffs. | `ordered_ii` (No Boss Debuffs) |
| `Card:set_cost` | **Shop Pricing**. Modifies card cost dynamically. | Tech Deck (cost mult) |
| `Card:set_ability` | **Card Creation**. Forces editions or centers. | `midas` (Polychrome/Plastic) |

## Joker Logic (src/jokers.lua)

Joker logic is contained within `SMODS.Joker` definitions.
- `loc_vars`: defines the variables shown in the tooltip (`{vars = { ... }}`).
- `calculate`: defines the runtime logic.
    - `context.joker_main`: Main scoring step (+Mult, +Chips, XMult).
    - `context.end_of_round`: End of round triggers.
    - `context.selling_self`: When sold.
    - `context.buying_card`: When buying from shop.
    - `context.other_joker`: Interaction with other jokers.

## Common Modification Patterns

### 1. Modifying Deck Logic
Go to `src/hooks.lua`. Use `Find` (Ctrl+F) to search for the deck key (e.g., `deck_key == 'timeline'`).
Logic is often split across multiple hooks:
- `play_cards`: Pre-computation (e.g., saving current chips).
- `draw_from_play_to_discard`: Post-computation (e.g., calculating gain).
- `calculate_joker`: Scoring effects (XMult, Chips during hand).

### 2. Modifying Joker Logic
Go to `src/jokers.lua`. Search for `key = 'j_name'`.
Update `loc_vars` for UI and `calculate` for mechanics.

### 3. Adding New Global Logic
If you need a new trigger (e.g., "When a card is discarded"), check `hooks.lua` if `G.FUNCS.discard_cards` or similar is already hooked. If not, you may need to add a hook, but **be careful not to break compatibility**.
