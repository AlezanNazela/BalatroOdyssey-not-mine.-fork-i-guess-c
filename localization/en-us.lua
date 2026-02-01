local result = { descriptions = {} }

-- Helper to safely load modules via SMODS or require
local function load_module(name)
    -- 1. Try SMODS.load_file (Correct way for Steamodded mods)
    if SMODS and SMODS.load_file then
        local path = "localization/" .. name .. ".lua"
        local chunk, err = SMODS.load_file(path, "BalatroOdyssey")
        if chunk then
            return chunk()
        end
        -- If SMODS.load_file fails, log it (err contains the error)
        print("SMODS.load_file failed for " .. path .. ": " .. (err or "nil"))
    end

    -- 2. Fallback to standard require (For dev environment or if SMODS fails)
    -- This handles cases where package.path is set correctly but SMODS isn't used for loading
    local status, mod = pcall(require, "localization." .. name)
    if status then 
        return mod 
    end
    
    -- 3. Last ditch: try loading relative to current file path if possible?
    -- No good cross-platform way in Lua without LÖVE/SMODS context.

    error("CRITICAL: Could not load localization module '" .. name .. "'. Please ensure the file exists in localization/ folder.")
end

-- Load all split modules
local joker = load_module('en-us_joker')
if joker and joker.Joker then result.descriptions['Joker'] = joker['Joker'] end

result.descriptions['Tarot'] = {}
local tarot1 = load_module('en-us_tarot_1')
if tarot1 and tarot1.Tarot then 
    for k, v in pairs(tarot1.Tarot) do result.descriptions['Tarot'][k] = v end
end
local tarot2 = load_module('en-us_tarot_2')
if tarot2 and tarot2.Tarot then 
    for k, v in pairs(tarot2.Tarot) do result.descriptions['Tarot'][k] = v end
end

local planet = load_module('en-us_planet')
if planet and planet.Planet then result.descriptions['Planet'] = planet['Planet'] end

local spectral = load_module('en-us_spectral')
if spectral and spectral.Spectral then result.descriptions['Spectral'] = spectral['Spectral'] end

local voucher = load_module('en-us_voucher')
if voucher and voucher.Voucher then result.descriptions['Voucher'] = voucher['Voucher'] end

local enhanced = load_module('en-us_enhanced')
if enhanced and enhanced.Enhanced then result.descriptions['Enhanced'] = enhanced['Enhanced'] end

local back = load_module('en-us_back')
if back and back.Back then result.descriptions['Back'] = back['Back'] end

local blind = load_module('en-us_blind')
if blind and blind.Blind then result.descriptions['Blind'] = blind['Blind'] end

local hand = load_module('en-us_hand')
if hand and hand.Hand then result.descriptions['Hand'] = hand['Hand'] end

local other = load_module('en-us_other')
if other and other.Other then result.descriptions['Other'] = other['Other'] end

-- Load misc module and merge strictly (it contains root keys like 'misc' and 'dictionary')
local misc = load_module('en-us_misc')
if misc then
    for k, v in pairs(misc) do 
        result[k] = v 
    end
end

return result
