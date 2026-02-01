-- Lunar Deck Editions
-- Phases cycle 1-4 every 4 rounds, evolution increases every 4 rounds
-- Total: 16 rounds (4 phases × 4 evolutions) + Eclipse

-- Register Shaders (shared across editions)
SMODS.Shader({key = 'lunar_green', path = 'lunar_green.fs'})
SMODS.Shader({key = 'lunar_red', path = 'lunar_red.fs'})
SMODS.Shader({key = 'lunar_eclipse', path = 'lunar_eclipse.fs'})

-- EVOLUTION 0 (Rounds 1-4)
SMODS.Edition({
    key = 'odyssey_lunar_p1e0', shader = 'lunar_green', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:green}New Moon{} (Evo 0)", "{C:red}0.75x{} debuff to all cards"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p2e0', shader = 'lunar_green', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:green}Waxing Moon{} (Evo 0)", "{C:mult}ALL{} cards {C:mult}+2{} Mult"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p3e0', shader = 'lunar_red', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:red}Full Moon{} (Evo 0)", "{C:mult}ALL{} cards {X:mult,C:white}X1.5{} Mult"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p4e0', shader = 'lunar_red', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:red}Waning Moon{} (Evo 0)", "{C:red}0.75x{} debuff to all cards"}}
})

-- EVOLUTION 1 (Rounds 5-8)
SMODS.Edition({
    key = 'odyssey_lunar_p1e1', shader = 'lunar_green', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:green}New Moon{} (Evo 1)", "{C:red}0.70x{} debuff", "{C:attention}Black{} cards immune"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p2e1', shader = 'lunar_green', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:green}Waxing Moon{} (Evo 1)", "{C:mult}ALL{} cards {C:mult}+4{} Mult"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p3e1', shader = 'lunar_red', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:red}Full Moon{} (Evo 1)", "{C:mult}ALL{} cards {X:mult,C:white}X2{} Mult"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p4e1', shader = 'lunar_red', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:red}Waning Moon{} (Evo 1)", "{C:red}0.70x{} debuff", "{C:attention}Red{} cards immune"}}
})

-- EVOLUTION 2 (Rounds 9-12)
SMODS.Edition({
    key = 'odyssey_lunar_p1e2', shader = 'lunar_green', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:green}New Moon{} (Evo 2)", "{C:red}0.65x{} debuff", "{C:attention}Black{} cards {C:mult}+5{} Mult"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p2e2', shader = 'lunar_green', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:green}Waxing Moon{} (Evo 2)", "{C:mult}ALL{} cards {C:mult}+6{} Mult"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p3e2', shader = 'lunar_red', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:red}Full Moon{} (Evo 2)", "{C:mult}ALL{} cards {X:mult,C:white}X2.25{} Mult"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p4e2', shader = 'lunar_red', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:red}Waning Moon{} (Evo 2)", "{C:red}0.65x{} debuff", "{C:attention}Red{} cards {C:mult}+5{} Mult"}}
})

-- EVOLUTION 3 (Rounds 13-16)
SMODS.Edition({
    key = 'odyssey_lunar_p1e3', shader = 'lunar_green', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:green}New Moon{} (Evo 3)", "{C:red}0.60x{} debuff", "{C:attention}Black{} cards {C:mult}+10{} Mult+Chips"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p2e3', shader = 'lunar_green', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:green}Waxing Moon{} (Evo 3)", "{C:mult}ALL{} cards {C:mult}+9{} Mult"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p3e3', shader = 'lunar_red', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:red}Full Moon{} (Evo 3)", "{C:mult}ALL{} cards {X:mult,C:white}X2.5{} Mult"}}
})
SMODS.Edition({
    key = 'odyssey_lunar_p4e3', shader = 'lunar_red', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:red}Waning Moon{} (Evo 3)", "{C:red}0.60x{} debuff", "{C:attention}Red{} cards {C:mult}+10{} Mult+Chips"}}
})

-- ECLIPSE (Round 17+)
SMODS.Edition({
    key = 'odyssey_lunar_eclipse', shader = 'lunar_eclipse', in_shop = false, weight = 0, extra_cost = 0, config = {},
    sound = {sound = 'generic1', per = 1, vol = 0.3},
    loc_txt = {name = "Lunar", text = {"{C:dark_edition}THE ECLIPSE", "{C:chips}+15{} Chips, {C:mult}+15{} Mult, {X:mult,C:white}X4{} Mult"}}
})

print("DEBUG: Lunar Editions registered (16 evolutions + eclipse)")
