-- HOOKS
------------------------------------------------------------------------

-- 1. Card:calculate_joker (For scoring effects)
local old_calculate_joker = Card.calculate_joker or function() return nil end
Card.calculate_joker = function(self, context)
    local ret = old_calculate_joker(self, context)
    
    local deck_key = get_deck_key()
    if not deck_key then return ret end

    local function merge_effect(base, new)
        if not base then return new end
        if new.mult_mod then base.mult_mod = (base.mult_mod or 0) + new.mult_mod end
        if new.chip_mod then base.chip_mod = (base.chip_mod or 0) + new.chip_mod end
        if new.Xmult_mod then base.Xmult_mod = (base.Xmult_mod or 1) * new.Xmult_mod end
        if not base.message then
            base.message = new.message
            base.colour = new.colour
        end
        return base
    end

    -- Deck 6: Gravitational (Moved to Card:calculate_seal)
    -- Logic removed from here to avoid multiple triggers and dependency on jokers

    -- Deck 10: Quasar (+20 Mult Base)
    if deck_key == 'quasar' and context.joker_main then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_mult', vars={20}},
            mult_mod = 20,
            colour = G.C.MULT
        })
    end

    -- Deck 35: Ascensao (Ascension) - Hands X2
    if deck_key == 'ascensao' and context.joker_main then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_xmult', vars={2}},
            Xmult_mod = 2,
            colour = G.C.MULT
        })
    end

    -- Deck 36: Queda (Fall) - Hands X0.5
    if deck_key == 'queda' and context.joker_main then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_xmult', vars={0.5}},
            Xmult_mod = 0.5,
            colour = G.C.MULT
        })
    end

    -- Deck 16: Order (Bonus for playing in order)
    if deck_key == 'order' and context.joker_main then
        -- Check if played cards are in rank order (ascending or descending)
        local ordered = true
        if #context.scoring_hand > 1 then
            local ascending = true
            local descending = true
            for i = 1, #context.scoring_hand - 1 do
                if context.scoring_hand[i].base.id >= context.scoring_hand[i+1].base.id then
                    ascending = false
                end
                if context.scoring_hand[i].base.id <= context.scoring_hand[i+1].base.id then
                    descending = false
                end
            end
            ordered = ascending or descending
        else
            ordered = false
        end

        if ordered then
             return merge_effect(ret, {
                message = localize{type='variable', key='a_xmult', vars={2}},
                Xmult_mod = 2,
                colour = G.C.MULT
            })
        end
    end

    -- Deck 18: Timeline (Add % of previous score)
    if deck_key == 'timeline' and context.joker_main then
        local stored = 0
        if G.GAME.selected_back.effect.config.extra and G.GAME.selected_back.effect.config.extra.stored_score then
            stored = G.GAME.selected_back.effect.config.extra.stored_score
        end
        if stored > 0 then
             return merge_effect(ret, {
                message = localize{type='variable', key='a_chips', vars={stored}},
                chip_mod = stored,
                colour = G.C.CHIPS
            })
        end
    end

    ------------------------------------------------------------------------
    -- NEW BARALHOS (41-100) IMPLEMENTATION (Merges)
    ------------------------------------------------------------------------

    -- 43. Lust (Luxuria) - Copas X1.2 Mult
    if deck_key == 'lust' and context.joker_main then
        local count = 0
        if context.scoring_hand then
            for _, c in ipairs(context.scoring_hand) do
                if c:is_suit('Hearts') then count = count + 1 end
            end
        end
        if count > 0 then
            return merge_effect(ret, {
                message = localize{type='variable', key='a_xmult', vars={count}},
                Xmult_mod = 1.2 ^ count,
                colour = G.C.MULT
            })
        end
    end

    -- 44. Pride (Orgulho) - Figuras +30 Fichas
    if deck_key == 'pride' and context.joker_main then
       local count = 0
       if context.scoring_hand then
           for _, c in ipairs(context.scoring_hand) do
               if c:is_face() then count = count + 1 end
           end
       end
       if count > 0 then
           return merge_effect(ret, {
               message = localize{type='variable', key='a_chips', vars={count * 30}},
               chip_mod = count * 30,
               colour = G.C.CHIPS
           })
       end
    end

    -- 67. Solar: Red suits only. Flush 2x.
    if deck_key == 'solar' and context.joker_main and context.scoring_name == 'Flush' then
        return merge_effect(ret, {
             message = localize{type='variable', key='a_xmult', vars={2}},
             Xmult_mod = 2,
             colour = G.C.MULT
        })
    end
    
    -- 66. Oceanic: Black suits only. Flush 2x.
    if deck_key == 'oceanic' and context.joker_main and context.scoring_name == 'Flush' then
        return merge_effect(ret, {
             message = localize{type='variable', key='a_xmult', vars={2}},
             Xmult_mod = 2,
             colour = G.C.MULT
        })
    end

    -- 80. Minimalist II: Hand size 3. X5 Mult.
    if deck_key == 'minimalist_ii' and context.joker_main then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_xmult', vars={5}},
            Xmult_mod = 5,
            colour = G.C.MULT
        })
    end
    
    -- 82. Chaotic II: X2 Score (Boss effect doubled is harder).
    if deck_key == 'chaotic_ii' and context.joker_main then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_xmult', vars={2}},
            Xmult_mod = 2,
            colour = G.C.MULT
        })
    end
    
    -- 83. Ordered II: 0.5x Score.
    if deck_key == 'ordered_ii' and context.joker_main then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_xmult', vars={0.5}},
            Xmult_mod = 0.5,
            colour = G.C.MULT
        })
    end

    -- 89. Dragon: X10 Mult
    if deck_key == 'dragon' and context.joker_main then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_xmult', vars={10}},
            Xmult_mod = 10,
            colour = G.C.MULT
        })
    end

    -- 96. Leviathan: Hand size 5 -> +1000 Chips
    if deck_key == 'leviathan' and context.joker_main and context.scoring_hand and #context.scoring_hand == 5 then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_chips', vars={1000}},
            chip_mod = 1000,
            colour = G.C.CHIPS
        })
    end

    -- 97. Behemoth: Hand size 1 -> X5 Mult
    if deck_key == 'behemoth' and context.joker_main and context.scoring_hand and #context.scoring_hand == 1 then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_xmult', vars={5}},
            Xmult_mod = 5,
            colour = G.C.MULT
        })
    end

    -- 42. Sloth (Preguiça): X3 Mult
    if deck_key == 'sloth' and context.joker_main then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_xmult', vars={3}},
            Xmult_mod = 3,
            colour = G.C.MULT
        })
    end

    -- 52. Mirror (Espelho): Right to Left (Descending) -> 2x
    if deck_key == 'mirror' and context.joker_main and context.scoring_hand and #context.scoring_hand >= 2 then
        local descending = true
        for i = 1, #context.scoring_hand - 1 do
            if context.scoring_hand[i].base.id <= context.scoring_hand[i+1].base.id then
                descending = false
                break
            end
        end
        if descending then
             return merge_effect(ret, {
                message = localize{type='variable', key='a_xmult', vars={2}},
                Xmult_mod = 2,
                colour = G.C.MULT
            })
        end
    end

    -- 54. Vampire: Apply accumulated Mult
    if deck_key == 'vampire' and context.joker_main then
        local mult = 0
        if G.GAME.selected_back.effect.config.extra then
            mult = G.GAME.selected_back.effect.config.extra.mult or 0
        end
        if mult > 0 then
            return merge_effect(ret, {
                message = localize{type='variable', key='a_mult', vars={mult}},
                mult_mod = mult,
                colour = G.C.MULT
            })
        end
    end

    -- 60. Invisible: X4 Mult if blind (checked elsewhere, technically always blind here)
    if deck_key == 'invisible' and context.joker_main then
        return merge_effect(ret, {
            message = localize{type='variable', key='a_xmult', vars={4}},
            Xmult_mod = 4,
            colour = G.C.MULT
        })
    end

    -- 65. Volcanic: +$5 per hand
    if deck_key == 'volcanic' and context.joker_main then
         -- Actually money should be applied on scoring? Or end of hand?
         -- joker_main calculates text.
         -- Use ease_dollars triggers in play_cards hook better.
         -- But user wants seeing it?
    end

    return ret
end

-- 2. Card:start_dissolve (For Event Horizon)
local old_start_dissolve = Card.start_dissolve
Card.start_dissolve = function(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
    local deck_key = get_deck_key()
    
    -- Deck 7: Event Horizon (Destroy cards -> +0.5 Mult)
    if deck_key == 'event_horizon' then
        G.GAME.selected_back.effect.config.extra = G.GAME.selected_back.effect.config.extra or {}
        G.GAME.selected_back.effect.config.extra.mult = (G.GAME.selected_back.effect.config.extra.mult or 0) + 0.5
        -- Visual feedback?
        card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = localize{type='variable', key='a_mult', vars={0.5}}})
    end

    old_start_dissolve(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
end

-- 2.1 Hook play_cards to capture score before hand (For Timeline Deck)
local old_play_cards = G.FUNCS.play_cards
G.FUNCS.play_cards = function(e)
    local deck_key = get_deck_key()
    if deck_key == 'timeline' then
        G.GAME.odyssey_temp_chips = G.GAME.chips
    end
    
    -- 41. Wrath (Ira): Hand gives $1
    if deck_key == 'wrath' then
        ease_dollars(1)
        card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = localize('$')..'1', colour = G.C.MONEY})
    end

    -- 65. Volcanic: +$5 per hand
    if deck_key == 'volcanic' then
        ease_dollars(5)
        card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = localize('$')..'5', colour = G.C.MONEY})
    end
    
    -- 64. Frozen: Debuff first hand
    if deck_key == 'frozen' and G.GAME.current_round.hands_played == 0 then
        -- This hook runs on play_cards. Cards are in G.play.cards or passed in event?
        -- G.play.cards should be populated.
        -- We debuff them.
        for k, v in ipairs(G.play.cards) do
            v:set_debuff(true)
        end
        card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = localize('k_frozen_ex')})
    end

    old_play_cards(e)
end

-- 2.2 Hook draw_from_play_to_discard to capture score after hand (For Timeline Deck)
local old_draw_from_play_to_discard = G.FUNCS.draw_from_play_to_discard
G.FUNCS.draw_from_play_to_discard = function(e)
    local deck_key = get_deck_key()
    
    if deck_key == 'timeline' then
        local current_chips = G.GAME.chips
        local previous_chips = G.GAME.odyssey_temp_chips or 0
        local hand_score = current_chips - previous_chips
        
        if hand_score > 0 then
            local to_store = math.floor(hand_score * 0.1)
            G.GAME.selected_back.effect.config.extra = G.GAME.selected_back.effect.config.extra or {}
            G.GAME.selected_back.effect.config.extra.stored_score = to_store
            
            -- Visual feedback
            card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {
                message = localize{type='variable', key='a_chips', vars={to_store}},
                colour = G.C.CHIPS
            })
        end
    end
    
    -- 51. Fractal: 5-of-a-Kind -> Clone card to deck
    -- We do this before cards are moved/destroyed
    if deck_key == 'fractal' then
         -- Identify if it was 5oak. Localizing text might be tricky, rely on internal name if possible?
         -- G.GAME.last_hand_played contains the text key?
         -- "Five of a Kind"
         -- We can check the cards count in scoring hand? context is not available here easily.
         -- But G.play.cards contains played cards.
         if #G.play.cards >= 5 then
            -- Rudimentary check: Are there 5 ranks same?
            -- Or just trust user? No.
            -- Check G.GAME.last_hand_played string (English key).
            -- This relies on game logic setting last_hand_played correctly before this function.
            -- Let's check G.GAME.hands[...].visible?
            
            -- Simplest: If 5 cards played, assume 5oak if they score?
            -- Actually, Flush House is 5 cards. Flush Five is 5 cards. 5oaK is 5 cards.
            -- If we just copy a card when 5 cards are played and they are all the same rank?
            local first_rank = G.play.cards[1].base.id
            local all_match = true
            for i=2, #G.play.cards do
                if G.play.cards[i].base.id ~= first_rank then all_match = false break end
            end
            
            if all_match and #G.play.cards >= 5 then
                 G.E_MANAGER:add_event(Event({
                    func = function() 
                        local card = copy_card(G.play.cards[1], nil, nil, G.playing_card)
                        card:add_to_deck()
                        G.deck:emplace(card)
                        card:start_materialize()
                        card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
                        return true
                    end
                }))
            end
         end
    end

    -- 53. Ghost: Return played cards to hand
    if deck_key == 'ghost' then
        local cards_to_return = {}
        for k, v in ipairs(G.play.cards) do
            cards_to_return[#cards_to_return+1] = v
        end
        
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                for i=1, #cards_to_return do
                    if cards_to_return[i]:is_face_down() then cards_to_return[i]:flip() end
                    draw_card(G.play, G.hand, 90, 'up', nil, cards_to_return[i])
                end
                return true
            end
        }))
        return -- Skip default discard
    end
    
    -- 54. Vampire: Destroy played cards, gain Mult
    if deck_key == 'vampire' then
        local played_count = #G.play.cards
        if played_count > 0 then
            G.GAME.selected_back.effect.config.extra = G.GAME.selected_back.effect.config.extra or {}
            local gain_per_card = G.GAME.selected_back.effect.config.extra.gain or 1
            local total_gain = played_count * gain_per_card
            
            G.GAME.selected_back.effect.config.extra.mult = (G.GAME.selected_back.effect.config.extra.mult or 0) + total_gain
            
            card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {
                message = localize{type='variable', key='a_mult', vars={total_gain}},
                colour = G.C.MULT
            })

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    for k, v in ipairs(G.play.cards) do
                        v:start_dissolve()
                    end
                    return true
                end
            }))
        end
        return -- Skip default discard behavior
    end
    
    -- 65. Volcanic: Discard entire hand (destroy or discard?) logic says "Descarta" (Discard).
    if deck_key == 'volcanic' then
        -- Trigger default discard for played cards
        
        -- And then trigger discard for HAND cards
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.5,
            func = function()
                -- Discard all cards in hand
                for i = #G.hand.cards, 1, -1 do
                    local card = G.hand.cards[i]
                    if not card.highlighted then -- if not highlighted (should be none highlighted after play)
                         draw_card(G.hand, G.discard, i*10, 'down', false, card)
                    end
                end
                return true
            end
        }))
        -- Default behavior for played cards continues
    end

    old_draw_from_play_to_discard(e)
end

-- 3. Game:update (For Supernova check? Or end_of_round)
local old_end_round = G.FUNCS.end_round
G.FUNCS.end_round = function()
    local deck_key = get_deck_key()

    -- Deck 9: Supernova (Money > 50 -> Reset to 0, X3 Mult)
    if deck_key == 'supernova_deck' then
        if G.GAME.dollars > 50 then
            G.GAME.dollars = 0
            G.GAME.selected_back.effect.config.extra = G.GAME.selected_back.effect.config.extra or {}
            G.GAME.selected_back.effect.config.extra.xmult = (G.GAME.selected_back.effect.config.extra.xmult or 1) + 3
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = "SUPERNOVA!", colour = G.C.RED})
                    return true
                end
            }))
        end
    end

    -- Deck 37: Avareza (Greed) - Gain $10 fixed
    if deck_key == 'avareza' then
        ease_dollars(10)
        card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = localize('$')..'10', colour = G.C.MONEY})
    end

    -- 58. Mutant: Suits change every round
    if deck_key == 'mutant' then
         G.E_MANAGER:add_event(Event({
            func = function()
                local suits = {'Spades', 'Hearts', 'Clubs', 'Diamonds'}
                for k, v in ipairs(G.playing_cards) do
                    local new_suit = suits[pseudorandom(pseudoseed('mutant')..v.base.id, 1, 4)]
                    v:change_suit(new_suit)
                end
                return true
            end
        }))
        card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = localize('k_mutant_ex')})
    end

    -- 62. Radioactive: Rank Decay
    if deck_key == 'radioactive' and G.hand and G.hand.cards then
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in ipairs(G.hand.cards) do
                    -- Check if not Ace (or 2 depending on logic). Let's say 2 is lowest.
                    if v.base.id > 2 then
                        local new_id = v.base.id - 1
                        -- Update card visual/value
                        local new_code = G.P_CARDS[string.sub(v.base.suit, 1, 1) .. '_' .. (G.id_def[new_id] or new_id)]
                        -- This P_CARDS lookup is tricky without utility.
                        -- Use internal helper if available or manually change base.
                        -- SMODS usually provides easy ways?
                        -- Trying manual base update approach
                        v.base.id = new_id
                        v.base.value = G.id_def[new_id] -- This might be a string like '2', 'K'
                        v:set_sprites(nil, v.config.card)
                    end
                end
                play_sound('timpani')
                card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = localize('k_decay_ex')})
                return true
            end
        }))
    end

    old_end_round()
end

-- 4. Blind Skip (For Wormhole)
local old_skip_blind = G.FUNCS.skip_blind
G.FUNCS.skip_blind = function(e)
    local deck_key = get_deck_key()
    
    if deck_key == 'wormhole' then
        -- Add Double Tag
        add_tag(Tag('tag_double'))
        
        -- [CRASH FIX] Verificamos si el objeto del mazo tiene la animación.
        -- Si no la tiene (es nil), le inyectamos una función vacía para que no falle.
        if G.GAME.selected_back and not G.GAME.selected_back.juice_up then
            G.GAME.selected_back.juice_up = function() end
        end
        
        -- Ahora es seguro llamar a esto
        card_eval_status_text(G.GAME.selected_back, 'extra', nil, nil, nil, {message = localize('k_double_tag'), colour = G.C.ATTENTION})
    end

    old_skip_blind(e)
end

-- 5. Interest (For Quasar)
-- Note: G.FUNCS.get_interest might not be global. It is usually local in Game.lua.
-- We might need to hook where it is used or check if it is exposed.
-- Actually, G.FUNCS are usually UI callbacks.
-- Interest is calculated in G.FUNCS.end_round usually.
-- Let's check if we can modify interest cap.
-- G.GAME.interest_cap is set in Game:start_run.
-- We can set it to 0 in apply() for Quasar.

-- 6. Poll Edition (For Dark Energy)
local old_poll_edition = poll_edition
function poll_edition(_key, _mod, _no_neg, _guaranteed)
    local deck_key = get_deck_key()
    if deck_key == 'dark_energy' and not _no_neg and not _guaranteed then
        -- 4x chance (approx 1.2%)
        if pseudorandom('dark_energy') < 0.012 then
            return {negative = true}
        end
    end
    return old_poll_edition(_key, _mod, _no_neg, _guaranteed)
end

-- 7. Reroll Shop (For Vacuum)
local old_reroll_shop = G.FUNCS.reroll_shop
G.FUNCS.reroll_shop = function(e)
    if get_deck_key() == 'vacuum' then
        play_sound('cancel')
        return
    end
    old_reroll_shop(e)
end

-- 8. Find Joker (For String Theory)
-- Fakes having a Shortcut joker to enable gap-of-1 straights
local old_find_joker = find_joker
function find_joker(key)
    local ret = old_find_joker(key)
    if key == 'Shortcut' and get_deck_key() == 'string_theory' then
        if not next(ret) then
            table.insert(ret, { ability = {} }) -- Dummy card object
        end
    end
    return ret
end


-- 9. Blind Scaling (For Paradox, Ascensao, Queda, Lucky II, Unlucky)
local old_get_blind_amount = get_blind_amount
function get_blind_amount(ante)
    local amount = old_get_blind_amount(ante)
    local deck_key = get_deck_key()
    
    if deck_key == 'paradox' then
        if ante > 0 then
             amount = amount * (1.5 ^ ante)
        end
    end

    if deck_key == 'ascensao' then
        amount = amount * 2
    end

    if deck_key == 'queda' then
        amount = amount * 0.5
    end

    if deck_key == 'lucky_ii' then
        amount = amount * 4
    end

    if deck_key == 'unlucky' then
        amount = amount * 0.25
    end
    
    return amount
end

-- 10. Card:calculate_seal (For Gravitational Deck repetition)
local old_calculate_seal = Card.calculate_seal
Card.calculate_seal = function(self, context)
    local ret = old_calculate_seal(self, context)
    
    local deck_key = get_deck_key()
    
    -- Deck 6: Gravitational (Retrigger first played card)
    if deck_key == 'gravitational' and context.repetition and context.cardarea == G.play then
        if self == G.play.cards[1] then
            if type(ret) ~= 'table' then ret = {} end
            ret.repetitions = (ret.repetitions or 0) + 1
            ret.message = localize('k_again_ex')
            ret.card = self
        end
    end
    
    return ret
end




-- 12. Card:can_sell_card (For Kraken)
local old_can_sell_card = Card.can_sell_card
Card.can_sell_card = function(self, context)
    -- First check if deck blocks it
    if get_deck_key() == 'kraken' and self.ability.set == 'Joker' then
         return false
    end
    
    -- Then check standard logic
    if old_can_sell_card then 
        return old_can_sell_card(self, context) 
    end
    return true
end

-- 13. Blind:debuff_card (For Ordered II)
local old_debuff_card = Blind.debuff_card
Blind.debuff_card = function(self, card, from_blind)
    if get_deck_key() == 'ordered_ii' then
        return false 
    end
    return old_debuff_card(self, card, from_blind)
end


-- 14. Card:set_cost (For Tech Deck)
local old_set_cost = Card.set_cost
Card.set_cost = function(self)
    old_set_cost(self)
    if G.GAME.modifiers and G.GAME.modifiers.odyssey_shop_price_mult and self.area and 
       (self.area == G.shop_jokers or self.area == G.shop_vouchers or self.area == G.shop_booster) then
        self.cost = math.floor(self.cost * G.GAME.modifiers.odyssey_shop_price_mult)
    end
end

-- 15. Card:set_ability (For Midas Deck)
local old_set_ability = Card.set_ability
Card.set_ability = function(self, center, initial, delay_sprites)
    old_set_ability(self, center, initial, delay_sprites)
    if G.GAME.modifiers and G.GAME.modifiers.odyssey_midas then
        if self.ability.set == 'Joker' then
            if not self.edition then
                self:set_edition({polychrome = true})
            end
        elseif self.ability.set == 'Default' or self.ability.set == 'Enhanced' then
            if self.config.center ~= G.P_CENTERS.m_odyssey_plastic then
                self:set_ability(G.P_CENTERS.m_odyssey_plastic)
            end
        end
    end
end


local enhancements = {}

-- Atlas for Enhancements (User needs to provide odyssey_enhancements.png)
-- Grid 4x4 for the 16 enhancements
-- Row 1: Wood, Plastic, Rubber, Shadow
-- Row 2: Ceramic, Cloth, Paper, Light
-- Row 3: Diamond, Ruby, Emerald, Plant
-- Row 4: Holy, Undead, Cursed, Magic

-- 1. Madeira (Wood)
-- Effect: +10 Chips, 1 in 8 chance to break
SMODS.Enhancement({
    key = 'wood',
    atlas = 'enhancements',
    pos = { x = 0, y = 0 },
    config = { extra = { chips = 10, chance = 8 } },
    loc_txt = {
        name = 'Carta de Madeira',
        text = {
            "{C:chips}+#1#{} Fichas",
            "{C:green}#2# em #3#{} chance de",
            "quebrar ao pontuar"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.chips, G.GAME.probabilities.normal, extra.chance } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.destroy_card and context.cardarea == G.play then
            if pseudorandom('wood_break') < G.GAME.probabilities.normal / card.ability.extra.chance then
                return {
                    remove = true
                }
            end
        end
    end
})

-- 2. Plástico (Plastic)
-- Effect: $3 when in hand at end of round
SMODS.Enhancement({
    key = 'plastic',
    atlas = 'enhancements',
    pos = { x = 1, y = 0 },
    config = { extra = { dollars = 3 } },
    loc_txt = {
        name = 'Carta de Plástico',
        text = {
            "Ganha {C:money}$#1#{} se esta",
            "carta estiver na mão",
            "ao final da rodada"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.dollars } }

    end,
    calculate = function(self, card, context, effect)
        if context.individual and context.cardarea == G.hand and context.end_of_round then
            if G.GAME.odyssey_money_laundering_active and G.GAME.odyssey_money_laundering_active > 0 then
                return nil
            end
            return {
                dollars = card.ability.extra.dollars,
                card = card
            }
        end
    end
})

-- 3. Borracha (Rubber)
-- Effect: Retrigger (Bouncy)
SMODS.Enhancement({
    key = 'rubber',
    atlas = 'enhancements',
    pos = { x = 2, y = 0 },
    config = {},
    loc_txt = {
        name = 'Carta de Borracha',
        text = {
            "Reativa esta carta",
            "{C:attention}1{} vez adicional"
        }
    },
    calculate = function(self, card, context, effect)
        if context.repetition and context.cardarea == G.play then
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
        end
    end
})

-- 4. Cerâmica (Ceramic)
-- Effect: X1.5 Mult, 1 in 4 chance to break
SMODS.Enhancement({
    key = 'ceramic',
    atlas = 'enhancements',
    pos = { x = 0, y = 1 },
    config = { extra = { xmult = 1.5, chance = 4 } },
    loc_txt = {
        name = 'Carta de Cerâmica',
        text = {
            "{X:mult,C:white} X#1# {} Mult",
            "{C:green}#2# em #3#{} chance de",
            "quebrar ao pontuar"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.xmult, G.GAME.probabilities.normal, extra.chance } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                x_mult = card.ability.extra.xmult
            }
        end
        if context.destroy_card and context.cardarea == G.play then
            if pseudorandom('ceramic_break') < G.GAME.probabilities.normal / card.ability.extra.chance then
                return {
                    remove = true
                }
            end
        end
    end
})

-- 5. Tecido (Cloth)
-- Effect: +5 Chips, +2 Mult
SMODS.Enhancement({
    key = 'cloth',
    atlas = 'enhancements',
    pos = { x = 1, y = 1 },
    config = { extra = { chips = 5, mult = 2 } },
    loc_txt = {
        name = 'Carta de Tecido',
        text = {
            "{C:chips}+#1#{} Fichas",
            "{C:mult}+#2#{} Mult"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.chips, extra.mult } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult
            }
        end
    end
})

-- 6. Papel (Paper)
-- Effect: +30 Chips, 1 in 6 chance to break
SMODS.Enhancement({
    key = 'paper',
    atlas = 'enhancements',
    pos = { x = 2, y = 1 },
    config = { extra = { chips = 30, chance = 6 } },
    loc_txt = {
        name = 'Carta de Papel',
        text = {
            "{C:chips}+#1#{} Fichas",
            "{C:green}#2# em #3#{} chance de",
            "quebrar ao pontuar"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.chips, G.GAME.probabilities.normal, extra.chance } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.destroy_card and context.cardarea == G.play then
            if pseudorandom('paper_break') < G.GAME.probabilities.normal / card.ability.extra.chance then
                return {
                    remove = true
                }
            end
        end
    end
})

-- 7. Diamante (Diamond)
-- Effect: $1 when scored
SMODS.Enhancement({
    key = 'diamond',
    atlas = 'enhancements',
    pos = { x = 0, y = 2 },
    config = { extra = { dollars = 1 } },
    loc_txt = {
        name = 'Carta de Diamante',
        text = {
            "Ganha {C:money}$#1#{} quando",
            "esta carta pontua"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.dollars } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                dollars = card.ability.extra.dollars
            }
        end
    end
})

-- 8. Rubi (Ruby)
-- Effect: +10 Mult
SMODS.Enhancement({
    key = 'ruby',
    atlas = 'enhancements',
    pos = { x = 1, y = 2 },
    config = { extra = { mult = 10 } },
    loc_txt = {
        name = 'Carta de Rubi',
        text = {
            "{C:mult}+#1#{} Mult"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.mult } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
})

-- 9. Esmeralda (Emerald)
-- Effect: +50 Chips
SMODS.Enhancement({
    key = 'emerald',
    atlas = 'enhancements',
    pos = { x = 2, y = 2 },
    config = { extra = { chips = 50 } },
    loc_txt = {
        name = 'Carta de Esmeralda',
        text = {
            "{C:chips}+#1#{} Fichas"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.chips } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
})

-- 10. Sombra (Shadow)
-- Effect: X1.5 Mult when scored
SMODS.Enhancement({
    key = 'shadow',
    atlas = 'enhancements',
    pos = { x = 3, y = 0 },
    config = { extra = { xmult = 1.5 } },
    loc_txt = {
        name = 'Carta de Sombra',
        text = {
            "{X:mult,C:white} X#1# {} Mult"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.xmult } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                x_mult = card.ability.extra.xmult
            }
        end
    end
})

-- 11. Luz (Light)
-- Effect: 1 in 4 chance to gain $3 when scored
SMODS.Enhancement({
    key = 'light',
    atlas = 'enhancements',
    pos = { x = 3, y = 1 },
    config = { extra = { dollars = 3, chance = 4 } },
    loc_txt = {
        name = 'Carta de Luz',
        text = {
            "{C:green}#1# em #2#{} chance de",
            "ganhar {C:money}$#3#{}"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { G.GAME.probabilities.normal, extra.chance, extra.dollars } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            if pseudorandom('light_money') < G.GAME.probabilities.normal / card.ability.extra.chance then
                return {
                    dollars = card.ability.extra.dollars
                }
            end
        end
    end
})

-- 12. Planta (Plant)
-- Effect: Gains +5 Chips when scored
SMODS.Enhancement({
    key = 'plant',
    atlas = 'enhancements',
    pos = { x = 3, y = 2 },
    config = { extra = { chips_gain = 5 } },
    loc_txt = {
        name = 'Carta de Planta',
        text = {
            "Ganha {C:chips}+#1#{} Fichas",
            "quando pontua"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.chips_gain } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            card.ability.extra_chips = (card.ability.extra_chips or 0) + card.ability.extra.chips_gain
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.CHIPS,
                card = card
            }
        end
    end
})

-- 13. Sagrada (Holy)
-- Effect: +10 Mult, +30 Chips
SMODS.Enhancement({
    key = 'holy',
    atlas = 'enhancements',
    pos = { x = 0, y = 3 },
    config = { extra = { mult = 10, chips = 30 } },
    loc_txt = {
        name = 'Carta Sagrada',
        text = {
            "{C:mult}+#1#{} Mult",
            "{C:chips}+#2#{} Fichas"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.mult, extra.chips } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                mult = card.ability.extra.mult,
                chips = card.ability.extra.chips
            }
        end
    end
})

-- 14. Morta-Viva (Undead)
-- Effect: 1 in 3 chance to retrigger
SMODS.Enhancement({
    key = 'undead',
    atlas = 'enhancements',
    pos = { x = 1, y = 3 },
    config = { extra = { chance = 3 } },
    loc_txt = {
        name = 'Carta Morta-Viva',
        text = {
            "{C:green}#1# em #2#{} chance de",
            "reativar esta carta"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { G.GAME.probabilities.normal, extra.chance } }

    end,
    calculate = function(self, card, context, effect)
        if context.repetition and context.cardarea == G.play then
            if pseudorandom('undead_retrigger') < G.GAME.probabilities.normal / card.ability.extra.chance then
                return {
                    message = localize('k_again_ex'),
                    repetitions = 1,
                    card = card
                }
            end
        end
    end
})

-- 15. Maldita (Cursed)
-- Effect: X2 Mult, -20 Chips
SMODS.Enhancement({
    key = 'cursed',
    atlas = 'enhancements',
    pos = { x = 2, y = 3 },
    config = { extra = { xmult = 2, chips_loss = 20 } },
    loc_txt = {
        name = 'Carta Maldita',
        text = {
            "{X:mult,C:white} X#1# {} Mult",
            "{C:chips}-#2#{} Fichas"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.xmult, extra.chips_loss } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                x_mult = card.ability.extra.xmult,
                chips = -card.ability.extra.chips_loss
            }
        end
    end
})

-- 16. Mágica (Magic)
-- Effect: 1 in 6 chance to create a Tarot card when scored
SMODS.Enhancement({
    key = 'magic',
    atlas = 'enhancements',
    pos = { x = 3, y = 3 },
    config = { extra = { chance = 6 } },
    loc_txt = {
        name = 'Carta Mágica',
        text = {
            "{C:green}#1# em #2#{} chance de",
            "criar uma carta de {C:tarot}Tarô{}",
            "quando pontua"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { G.GAME.probabilities.normal, extra.chance } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            if pseudorandom('magic_tarot') < G.GAME.probabilities.normal / card.ability.extra.chance then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                            local card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'magic_enhancement')
                            card:add_to_deck()
                            G.consumeables:emplace(card)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end)
                    }))
                    return {
                        message = localize('k_plus_tarot'),
                        colour = G.C.PURPLE,
                        card = card
                    }
                end
            end
        end
    end
})

-- 17. Platina (Platinum)
-- Effect: +100 Chips
SMODS.Enhancement({
    key = 'platinum',
    atlas = 'v_platinum',
    pos = { x = 0, y = 0 },
    config = { extra = { chips = 100 } },
    loc_txt = {
        name = 'Carta de Platina',
        text = {
            "{C:chips}+#1#{} Fichas"
        }
    },
    loc_vars = function(self, info_queue, card)

        local extra = ( (card and card.ability and card.ability.extra) or self.config.extra )

        return { vars = { extra.chips } }

    end,
    calculate = function(self, card, context, effect)
        if context.main_scoring and context.cardarea == G.play then
            return {
                chips = card.ability.extra.chips
            }
        end
    end
})




----------------------------------------------
-- 16. Hook Run Info to display Active Spectral Effects

-- Helper to find the tab container
-- Better Helper: Traverse and insert


-- 
-- RUN INFO UI HOOKS
-- 

-- Define the content for the Spectrals tab
G.UIDEF.run_info_spectrals = function()
    local active_spectrals = get_active_spectrals()
    
    local nodes = {}
    if #active_spectrals == 0 then
        table.insert(nodes, {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
            {n=G.UIT.T, config={text = "No used Spectral cards", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}
        }})
    else
        for _, effect in ipairs(active_spectrals) do
            table.insert(nodes, {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = G.C.L_BLACK, emboss = 0.05, minw = 5, mb=0.1}, nodes={
                {n=G.UIT.C, config={align = "cl", padding = 0.05, minw=4.8}, nodes={
                    {n=G.UIT.R, config={align = "cl"}, nodes={
                        {n=G.UIT.T, config={text = effect.name, scale = 0.45, colour = G.C.WHITE, shadow = true}}
                    }},
                    {n=G.UIT.R, config={align = "cl"}, nodes={
                        {n=G.UIT.T, config={text = effect.text, scale = 0.35, colour = G.C.UI.TEXT_LIGHT}}
                    }}
                }}
            }})
        end
    end

    -- Return a generic container with our list of nodes
    return {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
        {n=G.UIT.R, config={align = "cm", minh = 0.5}, nodes={}},
        {n=G.UIT.R, config={align = "cm", colour = G.C.BLACK, r = 1, padding = 0.15, emboss = 0.05}, nodes={
             {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes=nodes}
        }}
    }}
end

-- Override G.UIDEF.run_info to include the Spectrals tab
-- We fully redefine it to insert our tab into the list.
G.UIDEF.run_info = function()
  return create_UIBox_generic_options({contents ={create_tabs(
    {tabs = {
          {
            label = localize('b_poker_hands'),
            chosen = true,
            tab_definition_function = create_UIBox_current_hands,
        },
        {
          label = localize('b_blinds'),
          tab_definition_function = G.UIDEF.current_blinds,
        },
        {
            label = localize('b_vouchers'),
            tab_definition_function = G.UIDEF.used_vouchers,
        },
        {
            label = localize('k_spectral'),
            tab_definition_function = G.UIDEF.run_info_spectrals,
        },
        G.GAME.stake > 1 and {
          label = localize('b_stake'),
          tab_definition_function = G.UIDEF.current_stake,
        } or nil,
    },
    tab_h = 8,
    snap_to_nav = true})}})
end

------------------------------------------------------------------------
-- MAGNETIC DECK: Clustered Shuffle
------------------------------------------------------------------------
local old_shuffle = CardArea.shuffle
function CardArea:shuffle(type, rng)
    local deck_key = get_deck_key()
    if self == G.deck and deck_key == 'magnetic' then
        -- 1. Group cards by rank
        local ranks = {}
        for _, card in ipairs(self.cards) do
            local rank = card.base.value -- '2', '3', 'T', 'K', etc.
            if not ranks[rank] then ranks[rank] = {} end
            table.insert(ranks[rank], card)
        end
        
        -- 2. Scramble the list of ranks or sorting keys
        local rank_keys = {}
        for k, v in pairs(ranks) do
            table.insert(rank_keys, k)
        end
        pseudoshuffle(rank_keys, pseudoseed('magnetic_deck'))
        
        -- 3. Rebuild deck
        self.cards = {}
        for _, rank in ipairs(rank_keys) do
            local rank_group = ranks[rank]
            -- Shuffle within the rank group (so suits aren't always in same order)
            pseudoshuffle(rank_group, pseudoseed('magnetic_rank'))
            
            for _, card in ipairs(rank_group) do
                table.insert(self.cards, card)
            end
        end
        
        -- Override implies we don't call original shuffle
        return
    end
    
    return old_shuffle(self, type, rng)
end

------------------------------------------------------------------------
-- LUNAR DECK: Moon Phases
------------------------------------------------------------------------

------------------------------------------------------------------------
-- LUNAR DECK: Moon Phases
------------------------------------------------------------------------
-- Helper to get current phase (1-4) and evolution cycle


-- Visual Effects for Lunar Deck
-- Visual Effects for Lunar Deck via Dynamic Editions
-- Apply editions to cards based on current phase

-- Helper function to apply Lunar edition to a card
local function apply_lunar_edition(card, edition_key)
    if not card or not card.set_edition then 
        print("DEBUG: apply_lunar_edition - card or set_edition is nil")
        return 
    end
    
    -- Don't override existing special editions (Negative, Polychrome, etc.)
    if card.edition and (card.edition.negative or card.edition.polychrome or card.edition.holo or card.edition.foil) then
        print("DEBUG: Skipping card with special edition: " .. tostring(card.edition))
        return
    end
    
    -- Apply the lunar edition
    if edition_key then
        -- Safety Check: Verify existance in G.P_CENTERS
        if not G.P_CENTERS[edition_key] then
            print("CRITICAL ERROR: Edition key " .. edition_key .. " does not exist in G.P_CENTERS!")
            -- Try fallback to non-prefixed key?
            local no_e = edition_key:gsub("^e_", "")
            if G.P_CENTERS[no_e] then
                 print("DEBUG: Found non-prefixed key " .. no_e .. ", utilizing fallback.")
                 edition_key = no_e
            else
                 print("DEBUG: Fallback key " .. no_e .. " also not found. Aborting application.")
                 return
            end
        end
        
        print("DEBUG: Applying edition '" .. edition_key .. "' to card")
        -- Pass STRING to allow SMODS to handle prefix logic correctly
        card:set_edition(edition_key, true, true)
    else
        -- Remove lunar editions if nil is passed
        if card.edition then
            local to_remove = {}
            for k, v in pairs(card.edition) do
                if type(k) == 'string' and k:match("odyssey_lunar") then
                    to_remove[k] = true
                end
            end
            
            if next(to_remove) then
                print("DEBUG: Removing lunar editions from card")
                for k, v in pairs(to_remove) do
                    card.edition[k] = nil
                end
                card:set_edition(card.edition, true, true)
            end
        end
    end
end

-- Hook into round start to apply editions
local old_game_start_round = Game.start_round
Game.start_round = function(self)
    print("DEBUG: Game.start_round called!")
    local ret = old_game_start_round(self)
    
    local key = get_deck_key()
    print("DEBUG: Deck key in start_round: " .. tostring(key))
    
    if key == 'lunar' then
        local phase, cycle = get_odyssey_lunar_phase()
        local evolution = tonumber(cycle) or 0
        local edition_key = nil
        
        -- Determine which edition to apply (using evolving keys)
        if phase == 5 then
             edition_key = 'odyssey_lunar_eclipse'
        else
             edition_key = 'odyssey_lunar_p' .. phase .. 'e' .. evolution
        end
        
        print("DEBUG: Applying Lunar editions. Phase: " .. phase .. " Evo: " .. evolution .. " Key: " .. tostring(edition_key))
        
        local function apply_lunar_edition(card, key)
            if not card then return end
            -- Avoid redundant application
            if card.edition and card.edition[key] then return end
            
            -- Don't override existing special editions unless it's a previous lunar edition
            local has_other_special = false
            if card.edition then
                if card.edition.negative or card.edition.polychrome or card.edition.holo or card.edition.foil then
                   has_other_special = true
                end
            end
            
            if not has_other_special then
                card:set_edition(key, true, true)
            end
        end

        -- Apply to all cards in hand
        if G.hand and G.hand.cards then
            print("DEBUG: Applying to " .. #G.hand.cards .. " cards in hand")
            for i = 1, #G.hand.cards do
                apply_lunar_edition(G.hand.cards[i], edition_key)
            end
        else
            print("DEBUG: G.hand or G.hand.cards is nil!")
        end
        
        -- Apply to all cards in deck
        if G.deck and G.deck.cards then
            print("DEBUG: Applying to " .. #G.deck.cards .. " cards in deck")
            for i = 1, #G.deck.cards do
                apply_lunar_edition(G.deck.cards[i], edition_key)
            end
        else
            print("DEBUG: G.deck or G.deck.cards is nil!")
        end
    end
    
    return ret
end

-- Editions are applied once per round at round start (see Game:update hook)
-- No mid-round edition changes for stability

-- Helper function to check if card has any Lunar edition
function has_lunar_edition(card)
    if not card.edition then return false end
    -- Check if any edition key contains "odyssey_lunar"
    for k, v in pairs(card.edition) do
        if type(k) == "string" and k:match("odyssey_lunar") and v then
            return true
        end
    end
    return false
end


-- Hook Card:get_chip_mult (Waxing/Waning/Eclipse Mult Bonuses)
local old_get_chip_mult = Card.get_chip_mult or function(self) return 0 end
Card.get_chip_mult = function(self)
    local ret = old_get_chip_mult(self)
    
    local key = get_deck_key()
    if key == 'lunar' then
        local phase, evolution = get_odyssey_lunar_phase()
        evolution = tonumber(evolution) or 0
        
        -- Phase 1: New Moon (Mult Penalty + Black Immunity/Bonus)
        if phase == 1 then
             local mod = 1
             if evolution == 0 then mod = 0.75
             elseif evolution == 1 then mod = 0.70
             elseif evolution == 2 then mod = 0.65
             else mod = 0.60 end
             
             -- Immunity check (Black cards immune in Evo 1+)
             local immune = false
             if (self:is_suit("Spades") or self:is_suit("Clubs")) and evolution >= 1 then
                 immune = true
             end
             
             if not immune and ret > 0 then
                 ret = ret * mod
             end
             
             -- Conditional Bonus (Evo 2+: +5 Mult, Evo 3+: +10 Mult)
             if immune then
                 local bonus = 0
                 if evolution == 2 then bonus = 5
                 elseif evolution >= 3 then bonus = 10 end
                 
                 if bonus > 0 then ret = ret + bonus end
             end
        end
        
        -- Phase 4: Waning (Mult Penalty + Red Immunity/Bonus)
        if phase == 4 then
             local mod = 1
             if evolution == 0 then mod = 0.75
             elseif evolution == 1 then mod = 0.70
             elseif evolution == 2 then mod = 0.65
             else mod = 0.60 end
             
             -- Immunity check (Red cards immune in Evo 1+)
             local immune = false
             if (self:is_suit("Hearts") or self:is_suit("Diamonds")) and evolution >= 1 then
                 immune = true
             end
             
             if not immune and ret > 0 then
                 ret = ret * mod
             end
             
             -- Conditional Bonus (Evo 2+: +5 Mult, Evo 3+: +10 Mult)
             if immune then
                 local bonus = 0
                 if evolution == 2 then bonus = 5
                 elseif evolution >= 3 then bonus = 10 end
                 
                 if bonus > 0 then ret = ret + bonus end
             end
        end
        
        -- Phase 2, 3, 5 are handled by native SMODS configuration (editions.lua)
    end
    return ret
end

-- Card.calculate_joker hook removed as XMult is now handled by SMODS.Edition config

-- Hook Back:apply_to_run to log selection
local old_apply_to_run = Back.apply_to_run or function() end
Back.apply_to_run = function(self)
    print("DEBUG: Back:apply_to_run called")
    if self.effect.center.key then
        print("DEBUG: Selected Deck Key: " .. tostring(self.effect.center.key))
        if self.effect.config then
            print("DEBUG: Deck Config found")
        end
    end
    old_apply_to_run(self)
end

-- POISON ANTIDOTE: Inject dummy centers for broken keys to allow save loading
-- This prevents crashes when G.P_CENTERS[key] is accessed during load
if G.P_CENTERS then
    -- 1. Inject Standard Phase Keys (e_ prefix)
    for p = 1, 4 do
        for e = 0, 3 do
            local k = 'e_odyssey_lunar_p' .. p .. 'e' .. e
            if not G.P_CENTERS[k] then
                G.P_CENTERS[k] = { name = "Lunar (Broken)", key = k, weight = 0 }
            end
        end
    end
    -- 2. Inject Eclipse Key
    local k = 'e_odyssey_lunar_eclipse'
    if not G.P_CENTERS[k] then
        G.P_CENTERS[k] = { name = "Eclipse (Broken)", key = k, weight = 0 }
    end
    -- 3. Inject LEGACY/Non-Prefixed Keys (just in case save file has them)
    -- Includes: odyssey_lunar_green, odyssey_lunar_red, and non-prefixed pXeX
    local legacy = {'odyssey_lunar_green', 'odyssey_lunar_red', 'odyssey_lunar_eclipse'}
    for p = 1, 4 do for e = 0, 3 do table.insert(legacy, 'odyssey_lunar_p' .. p .. 'e' .. e) end end
    
    for _, k in ipairs(legacy) do
        if not G.P_CENTERS[k] then
            G.P_CENTERS[k] = { name = "Legacy (Broken)", key = k, weight = 0 }
        end
    end
    
    print("DEBUG: Antidote injected dummy P_CENTERS (Prefixed + Legacy)")
end

-- Hook Game:update to track round changes
local old_game_update = Game.update or function() end
Game.update = function(self, dt)
    old_game_update(self, dt)
    -- Only run logic if not in menu and game exists (Reverted strict round > 0 check)
    if G.GAME and G.GAME.round and G.GAME.round ~= G.ODYSSEY_LAST_ROUND and G.STATE ~= G.STATES.MENU then
        print("DEBUG: Round Changed! Old: " .. tostring(G.ODYSSEY_LAST_ROUND) .. " New: " .. tostring(G.GAME.round))
        G.ODYSSEY_LAST_ROUND = G.GAME.round
        G.ODYSSEY_DEBUG_DRAW_THROTTLED = false -- Reset throttle so we see logs again
        
        -- One-time Deck Check
        local debug_key = get_deck_key()
        
        -- Trigger Lunar Phase Logic HERE since start_round is unreliable
        local key = get_deck_key()
        
        -- Safety check: skip if deck not initialized yet
        if not key then
            -- Check if G.GAME.selected_back is valid but just not resolved yet?
            -- Actually, if we are loading, we might need to wait.
            return
        end
        
        if key == 'lunar' then
            -- REPAIR SCRIPT: Fix save files with broken non-prefixed edition keys
            if G.playing_cards then
                for i = 1, #G.playing_cards do
                    local card = G.playing_cards[i]
                    if card.edition then
                        -- Check for non-prefixed keys and fix them
                        for k, v in pairs(card.edition) do
                            if type(k) == 'string' and k:match("^odyssey_lunar") and not k:match("^e_") then
                                print("DEBUG: Converting legacy/broken key " .. k .. " to e_" .. k)
                                -- Use set_edition with string to let SMODS handle it
                                card:set_edition("e_" .. k, true, true)
                            end
                        end
                    end
                end
            end
            
            -- print("DEBUG: Game:update TRIGGERING LUNAR PHASE LOGIC")
            local phase, evolution = get_odyssey_lunar_phase()
            
            -- Apply Lunar Editions to all cards
            local edition_key = nil
            if phase == 5 then
                edition_key = 'e_odyssey_lunar_eclipse'
            else
                -- Build edition key: e_odyssey_lunar_p{phase}e{evolution}
                -- NOTE: SMODS prefixes keys with 'e_', so we must use that!
                if evolution < 0 then evolution = 0 end -- Safety clamp for evolution
                edition_key = 'e_odyssey_lunar_p' .. phase .. 'e' .. evolution
            end
            
            -- print("DEBUG: Applying editions. Phase: " .. phase .. " Evolution: " .. evolution .. " Edition: " .. tostring(edition_key))
            
            
            -- Store current phase/evolution globally for tooltip access
            if not G.GAME.odyssey_lunar_state then
                G.GAME.odyssey_lunar_state = {}
            end
            G.GAME.odyssey_lunar_state.phase = phase
            G.GAME.odyssey_lunar_state.evolution = evolution
            
            -- Apply to all cards in deck (only if they don't have a non-Lunar edition)
            if G.playing_cards then
                -- print("DEBUG: Found G.playing_cards, applying to " .. #G.playing_cards .. " cards")
                for i = 1, #G.playing_cards do
                    local card = G.playing_cards[i]
                    -- Only apply if card has no edition, or already has a Lunar edition
                    if not card.edition or has_lunar_edition(card) then
                        apply_lunar_edition(card, edition_key)
                    end
                end
            else
                print("DEBUG: G.playing_cards is nil!")
            end
            
            local phase_names = {
                "New Moon",
                "Waxing Moon",
                "Full Moon",
                "Waning Moon",
                "THE ECLIPSE"
            }
            
            local phase_name = phase_names[phase]
            local subtext = ""
            
            -- Evolution-based subtexts
            if phase == 5 then
                subtext = "ALL Cards: +15 Chips, +15 Mult, X4 Mult"
            elseif phase == 1 then
                -- Phase 1: Black Cards with Debuff
                if evolution == 0 then subtext = "0.75x Debuff"
                elseif evolution == 1 then subtext = "0.70x | Black Immune"
                elseif evolution == 2 then subtext = "0.65x | Black +Mult"
                else subtext = "0.60x | Black +Mult+Chips" end
            elseif phase == 2 then
                -- Phase 2: Neutral (All Cards) Mult
                if evolution == 0 then subtext = "ALL +2 Mult"
                elseif evolution == 1 then subtext = "ALL +4 Mult"
                elseif evolution == 2 then subtext = "ALL +6 Mult"
                else subtext = "ALL +9 Mult" end
            elseif phase == 3 then
                -- Phase 3: XMult
                if evolution == 0 then subtext = "X1.5 Mult"
                elseif evolution == 1 then subtext = "X2 Mult"
                elseif evolution == 2 then subtext = "X2.25 Mult"
                else subtext = "X2.5 Mult" end
            elseif phase == 4 then
                -- Phase 4: Red Cards with Debuff
                if evolution == 0 then subtext = "0.75x Debuff"
                elseif evolution == 1 then subtext = "0.70x | Red Immune"
                elseif evolution == 2 then subtext = "0.65x | Red +Mult"
                else subtext = "0.60x | Red +Mult+Chips" end
            end

            attention_text({
                text = phase_name .. (phase == 5 and "" or " (Evo " .. evolution .. ")"),
                scale = phase == 5 and 1.2 or 0.8, 
                hold = 3,
                colour = phase == 5 and G.C.PURPLE or G.C.WHITE
            })

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 3.0,
                func = function() 
                    attention_text({
                        text = subtext,
                        scale = 0.6, 
                        hold = 2,
                        colour = G.C.GOLD
                    })
                    return true
                end
            }))
        end
    end
end

print("DEBUG: src/hooks.lua loaded successfully")

-- Hook Card:get_chip_bonus (Phase 1: Black Card Bonuses with Debuff)
local old_get_chip_bonus = Card.get_chip_bonus or function(self)
    if self.ability and self.ability.bonus then return self.ability.bonus + (self.ability.perma_bonus or 0) end
    return 0
end

-- Helper function to check if card has any Lunar edition
local function has_lunar_edition(card)
    if not card.edition then return false end
    -- Check if any edition key starts with "odyssey_lunar"
    for k, v in pairs(card.edition) do
        if type(k) == "string" and k:match("^odyssey_lunar") and v then
            return true
        end
    end
    return false
end

Card.get_chip_bonus = function(self)
    local ret = old_get_chip_bonus(self)
    
    local key = get_deck_key()
    if key == 'lunar' then
        -- Only apply to cards with Lunar edition
        if not has_lunar_edition(self) then
            return ret
        end
        
        local phase, evolution = get_odyssey_lunar_phase()
        
        -- Phase 1: New Moon (Black Cards - Debuff with Immunity/Bonuses)
        if phase == 1 then
            local is_black = self:is_suit("Clubs") or self:is_suit("Spades")
            
            -- Debuff multipliers by evolution
            local debuff_mult = 0.75
            if evolution == 1 then debuff_mult = 0.70
            elseif evolution == 2 then debuff_mult = 0.65
            elseif evolution >= 3 then debuff_mult = 0.60 end
            
            -- Apply debuff to non-immune cards
            if not is_black or evolution == 0 then
                if ret > 0 then
                    ret = ret * debuff_mult
                end
            end
            
            -- Black card chip bonuses at higher evolutions
            if is_black and evolution >= 2 then
                local chip_bonus = evolution == 2 and 5 or 10
                ret = ret + chip_bonus
            end
        end
        
        -- Phase 4: Waning Moon (Red Cards - Debuff with Immunity/Bonuses)
        if phase == 4 then
            local is_red = self:is_suit("Hearts") or self:is_suit("Diamonds")
            
            -- Debuff multipliers by evolution
            local debuff_mult = 0.75
            if evolution == 1 then debuff_mult = 0.70
            elseif evolution == 2 then debuff_mult = 0.65
            elseif evolution >= 3 then debuff_mult = 0.60 end
            
            -- Apply debuff to non-immune cards
            if not is_red or evolution == 0 then
                if ret > 0 then
                    ret = ret * debuff_mult
                end
            end
            
            -- Red card chip bonuses at higher evolutions
            if is_red and evolution >= 2 then
                local chip_bonus = evolution == 2 and 5 or 10
                ret = ret + chip_bonus
            end
        end
    end
    return ret
end

-- Hook Card:get_chip_mult (All Phases: Evolution-Based Mult Bonuses)
local old_get_chip_mult = Card.get_chip_mult or function(self) return 0 end
Card.get_chip_mult = function(self)
    local ret = old_get_chip_mult(self)
    
    local key = get_deck_key()
    if key == 'lunar' then
        -- Only apply to cards with Lunar edition
        -- Note: If we use config AND this hook, we get double bonuses.
        -- BUT user says "broken", so maybe config failed or is silent.
        -- We will use this hook for VISUALS and Effect.
        -- I RECOMMEND removing config from editions.lua later if this works.
        
        if not has_lunar_edition(self) then return ret end
        
        local phase, evolution = get_odyssey_lunar_phase()
        evolution = tonumber(evolution) or 0
        local is_black = self:is_suit("Clubs") or self:is_suit("Spades")
        local is_red = self:is_suit("Hearts") or self:is_suit("Diamonds")
        
        -- Phase 1: New Moon (Black Cards - Debuff with Immunity/Bonuses)
        if phase == 1 then
             local mod = 1
             if evolution == 0 then mod = 0.75
             elseif evolution == 1 then mod = 0.70
             elseif evolution == 2 then mod = 0.65
             else mod = 0.60 end
             
             local immune = (is_black and evolution >= 1)
             if not immune and ret > 0 then ret = ret * mod end
             
             if immune then
                 local bonus = 0
                 if evolution == 2 then bonus = 5
                 elseif evolution >= 3 then bonus = 10 end
                 if bonus > 0 then ret = ret + bonus end
             end
        end
        
        -- Phase 2: Waxing (All Cards Mult)
        if phase == 2 then
            local bonus = 2
            if evolution == 1 then bonus = 4
            elseif evolution == 2 then bonus = 6
            elseif evolution >= 3 then bonus = 9 end
            
            -- We just return value here, popups are hard in get_chip_mult
            ret = ret + bonus
        end
        
        -- Phase 4: Waning (Red Cards - Debuff with Immunity/Bonuses)
        if phase == 4 then
             local mod = 1
             if evolution == 0 then mod = 0.75
             elseif evolution == 1 then mod = 0.70
             elseif evolution == 2 then mod = 0.65
             else mod = 0.60 end
             
             local immune = (is_red and evolution >= 1)
             if not immune and ret > 0 then ret = ret * mod end
             
             if immune then
                 local bonus = 0
                 if evolution == 2 then bonus = 5
                 elseif evolution >= 3 then bonus = 10 end
                 if bonus > 0 then ret = ret + bonus end
             end
        end
        
        -- Phase 5: Eclipse (All Cards +15 Mult)
        if phase == 5 then
            ret = ret + 15
        end
    end
    return ret
end

-- Re-Add Card.calculate_joker for XMult (Phase 3 & 5) Visuals
-- Card.calculate_joker hook removed as XMult is now properly handled by SMODS.Edition config in editions.lua

----------------------------------------------
-- COSMIC PARTICLE SYSTEMS (AURA & RUNES)
----------------------------------------------
print("DEBUG: Defining Card:update hook for Particles")
----------------------------------------------
-- SHADER UNIFORM INJECTION HOOK (BRUTE FORCE - CORRECTED)
----------------------------------------------
