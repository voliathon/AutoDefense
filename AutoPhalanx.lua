_addon.name = 'AutoPhalanx'
_addon.author = 'Voliathon'
_addon.version = '1.1.0 Return'
_addon.commands = {'ap', 'autophalanx'}

local packets = require('packets')
local res = require('resources')

-- ============================================================================
-- CONFIGURATION
-- ============================================================================
local phalanx_command = 'gs equip sets.Phalanx'
local return_command  = 'gs c update' -- Standard command to refresh GS state
local cast_delay      = 4             -- Seconds to wait before switching back
local debug_mode      = true 

-- ============================================================================
-- VALID IDS
-- ============================================================================
local ids = {
    ACCESSIO = 218,
    PHALANX_1 = 106,
    PHALANX_2 = 107,
    PHALANX_X = 24931
}

local accession_users = {}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================
local function log(msg)
    if debug_mode then
        windower.add_to_chat(207, '[AP-Debug] ' .. msg)
    end
end

local function get_distance_to_entity(target_id)
    local target = windower.ffxi.get_mob_by_id(target_id)
    if target then return math.sqrt(target.distance) end
    return 999
end

-- FUNCTION TO RESET GEAR
local function reset_gear()
    log('Spell should have landed. Resetting gear...')
    windower.send_command(return_command)
    
    -- Verification (Optional):
    -- We can't easily check "sets.phalanx" because we don't know what items are in it 
    -- from this addon's perspective. But we can confirm the reset command was sent.
end

-- ============================================================================
-- MAIN EVENT LOOP
-- ============================================================================
windower.register_event('incoming chunk', function(id, data)
    if id == 0x28 then
        local packet = packets.parse('incoming', data)
        local actor_id = packet['Actor']
        local category = packet['Category']
        local param = packet['Param']
        local player = windower.ffxi.get_player()

        -- 1. DETECT ACCESSION
        if category == 6 and param == ids.ACCESSIO then
            log('Accession used by Actor '..actor_id)
            accession_users[actor_id] = os.time() + 60
        end

        -- 2. DETECT PHALANX
        if category == 8 and (param == ids.PHALANX_1 or param == ids.PHALANX_2 or param == ids.PHALANX_X) then
            
            -- Ignore self-cast
            if actor_id == player.id then return end

            local target_id = packet['Target 1 ID']
            local should_swap = false

            -- CASE A: DIRECT CAST ON ME
            if target_id == player.id then
                log('Direct cast on me!')
                should_swap = true
            end

            -- CASE B: ACCESSION (AOE) LOGIC
            if not should_swap and accession_users[actor_id] and os.time() < accession_users[actor_id] then
                local dist = get_distance_to_entity(target_id)
                if dist < 10 then
                    log('AoE Logic: In range ('..dist..')')
                    should_swap = true
                    accession_users[actor_id] = nil
                end
            end

            -- EXECUTE SWAP AND QUEUE RESET
            if should_swap then
                windower.add_to_chat(207, '[AutoPhalanx] Incoming Phalanx! Equipping set.')
                windower.send_command(phalanx_command)
                
                -- SCHEDULE THE RESET
                -- We verify the swap implicitly by the fact we sent the command.
                -- To verify the *gear* specifically would require hardcoding your specific Phalanx items into this Lua.
                coroutine.schedule(reset_gear, cast_delay)
            end
        end
    end
end)