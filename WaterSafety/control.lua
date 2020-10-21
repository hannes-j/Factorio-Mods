local water_list = {
    "deepwater",
    "deepwater-green",
    "water",
    "water-green"
}

local rpl_list = {
    "deepwater-tmp",
    "deepwater-green-tmp",
    "water-tmp",
    "water-green-tmp"
}


script.on_init(function()
    validate_technologies()
    revise_tiles_globally()
end)

script.on_configuration_changed(function(configuration_changed_data)
    validate_technologies()
    revise_tiles_globally()
end)


function exe_swimming(player)
    if settings.get_player_settings(player)["WaterSafety-enable-swimming"].value and
       player.character and player.character.valid and not player.vehicle then
        local tiles = {}
        
        for _, check_name in pairs(water_list) do
            local tiles_filtered = player.surface.find_tiles_filtered({position = player.position, radius = 3, name = check_name})
            
            if tiles_filtered and #tiles_filtered >= 1 then
                for _, ob in pairs(tiles_filtered) do
                    tiles[#tiles + 1] = {name = check_name.."-tmp", position = ob.position}
                end
            end
        end
        
        if #tiles >= 1 then
            player.surface.set_tiles(tiles, true, false, false)
        end
    end
end

function revert_tiles(surface, pos, rng)
    for _, check_name in pairs(rpl_list) do
        local tiles = surface.find_tiles_filtered({position = pos, radius = rng, name = check_name})
        
        if tiles and #tiles >= 1 then
            revise_tiles(surface.index, tiles, tiles[1])
        end
    end
end

function revise_tiles(surface_index, tile_list, tile_new)
    if not tile_list or #tile_list < 1 or tile_new == nil then return end
    
    local new_name = tile_new.name
    local has_pltf = string.find(new_name, "landfill") or string.find(new_name, "platform")
    local has_temp = string.find(new_name, "-tmp")
    
    if has_temp then new_name = string.sub(new_name, 1, -5)
    elseif not has_pltf then return end
    
    local tile_srfc = game.surfaces[surface_index]
    local tile_subs = {}
    local tile_lids = {}
    
    for _, tile_itr in pairs(tile_list) do
        local tile_old = tile_itr
        for key, val in pairs(tile_itr) do
            if key == "name" then break
            elseif key == "old_tile" then
                tile_old = val
                break
            end
        end
        
        if has_temp then tile_subs[#tile_subs + 1] = {name = new_name, position = tile_itr.position} end
        
        if has_pltf then
            for _, tmp_name in pairs(rpl_list) do
                if string.find(tmp_name, tile_old.name) then
                    tile_lids[#tile_lids + 1] = {name = tmp_name, position = tile_itr.position}
                    tile_lids[#tile_lids + 1] = {name = new_name, position = tile_itr.position}
                    break
                end
            end
        end
    end
    
    if #tile_subs >= 1 then
        tile_srfc.set_tiles(tile_subs, true, false, true)
    end
    
    if #tile_lids >= 1 then
        tile_srfc.set_tiles(tile_lids, true, false, false)
    end
end

function revise_tiles_globally()
    for _, surface in pairs(game.surfaces) do
        if surface then
            local tiles = surface.find_tiles_filtered({name = rpl_list})
            
            if tiles and #tiles >= 1 then
                local tiles_per_type = {}
                
                for _, tile in pairs(tiles) do
                    if tiles_per_type[tile.name] == nil or #tiles_per_type[tile.name] < 1 then
                        tiles_per_type[tile.name] = { tile }
                    else
                        tiles_per_type[tile.name][#tiles_per_type[tile.name] + 1] = tile
                    end
                end
                
                for name, tile_list in pairs(tiles_per_type) do
                    revise_tiles(surface.index, tile_list, tile_list[1])
                end
            end
        end
    end
end

function validate_technologies()
    for _, force in pairs(game.forces) do
        if force and force.technologies["cliff-explosives"] and force.technologies["cliff-explosives"].researched then
            -- re-unlock recipes
            force.technologies["cliff-explosives"].researched = false
            force.technologies["cliff-explosives"].researched = true
        end
    end
end


script.on_event(defines.events.on_player_changed_position, function(event)
    revert_tiles(game.players[event.player_index].surface, game.players[event.player_index].position, 5)
    
    exe_swimming(game.players[event.player_index])
end)

script.on_event({defines.events.on_player_built_tile, defines.events.on_robot_built_tile}, function(event)
    revise_tiles(event.surface_index, event.tiles, event.tile)
end)

script.on_event({defines.events.on_player_mined_tile, defines.events.on_robot_mined_tile}, function(event)
    for _, check_name in pairs(rpl_list) do
        local tiles = {}
        
        for _, tile_itr in pairs(event.tiles) do
            local tiles_filtered = game.surfaces[event.surface_index].find_tiles_filtered({position = tile_itr.position, radius = 2, name = check_name})
            
            if tiles_filtered and #tiles_filtered >= 1 then
                for _, ob in pairs(tiles_filtered) do
                    tiles[#tiles + 1] = ob
                end
            end
        end
        
        if #tiles >= 1 then
            revise_tiles(event.surface_index, tiles, tiles[1])
        end
    end
end)

script.on_nth_tick(180, function()
    for i = 1, #game.players do
        revert_tiles(game.players[i].surface, game.players[i].position, 5)
    end
    
    for i = 1, #game.players do
        exe_swimming(game.players[i])
    end
end)

script.on_nth_tick(54000, revise_tiles_globally)
