----------------------------------------------
-- LUNAR EFFECTS MODULE
-- Handles particle systems (Runes, Solar Halo, Magic Cross)
----------------------------------------------

LunarEffects = {}

-- Main Update Loop for Card Particles
function LunarEffects:update(card, dt)
    -- DEBUG: Entry
    -- print("LunarEffects: Update called for " .. (card.base.name or "??"))

    -- Safety checks: Must have edition
    if not card.edition then return end

    -- Throttling & Contextual Logic
    local spawn_rate = 3.0 -- Default (Slow)
    
    -- 1. DECK LOGIC: Only spawn if it's the TOP card to prevent clutter
    if card.area and card.area == G.deck then
        -- Check if card is the last one in the deck list (top visual card)
        if G.deck.cards and G.deck.cards[#G.deck.cards] ~= card then
            return -- Skip buried cards entirely
        end
        spawn_rate = 4.0 -- Even slower for the deck pile
    end

    -- 2. HAND/PLAY LOGIC: Faster for active cards
    if card.area and (card.area == G.hand or card.area == G.play) then
        spawn_rate = 1.5 -- Faster (1.5s) to look active
    end

    if G.TIMERS.REAL - (card.last_cosmic_particle or 0) < spawn_rate then 
        return 
    end
    
    local ed_key = card.edition.key
    if not ed_key then 
        -- print("LunarEffects: Edition Key Missing")
        return 
    end

    -- Identify Lunar Type
    local is_lunar_green = ed_key:find("odyssey_lunar_p1") or ed_key:find("odyssey_lunar_p2") or ed_key == 'odyssey_lunar_green'
    local is_lunar_red = ed_key:find("odyssey_lunar_p3") or ed_key:find("odyssey_lunar_p4") or ed_key == 'odyssey_lunar_red'
    local is_lunar_eclipse = ed_key:find("eclipse")

    -- print("LunarEffects check: " .. ed_key .. " | Green:" .. tostring(is_lunar_green) .. " | Red:" .. tostring(is_lunar_red))
    
    if not (is_lunar_green or is_lunar_red or is_lunar_eclipse) then return end

    card.last_cosmic_particle = G.TIMERS.REAL

    -- Random position offset within card bounds
    local w, h = card.T.w, card.T.h
    local ox = (math.random() - 0.5) * w * 1.2
    local oy = (math.random() - 0.5) * h * 1.2
    
    -- SYSTEM 1: DARK VOID (Lunar Green) - Ancient Glyphs
    if is_lunar_green then
        if math.random() < 0.6 then 
            local symbols = {"Ω", "Π", "Ψ", "Φ", "Þ", "ð", "Æ", "†"}
            local sym = symbols[math.random(#symbols)]
            local scale = 0.5 + math.random() * 0.3
            
            -- Suit-based Tinting (Green System)
            local r, g, b = 1, 1, 1
            if card.base.suit == 'Spades' then
                r, g, b = 0.4, 0.6, 1.0 -- Vivid Azure Blue
            elseif card.base.suit == 'Clubs' then
                r, g, b = 0.4, 1.0, 0.4 -- Vivid Neon Green
            end

            local part = {
                text = sym,
                scale = scale,
                colour = {r, g, b, 1.0}, 
                shadow_colour = {0,0,0,1}, 
                pop_in = 1.0, 
                hold = 3.0, 
                pop_out = 1.0, 
                major = card, 
                offset = {x = ox, y = oy}
            }
            attention_text(part) 
        end
    end

    -- SYSTEM 2: GOLDEN SOLAR (Lunar Red) - Sun/Circles & Rays
    if is_lunar_red then
        if math.random() < 0.6 then
            local symbols = {"O", "o", "*", "+", "x", "^", "°", "☼"}
            local txt = symbols[math.random(#symbols)]
            local scale = 0.5 + math.random() * 0.3 -- Varied scale

            -- Color Correction (Red System) - FORCED COLORS
            local r, g, b = 1.0, 0.8, 0.2 -- Default Gold
            if card.base.suit == 'Diamonds' then
                r, g, b = 1.0, 0.5, 0.0 -- Safety Orange (No Pink!)
            elseif card.base.suit == 'Hearts' then
                r, g, b = 1.0, 0.2, 0.2 -- Fire Red
            end
            
            local part = {
                text = txt,
                scale = scale,
                colour = {r, g, b, 1.0},
                shadow_colour = {1, 0.2, 0, 0.5},
                pop_in = 1.0, 
                hold = 3.0, 
                pop_out = 1.0, 
                major = card, 
                offset = {x = ox, y = oy}
            }
            attention_text(part) 
        end
    end

    -- SYSTEM 3: ECLIPSE MAGIC (Eclipse) - Mystic Sigils
    if is_lunar_eclipse then
        if math.random() < 0.8 then 
            -- Mystic Symbols
            local symbols = {"?", "§", "¶", "‡", "∞", "∫", "≈", "◊"}
            local sym = symbols[math.random(#symbols)]
            local scale = 0.6 + math.random() * 0.4 
            
            local part = {
                text = sym,
                scale = scale,
                colour = {0.8, 0.4, 1.0, 1.0}, 
                shadow_colour = {0.5, 0, 0.8, 0.8},
                pop_in = 1.0, -- Slow fade in
                hold = 3.0, -- Stay visible
                pop_out = 1.0, -- Slow fade out
                major = card, 
                offset = {x = ox, y = oy}
            }
            attention_text(part)
        end
    end
end
