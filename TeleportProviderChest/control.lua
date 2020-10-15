local provider_prototype = "logistic-teleport-chest"


script.on_init(function()
    global.dist_max_squared = 0
    global.dist_pen_squared = 0
    global.distance_maximum = 0
    global.distance_penalty = 0
    global.provider_list = nil
    global.receiver_list = nil
    global.teleporting = false
end)

script.on_configuration_changed(function(configuration_changed_data)
    global.dist_max_squared = 0
    global.dist_pen_squared = 0
    global.distance_maximum = 0
    global.distance_penalty = 0
    global.provider_list = nil
    global.receiver_list = nil
    global.teleporting = false
end)


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
    if global.teleporting then return end
    global.teleporting = true
    
    global.distance_maximum = settings.global["teleport-provider-distance"].value
    global.dist_max_squared = global.distance_maximum^2 + 0.35
    
    global.distance_penalty = settings.global["teleport-provider-penalty"].value
    global.dist_pen_squared = global.distance_penalty^2 + 0.65
    
    if global.provider_list == nil then register_providers() end
    
    local providers = global.provider_list
    global.provider_list = {}
    for i = 1, #providers do
        if providers[i] and providers[i].valid then global.provider_list[#global.provider_list + 1] = providers[i] end
    end
    providers = global.provider_list
    
    local providers_by_force = {}
    for i = 1, #providers do
        if providers_by_force[providers[i].force.name] == nil then
            providers_by_force[providers[i].force.name] = {force = providers[i].force, entity_array = {}}
        end
        providers_by_force[providers[i].force.name].entity_array[#(providers_by_force[providers[i].force.name].entity_array) + 1] = providers[i]
    end
    
    handle_player_requests(providers_by_force)
    handle_storage_requests(providers_by_force)
    
    global.teleporting = false
end

function handle_player_requests(providers_by_force)
    for key, value in pairs(providers_by_force) do
        for i, player in pairs(value.force.players) do
            if player.character and player.character.valid and player.character_logistic_slot_count and player.character_personal_logistic_requests_enabled then
                local inventory = player.get_main_inventory()
                local item_amts = inventory.get_contents()
                
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
                            transfer_items(value.entity_array, slot.name, count, inventory, player.character.get_logistic_point(), player.character.position, player.character.surface)
                        end
                    end
                end
            end
        end
    end
end

function handle_storage_requests(providers_by_force)
    if global.receiver_list == nil then register_receivers() end
    
    local receivers = global.receiver_list
    global.receiver_list = {}
    for i = 1, #receivers do
        if receivers[i] and receivers[i].valid then global.receiver_list[#global.receiver_list + 1] = receivers[i] end
    end
    receivers = global.receiver_list
    
    local receivers_by_force = {}
    for i = 1, #receivers do
        if receivers_by_force[receivers[i].force.name] == nil then
            receivers_by_force[receivers[i].force.name] = {force = receivers[i].force, entity_array = {}}
        end
        receivers_by_force[receivers[i].force.name].entity_array[#(receivers_by_force[receivers[i].force.name].entity_array) + 1] = receivers[i]
    end
    
    for key, value in pairs(providers_by_force) do
        if not receivers_by_force[key] then
            receivers_by_force[key] = {force = providers_by_force[key].force, entity_array = {}}
        end
        
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
                            transfer_items(value.entity_array, slot.name, count, inventory, receiver.get_logistic_point(), receiver.position, receiver.surface)
                        end
                    end
                end
            end
        end
    end
end

function register_providers()
    global.provider_list = {}
    
    for _, surface in pairs(game.surfaces) do
        if surface then
            local entities = surface.find_entities_filtered({type = "logistic-container"})
            
            for i = 1, #entities do
                if entities[i].valid and entities[i].prototype.name == provider_prototype then
                    global.provider_list[#global.provider_list + 1] = entities[i]
                end
            end
        end
    end
end

function register_receivers()
    global.receiver_list = {}
    
    for _, surface in pairs(game.surfaces) do
        if surface then
            local entities = surface.find_entities_filtered({type = "logistic-container"})
            
            for i = 1, #entities do
                if entities[i].valid and entities[i].prototype.name ~= provider_prototype and
                  (entities[i].prototype.logistic_mode == "buffer" or entities[i].prototype.logistic_mode == "requester") then
                    global.receiver_list[#global.receiver_list + 1] = entities[i]
                end
            end
        end
    end
end

function transfer_items(provider_chests, item_name, item_count, target_inventory, target_logistic_pts, target_position, target_surface)
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
            
            if target_surface and target_surface.name ~= provider_chests[i].surface.name then
                dist_sqrd = dist_sqrd + global.dist_pen_squared
            end
            
            if global.distance_maximum <= 0 or dist_sqrd < global.dist_max_squared then
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
    
    local tmp_inv = game.create_inventory(1)
    
    for i = 1, #providers do
        if item_count < 1 then break end
        
        local src_inv = providers[i].get_inventory(defines.inventory.chest)
        local src_stk = src_inv.find_item_stack(item_name)
        local tmp_stk = nil
        
        while src_stk and item_count >= 1 and target_inventory.can_insert(src_stk) do
            if src_stk.count > item_count then
                tmp_inv[1].set_stack(src_stk)
                tmp_inv[1].count = item_count  -- changing count of stack resets some meta-values
                tmp_stk = tmp_inv[1]
                
                if src_stk.durability     then tmp_stk.durability = src_stk.durability end
                if src_stk.health         then tmp_stk.health     = src_stk.health     end
                if src_stk.type == "ammo" then tmp_stk.ammo       = src_stk.ammo       end
            else
                tmp_stk = src_stk
            end
            
            local trns_count = target_inventory.insert(tmp_stk)
            
            if trns_count >= 1 then
                item_count = item_count - trns_count
                src_stk.count = src_stk.count - trns_count
                
                if item_count >= 1 then src_stk = src_inv.find_item_stack(item_name) end
            else break end
        end
        
        tmp_inv.clear()
        src_inv.sort_and_merge()
    end
    
    tmp_inv.destroy()
end


script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built}, function(event)
    local entity = event.created_entity
    if not entity then entity = event.entity end
    if not entity then return end
    
    if entity.prototype.name == provider_prototype then
        if global.provider_list == nil then
            register_providers()
        else
            global.provider_list[#global.provider_list + 1] = entity
        end
    elseif entity.type == "logistic-container" and (entity.prototype.logistic_mode == "buffer" or entity.prototype.logistic_mode == "requester") then
        if global.receiver_list == nil then
            register_receivers()
        else
            global.receiver_list[#global.receiver_list + 1] = entity
        end
    end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
    if not string.find(event.setting, "teleport%-provider") then return end
    global.teleporting = true
    
    register_providers()
    register_receivers()
    
    global.teleporting = false
end)

script.on_nth_tick(settings.startup["teleport-provider-interval"].value, handle_requests)
