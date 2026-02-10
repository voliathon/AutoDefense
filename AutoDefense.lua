--[[
    Copyright (c) 2025 Voliathon
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
       this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.
]]

_addon.name = 'AutoDefense'
_addon.author = 'Voliathon'
_addon.version = '1.0.0'
_addon.commands = {'ad', 'autodefense'}

local res = require('resources')

-- ============================================================================
-- CONFIGURATION
-- ============================================================================
local phalanx_cmd = 'gs equip sets.Phalanx'
local cursna_cmd  = 'gs equip sets.CursnaReceived'
local return_cmd  = 'gs c update' 
local debug_mode  = true 

-- ============================================================================
-- STATE TRACKING
-- ============================================================================
local ids = {
    ACCESSIO  = 218,
    PHALANX_1 = 106,
    PHALANX_2 = 107,
    CURSNA    = 20, -- The "Mystery ID" discovered via packet analysis
    DOOM      = 15
}

local accession_users = {}
local reset_timestamp = 0 

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================
local function log(msg)
    if debug_mode then windower.add_to_chat(207, '[AD-Debug] ' .. msg) end
end

local function has_doom()
    local player = windower.ffxi.get_player()
    if not player then return false end
    for _, buff_id in pairs(player.buffs) do
        if buff_id == ids.DOOM then return true end
    end
    return false
end

local function get_distance(target_id)
    local target = windower.ffxi.get_mob_by_id(target_id)
    if target then return math.sqrt(target.distance) end
    return 999
end

-- ============================================================================
-- GEAR LOGIC
-- ============================================================================
local function try_reset_gear()
    if os.time() >= reset_timestamp then
        log('Resetting gear.')
        windower.send_command(return_cmd)
    else
        log('Reset delayed (Window extended).')
    end
end

local function equip_and_schedule(command, spell_name)
    reset_timestamp = os.time() + 4
    windower.add_to_chat(207, '[AutoDefense] Incoming '..spell_name..'! Equipping set.')
    windower.send_command(command)
    coroutine.schedule(try_reset_gear, 4)
end

-- ============================================================================
-- MAIN EVENT: ACTION (Packet Logic)
-- ============================================================================
windower.register_event('action', function(act)
    
    -- Category 6 = Job Ability (Accession)
    -- Category 8 = Spell Casting (Phalanx/Cursna)
    if act.category == 6 or act.category == 8 then
        
        -- Optimization: Party Check
        local party = windower.ffxi.get_party()
        if not party or party.party1_count <= 1 then return end
        
        local actor_id = act.actor_id
        local player = windower.ffxi.get_player()

        -- 1. DETECT ACCESSION (Category 6)
        if act.category == 6 and act.param == ids.ACCESSIO then
            log('Accession active for Actor ' .. actor_id)
            accession_users[actor_id] = os.time() + 60
            return
        end

        -- 2. DETECT SPELLS (Category 8)
        if act.category == 8 then
            -- Ignore self-cast
            if actor_id == player.id then return end

            local should_swap_phalanx = false
            local should_swap_cursna = false
            local is_accession = (accession_users[actor_id] and os.time() < accession_users[actor_id])

            -- Iterate through targets
            for i, target in pairs(act.targets) do
                local action = target.actions[1]
                
                if action then
                    -- THE FIX: Look at the Sub-Param
                    local sub_param = action.param 

                    -- LOGIC: PHALANX
                    if sub_param == ids.PHALANX_1 or sub_param == ids.PHALANX_2 then
                        if target.id == player.id then 
                            should_swap_phalanx = true
                        elseif is_accession and get_distance(target.id) < 10 then
                            should_swap_phalanx = true
                            log('AoE Phalanx proximity detected.')
                        end

                    -- LOGIC: CURSNA
                    elseif sub_param == ids.CURSNA then
                        if has_doom() then
                            if target.id == player.id then 
                                should_swap_cursna = true
                            elseif is_accession and get_distance(target.id) < 10 then
                                should_swap_cursna = true
                                log('AoE Cursna proximity detected.')
                            end
                        end
                    end
                end
            end

            -- EXECUTE SWAPS
            if should_swap_phalanx then
                equip_and_schedule(phalanx_cmd, "Phalanx")
            elseif should_swap_cursna then
                equip_and_schedule(cursna_cmd, "Cursna")
            end
        end
    end
end)