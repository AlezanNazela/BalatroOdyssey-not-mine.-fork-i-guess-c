-- 6. Baralho Gravitacional
SMODS.Back({
    name = "Gravitacional",
    key = "gravitational",
    atlas = "b_gravitational",
    pos = { x = 0, y = 0 },
    config = { odyssey_gravitational = true },
})

-- 7. Baralho Horizonte de Eventos
SMODS.Back({
    name = "Horizonte de Eventos",
    key = "event_horizon",
    atlas = "b_event_horizon",
    pos = { x = 0, y = 0 },
    config = { odyssey_event_horizon = true },
})

-- 8. Baralho Buraco de Minhoca
SMODS.Back({
    name = "Buraco de Minhoca",
    key = "wormhole",
    atlas = "b_wormhole",
    pos = { x = 0, y = 0 },
    config = { odyssey_wormhole = true },
})

-- 9. Baralho Supernova
SMODS.Back({
    name = "Supernova Deck",
    key = "supernova_deck",
    atlas = "b_supernova",
    pos = { x = 0, y = 0 },
    config = { odyssey_supernova = true },
})

-- 10. Baralho Quasar
SMODS.Back({
    name = "Quasar",
    key = "quasar",
    atlas = "b_quasar",
    pos = { x = 0, y = 0 },
    config = { odyssey_quasar = true, no_interest = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.round_resets.blind_states.Small = 'Skipped' -- Example logic, actually handled in game hooks
                return true
            end
        }))
    end
})

-- 11. Baralho Energia Escura
SMODS.Back({
    name = "Energia Escura",
    key = "dark_energy",
    atlas = "b_dark_energy",
    pos = { x = 0, y = 0 },
    config = { odyssey_dark_energy = true },
})

-- 12. Baralho Antimatéria
SMODS.Back({
    name = "Antimatéria",
    key = "antimatter",
    atlas = "b_antimatter",
    pos = { x = 0, y = 0 },
    config = { odyssey_antimatter = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                add_tag(Tag('tag_negative'))
                return true
            end
        }))
    end
})

-- 13. Baralho Vácuo
SMODS.Back({
    name = "Vácuo",
    key = "vacuum",
    atlas = "b_vacuum",
    pos = { x = 0, y = 0 },
    config = { odyssey_vacuum = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                if G.shop_jokers then
                    G.shop_jokers.card_limit = 6
                end
                return true
            end
        }))
    end
})

-- 14. Baralho Teoria das Cordas
SMODS.Back({
    name = "Teoria das Cordas",
    key = "string_theory",
    atlas = "b_string_theory",
    pos = { x = 0, y = 0 },
    config = { odyssey_string_theory = true },
})

-- 15. Baralho do Caos
SMODS.Back({
    name = "Caos",
    key = "chaos",
    atlas = "b_chaos",
    pos = { x = 0, y = 0 },
    config = { odyssey_chaos = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    local suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('chaos_suit'))
                    local rank = pseudorandom_element({'2','3','4','5','6','7','8','9','T','J','Q','K','A'}, pseudoseed('chaos_rank'))
                    v:set_base(G.P_CARDS[suit..'_'..rank])
                end
                return true
            end
        }))
    end
})

-- 16. Baralho da Ordem
SMODS.Back({
    name = "Ordem",
    key = "order",
    atlas = "b_order",
    pos = { x = 0, y = 0 },
    config = { odyssey_order = true },
})

-- 17. Baralho do Paradoxo
SMODS.Back({
    name = "Paradoxo",
    key = "paradox",
    atlas = "b_paradox",
    pos = { x = 0, y = 0 },
    config = { odyssey_paradox = true, ante_scaling = 2 },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.round_resets.ante = 0
                return true
            end
        }))
    end
})

-- 18. Baralho da Linha do Tempo
SMODS.Back({
    name = "Linha do Tempo",
    key = "timeline",
    atlas = "b_timeline",
    pos = { x = 0, y = 0 },
    config = { odyssey_timeline = true },
})

-- 19. Baralho Paralelo
SMODS.Back({
    name = "Paralelo",
    key = "parallel",
    atlas = "b_parallel",
    pos = { x = 0, y = 0 },
    config = { hands = 2, discards = -2 },
})

-- 20. Baralho Dimensional
SMODS.Back({
    name = "Dimensional",
    key = "dimensional",
    atlas = "b_dimensional",
    pos = { x = 0, y = 0 },
    config = { odyssey_dimensional = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                -- Add 26 random cards to reach 78 cards
                for i = 1, 26 do
                    local card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'dim')
                    card:add_to_deck()
                    G.deck:emplace(card)
                    table.insert(G.playing_cards, card)
                end
                G.deck:shuffle()
                return true
            end
        }))
    end
})


-- 21. Baralho Holográfico
SMODS.Back({
    name = "Holográfico",
    key = "holografico",
    atlas = "b_holographic",
    pos = { x = 0, y = 0 },
    config = { odyssey_holographic = true },
    loc_vars = function(self, info_queue, card) return { vars = {} } end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'holographic_deck')
                card:set_edition({holo = true}, true)
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end
        }))
    end
})

-- 22. Baralho Policromático
SMODS.Back({
    name = "Policromático",
    key = "policromatico",
    atlas = "b_polychrome",
    pos = { x = 0, y = 0 },
    config = { odyssey_polychrome = true },
    loc_vars = function(self, info_queue, card) return { vars = {} } end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'polychrome_deck')
                card:set_edition({polychrome = true}, true)
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end
        }))
    end
})

-- 23. Baralho Laminado
SMODS.Back({
    name = "Laminado",
    key = "laminado",
    atlas = "b_foil",
    pos = { x = 0, y = 0 },
    config = { odyssey_laminado = true },
    loc_vars = function(self, info_queue, card) return { vars = {} } end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'foil_deck')
                card:set_edition({foil = true}, true)
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end
        }))
    end
})

-- 24. Baralho Negativo
SMODS.Back({
    name = "Negativo",
    key = "negativo",
    atlas = "b_negative",
    pos = { x = 0, y = 0 },
    config = { odyssey_negative = true },
    loc_vars = function(self, info_queue, card) return { vars = {} } end,
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'negative_deck')
                card:set_edition({negative = true}, true)
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end
        }))
    end
})

-- 25. Baralho Cerâmica
SMODS.Back({
    name = "Cerâmica",
    key = "ceramic",
    atlas = "b_glass",
    pos = { x = 0, y = 0 },
    config = { odyssey_ceramic = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    v:set_ability(G.P_CENTERS.m_odyssey_ceramic)
                end
                return true
            end
        }))
    end
})

-- 26. Baralho Borracha
SMODS.Back({
    name = "Borracha",
    key = "rubber",
    atlas = "b_steel",
    pos = { x = 0, y = 0 },
    config = { odyssey_rubber = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    v:set_ability(G.P_CENTERS.m_odyssey_rubber)
                end
                return true
            end
        }))
    end
})

-- 27. Baralho Platina
SMODS.Back({
    name = "Platina",
    key = "platinum",
    atlas = "b_stone",
    pos = { x = 0, y = 0 },
    config = { odyssey_platinum = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    v:set_ability(G.P_CENTERS.m_odyssey_platinum)
                end
                return true
            end
        }))
    end
})

-- 28. Baralho Diamante
SMODS.Back({
    name = "Diamante",
    key = "diamond",
    atlas = "b_gold",
    pos = { x = 0, y = 0 },
    config = { odyssey_diamond = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    v:set_ability(G.P_CENTERS.m_odyssey_diamond)
                end
                return true
            end
        }))
    end
})

-- 29. Baralho Mágico
SMODS.Back({
    name = "Baralho Mágico",
    key = "sorte",
    atlas = "b_lucky",
    pos = { x = 0, y = 0 },
    config = { odyssey_magic_deck = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    v:set_ability(G.P_CENTERS.m_odyssey_magic)
                end
                return true
            end
        }))
    end
})

-- 30. Baralho Sagrado
SMODS.Back({
    name = "Baralho Sagrado",
    key = "selvagem",
    atlas = "b_wild",
    pos = { x = 0, y = 0 },
    config = { odyssey_holy_deck = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    v:set_ability(G.P_CENTERS.m_odyssey_holy)
                end
                return true
            end
        }))
    end
})

-- 31. Baralho de Rubi
SMODS.Back({
    name = "Baralho de Rubi",
    key = "multiplicador",
    atlas = "b_mult",
    pos = { x = 0, y = 0 },
    config = { odyssey_ruby_deck = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    v:set_ability(G.P_CENTERS.m_odyssey_ruby)
                end
                return true
            end
        }))
    end
})

-- 32. Baralho de Esmeralda
SMODS.Back({
    name = "Baralho de Esmeralda",
    key = "bonus",
    atlas = "b_bonus",
    pos = { x = 0, y = 0 },
    config = { odyssey_emerald_deck = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    v:set_ability(G.P_CENTERS.m_odyssey_emerald)
                end
                return true
            end
        }))
    end
})

-- 33. Baralho Duplo
SMODS.Back({
    name = "Duplo",
    key = "duplo",
    atlas = "b_double",
    pos = { x = 0, y = 0 },
    config = { odyssey_double = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = 1, 52 do
                    local card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'double')
                    card:add_to_deck()
                    G.deck:emplace(card)
                    table.insert(G.playing_cards, card)
                end
                G.deck:shuffle()
                return true
            end
        }))
    end
})

-- 34. Baralho Minúsculo
SMODS.Back({
    name = "Minúsculo",
    key = "minusculo",
    atlas = "b_tiny",
    pos = { x = 0, y = 0 },
    config = { odyssey_tiny = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if v.base.suit == 'Spades' or v.base.suit == 'Clubs' then
                        v:start_dissolve(nil, true)
                    end
                end
                return true
            end
        }))
    end
})

-- 35. Baralho Ascensão
SMODS.Back({
    name = "Ascensão",
    key = "ascensao",
    atlas = "b_ascension",
    pos = { x = 0, y = 0 },
    config = { odyssey_ascension = true },
})

-- 36. Baralho Queda
SMODS.Back({
    name = "Queda",
    key = "queda",
    atlas = "b_fall",
    pos = { x = 0, y = 0 },
    config = { odyssey_fall = true },
})

-- 37. Baralho Avareza
SMODS.Back({
    name = "Avareza",
    key = "avareza",
    atlas = "b_avarice",
    pos = { x = 0, y = 0 },
    config = { odyssey_avarice = true, no_interest = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.modifiers.no_interest = true
                return true
            end
        }))
    end
})

-- 38. Baralho Pobreza
SMODS.Back({
    name = "Pobreza",
    key = "pobreza",
    atlas = "b_poverty",
    pos = { x = 0, y = 0 },
    config = { odyssey_poverty = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                G.GAME.dollars = 0
                G.GAME.interest_cap = 10
                return true
            end
        }))
    end
})

-- 39. Baralho Gula
SMODS.Back({
    name = "Gula",
    key = "gula",
    atlas = "b_gluttony",
    pos = { x = 0, y = 0 },
    config = { joker_slot = 2, consumable_slot = -2 },
})

-- 40. Baralho Inveja
SMODS.Back({
    name = "Inveja",
    key = "inveja",
    atlas = "b_envy",
    pos = { x = 0, y = 0 },
    config = { odyssey_envy = true },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card('Joker', G.jokers, nil, 0, nil, nil, 'j_mime', 'envy_deck')
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end
        }))
    end
})


-- Decks 41-60

-- 41. Baralho Baralho Ira
SMODS.Back({
    key = 'wrath',
    atlas = 'b_wrath',
    pos = { x = 0, y = 0 },
    config = { discards = 1 },
    apply = function(self)
        G.GAME.modifiers.discard_cost = 1
    end
})

-- 42. Baralho Baralho Preguiça
SMODS.Back({
    key = 'sloth',
    atlas = 'b_sloth',
    pos = { x = 0, y = 0 },
    config = { discards = -100, hands = -3 }
})

-- 43. Baralho Baralho Luxúria
SMODS.Back({
    key = 'lust',
    atlas = 'b_lust',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 44. Baralho Baralho Orgulho
SMODS.Back({
    key = 'pride',
    atlas = 'b_pride',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 45. Baralho Baralho Alfa
SMODS.Back({
    key = 'alpha',
    atlas = 'b_alpha',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    local card = G.playing_cards[i]
                    local id = card.base.id
                    -- Keep A(14), 2, 3, 4, 5. Remove others.
                    if id > 5 and id < 14 then
                        card:remove()
                        card = nil
                    end
                end
                return true
            end
        }))
    end
})

-- 46. Baralho Baralho Ômega
SMODS.Back({
    key = 'omega',
    atlas = 'b_omega',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    local card = G.playing_cards[i]
                    local id = card.base.id
                    -- Keep 10, J, Q, K, A. Remove id < 10.
                    if id < 10 then
                        card:remove()
                        card = nil
                    end
                end
                return true
            end
        }))
    end
})

-- 47. Baralho Baralho Zero
SMODS.Back({
    key = 'zero',
    atlas = 'b_zero',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    local card = G.playing_cards[i]
                    local id = card.base.id
                    -- Keep 2-9. Remove id >= 10.
                    if id >= 10 then
                        card:remove()
                        card = nil
                    end
                end
                return true
            end
        }))
    end
})

-- 48. Baralho Baralho Fibonacci
SMODS.Back({
    key = 'fibonacci',
    atlas = 'b_fibonacci',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local allowed = { [14] = true, [2] = true, [3] = true, [5] = true, [8] = true }
                for i = #G.playing_cards, 1, -1 do
                    local card = G.playing_cards[i]
                    if not allowed[card.base.id] then
                        card:remove()
                        card = nil
                    end
                end
                return true
            end
        }))
    end
})

-- 49. Baralho Baralho Primo
SMODS.Back({
    key = 'prime',
    atlas = 'b_prime',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local allowed = { [2] = true, [3] = true, [5] = true, [7] = true, [11] = true, [13] = true }
                for i = #G.playing_cards, 1, -1 do
                    local card = G.playing_cards[i]
                    if not allowed[card.base.id] then
                        card:remove()
                        card = nil
                    end
                end
                return true
            end
        }))
    end
})

-- 50. Baralho Baralho Odisseia
SMODS.Back({
    key = 'odyssey',
    atlas = 'b_odyssey',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card('Joker', G.jokers, true, 4, nil, nil, 'j_final_odyssey', 'odyssey_deck')
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end
        }))
    end
})

-- 51. Baralho Baralho Fractal
SMODS.Back({
    key = 'fractal',
    atlas = 'b_fractal',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 52. Baralho Baralho Espelho
SMODS.Back({
    key = 'mirror',
    atlas = 'b_mirror',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 53. Baralho Baralho Fantasma
SMODS.Back({
    key = 'ghost',
    atlas = 'b_ghost',
    pos = { x = 0, y = 0 },
    config = { hands = -2 }
})

-- 54. Baralho Baralho Vampiro
SMODS.Back({
    key = 'vampire',
    atlas = 'b_vampire',
    pos = { x = 0, y = 0 },
    config = { extra = { mult = 0, gain = 1 } }
})

-- 55. Baralho Baralho Zumbi
SMODS.Back({
    key = 'zombie',
    atlas = 'b_zombie',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.modifiers.odyssey_zombie = true
    end
})

-- 56. Baralho Baralho Ciborgue
SMODS.Back({
    key = 'cyborg',
    atlas = 'b_cyborg',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i=1, 2 do
                    local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'cyborg_deck')
                    card:add_to_deck()
                    G.jokers:emplace(card)
                end
                return true
            end
        }))
    end
})

-- 57. Baralho Baralho Alien
SMODS.Back({
    key = 'alien',
    atlas = 'b_alien',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 58. Baralho Baralho Mutante
SMODS.Back({
    key = 'mutant',
    atlas = 'b_mutant',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 59. Baralho Baralho Clone
SMODS.Back({
    key = 'clone',
    atlas = 'b_clone',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in ipairs(G.playing_cards) do
                    v:set_base(G.P_CARDS.S_A)
                end
                return true
            end
        }))
    end
})

-- 60. Baralho Baralho Invisível
SMODS.Back({
    key = 'invisible',
    atlas = 'b_invisible',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in ipairs(G.playing_cards) do
                    v.facing = 'back'
                end
                return true
            end
        }))
    end
})



-- Decks 61-80

-- 61. Baralho Baralho Etéreo
SMODS.Back({
    key = 'ethereal',
    atlas = 'b_ethereal',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        -- Logic handled in 03_vanilla_override (or standard Steamodded config?)
        -- Actually we need to hook into usage rate.
        -- Base game uses G.GAME.modifiers.spectral_rate or similar? No, only tarot/planet usually.
        -- Standard shop generation: G.E_MANAGER adds cards.
        -- We can set a flag G.GAME.modifiers.odyssey_ethereal_shop = true
        G.GAME.modifiers.odyssey_ethereal_shop = true
    end
})

-- 62. Baralho Baralho Radioativo
SMODS.Back({
    key = 'radioactive',
    atlas = 'b_radioactive',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 63. Baralho Baralho Magnético
SMODS.Back({
    key = 'magnetic',
    atlas = 'b_magnetic',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 64. Baralho Baralho Congelado
SMODS.Back({
    key = 'frozen',
    atlas = 'b_frozen',
    pos = { x = 0, y = 0 },
    config = { hands = 2 }
})

-- 65. Baralho Baralho Vulcânico
SMODS.Back({
    key = 'volcanic',
    atlas = 'b_volcanic',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 66. Baralho Baralho Oceânico
SMODS.Back({
    key = 'oceanic',
    atlas = 'b_oceanic',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    local card = G.playing_cards[i]
                    if card.base.suit == 'Diamonds' or card.base.suit == 'Hearts' then
                        card:remove()
                        card = nil
                    end
                end
                return true
            end
        }))
    end
})

-- 67. Baralho Baralho Solar
SMODS.Back({
    key = 'solar',
    atlas = 'b_solar',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i = #G.playing_cards, 1, -1 do
                    local card = G.playing_cards[i]
                    if card.base.suit == 'Spades' or card.base.suit == 'Clubs' then
                        card:remove()
                        card = nil
                    end
                end
                return true
            end
        }))
    end
})

-- 68. Baralho Baralho Lunar
SMODS.Back({
    key = 'lunar',
    atlas = 'b_lunar',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 69. Baralho Baralho Estelar
SMODS.Back({
    key = 'stellar',
    atlas = 'b_stellar',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i=1, 5 do
                    local card = create_card('Planet', G.consumables, nil, nil, nil, nil, nil, 'stellar_deck')
                    card:add_to_deck()
                    G.consumables:emplace(card)
                end
                return true
            end
        }))
    end
})

-- 70. Baralho Baralho Místico
SMODS.Back({
    key = 'mystic',
    atlas = 'b_mystic',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i=1, 5 do
                    local card = create_card('Tarot', G.consumables, nil, nil, nil, nil, nil, 'mystic_deck')
                    card:add_to_deck()
                    G.consumables:emplace(card)
                end
                return true
            end
        }))
    end
})

-- 71. Baralho Baralho Tecnológico
SMODS.Back({
    key = 'tech',
    atlas = 'b_tech',
    pos = { x = 0, y = 0 },
    config = { dollars = 100 },
    apply = function(self)
        G.GAME.modifiers.odyssey_shop_price_mult = 2
    end
})

-- 72. Baralho Baralho Primitivo
SMODS.Back({
    key = 'primitive',
    atlas = 'b_primitive',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 73. Baralho Baralho Arcano
SMODS.Back({
    key = 'arcane',
    atlas = 'b_arcane',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.modifiers.odyssey_free_arcana = true
    end
})

-- 74. Baralho Baralho Celestial
SMODS.Back({
    key = 'celestial',
    atlas = 'b_celestial',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.modifiers.odyssey_free_planet = true
    end
})

-- 75. Baralho Baralho Espectral
SMODS.Back({
    key = 'spectral',
    atlas = 'b_spectral',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.modifiers.odyssey_free_spectral = true
    end
})

-- 76. Baralho Baralho Standard
SMODS.Back({
    key = 'standard',
    atlas = 'b_standard',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.modifiers.odyssey_free_standard = true
    end
})

-- 77. Baralho Baralho Buffoon
SMODS.Back({
    key = 'buffoon',
    atlas = 'b_buffoon',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.modifiers.odyssey_free_buffoon = true
    end
})

-- 78. Baralho Baralho Mercenário
SMODS.Back({
    key = 'mercenary',
    atlas = 'b_mercenary',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 79. Baralho Baralho Investidor
SMODS.Back({
    key = 'investor',
    atlas = 'b_investor',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.interest_cap = 1000
    end
})

-- 80. Baralho Baralho Minimalista II
SMODS.Back({
    key = 'minimalist_ii',
    atlas = 'b_minimalist_ii',
    pos = { x = 0, y = 0 },
    config = { hand_size = -5 }
})



-- Decks 81-100

-- 81. Baralho Baralho Maximalista II
SMODS.Back({
    key = 'maximalist_ii',
    atlas = 'b_maximalist_ii',
    pos = { x = 0, y = 0 },
    config = { hand_size = 2, discards = -100 }
})

-- 82. Baralho Baralho Caótico II
SMODS.Back({
    key = 'chaotic_ii',
    atlas = 'b_chaotic_ii',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 83. Baralho Baralho Ordenado II
SMODS.Back({
    key = 'ordered_ii',
    atlas = 'b_ordered_ii',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        -- Disable boss blinds (handled in game logic usually by simply not triggering ability)
        -- But for global effect, we might need a hook.
        -- Setting a custom modifier flag.
        G.GAME.modifiers.odyssey_no_boss_effect = true
    end
})

-- 84. Baralho Baralho Sortudo II
SMODS.Back({
    key = 'lucky_ii',
    atlas = 'b_lucky_ii',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.probabilities.normal = 1
    end
})

-- 85. Baralho Baralho Azarado
SMODS.Back({
    key = 'unlucky',
    atlas = 'b_unlucky',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.probabilities.normal = 1000
    end
})

-- 86. Baralho Baralho Rei Midas
SMODS.Back({
    key = 'midas',
    atlas = 'b_midas',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.GAME.modifiers.odyssey_midas = true
    end
})

-- 87. Baralho Baralho Rei Arthur
SMODS.Back({
    key = 'arthur',
    atlas = 'b_arthur',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card('Joker', G.jokers, true, 4, nil, nil, 'j_final_odyssey', 'arthur_deck')
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end
        }))
    end
})

-- 88. Baralho Baralho Merlin
SMODS.Back({
    key = 'merlin',
    atlas = 'b_merlin',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for i=1, 3 do
                    local card = create_card('Tarot', G.consumables, nil, nil, nil, nil, nil, 'merlin_deck')
                    card:add_to_deck()
                    G.consumables:emplace(card)
                end
                return true
            end
        }))
    end
})

-- 89. Baralho Baralho Dragão
SMODS.Back({
    key = 'dragon',
    atlas = 'b_dragon',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 90. Baralho Baralho Fênix
SMODS.Back({
    key = 'phoenix',
    atlas = 'b_phoenix',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 91. Baralho Baralho Hidra
SMODS.Back({
    key = 'hydra',
    atlas = 'b_hydra',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 92. Baralho Baralho Quimera
SMODS.Back({
    key = 'chimera',
    atlas = 'b_chimera',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 93. Baralho Baralho Grifo
SMODS.Back({
    key = 'griffin',
    atlas = 'b_griffin',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 94. Baralho Baralho Unicórnio
SMODS.Back({
    key = 'unicorn',
    atlas = 'b_unicorn',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 95. Baralho Baralho Kraken
SMODS.Back({
    key = 'kraken',
    atlas = 'b_kraken',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 96. Baralho Baralho Leviatã
SMODS.Back({
    key = 'leviathan',
    atlas = 'b_leviathan',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 97. Baralho Baralho Behemoth
SMODS.Back({
    key = 'behemoth',
    atlas = 'b_behemoth',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 98. Baralho Baralho Titã
SMODS.Back({
    key = 'titan',
    atlas = 'b_titan',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 99. Baralho Baralho Gnomo
SMODS.Back({
    key = 'gnome',
    atlas = 'b_gnome',
    pos = { x = 0, y = 0 },
    config = {}
})

-- 100. Baralho Baralho O Criador
SMODS.Back({
    key = 'the_creator',
    atlas = 'b_the_creator',
    pos = { x = 0, y = 0 },
    config = {},
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                local card = create_card('Joker', G.jokers, true, 4, nil, nil, 'j_final_the_creator', 'creator_deck')
                card:add_to_deck()
                G.jokers:emplace(card)
                return true
            end
        }))
    end
})



----------------------------------------------
------------MOD CODE END----------------------
----------------------------------------------

-- Executar overrides de vanilla
if BalatroOdyssey.disable_vanilla_content then
    BalatroOdyssey.disable_vanilla_content()
end
if BalatroOdyssey.disable_vanilla_decks then
    BalatroOdyssey.disable_vanilla_decks()
end

-- Revelar todo o conteúdo do Odyssey no menu Coleções
BalatroOdyssey.reveal_all_content()

--------------------------------------------------------------------------------
-- PONTUAÇÃO E LIMITES (EXPAND PLAY LIMIT)
--------------------------------------------------------------------------------
-- Permitir jogar até 10 cartas para as mãos especiais do Odyssey

G.FUNCS.can_play = function(e)
    if not G.hand or not G.hand.highlighted or #G.hand.highlighted <= 0 or (G.GAME and G.GAME.blind and G.GAME.blind.block_play) or #G.hand.highlighted > 10 then 
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.BLUE
        e.config.button = 'play_cards_from_highlighted'
    end
end

-- Hook para garantir limites (Reforço dinâmico em cada frame)
local old_game_update = Game.update
function Game:update(dt)
    old_game_update(self, dt)
    
    -- Safety checks para evitar crash se o jogo não estiver totalmente carregado
    if G.play and G.play.config then
        G.play.config.card_limit = 10
    end
    
    if G.hand and G.hand.config then
        -- Balatro usa ambos os nomes dependendo do contexto
        G.hand.config.highlighted_limit = 10
        G.hand.config.highlight_limit = 10
    end
end

-- Garantir limites no início ou carregamento de uma run
local game_start_run_ref = Game.start_run
function Game:start_run(args)
    local ret = game_start_run_ref(self, args)
    if G.play then G.play.config.card_limit = 10 end
    if G.hand then 
        G.hand.config.highlighted_limit = 10
        G.hand.config.highlight_limit = 10
    end
    return ret
end

local game_load_run_ref = Game.load_run
function Game:load_run(args)
    local ret = game_load_run_ref(self, args)
    if G.play then G.play.config.card_limit = 10 end
    if G.hand then 
        G.hand.config.highlighted_limit = 10
        G.hand.config.highlight_limit = 10
    end
    return ret
end


