local provider_prototype = "logistic-teleport-chest"

local dist_max_squared = 0
local distance_maximum = 0
local provider_list = nil
local receiver_list = nil
local teleporting = false

function calc_distance_squared(pos1, pos2)
    if not pos1 then
        pos1 = {x = 0, y = 0}
    end
    
    if not pos2 then
        pos2 = {x = 0, y = 0}
    end
    
    return (pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2
end

function handle_requests()
    if teleporting then return end
    teleporting = true
    
    distance_maximum = settings.global["teleport-provider-distance"].value
    dist_max_squared = distance_maximum^2
    
    if provider_list == nil then
        register_providers()
    end
    
    local providers = {}
    local providers_up = {}
    for i = 1, #provider_list do
        if provider_list[i] and provider_list[i].valid then
            providers_up[#providers_up + 1] = provider_list[i]
            providers[#providers + 1] = provider_list[i]
        end
    end
    provider_list = providers_up
    
    local providers_by_force = {}
    for i = 1, #providers do
        if providers_by_force[providers[i].force.name] == nil then
            providers_by_force[providers[i].force.name] = {force = providers[i].force, entity_array = {}}
        end
        providers_by_force[providers[i].force.name].entity_array[#(providers_by_force[providers[i].force.name].entity_array) + 1] = providers[i]
    end
    
    handle_player_requests(providers_by_force)
    handle_storage_requests(providers_by_force)
    
    teleporting = false
end

function handle_player_requests(providers_by_force)
    for key, value in pairs(providers_by_force) do
        for i, player in pairs(value.force.players) do
            if player.character_logistic_slot_count and player.character_personal_logistic_requests_enabled then
                local inventory = player.get_main_inventory()
                local item_amts = inventory.get_contents()
                
                local position = nil
                local logistic_points = nil
                if player.character and player.character.valid then
                    logistic_points = player.character.get_logistic_point()
                    position = player.character.position
                end
                
                for j = 1, player.character_logistic_slot_count do
                    local slot = player.get_personal_logistic_slot(j)
                    
                    if slot and slot.name then
                        local count = slot.min
                        
                        if item_amts[slot.name] then
                            count = count - item_amts[slot.name]
                        end
                        
                        if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == slot.name then
                            count = count - player.cursor_stack.count
                        end
                        
                        if count >= 1 then
                            transfer_items(value.entity_array, slot.name, count, inventory, logistic_points, position)
                        end
                    end
                end
            end
        end
    end
end

function handle_storage_requests(providers_by_force)
    if receiver_list == nil then
        register_receivers()
    end
    
    local receivers = {}
    local receivers_up = {}
    for i = 1, #receiver_list do
        if receiver_list[i] and receiver_list[i].valid then
            receivers_up[#receivers_up + 1] = receiver_list[i]
            receivers[#receivers + 1] = receiver_list[i]
        end
    end
    receiver_list = receivers_up
    
    local receivers_by_force = {}
    for i = 1, #receivers do
        if receivers_by_force[receivers[i].force.name] == nil then
            receivers_by_force[receivers[i].force.name] = {force = receivers[i].force, entity_array = {}}
        end
        receivers_by_force[receivers[i].force.name].entity_array[#(receivers_by_force[receivers[i].force.name].entity_array) + 1] = receivers[i]
    end
    
    for key, value in pairs(providers_by_force) do
        for i, receiver in pairs(receivers_by_force[key].entity_array) do
            if receiver.request_slot_count and (receiver.request_from_buffers == nil or receiver.request_from_buffers or receiver.prototype.logistic_mode == "buffer") then
                local inventory = receiver.get_inventory(defines.inventory.chest)
                local item_amts = inventory.get_contents()
                
                for j = 1, receiver.request_slot_count do
                    local slot = receiver.get_request_slot(j)
                    
                    if slot and slot.name then
                        local count = slot.count
                        
                        if item_amts[slot.name] then
                            count = count - item_amts[slot.name]
                        end
                        
                        if count >= 1 then
                            transfer_items(value.entity_array, slot.name, count, inventory, receiver.get_logistic_point(), receiver.position)
                        end
                    end
                end
            end
        end
    end
end

function register_providers()
    teleporting = true
    provider_list = {}
    
    for i = 1, #game.surfaces do
        local entities = game.surfaces[i].find_entities_filtered({type = "logistic-container"})
        
        for j = 1, #entities do
            if entities[j].valid and entities[j].prototype.name == provider_prototype then
                provider_list[#provider_list + 1] = entities[j]
            end
        end
    end
    
    teleporting = false
end

function register_receivers()
    receiver_list = {}
    
    for i = 1, #game.surfaces do
        local entities = game.surfaces[i].find_entities_filtered({type = "logistic-container"})
        
        for j = 1, #entities do
            if entities[j].valid and entities[j].prototype.name ~= provider_prototype and
              (entities[j].prototype.logistic_mode == "buffer" or entities[j].prototype.logistic_mode == "requester") then
                receiver_list[#receiver_list + 1] = entities[j]
            end
        end
    end
end

function transfer_items(provider_chests, item_name, item_count, target_inventory, target_logistic_pts, target_position)
    if target_logistic_pts then
        for i = 1, #target_logistic_pts do
            if target_logistic_pts[i].targeted_items_deliver and target_logistic_pts[i].targeted_items_deliver[item_name] then
                item_count = item_count - target_logistic_pts[i].targeted_items_deliver[item_name]
            end
        end
    end
    if item_count < 1 then return end
    
    local providers = {}
    if target_position then
        local index_by_dist = {}
        
        for i = 1, #provider_chests do
            local dist_sqrd = calc_distance_squared(provider_chests[i].position, target_position)
            
            if distance_maximum <= 0 or dist_sqrd < dist_max_squared then
                index_by_dist[#index_by_dist + 1] = {idx = i, dist = dist_sqrd}
            
                for j = #index_by_dist, 2, -1 do
                    if index_by_dist[j - 1].dist >= dist_sqrd then
                        index_by_dist[j] = index_by_dist[j - 1]
                        index_by_dist[j - 1] = {idx = i, dist = dist_sqrd}
                    else break end
                end
            end
        end
        
        for i = 1, #index_by_dist do
            providers[#providers + 1] = provider_chests[index_by_dist[i].idx]
        end
    else
        providers = provider_chests
    end    
    
    for i = 1, #providers do
        if item_count < 1 then break end
        
        local inventory = providers[i].get_inventory(defines.inventory.chest)
        local item_amts = inventory.get_contents()
            
        if item_amts[item_name] ~= nil and item_amts[item_name] >= 1 then
            local transfer_count = target_inventory.insert({name = item_name, count = math.min(item_count, item_amts[item_name])})
            
            if transfer_count then
                inventory.remove({name = item_name, count = transfer_count})
                
                item_count = item_count - transfer_count
            end
        end
    end
end

script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    
    if entity.prototype.name == provider_prototype then
        if provider_list == nil then
            register_providers()
        else
            provider_list[#provider_list + 1] = entity
        end
    elseif entity.type == "logistic-container" and (entity.prototype.logistic_mode == "buffer" or entity.prototype.logistic_mode == "requester") then
        if receiver_list == nil then
            register_receivers()
        else
            receiver_list[#receiver_list + 1] = entity
        end
    end
end)

script.on_nth_tick(settings.startup["teleport-provider-interval"].value, handle_requests)
