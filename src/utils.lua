-- UTILITY FUNCTIONS
----------------------------------------------

-- Lunar Deck Phase & Evolution Tracking
-- Phases cycle 1-4 every 4 rounds
-- Evolution increases every 4 rounds (after completing all 4 phases)
-- Eclipse starts at round 17
function get_odyssey_lunar_phase()
    if not G.GAME or not G.GAME.round then 
        return 1, 0 
    end
    
    local round = G.GAME.round
    
    -- Eclipse starts at round 17 (after 4 full cycles of 4 phases)
    local adjusted_round = round + 1
    
    if adjusted_round >= 17 then
        return 5, 0 -- Eclipse, no evolution levels
    end
    
    -- Phase cycles 1-4 every 4 rounds
    -- Round 1=Phase1, R2=Phase2, R3=Phase3, R4=Phase4, R5=Phase1(Evo1), etc
    local phase = ((adjusted_round - 1) % 4) + 1  -- Cycles 1,2,3,4,1,2,3,4...
    local evolution = math.floor((adjusted_round - 1) / 4)  -- 0 for rounds 1-4, 1 for 5-8, 2 for 9-12, 3 for 13-16
    
    return phase, evolution
end

-- Helper: Count total number of Jokers
function count_jokers()
    return #G.jokers.cards
end

-- Helper: Get number of empty Joker slots
function get_empty_slots()
    return G.jokers.config.card_limit - #G.jokers.cards
end

-- Helper: Get current deck size
function get_deck_size()
    return #G.playing_cards
end

-- Helper: Check if card is specific suit
function is_suit(card, suit)
    return card:is_suit(suit)
end

-- Helper: Check if card is specific rank
function is_rank(card, rank)
    return card.base.value == rank
end

-- Helper: Get Joker by key
function get_joker_by_key(key)
    for i = 1, #G.jokers.cards do
        if G.jokers.cards[i].ability.name == key then
            return G.jokers.cards[i]
        end
    end
    return nil
end

-- Helper: Count Jokers of specific rarity
function count_jokers_by_rarity(rarity)
    local count = 0
    for i = 1, #G.jokers.cards do
        if G.jokers.cards[i].config.center.rarity == rarity then
            count = count + 1
        end
    end
    return count
end

-- Helper: Get neighbor Joker (supports Connector bridging)
function get_joker_neighbor(card, direction)
    local my_pos = nil
    for i=1, #G.jokers.cards do
        if G.jokers.cards[i] == card then my_pos = i break end
    end
    if not my_pos then return nil end
    
    local step = direction == 'left' and -1 or 1
    local target_pos = my_pos + step
    
    local target = G.jokers.cards[target_pos]
    if target and target.config.center.key == 'j_odyssey_j_pos_connector' then
        target_pos = target_pos + step
        target = G.jokers.cards[target_pos]
    end
    
    return target
end

-- Helper: Check if only one Joker of this type exists
function is_unique_joker(card)
    local duplicates = 0
    for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] and G.jokers.cards[i] ~= card and G.jokers.cards[i].ability.name == card.ability.name then
            duplicates = duplicates + 1
        end
    end
    return duplicates == 0
end

-- Helper: Utility function for localization
function create_loc_text(key, name, text)
    return {
        name = name,
        text = text
    }
end

-- Sorte Azarada: Override pseudorandom to fail checks for luck cards
local old_pseudorandom = pseudorandom
function pseudorandom(seed, min, max)
    if G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            if j.config.center.key == 'j_odyssey_j_paradox_unlucky_luck' and not j.debuff then
                if seed == 'undead_retrigger' or seed == 'light_money' or seed == 'magic_tarot' then
                    return 0.99 -- Fail the check (usually check is < prob)
                end
            end
        end
    end
    return old_pseudorandom(seed, min, max)
end

-- ODYSSEY CUSTOM: Robust n-of-a-kind helper for custom hands
function get_n_of_a_kind(hand, n)
    local ranks = {}
    for i = 1, #hand do
        local r = hand[i]:get_id()
        if r > 0 then
            ranks[r] = ranks[r] or {}
            table.insert(ranks[r], hand[i])
        end
    end
    local results = {}
    -- Sort ranks to ensure deterministic order (highest rank first like vanilla)
    local sorted_ranks = {}
    for r, group in pairs(ranks) do
        table.insert(sorted_ranks, {rank = r, group = group})
    end
    table.sort(sorted_ranks, function(a, b) return a.rank > b.rank end)

    for _, item in ipairs(sorted_ranks) do
        if #item.group >= n then
            -- If it's more than n, we only return first n cards to match vanilla behavior
            local group = {}
            for i = 1, n do
                table.insert(group, item.group[i])
            end
            table.insert(results, group)
        end
    end
    return results
end

-- Safety patch for create_popup_UIBox_tooltip to prevent crash when localization is missing
-- Some game parts expect tooltip.text to be a table, but localize returns a string "ERROR" on failure
local old_create_popup_UIBox_tooltip = create_popup_UIBox_tooltip
function create_popup_UIBox_tooltip(tooltip)
    if tooltip and type(tooltip.text) == 'string' then
        tooltip.text = {tooltip.text}
    end
    return old_create_popup_UIBox_tooltip(tooltip)
end

-- Helper: Get Active Spectral Effects for Run Info
function get_active_spectrals()
    local spectral_usage = {}  -- Track usage count per spectral ID
    local spectral_info = {}   -- Track name and effect text per spectral ID
    
    -- Mapping from variable name to Spectral ID
    local var_to_id = {
        ['odyssey_sharma_active'] = 95,
        ['odyssey_yang_active'] = 94,
        ['odyssey_galileo_active'] = 39,
        ['odyssey_newton_active'] = 40,
        ['odyssey_einstein_active'] = 41,
        ['odyssey_drake_active'] = 35,
        ['odyssey_curie_active'] = 53,
        ['odyssey_darwin_active'] = 54,
        ['odyssey_vitalik_active'] = 74,
        ['odyssey_vostok_active'] = 98,
        ['odyssey_gemini_active'] = 100,
        ['odyssey_mercury_vessel_active'] = 99,
        ['odyssey_hopper_active'] = 66,
    }

    -- Helper function to get spectral card name
    local function get_spectral_name(id)
        -- First try localization (how the base game does it)
        local card_key = 'c_odyssey_spectral_' .. id
        local loc_name = localize{type = 'name_text', set = 'Spectral', key = card_key}
        if loc_name and loc_name ~= '' and not loc_name:find('ERROR') then
            return loc_name
        end
        
        -- Then try G.P_CENTERS with different key formats
        local possible_keys = {
            card_key,
            'c_spectral_' .. id,
            'spectral_' .. id
        }
        
        for _, key in ipairs(possible_keys) do
            if G.P_CENTERS[key] and G.P_CENTERS[key].name then
                return G.P_CENTERS[key].name
            end
        end
        
        -- Last resort: return a readable fallback
        return "Spectral #" .. id
    end

    -- Helper function to register a spectral usage
    local function register_spectral(id, effect_text)
        spectral_usage[id] = (spectral_usage[id] or 0) + 1
        if not spectral_info[id] then
            spectral_info[id] = {
                name = get_spectral_name(id),
                effects = {}
            }
        end
        -- Add effect if not already tracked
        if effect_text and not spectral_info[id].effects[effect_text] then
            spectral_info[id].effects[effect_text] = true
        end
    end

    -- 1. Scan G.GAME for active spectral effects
    if G.GAME then
        for k, v in pairs(G.GAME) do
            if type(k) == 'string' and k:find('odyssey_') then
                local id = nil
                local effect_text = nil
                
                -- Case A: Generic Spectral XMult (odyssey_spectral_ID_xmult)
                local id_xmult = k:match("odyssey_spectral_(%d+)_xmult")
                if id_xmult and type(v) == 'number' and v > 1 then
                    id = tonumber(id_xmult)
                    effect_text = "X" .. tostring(v) .. " Mult"
                
                -- Case B: Named Active Flags
                elseif var_to_id[k] and v then
                    id = var_to_id[k]
                    effect_text = "Active"
                
                -- Case C: Zero Absolute
                elseif k == 'odyssey_zero_absolute' and v then
                    id = 14
                    effect_text = "Active"
                
                -- Case D: Temporary Next Hand Effects
                elseif k:find("_next_xmult") then
                    local id_next = k:match("odyssey_spectral_(%d+)_next_xmult")
                    if id_next and v and v > 1 then
                        id = tonumber(id_next)
                        effect_text = "X" .. tostring(v) .. " Mult (Next Hand)"
                    end
                end
                
                if id then
                    register_spectral(id, effect_text)
                end
            end
        end
    end

    -- 2. Scan History for all used spectrals
    if G.GAME and G.GAME.odyssey_history then
        for id, count in pairs(G.GAME.odyssey_history) do
            if type(count) == 'number' and count > 0 then
                -- Register the spectral with its usage count
                spectral_usage[id] = count
                if not spectral_info[id] then
                    spectral_info[id] = {
                        name = get_spectral_name(id),
                        effects = {}
                    }
                end
            elseif count == true then
                -- Old boolean format, just mark as used once
                register_spectral(id, nil)
            end
        end
    end
    
    -- 3. Build the effects list
    local effects = {}
    for id, count in pairs(spectral_usage) do
        local info = spectral_info[id]
        local name = info.name
        
        -- Add count if used more than once
        if count > 1 then
            name = name .. " (" .. count .. ")"
        end
        
        -- Combine all effects for this spectral
        local effect_list = {}
        for effect, _ in pairs(info.effects) do
            table.insert(effect_list, effect)
        end
        
        local text = #effect_list > 0 and table.concat(effect_list, ", ") or "Used"
        
        table.insert(effects, { 
            name = name, 
            text = text,
            id = id  -- For sorting
        })
    end
    
    -- Sort by spectral ID
    table.sort(effects, function(a, b) 
        return a.id < b.id
    end)

    return effects
end

-- Hook for global Odyssey mechanics (like per-hand Tarot buffs)
SMODS.current_mod.calculate = function(self, context)
    if not context or type(context) ~= 'table' then return end
    
    -- Per-hand scoring buffs
    if context.joker_main then
        local chips = G.GAME.warrior_chips or 0
        local mult = G.GAME.magician_mult or 0
        local x_mult = G.GAME.rogue_x_mult or 1
        
        -- Spectral: Supernova (1), Zero Absoluto (14), Planck (15)
        x_mult = x_mult * (G.GAME.odyssey_spectral_1_xmult or 1)
        x_mult = x_mult * (G.GAME.odyssey_spectral_14_xmult or 1)
        x_mult = x_mult * (G.GAME.odyssey_spectral_15_xmult or 1)
        
        -- Spectral: Oppenheimer (50) X10 next hand
        if G.GAME.odyssey_spectral_50_next_xmult then
            x_mult = x_mult * G.GAME.odyssey_spectral_50_next_xmult
            G.GAME.odyssey_spectral_50_next_xmult = nil -- Consume
        end

        -- Spectral: Hopper (66) 10% chance for X100 Mult
        if G.GAME.odyssey_hopper_active then
             if pseudorandom('hopper') < 0.1 then
                 x_mult = x_mult * 100
             end
        end

        -- Spectral: Yang (94) X1.5 for 5-card hands
        if G.GAME.odyssey_yang_active and #context.full_hand == 5 then
            x_mult = x_mult * 1.5
        end

        if chips > 0 or mult > 0 or x_mult > 1 then
            return {
                message = "Odyssey!",
                chips = chips > 0 and chips or nil,
                mult = mult > 0 and mult or nil,
                x_mult = x_mult > 1 and x_mult or nil,
                colour = G.C.PURPLE
            }
        end
    end

    -- Spectral: Sharma (95) +$1 per Joker per hand
    if context.after and G.GAME.odyssey_sharma_active then
        ease_dollars(#G.jokers.cards)
    end

    -- Bard Retrigger
    if context.repetition and context.cardarea == G.play then
        if G.GAME.bard_retrigger and G.GAME.bard_retrigger > 0 then
            return {
                message = "Bard!",
                repetitions = 1,
                card = context.other_card
            }
        end
    end

    -- Reset round-based effects
    if context.end_of_round and not context.other_card then
        G.GAME.odyssey_spectral_1_xmult = 1
        G.GAME.odyssey_galileo_active = nil
        G.GAME.odyssey_newton_active = nil
        G.GAME.odyssey_einstein_active = nil
        G.GAME.odyssey_drake_active = nil
        
        -- Reset Tarot buffs
        G.GAME.warrior_chips = 0
        G.GAME.magician_mult = 0
        G.GAME.rogue_x_mult = 1
        G.GAME.bard_retrigger = 0

        -- Safety: Turn all cards face up when winning a round to prevent permanent flip bugs
        -- Specifically helpful for Endless mode transition.
        if G.playing_cards then
            for k, v in ipairs(G.playing_cards) do
                v.facing = 'front'
                v.sprite_facing = 'front'
            end
        end
    end
end

-- Reveal all Odyssey content (Jokers, Vouchers, Decks, etc.) in the Collections menu
function BalatroOdyssey.reveal_all_content()
    -- Prefix for Odyssey content
    local function is_odyssey_key(k)
        if not k then return false end
        return type(k) == 'string' and k:find('odyssey_') ~= nil
    end

    -- Mark discovered in individual centers
    for k, v in pairs(G.P_CENTERS) do
        if is_odyssey_key(k) then
            v.discovered = true
            v.unlocked = true
            v.alerted = true
        end
    end
    
    -- Mark discovered in Blinds
    for k, v in pairs(G.P_BLINDS) do
        if is_odyssey_key(k) then
            v.discovered = true
            v.unlocked = true
        end
    end

    -- Update profile metadata if available
    local profile = (G and G.SETTINGS and G.SETTINGS.profile and G.PROFILES) and G.PROFILES[G.SETTINGS.profile] or nil
    if profile then
        profile.meta = profile.meta or { unlocked = {}, discovered = {}, alerted = {} }
        profile.meta.unlocked = profile.meta.unlocked or {}
        profile.meta.discovered = profile.meta.discovered or {}
        profile.meta.alerted = profile.meta.alerted or {}
        
        for k, v in pairs(G.P_CENTERS) do
            if is_odyssey_key(k) then
                profile.meta.unlocked[k] = true
                profile.meta.discovered[k] = true
                profile.meta.alerted[k] = true
            end
        end
        for k, v in pairs(G.P_BLINDS) do
            if is_odyssey_key(k) then
                profile.meta.unlocked[k] = true
                profile.meta.discovered[k] = true
            end
        end
    end
end

-- ODYSSEY ADJACENCY HELPERS
function BalatroOdyssey.get_card_index(card, area)
    if not area or not area.cards then return nil end
    for i = 1, #area.cards do
        if area.cards[i] == card then return i end
    end
    return nil
end

function BalatroOdyssey.is_adjacent(card1, card2, area)
    local idx1 = BalatroOdyssey.get_card_index(card1, area)
    local idx2 = BalatroOdyssey.get_card_index(card2, area)
    if idx1 and idx2 and math.abs(idx1 - idx2) == 1 then
        return true
    end
    return false
end

function BalatroOdyssey.get_adjacent_cards(card, area)
    local idx = BalatroOdyssey.get_card_index(card, area)
    local adjacent = {}
    if not idx or not area or not area.cards then return adjacent end
    if area.cards[idx-1] then table.insert(adjacent, area.cards[idx-1]) end
    if area.cards[idx+1] then table.insert(adjacent, area.cards[idx+1]) end
    return adjacent
end


-- Safety patch for create_popup_UIBox_tooltip to prevent crash when localization is missing

----------------------------------------------
-- ODYSSEY ENGINE MONITOR & LOGGING SYSTEM
----------------------------------------------
-- Sistema centralizado para rastrear cada ação dos 1000 Jokers e itens.

ODYSSEY_LOG = {
    info = function(cat, msg) print("[ODYSSEY INFO][" .. cat .. "] " .. msg) end,
    warn = function(cat, msg) print("[ODYSSEY WARN][" .. cat .. "] " .. msg) end,
    err  = function(cat, msg) print("[ODYSSEY ERROR][" .. cat .. "] " .. msg) end,
    debug = function(card, context, ret)
        local key = (card.config and card.config.center and card.config.center.key) or "unknown"
        if not key:find("odyssey") then return end -- Só loga itens do mod
        
        local ctx_name = "Unknown"
        if context.joker_main then ctx_name = "Main Scoring"
        elseif context.before then ctx_name = "Before Hand"
        elseif context.after then ctx_name = "After Hand"
        elseif context.end_of_round then ctx_name = "End of Round"
        elseif context.discard then ctx_name = "Discard"
        elseif context.individual then ctx_name = "Individual Card"
        elseif context.repetition then ctx_name = "Repetition/Retrigger"
        elseif context.setting_blind then ctx_name = "Setting Blind"
        elseif context.selling_self then ctx_name = "Selling Joker"
        elseif context.skip_blind then ctx_name = "Skip Blind"
        elseif context.open_booster then ctx_name = "Open Booster"
        elseif context.buying_card then ctx_name = "Buying Card"
        end

        local res = "Ignored"
        if ret then
            res = "SUCCESS -> "
            if type(ret) == "table" then
                for k, v in pairs(ret) do
                    if k ~= "card" then res = res .. k .. ": " .. tostring(v) .. " | " end
                end
            end
        end
        if ret then
            print("[ODYSSEY DEBUG][" .. key .. "] Context: " .. ctx_name .. " | Result: " .. res)
        end
    end
}

-- 1. Hook de Cálculo de Jokers (Com Proteção contra Crash)
local card_calc_joker_ref = Card.calculate_joker
function Card.calculate_joker(self, context)
    -- Tenta executar o cálculo original
    local status, ret = pcall(card_calc_joker_ref, self, context)
    
    if not status then
        -- Se o Joker do mod deu erro de código, logamos o erro detalhado em vez de fechar o jogo
        ODYSSEY_LOG.err("CRASH PROTECT", "Joker " .. (self.config.center.key or "unknown") .. " crashed! Error: " .. tostring(ret))
        return nil
    end

    -- Se for um item do Odyssey, logamos o comportamento
    if self.config.center.key and self.config.center.key:find("odyssey") then
        ODYSSEY_LOG.debug(self, context, ret)
    end
    
    return ret
end

-- 2. Hook de Uso de Consumíveis
local card_use_consumeable_ref = Card.use_consumeable
function Card.use_consumeable(self, area, copier)
    local key = self.config.center.key or "unknown"
    if key:find("odyssey") then
        ODYSSEY_LOG.info("CONSUMABLE", "Using " .. key .. " (Area: " .. (area and area.config.type or "nil") .. ")")
    end
    
    local status, ret = pcall(card_use_consumeable_ref, self, area, copier)
    if not status then
        ODYSSEY_LOG.err("CRASH PROTECT", "Consumable " .. key .. " crashed! Error: " .. tostring(ret))
    end
    return ret
end

-- 3. Hook de Criação de Cartas (Para rastrear pools)
local create_card_ref = create_card
function create_card(...)
    local card = create_card_ref(...)
    if card and card.config.center.key and card.config.center.key:find("odyssey") then
        local args = {...}
        ODYSSEY_LOG.info("POOL", "Generated Odyssey item: " .. card.config.center.key .. " (Set: " .. tostring(args[1]) .. ")")
    end
    return card
end


-- Balatro Odyssey: Standard Vanilla Overrides & Hooks
-- Consolidates critical game logic and patches known injector bugs.

-- 1. Game Setup & Pool Management
local old_get_blind_amount = get_blind_amount
function get_blind_amount(ante)
    local amount = old_get_blind_amount(ante)
    -- Odyssey Scale: Base points grow 3x faster to compensate for 1000 Jokers power creep.
    return amount * 3
end

-- 2. Currency & Stat Easing
local old_ease_dollars = ease_dollars
function ease_dollars(amount, instant)
    if G.GAME.bankrupt_at and (G.GAME.dollars + amount < G.GAME.bankrupt_at) then return end
    old_ease_dollars(amount, instant)
end

-- 3. Card & Hand Logic Consolidation
local old_is_suit = Card.is_suit
function Card:is_suit(suit, bypass_debuff, flush_calc)
    if G.GAME and G.GAME.modifiers.odyssey_chameleon and not bypass_debuff then return true end
    return old_is_suit(self, suit, bypass_debuff, flush_calc)
end

local old_get_cost = Card.get_cost
function Card:get_cost()
    local cost = old_get_cost(self)
    if G.GAME.odyssey_astronomer_planets_free and self.ability.set == 'Planet' then return 0 end
    
    -- Odyssey Coupon Joker (j_economy_coupon)
    if G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            if j.config.center.key == 'j_odyssey_j_economy_coupon' and j.ability.extra and j.ability.extra.active then
                return 0
            end
        end
    end
    
    return cost
end

-- 4. Safety Fixes (Lovely/Injector Stability)
local old_ebcb = ease_background_colour_blind
function ease_background_colour_blind(state, blindname)
    local b_name = blindname or (G.GAME.blind and G.GAME.blind.name) or ''
    -- Safety check: Avoid "attempt to index field 'boss' (a nil value)" in common_events.lua
    for _, v in pairs(G.P_BLINDS) do
        if v.name == b_name and not v.boss then
            ease_background_colour{new_colour = G.C.BLIND['Small'], contrast = 1}
            return
        end
    end
    old_ebcb(state, b_name)
end

local old_reroll_boss = G.FUNCS.reroll_boss
G.FUNCS.reroll_boss = function(e)
    if not G.blind_select_opts or not G.blind_select_opts.boss then return end
    old_reroll_boss(e)
end

-- 5. Round Timer Initializer
local old_set_blind = Blind.set_blind
function Blind:set_blind(blind, reset, silent)
    old_set_blind(self, blind, reset, silent)
    G.GAME.last_hand_time = G.TIMERS.REAL
end

-- 6. Blind Mechanics Overrides
-- A Espaguetificação: Jokers don't give Mult (Only Chips/XMult)
local old_calculate_joker = Card.calculate_joker
function Card:calculate_joker(context)
    local ret = old_calculate_joker(self, context)
    if ret and G.GAME.blind and G.GAME.blind.key == 'blind_odyssey_blind_64' then
        if ret.mult_mod then ret.mult_mod = nil end
        if ret.mult then ret.mult = nil end
    end
    return ret
end

-- 7. Perma-Mult & Perma-Bonus Logic for Playing Cards
local old_get_chip_mult = Card.get_chip_mult
function Card:get_chip_mult()
    local mult = old_get_chip_mult(self)
    if self.debuff then return 0 end
    if self.ability.set == 'Joker' then return 0 end
    return mult + (self.ability.perma_mult or 0)
end

local old_generate_UIBox_ability_table = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table()
    local res = old_generate_UIBox_ability_table(self)
    if (self.ability.set == 'Default' or self.ability.set == 'Enhanced') and self.ability.perma_mult and self.ability.perma_mult ~= 0 then
        -- Inject perma_mult into loc_vars if needed
    end
    return res
end



-- src/04_ui_overrides.lua
-- Sobrescreve a formatação de números do jogo para usar sufixos (K, M, B...)

if not G.E_MANAGER then
    -- If loaded very early
end

function create_UIBox_hand_tip(handname)
  if not G.GAME.hands[handname].example then return {n=G.UIT.R, config={align = "cm"},nodes = {}} end 
  local hand_example = G.GAME.hands[handname].example
  local is_discovered = G.GAME.hands[handname].visible

  local card_limit = #hand_example
  -- Fine-tune width to avoid excessive spacing (0.5 * G.CARD_W is enough for smaller cards)
  local cardarea = CardArea(
    2,2,
    (card_limit * 0.55) * G.CARD_W, 
    0.75*G.CARD_H, 
    {card_limit = card_limit, type = 'title', highlight_limit = 0})

  for k, v in ipairs(hand_example) do
      local card = Card(0,0, 0.5*G.CARD_W, 0.5*G.CARD_H, G.P_CARDS[v[1]], G.P_CENTERS.c_base)
      
      -- If the hand is a secret hand and NOT discovered, use the lock sprite
      if not is_discovered and handname:find('secret_hand') then
          if G.ASSET_ATLAS['odyssey_mystery'] then
              card.children.front.atlas = G.ASSET_ATLAS['odyssey_mystery']
              card.children.front:set_sprite_pos({x=0, y=0})
          end
      end

      -- If discovered, we use normal behavior. If not discovered, we force them to look "highlighted" (bigger)
      -- so the lock image is more visible and fills the space.
      local scale_mod = (is_discovered and v[2]) and 0.25 or (not is_discovered and 0.2) or -0.15
      
      if v[2] or not is_discovered then card:juice_up(0.3, 0.2) end
      if k == 1 then play_sound('paper1',0.95 + math.random()*0.1, 0.3) end
      ease_value(card.T, 'scale', scale_mod, nil, 'REAL', true, 0.2)
      cardarea:emplace(card)
  end

  return {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, r = 0.1}, nodes={
    {n=G.UIT.C, config={align = "cm"}, nodes={
      {n=G.UIT.O, config={object = cardarea}}
    }}
  }}
end

--------------------------------------------------------------------------------
-- 1. Number Formatting
--------------------------------------------------------------------------------

-- Salva a função original por segurança
local original_number_format = number_format

function number_format(number, reformat)
    if not number then return "0" end
    
    -- Garante que é um número
    local n = tonumber(number)
    if not n then return tostring(number) end

    -- Se for menor que 1000, retorna o número normal (arredondado)
    if math.abs(n) < 1000 then
        -- Permite decimais para números pequenos (importante para multiplicadores como 0.5)
        if n == math.floor(n) then
            return tostring(math.floor(n))
        else
            return string.format("%.1f", n):gsub("%.0$", "")
        end
    end

    -- Tabela de sufixos
    local suffixes = {
        "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"
    }
    
    local suffix_index = 0
    local temp_number = n
    
    -- Divide por 1000 até ficar menor que 1000
    while math.abs(temp_number) >= 1000 and suffix_index < #suffixes do
        temp_number = temp_number / 1000
        suffix_index = suffix_index + 1
    end
    
    -- Se estourou a lista de sufixos (números absurdamente grandes), usa notação científica original
    if suffix_index > #suffixes then
        return original_number_format(number, reformat)
    end
    
    -- Formata com até 2 casas decimais
    local formatted = string.format("%.2f", temp_number)
    
    -- Remove zeros à direita desnecessários
    if formatted:sub(-3) == ".00" then
        formatted = formatted:sub(1, -4)
    elseif formatted:sub(-1) == "0" then
        formatted = formatted:sub(1, -2)
    end
    
    return formatted .. suffixes[suffix_index]
end

--------------------------------------------------------------------------------
-- 2. Card Cost Overrides
--------------------------------------------------------------------------------
-- Hook Card:set_cost to implement deck logic for free/double prices

if Card then
    local old_set_cost = Card.set_cost
    Card.set_cost = function(self)
        -- Call original first to compute base cost
        if old_set_cost then old_set_cost(self) end
        
        -- Safe check for G variables
        if not (G and G.GAME and G.GAME.modifiers) then return end

        if G.GAME.selected_back and G.GAME.selected_back.effect.center.key == 'odyssey_tech' then
            -- Check if we are in shop (Booster or Jokers or Vouchers)
            if self.area == G.shop_jokers or self.area == G.shop_booster or self.area == G.shop_vouchers then
                 self.cost = self.cost * 2
                 -- Recompute sell cost
                 self.sell_cost = math.max(1, math.floor(self.cost/2))
                 -- Fix label
                 self.sell_cost_label = self.facing == 'back' and '?' or self.sell_cost
            end
        end

        local set = self.ability.set
        local name = self.ability.name

        -- Free Arcana (73)
        if G.GAME.modifiers.odyssey_free_arcana and set == 'Booster' and name and name:find('Arcane') then
             self.cost = 0
        end
        -- Free Celestial (74)
        if G.GAME.modifiers.odyssey_free_planet and set == 'Booster' and name and name:find('Celestial') then
             self.cost = 0
        end
        -- Free Spectral (75)
        if G.GAME.modifiers.odyssey_free_spectral and set == 'Booster' and name and name:find('Spectral') then
             self.cost = 0
        end
        -- Free Standard (76)
        if G.GAME.modifiers.odyssey_free_standard and set == 'Booster' and name and name:find('Standard') then
             self.cost = 0
        end
        -- Free Buffoon (77)
        if G.GAME.modifiers.odyssey_free_buffoon and set == 'Booster' and name and name:find('Buffoon') then
             self.cost = 0
        end
    end
end

------------------------------------------------------------------------
-- UI Override for Deck Selection Pagination
------------------------------------------------------------------------

-- Helper to apply the fix to a UI definition table (REORGANIZE PIPS TO ROWS OF 10)
local function apply_pip_fix(t)
    local function find_and_fix_pips(node, depth)
        if not node or type(node) ~= 'table' then return false end
        if depth > 40 then return false end
        
        -- Check if this node has many children (likely the pips container)
        if node.nodes and #node.nodes > 15 then
            -- Double check: Are the children UI nodes with B type (Button/Pip)?
            local all_pips = true
            for _, child in ipairs(node.nodes) do
                if type(child) ~= 'table' or child.n ~= G.UIT.B then
                    all_pips = false
                    break
                end
            end

            if all_pips then
                -- node.nodes is the array of pips. We empty it to hide them.
                node.nodes = {}
                return true -- Stop searching
            end
        end
        
        -- Recurse into children
        if node.nodes then
            for _, child in ipairs(node.nodes) do
                if find_and_fix_pips(child, depth + 1) then
                    return true
                end
            end
        end
        
        return false
    end

    find_and_fix_pips(t, 0)
end

-- Hook 1: G.UIDEF.run_setup_option
if G and G.UIDEF then
    local old_run_setup_option = G.UIDEF.run_setup_option
    G.UIDEF.run_setup_option = function(type)
        local t = old_run_setup_option(type)
        if type == 'Back' then
            apply_pip_fix(t)
        end
        return t
    end
end

-- Hook 2: create_option_cycle (Global)
if create_option_cycle then
    local old_create_option_cycle = create_option_cycle
    create_option_cycle = function(args)
        -- Filter Vanilla Decks if this is the Deck Selection cycle
        if args and args.options then
            local vanilla_keys = {
                ["b_red"] = true, ["b_blue"] = true, ["b_yellow"] = true, ["b_green"] = true, ["b_black"] = true,
                ["b_magic"] = true, ["b_nebula"] = true, ["b_ghost"] = true, ["b_abandoned"] = true, ["b_checkered"] = true,
                ["b_zodiac"] = true, ["b_painted"] = true, ["b_anaglyph"] = true, ["b_plasma"] = true, ["b_erratic"] = true
            }
            
            -- Check if this is a deck cycle
            local is_deck_cycle = false
            local first_opt = args.options[1]
            
            -- Heuristic: Check first option
            if type(first_opt) == 'table' then
                if first_opt.key and (vanilla_keys[first_opt.key] or string.find(first_opt.key, "^b_odyssey")) then
                    is_deck_cycle = true
                elseif first_opt.set == 'Back' then
                    is_deck_cycle = true
                end
            elseif type(first_opt) == 'string' then
                -- If it's a string, check if it matches a known deck name
                if first_opt == "Red Deck" or first_opt == "Baralho Vermelho" then
                    is_deck_cycle = true
                end
            end
            
            if is_deck_cycle then
                local new_options = {}
                for _, opt in ipairs(args.options) do
                    local is_odyssey = false
                    
                    -- STRICT FILTER: Only allow Odyssey decks
                    if type(opt) == 'table' then
                        if opt.key and (string.find(opt.key, "odyssey") or string.find(opt.key, "b_odyssey")) then
                            is_odyssey = true
                        end
                    end
                    
                    if is_odyssey then
                        table.insert(new_options, opt)
                    end
                end
                
                -- Only replace if we found at least one Odyssey deck
                if #new_options > 0 then
                    args.options = new_options
                end
            end
        end
        
        local t = old_create_option_cycle(args)
        
        -- Check if this is a large cycle (likely decks)
        if args and args.options and #args.options > 20 then
            apply_pip_fix(t)
        end
        
        return t
    end
end

sendDebugMessage("Balatro Odyssey: UI Overrides Loaded (Number Formatting + Deck Pagination)")


-- 05_deck_mechanics.lua
-- Handles custom logic for Balatro Odyssey Decks

local deck_mechanics = {}

-- Helper to get current deck key
-- Helper to get current deck key
function get_deck_key()
    if not G then return nil end
    if not G.GAME then return nil end
    if not G.GAME.selected_back then 
        -- print("DEBUG: get_deck_key - G.GAME.selected_back is nil")
        return nil 
    end
    if not G.GAME.selected_back.effect then return nil end
    if not G.GAME.selected_back.effect.center then return nil end

    local key = G.GAME.selected_back.effect.center.key
    -- Debugging: Print the actual key
    -- print("DEBUG DECK KEY:", key) 
    
    if not key then return nil end
    
    -- Handle Steamodded varying formats
    key = key:gsub("^b_odyssey_", "")
    key = key:gsub("^odyssey_", "")
    key = key:gsub("^BalatroOdyssey_", "")
    -- Fallback: if key is b_lunar (atlas name leak?) or similar
    key = key:gsub("^b_", "") 
    return key
end

-- Helper to get deck config
function get_deck_config()
    if G.GAME.selected_back and G.GAME.selected_back.effect.config then
        return G.GAME.selected_back.effect.config
    end
    return {}
end

------------------------------------------------------------------------
