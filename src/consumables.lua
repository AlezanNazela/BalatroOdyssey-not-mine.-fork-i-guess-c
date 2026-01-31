-- [[ TAROT REGISTER LOOP ]]
local tarot_max = {
    [4] = 2, [6] = 2, [7] = 1, [8] = 1, [9] = 1, [12] = 2, [13] = 2, [14] = 2,
    [16] = 1, [17] = 1, [18] = 3, [19] = 3, [20] = 3, [22] = 3, [25] = 3, [26] = 2, [27] = 3,
    [35] = 2, [36] = 2, [37] = 1, [38] = 1, [44] = 1, [45] = 1, [59] = 3, [69] = 1,
    [84] = 1, [85] = 1, [86] = 1, [87] = 1, [88] = 1, [89] = 1, [90] = 1, [91] = 1, [92] = 1, [93] = 1, [94] = 1, [95] = 1, [96] = 1,
    [97] = 1, [98] = 1, [99] = 1, [100] = 1
}

local tarots = {}
for i = 1, 100 do
    table.insert(tarots, { id = i })
end

for _, t in ipairs(tarots) do
    SMODS.Consumable({
        key = 'tarot_' .. t.id,
        set = "Tarot",
        config = { extra = t.id, max_highlighted = tarot_max[t.id] or 0 },
        max_highlighted = tarot_max[t.id] or 0,
        atlas = "tarot_" .. t.id,
        pos = { x = 0, y = 0 },
        cost = 3,
        discovered = true,
        can_use = function(self, card)
            local id = card.ability.extra
            local max_h = tarot_max[id] or 0
            
            -- Targeted Tarots
            if max_h > 0 then
                if id == 14 or id == 26 then -- Death/Singularity (Exactly 2)
                    return #G.hand.highlighted == 2
                end
                return #G.hand.highlighted > 0 and #G.hand.highlighted <= max_h
            end

            -- Special condition Tarots
            if id == 1 then -- Fool
                return G.GAME.last_consumeable and G.GAME.last_consumeable.set ~= 'Spectral'
            elseif id == 60 then -- Life
                return G.GAME.last_destroyed_joker ~= nil
            elseif id == 61 then -- Death II (Joker)
                return G.jokers.highlighted and #G.jokers.highlighted == 1
            elseif id == 68 then -- Thief (Shop)
                if not (G.shop_jokers and G.shop_jokers.cards and #G.shop_jokers.cards > 0) then return false end
                for k, v in ipairs(G.shop_jokers.cards) do
                    local is_joker = (v.ability.set == 'Joker' or not v.ability.set)
                    local is_consumeable = (v.ability.set == 'Tarot' or v.ability.set == 'Planet' or v.ability.set == 'Spectral')
                    if (is_joker and #G.jokers.cards < G.jokers.config.card_limit) or
                       (is_consumeable and #G.consumeables.cards < G.consumeables.config.card_limit) then
                        return true
                    end
                end
                return false
            elseif id == 47 or id == 48 or id == 46 or id == 32 or id == 21 or id == 66 then -- Joker Tarots
                return #G.jokers.cards < G.jokers.config.card_limit or card.area == G.jokers
            elseif id == 71 or id == 52 or id == 3 or id == 5 then -- Consumable Tarots
                return #G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables
            end

            -- Instant Tarots
            return true
        end,
        loc_vars = function(self, info_queue, card)
            local id = self.config.extra
            local mapping = {
                [4] = "m_odyssey_ruby", [6] = "m_odyssey_emerald", [7] = "m_odyssey_cloth",
                [8] = "m_odyssey_rubber", [9] = "m_odyssey_ceramic", [16] = "m_odyssey_diamond",
                [17] = "m_odyssey_platinum", [30] = "m_odyssey_emerald", [31] = "m_odyssey_plastic",
                [37] = "m_odyssey_shadow", [38] = "m_odyssey_light",
                [84] = "m_odyssey_plant", [85] = "m_odyssey_holy", [86] = "m_odyssey_undead",
                [87] = "m_odyssey_cursed", [88] = "m_odyssey_magic", [89] = "m_odyssey_diamond",
                [90] = "m_odyssey_paper", [91] = "m_odyssey_ceramic", [92] = "m_odyssey_platinum", [93] = "m_odyssey_wood",
                [94] = "m_odyssey_cloth", [95] = "m_odyssey_ruby", [96] = "m_odyssey_emerald"
            }
            if mapping[id] then
                info_queue[#info_queue+1] = G.P_CENTERS[mapping[id]]
            end
            if id == 11 then
                info_queue[#info_queue+1] = G.P_CENTERS.e_foil
                info_queue[#info_queue+1] = G.P_CENTERS.e_holo
                info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
            end
            return { vars = {} }
        end,
        use = function(self, card, area, copier)
            local id = self.config.extra
            local highlighted = G.hand.highlighted

            if id == 1 then -- Fool
                if G.GAME.last_consumeable and G.GAME.last_consumeable.set ~= 'Spectral' then
                    local _card = create_card(G.GAME.last_consumeable.set, G.consumeables, nil, nil, nil, nil, G.GAME.last_consumeable.key, 'fool')
                    _card:add_to_deck()
                    G.consumeables:emplace(_card)
                end
            elseif id == 2 then -- Magician
                for i = 1, 2 do
                    local _card = create_card("Enhanced", G.hand, nil, nil, nil, nil, nil, "magician")
                    _card:add_to_deck()
                    G.hand:emplace(_card)
                end
            elseif id == 3 then -- High Priestess
                for i = 1, 2 do
                    local _card = create_card("Planet", G.consumeables, nil, nil, nil, nil, nil, "priestess")
                    _card:add_to_deck()
                    G.consumeables:emplace(_card)
                end
            elseif id == 4 then -- Empress
                for i=1, math.min(#highlighted, 2) do
                    highlighted[i]:set_ability(G.P_CENTERS.m_odyssey_ruby)
                end
            elseif id == 5 then -- Emperor
                for i=1, 2 do
                    local _card = create_card("Tarot", G.consumeables, nil, nil, nil, nil, nil, "emperor")
                    _card:add_to_deck()
                    G.consumeables:emplace(_card)
                end
            elseif id == 6 then -- Hierophant
                for i=1, math.min(#highlighted, 2) do
                    highlighted[i]:set_ability(G.P_CENTERS.m_odyssey_emerald)
                end
            elseif id == 7 then -- Lovers
                for i=1, math.min(#highlighted, 1) do
                    highlighted[i]:set_ability(G.P_CENTERS.m_odyssey_cloth)
                end
            elseif id == 8 then -- Chariot
                for i=1, math.min(#highlighted, 1) do
                    highlighted[i]:set_ability(G.P_CENTERS.m_odyssey_rubber)
                end
            elseif id == 9 then -- Justice
                for i=1, math.min(#highlighted, 1) do
                    highlighted[i]:set_ability(G.P_CENTERS.m_odyssey_ceramic)
                end
            elseif id == 10 then -- Hermit
                ease_dollars(math.min(G.GAME.dollars, 20))
            elseif id == 11 then -- Wheel of Fortune
                if pseudorandom('wheel') < G.GAME.probabilities.normal / 4 then
                    local temp_jokers = {}
                    for k, v in ipairs(G.jokers.cards) do
                        if v.ability.set == 'Joker' and not v.edition then
                            table.insert(temp_jokers, v)
                        end
                    end
                    if #temp_jokers > 0 then
                        local random_joker = pseudorandom_element(temp_jokers, pseudoseed('wheel'))
                        local edition = poll_edition('wheel', nil, true, true)
                        random_joker:set_edition(edition, true)
                        card_eval_status_text(random_joker, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.WHITE})
                    end
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_nope_ex'), colour = G.C.DARK_EDITION})
                end
            elseif id == 12 then -- Strength
                for i=1, math.min(#highlighted, 2) do
                    local _card = highlighted[i]
                    local suit_prefix = string.sub(_card.base.suit, 1, 1)..'_'
                    local rank_suffix = _card.base.id == 14 and 2 or math.min(_card.base.id+1, 14)
                    if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                    elseif rank_suffix == 10 then rank_suffix = 'T'
                    elseif rank_suffix == 11 then rank_suffix = 'J'
                    elseif rank_suffix == 12 then rank_suffix = 'Q'
                    elseif rank_suffix == 13 then rank_suffix = 'K'
                    elseif rank_suffix == 14 then rank_suffix = 'A'
                    end
                    _card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                end
            elseif id == 13 then -- Hanged Man
                for i=1, math.min(#highlighted, 2) do
                    highlighted[i]:start_dissolve()
                end
            elseif id == 14 then -- Death
                if #highlighted == 2 then
                    highlighted[2]:set_base(highlighted[1].config.card)
                    highlighted[2]:set_ability(highlighted[1].config.center)
                end
            elseif id == 15 then -- Temperance
                local total = 0
                for k, v in ipairs(G.jokers.cards) do
                    total = total + v.sell_cost
                end
                ease_dollars(math.min(total, 50))
            elseif id == 16 then -- Devil
                for i=1, math.min(#highlighted, 1) do
                    highlighted[i]:set_ability(G.P_CENTERS.m_odyssey_diamond)
                end
            elseif id == 17 then -- Tower
                for i=1, math.min(#highlighted, 1) do
                    highlighted[i]:set_ability(G.P_CENTERS.m_odyssey_platinum)
                end
            elseif id == 18 then -- Star
                for i=1, math.min(#highlighted, 3) do
                    highlighted[i]:change_suit('Diamonds')
                end
            elseif id == 19 then -- Moon
                for i=1, math.min(#highlighted, 3) do
                    highlighted[i]:change_suit('Clubs')
                end
            elseif id == 20 then -- Sun
                for i=1, math.min(#highlighted, 3) do
                    highlighted[i]:change_suit('Hearts')
                end
            elseif id == 21 then -- Judgement
                local _card = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, "judgement")
                _card:add_to_deck()
                G.jokers:emplace(_card)
            elseif id == 22 then -- World
                for i=1, math.min(#highlighted, 3) do
                    highlighted[i]:change_suit('Spades')
                end
            elseif id == 23 then -- Aeon (Reset Ante)
                ease_ante(-1)
            elseif id == 24 then -- Universe (All Planets)
                for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                    local _card = create_card("Planet", G.consumeables, nil, nil, nil, nil, v.key, "universe")
                    _card:add_to_deck()
                    G.consumeables:emplace(_card)
                end
            elseif id == 25 then -- Void
                for i=1, math.min(#highlighted, 3) do
                    highlighted[i]:start_dissolve()
                end
                ease_dollars(10)
            elseif id == 26 then -- Singularity
                if #highlighted == 2 then
                    highlighted[2]:set_base(highlighted[1].config.card)
                    highlighted[2]:set_ability(highlighted[1].config.center)
                    highlighted[1]:start_dissolve()
                end
            elseif id == 27 then -- Quantum
                for i=1, math.min(#highlighted, 3) do
                    local suits = {'S', 'H', 'C', 'D'}
                    local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}
                    highlighted[i]:set_base(G.P_CARDS[pseudorandom_element(suits, pseudoseed('quantum')).. '_' .. pseudorandom_element(ranks, pseudoseed('quantum'))])
                end
            elseif id == 28 then -- Time
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
            elseif id == 29 then -- Space
                G.hand:change_size(1)
            elseif id == 30 then -- Matter
                for i = 1, 2 do
                    local _card = create_card("Enhanced", G.hand, nil, nil, nil, nil, "m_odyssey_emerald", "matter")
                    _card:add_to_deck()
                    G.hand:emplace(_card)
                end
            elseif id == 31 then -- Energy
                for i = 1, 2 do
                    local _card = create_card("Enhanced", G.hand, nil, nil, nil, nil, "m_odyssey_plastic", "energy")
                    _card:add_to_deck()
                    G.hand:emplace(_card)
                end
            elseif id == 32 then -- Soul
                local _card = create_card("Joker", G.jokers, nil, 0.9, nil, nil, nil, "soul")
                _card:add_to_deck()
                G.jokers:emplace(_card)
            elseif id == 33 then -- Spirit
                local _card = create_card("Spectral", G.consumeables, nil, nil, nil, nil, nil, "spirit")
                _card:add_to_deck()
                G.consumeables:emplace(_card)
            elseif id == 34 then -- Mind (Sort Deck)
                table.sort(G.deck.cards, function(a, b) return a.base.value < b.base.value end)
            elseif id == 35 then -- Body
                for i=1, math.min(#highlighted, 2) do
                    highlighted[i].ability.perma_bonus = (highlighted[i].ability.perma_bonus or 0) + 50
                    highlighted[i]:juice_up()
                    card_eval_status_text(highlighted[i], 'extra', nil, nil, nil, {message = "+50 Fichas", colour = G.C.CHIPS})
                end
            elseif id == 36 then -- Heart
                for i=1, math.min(#highlighted, 2) do
                    highlighted[i].ability.perma_mult = (highlighted[i].ability.perma_mult or 0) + 10
                    highlighted[i]:juice_up()
                    card_eval_status_text(highlighted[i], 'extra', nil, nil, nil, {message = "+10 Mult", colour = G.C.MULT})
                end
            elseif id == 37 then -- Shadow
                for i=1, math.min(#highlighted, 1) do
                    if G.P_CENTERS.m_odyssey_shadow then
                        highlighted[i]:set_ability(G.P_CENTERS.m_odyssey_shadow)
                    end
                end
            elseif id == 38 then -- Light
                for i=1, math.min(#highlighted, 1) do
                    if G.P_CENTERS.m_odyssey_light then
                        highlighted[i]:set_ability(G.P_CENTERS.m_odyssey_light)
                    end
                end
            elseif id == 39 then -- Chaos
                G.hand:shuffle()
            elseif id == 40 then -- Order
                G.hand:sort()
                for i = 1, #G.hand.cards do
                    G.hand.cards[i].ability.perma_bonus = (G.hand.cards[i].ability.perma_bonus or 0) + 10
                end
            elseif id == 41 then -- Balance
                ease_dollars(25 - G.GAME.dollars)
            elseif id == 42 then -- Infinity
                local temp_jokers = {}
                for k, v in ipairs(G.jokers.cards) do
                    if v.ability.set == 'Joker' then table.insert(temp_jokers, v) end
                end
                if #temp_jokers > 0 then
                    pseudorandom_element(temp_jokers, pseudoseed('inf')):set_edition({polychrome = true}, true)
                end
            elseif id == 43 then -- Zero
                local temp_jokers = {}
                for k, v in ipairs(G.jokers.cards) do
                    if v.edition then table.insert(temp_jokers, v) end
                end
                if #temp_jokers > 0 then
                    pseudorandom_element(temp_jokers, pseudoseed('zero')):set_edition(nil, true)
                    ease_dollars(20)
                end
            elseif id == 44 then -- One
                for i = 1, math.min(#highlighted, 1) do
                    highlighted[i]:set_base(G.P_CARDS[string.sub(highlighted[i].base.suit, 1, 1)..'_A'])
                end
            elseif id == 45 then -- Many
                if #highlighted == 1 then
                    for i = 1, 2 do
                        local _card = copy_card(highlighted[1], nil, nil, nil)
                        _card:add_to_deck()
                        G.hand:emplace(_card)
                    end
                end
            elseif id == 46 then -- Past (Vintage)
                local _card = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, "past")
                _card:set_edition({foil = true}, true) -- placeholder for vintage
                _card:add_to_deck()
                G.jokers:emplace(_card)
            elseif id == 47 then -- Future (Futuristic)
                local _card = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, "future")
                _card:set_edition({holo = true}, true) -- placeholder
                _card:add_to_deck()
                G.jokers:emplace(_card)
            elseif id == 48 then -- Present (Modern)
                local _card = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, "present")
                _card:add_to_deck()
                G.jokers:emplace(_card)
            elseif id == 49 then -- Unknown (Random)
                local random_id = pseudorandom(pseudoseed('unknown'), 1, 22)
                self.config.extra = random_id
                self:use(card, area, copier)
                self.config.extra = id
            elseif id == 50 then -- Truth
                for k, v in ipairs(G.deck.cards) do v.facing = 'front' end
            elseif id == 51 then -- Lie
                for k, v in ipairs(G.hand.cards) do v.facing = 'back' end
                ease_dollars(5)
            elseif id == 52 then -- Dream
                local _card = create_card("Tarot", G.consumeables, nil, nil, nil, nil, nil, "dream")
                _card:add_to_deck()
                G.consumeables:emplace(_card)
            elseif id == 53 then -- Nightmare
                local _card = create_card("Spectral", G.consumeables, nil, nil, nil, nil, nil, "nightmare")
                _card:add_to_deck()
                G.consumeables:emplace(_card)
            elseif id == 54 then -- Hope
                ease_ante(1)
            elseif id == 55 then -- Despair
                ease_ante(-1)
            elseif id == 56 then -- Love
                local to_add = {}
                for k, v in ipairs(G.hand.cards) do
                    if v.base.suit == 'Hearts' then
                        table.insert(to_add, v)
                    end
                end
                for k, v in ipairs(to_add) do
                    local _card = copy_card(v, nil, nil, nil)
                    _card:add_to_deck()
                    G.hand:emplace(_card)
                end
            elseif id == 57 then -- Hate
                for i=#G.hand.cards, 1, -1 do
                    if G.hand.cards[i].base.suit == 'Spades' then
                        G.hand.cards[i]:start_dissolve()
                    end
                end
            elseif id == 58 then -- War
                local count = 0
                for i=#G.hand.cards, 1, -1 do
                    if G.hand.cards[i]:is_face() then
                        G.hand.cards[i]:start_dissolve()
                        count = count + 1
                    end
                end
                ease_dollars(count * 2)
            elseif id == 59 then -- Peace
                local suits = {Spades=0, Hearts=0, Clubs=0, Diamonds=0}
                for k, v in ipairs(G.deck.cards) do suits[v.base.suit] = suits[v.base.suit] + 1 end
                local max_suit = 'Spades'
                for k, v in pairs(suits) do if v > suits[max_suit] then max_suit = k end end
                for i=1, math.min(#highlighted, 3) do highlighted[i]:change_suit(max_suit) end
            elseif id == 60 then -- Life
                if G.GAME.last_destroyed_joker then
                    local _card = copy_card(G.P_CENTERS[G.GAME.last_destroyed_joker], nil, nil, nil)
                    _card:add_to_deck()
                    G.jokers:emplace(_card)
                end
            elseif id == 61 then -- Death II
                if #G.jokers.highlighted == 1 then
                    local _joker = G.jokers.highlighted[1]
                    ease_dollars(_joker.sell_cost * 2)
                    _joker:start_dissolve()
                end
            elseif id == 62 then -- King
                for i = 1, 2 do
                    local _card = create_card("Base", G.hand, nil, nil, nil, nil, "S_K", "king")
                    _card:add_to_deck()
                    G.hand:emplace(_card)
                end
            elseif id == 63 then -- Queen
                for i = 1, 2 do
                    local _card = create_card("Base", G.hand, nil, nil, nil, nil, "H_Q", "queen")
                    _card:add_to_deck()
                    G.hand:emplace(_card)
                end
            elseif id == 64 then -- Jack
                for i = 1, 2 do
                    local _card = create_card("Base", G.hand, nil, nil, nil, nil, "D_J", "jack")
                    _card:add_to_deck()
                    G.hand:emplace(_card)
                end
            elseif id == 65 then -- Ace
                for i = 1, 2 do
                    local _card = create_card("Base", G.hand, nil, nil, nil, nil, "C_A", "ace")
                    _card:add_to_deck()
                    G.hand:emplace(_card)
                end
            elseif id == 66 then -- Joker
                local _card = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, "joker_t")
                _card:add_to_deck()
                G.jokers:emplace(_card)
            elseif id == 67 then -- Merchant
                G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
                    G.FUNCS.reroll_shop()
                    return true
                end}))
            elseif id == 68 then -- Thief
                local pool = {}
                if G.shop_jokers and G.shop_jokers.cards then
                    for _, v in ipairs(G.shop_jokers.cards) do
                        local is_joker = (v.ability.set == 'Joker' or not v.ability.set)
                        local is_consumeable = (v.ability.set == 'Tarot' or v.ability.set == 'Planet' or v.ability.set == 'Spectral')
                        if (is_joker and #G.jokers.cards < G.jokers.config.card_limit) or
                           (is_consumeable and #G.consumeables.cards < G.consumeables.config.card_limit) then
                            table.insert(pool, v)
                        end
                    end
                end
                
                if #pool > 0 then
                    local _card = pseudorandom_element(pool, pseudoseed('thief'))
                    local area = (_card.ability.set == 'Joker' or not _card.ability.set) and G.jokers or G.consumeables
                    _card:add_to_deck()
                    area:emplace(_card)
                    _card:juice_up()
                end
            elseif id == 69 then -- Guardian
                if #highlighted == 1 then
                    highlighted[1].ability.eternal = true
                end
            elseif id == 70 then -- Sage
                level_up_hand(card, pseudorandom_element(G.GAME.hands, pseudoseed('sage')), nil, 1)
            elseif id == 71 then -- Fool II
                if G.GAME.last_consumeable and #G.consumeables.cards < G.consumeables.config.card_limit then
                    local _card = create_card(G.GAME.last_consumeable.set, G.consumeables, nil, nil, nil, nil, G.GAME.last_consumeable.key, 'fool_ii')
                    _card:add_to_deck()
                    G.consumeables:emplace(_card)
                end
            elseif id == 72 then -- Architect
                G.hand:change_size(1)
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+1 Tam. Mão", colour = G.C.BLUE})
            elseif id == 73 then -- Builder
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+1 Descarte", colour = G.C.RED})
            elseif id == 74 then -- Destroyer
                G.hand:change_size(-1)
                ease_dollars(20)
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "-1 Tam. Mão, +$20", colour = G.C.GOLD})
            elseif id == 75 then -- Creator
                local _card = create_card(pseudorandom_element({'Tarot', 'Planet', 'Spectral', 'Joker'}, pseudoseed('creator')), G.consumeables, nil, nil, nil, nil, nil, 'creator')
                _card:add_to_deck()
                G.consumeables:emplace(_card)
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_active_ex'), colour = G.C.FILTER})
            elseif id == 76 then -- Observer
                -- Revela o Boss: Na prática do mod, troca o boss atual por um novo
                local new_blind = pseudorandom_element(G.P_CENTER_POOLS.Blind, pseudoseed('observer'))
                while not new_blind.boss or new_blind.key == G.GAME.blind.key do
                    new_blind = pseudorandom_element(G.P_CENTER_POOLS.Blind, pseudoseed('observer'))
                end
                G.GAME.blind:set_blind(new_blind)
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Novo Boss!", colour = G.C.FILTER})
            elseif id == 77 then -- Traveler
                local boss_keys = {}
                for _, v in pairs(G.P_BLINDS) do
                    if v.boss and v.key ~= G.GAME.blind.key then
                        table.insert(boss_keys, v)
                    end
                end
                local new_blind = pseudorandom_element(#boss_keys > 0 and boss_keys or {G.P_BLINDS.bl_small}, pseudoseed('traveler'))
                G.GAME.blind:set_blind(new_blind)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        G.GAME.blind:juice_up()
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_active_ex'), colour = G.C.FILTER})
            elseif id == 78 then -- Pilgrim
                local tag = Tag(pseudorandom_element(G.P_TAGS, pseudoseed('pilgrim')).key)
                add_tag(tag)
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_active_ex'), colour = G.C.FILTER})
            elseif id == 79 then -- Monk
                for k, v in ipairs(G.hand.cards) do v.debuff = false end
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_active_ex'), colour = G.C.FILTER})
            elseif id == 80 then -- Warrior
                G.GAME.warrior_chips = (G.GAME.warrior_chips or 0) + 100
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+100 Fichas", colour = G.C.CHIPS})
            elseif id == 81 then -- Magician II
                G.GAME.magician_mult = (G.GAME.magician_mult or 0) + 20
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+20 Multi", colour = G.C.MULT})
            elseif id == 82 then -- Rogue
                G.GAME.rogue_x_mult = (G.GAME.rogue_x_mult or 1) * 2
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "X2 Multi", colour = G.C.MULT})
            elseif id == 83 then -- Bard
                G.GAME.bard_retrigger = (G.GAME.bard_retrigger or 0) + 1
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+1 Reativar", colour = G.C.FILTER})
            elseif id >= 84 and id <= 96 then
                local enhancements = {
                    [84] = "m_odyssey_plant", [85] = "m_odyssey_holy", [86] = "m_odyssey_undead",
                    [87] = "m_odyssey_cursed", [88] = "m_odyssey_magic", [89] = "m_odyssey_diamond",
                    [90] = "m_odyssey_paper", [91] = "m_odyssey_ceramic", [92] = "m_odyssey_platinum", [93] = "m_odyssey_wood",
                    [94] = "m_odyssey_cloth", [95] = "m_odyssey_ruby", [96] = "m_odyssey_emerald"
                }
                local max_h = tarot_max[id] or 1
                for i=1, math.min(#highlighted, max_h) do
                    if G.P_CENTERS[enhancements[id]] then
                        highlighted[i]:set_ability(G.P_CENTERS[enhancements[id]])
                    end
                end
            elseif id == 97 then -- Duplicator
                if #highlighted == 1 then
                    local _card = copy_card(highlighted[1], nil, nil, nil)
                    _card:add_to_deck()
                    G.hand:emplace(_card)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex'), colour = G.C.FILTER})
                end
            elseif id == 98 then -- Remover
                for i=1, math.min(#highlighted, 1) do
                    highlighted[i]:start_dissolve()
                end
            elseif id == 99 then -- Transformer
                if #highlighted == 1 then
                    local suits = {'S', 'H', 'C', 'D'}
                    local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}
                    highlighted[1]:set_base(G.P_CARDS[pseudorandom_element(suits, pseudoseed('trans_s')).. '_' .. pseudorandom_element(ranks, pseudoseed('trans_r'))])
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_active_ex'), colour = G.C.FILTER})
                end
            elseif id == 100 then -- Enhancer
                if #highlighted == 1 then
                    local enhancements = {"m_odyssey_ruby", "m_odyssey_emerald", "m_odyssey_cloth", "m_odyssey_ceramic", "m_odyssey_rubber", "m_odyssey_platinum", "m_odyssey_diamond", "m_odyssey_wood", "m_odyssey_plant", "m_odyssey_holy", "m_odyssey_undead", "m_odyssey_cursed", "m_odyssey_magic"}
                    highlighted[1]:set_ability(G.P_CENTERS[pseudorandom_element(enhancements, pseudoseed('enhancer'))])
                end
            end
        end
    })
end



local planets = {
    { id = 1, key = "planet_1", name = "Mercúrio", hand = "Pair" },
    { id = 2, key = "planet_2", name = "Vênus", hand = "Three of a Kind" },
    { id = 3, key = "planet_3", name = "Terra", hand = "Full House" },
    { id = 4, key = "planet_4", name = "Marte", hand = "Four of a Kind" },
    { id = 5, key = "planet_5", name = "Júpiter", hand = "Flush" },
    { id = 6, key = "planet_6", name = "Saturno", hand = "Straight" },
    { id = 7, key = "planet_7", name = "Urano", hand = "Two Pair" },
    { id = 8, key = "planet_8", name = "Netuno", hand = "Straight Flush" },
    { id = 9, key = "planet_9", name = "Plutão", hand = "High Card" },
    { id = 10, key = "planet_10", name = "Planeta X", hand = "Five of a Kind" },
    { id = 11, key = "planet_11", name = "Ceres", hand = "Flush House" },
    { id = 12, key = "planet_12", name = "Eris", hand = "Flush Five" },
    { id = 13, key = "planet_13", name = "Titã", hand = "Two Pair" },
    { id = 14, key = "planet_14", name = "Europa", hand = "Three of a Kind" },
    { id = 15, key = "planet_15", name = "Io", hand = "Straight" },
    { id = 16, key = "planet_16", name = "Ganimedes", hand = "Flush" },
    { id = 17, key = "planet_17", name = "Calisto", hand = "Full House" },
    { id = 18, key = "planet_18", name = "Fobos", hand = "Four of a Kind" },
    { id = 19, key = "planet_19", name = "Deimos", hand = "Straight Flush" },
    { id = 20, key = "planet_20", name = "Caronte", hand = "odyssey_royal_flush" },
    { id = 21, key = "planet_21", name = "Makemake", hand = "odyssey_wrap_around_straight" },
    { id = 22, key = "planet_22", name = "Haumea", hand = "odyssey_jump_straight" },
    { id = 23, key = "planet_23", name = "Sedna", hand = "odyssey_alternating_straight" },
    { id = 24, key = "planet_24", name = "Quaoar", hand = "odyssey_spectrum" },
    { id = 25, key = "planet_25", name = "Orcus", hand = "odyssey_corner_hand" },
    { id = 26, key = "planet_26", name = "Salacia", hand = "odyssey_middle_hand" },
    { id = 27, key = "planet_27", name = "Varda", hand = "odyssey_prime_hand" },
    { id = 28, key = "planet_28", name = "Ixion", hand = "odyssey_fibonacci_hand" },
    { id = 29, key = "planet_29", name = "Varuna", hand = "odyssey_even_hand" },
    { id = 30, key = "planet_30", name = "Caos", hand = "odyssey_odd_hand" },
    { id = 31, key = "planet_31", name = "Proxima", hand = "odyssey_red_hand" },
    { id = 32, key = "planet_32", name = "Alpha", hand = "odyssey_black_hand" },
    { id = 33, key = "planet_33", name = "Sirius", hand = "odyssey_face_hand" },
    { id = 34, key = "planet_34", name = "Vega", hand = "odyssey_number_hand" },
    { id = 35, key = "planet_35", name = "Betelgeuse", hand = "odyssey_low_hand" },
    { id = 36, key = "planet_36", name = "Rigel", hand = "odyssey_high_hand" },
    { id = 37, key = "planet_37", name = "Antares", hand = "odyssey_mega_straight" },
    { id = 38, key = "planet_38", name = "Aldebaran", hand = "odyssey_mega_flush" },
    { id = 39, key = "planet_39", name = "Spica", hand = "odyssey_mega_full_house" },
    { id = 40, key = "planet_40", name = "Pollux", hand = "odyssey_double_three_of_a_kind" },
    { id = 41, key = "planet_41", name = "Castor", hand = "odyssey_triple_pair" },
    { id = 42, key = "planet_42", name = "Deneb", hand = "odyssey_quadruple_pair" },
    { id = 43, key = "planet_43", name = "Altair", hand = "odyssey_quintuple_pair" },
    { id = 44, key = "planet_44", name = "Fomalhaut", hand = "odyssey_six_of_a_kind" },
    { id = 45, key = "planet_45", name = "Regulus", hand = "odyssey_seven_of_a_kind" },
    { id = 46, key = "planet_46", name = "Canopus", hand = "odyssey_eight_of_a_kind" },
    { id = 47, key = "planet_47", name = "Arcturus", hand = "odyssey_nine_of_a_kind" },
    { id = 48, key = "planet_48", name = "Capella", hand = "odyssey_ten_of_a_kind" },
    { id = 49, key = "planet_49", name = "Achernar", hand = "odyssey_flush_pair" },
    { id = 50, key = "planet_50", name = "Hadar", hand = "odyssey_flush_two_pair" },
    { id = 51, key = "planet_51", name = "Acrux", hand = "odyssey_flush_three_of_a_kind" },
    { id = 52, key = "planet_52", name = "Mimosa", hand = "odyssey_flush_four_of_a_kind" },
    { id = 53, key = "planet_53", name = "Gacrux", hand = "odyssey_flush_six_of_a_kind" },
    { id = 54, key = "planet_54", name = "Bellatrix", hand = "odyssey_flush_seven_of_a_kind" },
    { id = 55, key = "planet_55", name = "Elnath", hand = "odyssey_flush_eight_of_a_kind" },
    { id = 56, key = "planet_56", name = "Alnilam", hand = "odyssey_flush_nine_of_a_kind" },
    { id = 57, key = "planet_57", name = "Alnitak", hand = "odyssey_flush_ten_of_a_kind" },
    { id = 58, key = "planet_58", name = "Mintaka", hand = "odyssey_super_royal_flush" },
    { id = 59, key = "planet_59", name = "Saiph", hand = "odyssey_ultimate_flush" },
    { id = 60, key = "planet_60", name = "Kepler", hand = "odyssey_all_hands" },
    { id = 61, key = "planet_61", name = "Kepler-22b", hand = "Pair" },
    { id = 62, key = "planet_62", name = "Kepler-186f", hand = "Three of a Kind" },
    { id = 63, key = "planet_63", name = "Kepler-452b", hand = "Full House" },
    { id = 64, key = "planet_64", name = "Kepler-62f", hand = "Four of a Kind" },
    { id = 65, key = "planet_65", name = "TRAPPIST-1d", hand = "Flush" },
    { id = 66, key = "planet_66", name = "TRAPPIST-1e", hand = "Straight" },
    { id = 67, key = "planet_67", name = "TRAPPIST-1f", hand = "Two Pair" },
    { id = 68, key = "planet_68", name = "TRAPPIST-1g", hand = "Straight Flush" },
    { id = 69, key = "planet_69", name = "Gliese 581g", hand = "High Card" },
    { id = 70, key = "planet_70", name = "Gliese 667Cc", hand = "Five of a Kind" },
    { id = 71, key = "planet_71", name = "HD 40307g", hand = "Flush House" },
    { id = 72, key = "planet_72", name = "HD 85512b", hand = "Flush Five" },
    { id = 73, key = "planet_73", name = "Tau Ceti e", hand = "odyssey_royal_flush" },
    { id = 74, key = "planet_74", name = "Kapteyn b", hand = "odyssey_secret_hand_1" },
    { id = 75, key = "planet_75", name = "Wolf 1061c", hand = "odyssey_secret_hand_2" },
    { id = 76, key = "planet_76", name = "GJ 357 d", hand = "odyssey_secret_hand_3" },
    { id = 77, key = "planet_77", name = "LHS 1140 b", hand = "odyssey_secret_hand_4" },
    { id = 78, key = "planet_78", name = "Teegarden b", hand = "odyssey_secret_hand_5" },
    { id = 79, key = "planet_79", name = "Ross 128 b", hand = "odyssey_secret_hand_6" },
    { id = 80, key = "planet_80", name = "Luyten b", hand = "odyssey_secret_hand_7" },
    { id = 81, key = "planet_81", name = "K2-18b", hand = "odyssey_secret_hand_8" },
    { id = 82, key = "planet_82", name = "TOI-700 d", hand = "odyssey_secret_hand_9" },
    { id = 83, key = "planet_83", name = "Kepler-1649c", hand = "odyssey_secret_hand_10" },
    { id = 84, key = "planet_84", name = "Kepler-442b", hand = "odyssey_secret_hand_11" },
    { id = 85, key = "planet_85", name = "Kepler-1638b", hand = "odyssey_secret_hand_12" },
    { id = 86, key = "planet_86", name = "Kepler-296f", hand = "odyssey_secret_hand_13" },
    { id = 87, key = "planet_87", name = "Kepler-174d", hand = "odyssey_secret_hand_14" },
    { id = 88, key = "planet_88", name = "Kepler-62e", hand = "odyssey_secret_hand_15" },
    { id = 89, key = "planet_89", name = "Kepler-1229b", hand = "odyssey_secret_hand_16" },
    { id = 90, key = "planet_90", name = "Kepler-1544b", hand = "odyssey_secret_hand_17" },
    { id = 91, key = "planet_91", name = "Kepler-1652b", hand = "odyssey_secret_hand_18" },
    { id = 92, key = "planet_92", name = "Kepler-1410b", hand = "odyssey_secret_hand_19" },
    { id = 93, key = "planet_93", name = "Kepler-155c", hand = "odyssey_secret_hand_20" },
    { id = 94, key = "planet_94", name = "Kepler-283c", hand = "odyssey_secret_hand_21" },
    { id = 95, key = "planet_95", name = "Kepler-438b", hand = "odyssey_secret_hand_22" },
    { id = 96, key = "planet_96", name = "Kepler-440b", hand = "odyssey_secret_hand_23" },
    { id = 97, key = "planet_97", name = "Kepler-443b", hand = "odyssey_secret_hand_24" },
    { id = 98, key = "planet_98", name = "Kepler-296e", hand = "odyssey_secret_hand_25" },
    { id = 99, key = "planet_99", name = "Kepler-1653b", hand = "odyssey_secret_hand_26" },
    { id = 100, key = "planet_100", name = "Kepler-1512b", hand = "odyssey_secret_hand_27" },
}

for _, p in ipairs(planets) do
    local planet_def = {
        key = p.key,
        atlas = "planet_" .. p.id,
        pos = { x = 0, y = 0 },
        config = { hand_type = p.hand },
        discovered = true,
        set = "Planet",
        cost = 3,
        loc_vars = function(self, info_queue, card)

            local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

            return { vars = { localize(p.hand, 'poker_hands') } }

        end
    }

    if p.id == 60 then
        planet_def.use = function(self, card, area, copier)
            local used_tarot = copier or card
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                for k, v in pairs(G.GAME.hands) do
                    level_up_hand(used_tarot, k, nil, 1)
                end
                return true
            end }))
        end
    end

    SMODS.Planet(planet_def)
end



local spectrals = {
    { id = 1, key = "spectral_1", name = "Supernova" },
    { id = 2, key = "spectral_2", name = "Buraco Negro" },
    { id = 3, key = "spectral_3", name = "Quasar" },
    { id = 4, key = "spectral_4", name = "Pulsar" },
    { id = 5, key = "spectral_5", name = "Nebulosa" },
    { id = 6, key = "spectral_6", name = "Raio Gama" },
    { id = 7, key = "spectral_7", name = "Raio X" },
    { id = 8, key = "spectral_8", name = "Raio Cósmico" },
    { id = 9, key = "spectral_9", name = "Raio Vazio" },
    { id = 10, key = "spectral_10", name = "Antimatéria" },
    { id = 11, key = "spectral_11", name = "Matéria Escura" },
    { id = 12, key = "spectral_12", name = "Entropia" },
    { id = 13, key = "spectral_13", name = "Entalpia" },
    { id = 14, key = "spectral_14", name = "Zero Absoluto" },
    { id = 15, key = "spectral_15", name = "Planck" },
    { id = 16, key = "spectral_16", name = "Luz" },
    { id = 17, key = "spectral_17", name = "Dobra" },
    { id = 18, key = "spectral_18", name = "Minhoca" },
    { id = 19, key = "spectral_19", name = "Multiverso" },
    { id = 20, key = "spectral_20", name = "Paradoxo" },
    { id = 21, key = "spectral_21", name = "Singularidade" },
    { id = 22, key = "spectral_22", name = "Big Bang" },
    { id = 23, key = "spectral_23", name = "Salto" },
    { id = 24, key = "spectral_24", name = "Horizonte" },
    { id = 25, key = "spectral_25", name = "Poço" },
    { id = 26, key = "spectral_26", name = "Energia" },
    { id = 27, key = "spectral_27", name = "Vácuo" },
    { id = 28, key = "spectral_28", name = "Cordas" },
    { id = 29, key = "spectral_29", name = "Caos" },
    { id = 30, key = "spectral_30", name = "Borboleta" },
    { id = 31, key = "spectral_31", name = "Schrodinger" },
    { id = 32, key = "spectral_32", name = "Heisenberg" },
    { id = 33, key = "spectral_33", name = "Pauli" },
    { id = 34, key = "spectral_34", name = "Fermi" },
    { id = 35, key = "spectral_35", name = "Drake" },
    { id = 36, key = "spectral_36", name = "Hubble" },
    { id = 37, key = "spectral_37", name = "Webb" },
    { id = 38, key = "spectral_38", name = "Kepler" },
    { id = 39, key = "spectral_39", name = "Galileu" },
    { id = 40, key = "spectral_40", name = "Newton" },
    { id = 41, key = "spectral_41", name = "Einstein" },
    { id = 42, key = "spectral_42", name = "Hawking" },
    { id = 43, key = "spectral_43", name = "Sagan" },
    { id = 44, key = "spectral_44", name = "Tyson" },
    { id = 45, key = "spectral_45", name = "Kaku" },
    { id = 46, key = "spectral_46", name = "Greene" },
    { id = 47, key = "spectral_47", name = "Penrose" },
    { id = 48, key = "spectral_48", name = "Godel" },
    { id = 49, key = "spectral_49", name = "Turing" },
    { id = 50, key = "spectral_50", name = "Oppenheimer" },
    { id = 51, key = "spectral_51", name = "Feynman" },
    { id = 52, key = "spectral_52", name = "Bohr" },
    { id = 53, key = "spectral_53", name = "Curie" },
    { id = 54, key = "spectral_54", name = "Darwin" },
    { id = 55, key = "spectral_55", name = "Mendel" },
    { id = 56, key = "spectral_56", name = "Pasteur" },
    { id = 57, key = "spectral_57", name = "Fleming" },
    { id = 58, key = "spectral_58", name = "Tesla" },
    { id = 59, key = "spectral_59", name = "Edison" },
    { id = 60, key = "spectral_60", name = "Bell" },
    { id = 61, key = "spectral_61", name = "Marconi" },
    { id = 62, key = "spectral_62", name = "Wright" },
    { id = 63, key = "spectral_63", name = "Ford" },
    { id = 64, key = "spectral_64", name = "Babbage" },
    { id = 65, key = "spectral_65", name = "Lovelace" },
    { id = 66, key = "spectral_66", name = "Hopper" },
    { id = 67, key = "spectral_67", name = "Berners-Lee" },
    { id = 68, key = "spectral_68", name = "Jobs" },
    { id = 69, key = "spectral_69", name = "Gates" },
    { id = 70, key = "spectral_70", name = "Musk" },
    { id = 71, key = "spectral_71", name = "Bezos" },
    { id = 72, key = "spectral_72", name = "Zuckerberg" },
    { id = 73, key = "spectral_73", name = "Nakamoto" },
    { id = 74, key = "spectral_74", name = "Vitalik" },
    { id = 75, key = "spectral_75", name = "Armstrong" },
    { id = 76, key = "spectral_76", name = "Aldrin" },
    { id = 77, key = "spectral_77", name = "Collins" },
    { id = 78, key = "spectral_78", name = "Gagarin" },
    { id = 79, key = "spectral_79", name = "Tereshkova" },
    { id = 80, key = "spectral_80", name = "Laika" },
    { id = 81, key = "spectral_81", name = "Ham" },
    { id = 82, key = "spectral_82", name = "Shepard" },
    { id = 83, key = "spectral_83", name = "Glenn" },
    { id = 84, key = "spectral_84", name = "Leonov" },
    { id = 85, key = "spectral_85", name = "Ride" },
    { id = 86, key = "spectral_86", name = "Hadfield" },
    { id = 87, key = "spectral_87", name = "Kelly" },
    { id = 88, key = "spectral_88", name = "Pesquet" },
    { id = 89, key = "spectral_89", name = "Cristoforetti" },
    { id = 90, key = "spectral_90", name = "Gerst" },
    { id = 91, key = "spectral_91", name = "Peake" },
    { id = 92, key = "spectral_92", name = "Hoshide" },
    { id = 93, key = "spectral_93", name = "Yi" },
    { id = 94, key = "spectral_94", name = "Yang" },
    { id = 95, key = "spectral_95", name = "Sharma" },
    { id = 96, key = "spectral_96", name = "Al Mansoori" },
    { id = 97, key = "spectral_97", name = "Pontes" },
    { id = 98, key = "spectral_98", name = "Vostok" },
    { id = 99, key = "spectral_99", name = "Mercury" },
    { id = 100, key = "spectral_100", name = "Gemini" },
}

local spectral_logic = {
    [1] = function(card, area, copier) -- Supernova
        local cards = {}
        for i=1, #G.hand.cards do cards[#cards+1] = G.hand.cards[i] end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            for i=1, #cards do cards[i]:start_dissolve() end 
            G.GAME.odyssey_spectral_1_xmult = (G.GAME.odyssey_spectral_1_xmult or 1) * 3
            return true end }))
    end,
    [2] = function(card, area, copier) -- Buraco Negro
        local cards = {}
        for i=1, #G.hand.cards do cards[#cards+1] = G.hand.cards[i] end
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            for i=1, #cards do cards[i]:start_dissolve() end 
            G.GAME.starting_params.hand_size = G.GAME.starting_params.hand_size + 1
            G.hand:change_size(1)
            return true end }))
    end,
    [3] = function(card, area, copier) -- Quasar
        if #G.jokers.cards > 0 then
            local target = pseudorandom_element(G.jokers.cards, pseudoseed('quasar'))
            for i=#G.jokers.cards, 1, -1 do
                if G.jokers.cards[i] ~= target then
                    G.jokers.cards[i]:start_dissolve()
                end
            end
            target:set_edition({polychrome = true}, true)
        end
    end,
    [4] = function(card, area, copier) -- Pulsar
        for i=1, #G.hand.cards do
            G.hand.cards[i]:set_edition({foil = true}, true)
        end
        G.GAME.starting_params.hand_size = (G.GAME.starting_params.hand_size or 8) - 1
        G.hand:change_size(-1)
    end,
    [5] = function(card, area, copier) -- Nebulosa
        for i=1, #G.hand.cards do
            G.hand.cards[i]:set_edition({holo = true}, true)
        end
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
        ease_discard(-1)
    end,
    [6] = function(card, area, copier) -- Raio Gama
        for i=1, #G.hand.cards do
            G.hand.cards[i]:set_ability(G.P_CENTERS.m_odyssey_diamond, nil)
        end
        ease_dollars(-G.GAME.dollars, true)
    end,
    [7] = function(card, area, copier) -- Raio X
        for i=1, #G.hand.cards do
            G.hand.cards[i]:set_ability(G.P_CENTERS.m_odyssey_ceramic, nil)
        end
        ease_discard(-G.GAME.current_round.discards_left)
    end,
    [8] = function(card, area, copier) -- Raio Cósmico
         for i=1, #G.hand.cards do
            G.hand.cards[i]:set_ability(G.P_CENTERS.m_odyssey_rubber, nil)
        end
        ease_hands_played(-(G.GAME.current_round.hands_left - 1))
    end,
    [9] = function(card, area, copier) -- Raio Vazio
        for i=1, #G.hand.cards do
            G.hand.cards[i]:set_ability(G.P_CENTERS.m_odyssey_platinum, nil)
        end
        for i=#G.jokers.cards, 1, -1 do
            G.jokers.cards[i]:start_dissolve()
        end
    end,
    [10] = function(card, area, copier) -- Antimatéria
        if #G.jokers.cards > 0 then
            local target = pseudorandom_element(G.jokers.cards, pseudoseed('antimatter'))
            target:set_edition({negative = true}, true)
            ease_dollars(-G.GAME.dollars, true)
        end
    end,
    [11] = function(card, area, copier) -- Matéria Escura
        if #G.consumeables.cards > 0 then
            local target = pseudorandom_element(G.consumeables.cards, pseudoseed('darkmatter'))
            target:set_edition({negative = true}, true)
            for i=#G.jokers.cards, 1, -1 do
                G.jokers.cards[i]:start_dissolve()
            end
        end
    end,
    [12] = function(card, area, copier) -- Entropia
        local ranks = {'2','3','4','5','6','7','8','9','T','J','Q','K','A'}
        for i=1, #G.playing_cards do
            local new_rank = pseudorandom_element(ranks, pseudoseed('entropy'..i))
            local suit_prefix = G.playing_cards[i].base.suit:sub(1,1)
            G.playing_cards[i]:set_base(G.P_CARDS[suit_prefix..'_'..new_rank])
        end
        ease_dollars(20)
    end,
    [13] = function(card, area, copier) -- Entalpia
        local suits = {'Spades', 'Hearts', 'Clubs', 'Diamonds'}
        for i=1, #G.playing_cards do
            local new_suit = pseudorandom_element(suits, pseudoseed('enthalpy'..i))
            local rank = G.playing_cards[i].base.value
            local suit_prefix = new_suit:sub(1,1)
            G.playing_cards[i]:set_base(G.P_CARDS[suit_prefix..'_'..rank])
        end
        ease_dollars(20)
    end,
    [14] = function(card, area, copier) -- Zero Absoluto
        G.GAME.odyssey_zero_absolute = true
        G.GAME.odyssey_spectral_14_xmult = (G.GAME.odyssey_spectral_14_xmult or 1) * 5
    end,
    [15] = function(card, area, copier) -- Planck
        G.GAME.starting_params.hand_size = 1
        G.hand:change_size(1 - G.hand.config.card_limit)
        G.GAME.odyssey_spectral_15_xmult = (G.GAME.odyssey_spectral_15_xmult or 1) * 10
    end,
    [16] = function(card, area, copier) -- Luz
        G.GAME.round_resets.discards = 0
        ease_discard(-G.GAME.current_round.discards_left)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + 5
        ease_hands_played(5)
    end,
    [17] = function(card, area, copier) -- Dobra
        G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
            G.STATE = G.STATES.BLIND_SELECT
            G.STATE_COMPLETE = true
            return true
        end }))
    end,
    [18] = function(card, area, copier) -- Minhoca
        ease_ante(1)
        ease_dollars(-G.GAME.dollars, true)
    end,
    [19] = function(card, area, copier) -- Multiverso
         for i=1, math.min(2, #G.jokers.cards) do
             local joker = G.jokers.cards[i]
             local copy = copy_card(joker, nil, nil, nil, joker.edition)
             copy:set_perishable(true)
             copy:add_to_deck()
             G.jokers:emplace(copy)
         end
    end,
    [20] = function(card, area, copier) -- Paradoxo
        local score = G.GAME.last_round_score or 0
        local amount = math.min(100, score)
        ease_dollars(amount - G.GAME.dollars, true)
    end,
    [21] = function(card, area, copier) -- Singularidade
        if #G.jokers.cards >= 2 then
            for i=1, 2 do G.jokers.cards[1]:start_dissolve() end
            local card = create_card('Joker', G.jokers, nil, 3, nil, nil, nil, 'sing')
            card:set_edition({negative = true}, true)
            card:add_to_deck()
            G.jokers:emplace(card)
        end
    end,
    [23] = function(card, area, copier) -- Salto
        ease_ante(8 - G.GAME.round_resets.ante)
        ease_dollars(-G.GAME.dollars, true)
    end,
    [24] = function(card, area, copier) -- Horizonte
        for i=#G.playing_cards, 1, -1 do
            if G.playing_cards[i]:is_face() then
                G.playing_cards[i]:start_dissolve()
            end
        end
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
    end,
    [25] = function(card, area, copier) -- Poço
        for i=#G.playing_cards, 1, -1 do
            if not G.playing_cards[i]:is_face() then
                G.playing_cards[i]:start_dissolve()
            end
        end
        G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
    end,
    [26] = function(card, area, copier) -- Energia
        for i=1, #G.hand.cards do
            G.hand.cards[i]:set_edition({negative = true}, true)
        end
    end,
    [27] = function(card, area, copier) -- Vácuo
        for i=1, #G.playing_cards do
            G.playing_cards[i]:set_ability(G.P_CENTERS.c_base)
            G.playing_cards[i]:set_edition(nil, true)
        end
        ease_dollars(50)
    end,
    [29] = function(card, area, copier) -- Caos
        local editions = {nil, {foil = true}, {holo = true}, {polychrome = true}, {negative = true}}
        for i=1, #G.jokers.cards do
            local ed = pseudorandom_element(editions, pseudoseed('chaos'..i))
            G.jokers.cards[i]:set_edition(ed, true)
        end
    end,
    [30] = function(card, area, copier) -- Borboleta
        if G.hand.highlighted[1] then
            local c = G.hand.highlighted[1]
            local ranks = {'2','3','4','5','6','7','8','9','T','J','Q','K','A'}
            local suits = {'S','H','C','D'}
            local r = pseudorandom_element(ranks, pseudoseed('butt_r'))
            local s = pseudorandom_element(suits, pseudoseed('butt_s'))
            c:set_base(G.P_CARDS[s..'_'..r])
        end
    end,
    [31] = function(card, area, copier) -- Schrodinger
        if pseudorandom('schro') > 0.5 then
            ease_dollars(G.GAME.dollars)
        else
            ease_dollars(-G.GAME.dollars)
        end
    end,
    [33] = function(card, area, copier) -- Pauli
        local ranks = {}
        local has_pair = false
        for i=1, #G.hand.cards do
            local r = G.hand.cards[i].base.value
            if ranks[r] then has_pair = true; break end
            ranks[r] = true
        end
        if not has_pair then ease_dollars(20) end
    end,
    [34] = function(card, area, copier) -- Fermi
        local card = create_card('Joker', G.jokers, nil, 3, nil, nil, nil, 'fermi')
        card:set_edition({negative = true}, true)
        card:add_to_deck()
        G.jokers:emplace(card)
    end,
    [35] = function(card, area, copier) -- Drake
        G.GAME.odyssey_drake_active = true
    end,
    [38] = function(card, area, copier) -- Kepler
        for k, v in pairs(G.GAME.hands) do
            if v.level > 1 then
                update_hand_stats(k, {level = v.level})
            end
        end
    end,
    [39] = function(card, area, copier) -- Galileu
        G.GAME.odyssey_galileo_active = true
    end,
    [40] = function(card, area, copier) -- Newton
        G.GAME.odyssey_newton_active = true
    end,
    [41] = function(card, area, copier) -- Einstein
        G.GAME.odyssey_einstein_active = true
    end,
    [43] = function(card, area, copier) -- Sagan
        local count = 0
        for i=1, #G.playing_cards do
            if G.playing_cards[i].seal or G.playing_cards[i].edition then
                count = count + 1
            end
        end
        ease_dollars(count)
    end,
    [46] = function(card, area, copier) -- Greene
        local card = create_card('Joker', G.jokers, nil, 0.9, nil, nil, nil, 'greene')
        card:add_to_deck()
        G.jokers:emplace(card)
    end,
    [50] = function(card, area, copier) -- Oppenheimer
        for i=1, 5 do
            if #G.playing_cards > 0 then
                pseudorandom_element(G.playing_cards, pseudoseed('oppen')):start_dissolve()
            end
        end
        G.GAME.odyssey_spectral_50_next_xmult = 10
    end,
    [53] = function(card, area, copier) -- Curie
        G.GAME.odyssey_curie_active = true
    end,
    [54] = function(card, area, copier) -- Darwin
        G.GAME.odyssey_darwin_active = true
    end,
    [56] = function(card, area, copier) -- Pasteur
        for i=1, #G.playing_cards do
            G.playing_cards[i].ability.perma_debuff_immune = true
        end
    end,
    [57] = function(card, area, copier) -- Fleming
        for i=1, #G.playing_cards do
            G.playing_cards[i].debuff = false
        end
    end,
    [59] = function(card, area, copier) -- Edison
        local card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'edison')
        card:add_to_deck()
        G.jokers:emplace(card)
    end,
    [60] = function(card, area, copier) -- Bell
        local card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'bell')
        card:add_to_deck()
        G.consumeables:emplace(card)
    end,
    [63] = function(card, area, copier) -- Ford
         G.SETTINGS.GAMESPEED = 10
    end,
    [68] = function(card, area, copier) -- Jobs
        if G.hand.highlighted[1] then
            local c = G.hand.highlighted[1]
            local new_card = create_card('Base', G.deck, nil, nil, nil, nil, nil, 'jobs')
            c:set_base(new_card.config.center)
            new_card:remove()
        end
    end,
    [71] = function(card, area, copier) -- Bezos
        for i=1, 3 do
            local card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'bezos')
            card:add_to_deck()
            G.jokers:emplace(card)
        end
    end,
    [74] = function(card, area, copier) -- Vitalik
        G.GAME.odyssey_vitalik_active = true
    end,
    [75] = function(card, area, copier) -- Armstrong
        ease_ante(2)
    end,
    [76] = function(card, area, copier) -- Aldrin
        if #G.jokers.cards > 0 then
            local joker = G.jokers.cards[1]
            for i=2, #G.jokers.cards do
                if G.jokers.cards[i].config.center.rarity > joker.config.center.rarity then
                    joker = G.jokers.cards[i]
                end
            end
            local copy = copy_card(joker, nil, nil, nil, joker.edition)
            copy:add_to_deck()
            G.jokers:emplace(copy)
        end
    end,
    [78] = function(card, area, copier) -- Gagarin
        local card = create_card('Voucher', G.shop_vouchers, nil, nil, nil, nil, nil, 'gagarin')
        card:apply_to_run()
    end,
    [79] = function(card, area, copier) -- Tereshkova
        for i=1, #G.playing_cards do
            if G.playing_cards[i].base.value == 'Queen' then
                G.playing_cards[i]:set_edition({polychrome = true}, true)
            end
        end
    end,
    [82] = function(card, area, copier) -- Shepard
        if #G.playing_cards > 0 then
            local weak = G.playing_cards[1]
            for i=2, #G.playing_cards do
                if G.playing_cards[i].base.nominal < weak.base.nominal then
                    weak = G.playing_cards[i]
                end
            end
            weak:start_dissolve()
            ease_dollars(10)
        end
    end,
    [83] = function(card, area, copier) -- Glenn
        for k, v in pairs(G.GAME.hands) do
            v.level = 1
        end
        ease_dollars(100)
    end,
    [85] = function(card, area, copier) -- Ride
        add_tag(Tag('tag_coupon'))
        add_tag(Tag('tag_investment'))
    end,
    [88] = function(card, area, copier) -- Pesquet
        for i=1, #G.playing_cards do
            if G.playing_cards[i].base.suit == 'Hearts' then
                G.playing_cards[i]:set_ability(G.P_CENTERS.m_odyssey_ceramic, nil)
            end
        end
    end,
    [90] = function(card, area, copier) -- Gerst
        for i=1, #G.playing_cards do
            if G.playing_cards[i].base.suit == 'Clubs' then
                G.playing_cards[i]:set_ability(G.P_CENTERS.m_odyssey_rubber, nil)
            end
        end
    end,
    [92] = function(card, area, copier) -- Hoshide
        for i=1, #G.playing_cards do
            if G.playing_cards[i].base.suit == 'Diamonds' then
                G.playing_cards[i]:set_ability(G.P_CENTERS.m_odyssey_diamond, nil)
            end
        end
    end,
    [93] = function(card, area, copier) -- Yi
        local top_hands = {}
        for k, v in pairs(G.GAME.hands) do
            table.insert(top_hands, {key = k, level = v.level})
        end
        table.sort(top_hands, function(a, b) return a.level > b.level end)
        for i=1, math.min(3, #top_hands) do
            update_hand_stats(top_hands[i].key, {level = 2})
        end
    end,
    [94] = function(card, area, copier) -- Yang
        G.GAME.odyssey_yang_active = true
    end,
    [95] = function(card, area, copier) -- Sharma
        G.GAME.odyssey_sharma_active = true
    end,
    [96] = function(card, area, copier) -- Al Mansoori
        ease_dollars(100 - G.GAME.dollars, true)
        G.GAME.used_vouchers = {}
    end,
    [97] = function(card, area, copier) -- Pontes
        for i=1, #G.playing_cards do
            G.playing_cards[i]:set_ability(G.P_CENTERS.m_odyssey_cloth, nil)
        end
        ease_dollars(15)
    end,
    [98] = function(card, area, copier) -- Vostok
        G.GAME.odyssey_vostok_active = true
    end,
    [99] = function(card, area, copier) -- Mercury
        G.GAME.odyssey_mercury_vessel_active = true
    end,
    [100] = function(card, area, copier) -- Gemini
        G.GAME.odyssey_gemini_active = true
    end,
}

for _, s in ipairs(spectrals) do
    SMODS.Consumable({
        key = s.key,
        set = "Spectral",
        atlas = s.id <= 100 and ("spectral_" .. s.id) or nil,
        pos = { x = 0, y = 0 },
        cost = 4,
        discovered = true,
        can_use = function(self, card)
            return true
        end,
        use = function(self, card, area, copier)
            local id = tonumber(self.key:match("spectral_(%d+)"))
            if spectral_logic[id] then
                spectral_logic[id](card, area, copier)
            end
        end,
        loc_vars = function(self, info_queue, card)
            local id = tonumber(self.key:match("spectral_(%d+)"))
            local mapping = {
                [6] = "m_odyssey_diamond",
                [7] = "m_odyssey_ceramic",
                [8] = "m_odyssey_rubber",
                [9] = "m_odyssey_platinum",
                [88] = "m_odyssey_ceramic",
                [90] = "m_odyssey_rubber",
                [92] = "m_odyssey_diamond",
                [97] = "m_odyssey_cloth"
            }
            if mapping[id] then
                info_queue[#info_queue+1] = G.P_CENTERS[mapping[id]]
            end
            if id == 19 then
                info_queue[#info_queue+1] = {set = 'Other', key = 'perishable', vars = {G.GAME.perishable_rounds}}
            end
            if id == 10 or id == 11 or id == 26 then
                info_queue[#info_queue+1] = G.P_CENTERS.e_negative
            end
            if id == 3 then
                info_queue[#info_queue+1] = G.P_CENTERS.e_polychrome
            end
            if id == 4 then
                info_queue[#info_queue+1] = G.P_CENTERS.e_foil
            end
            if id == 5 then
                info_queue[#info_queue+1] = G.P_CENTERS.e_holo
            end
            return { vars = {} }
        end
    })
end


