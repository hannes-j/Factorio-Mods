script.on_init(function()
	global.next_teleport = {}
end)

script.on_configuration_changed(function(configuration_changed_data)
	if not global.next_teleport then
		global.next_teleport = {}
	end
end)

local teleport_btn = {type="button",    name="teleport-tag-gui-btn", caption={"mod-interface.teleport-button"}}
local teleport_txt = {type="textfield", name="teleport-tag-gui-txt", clear_and_focus_on_right_click=true, text="{tag-name}"}
local teleport_win = {type="frame",     name="teleport-tag-gui",     caption={"mod-interface.teleport-caption"}}

function directed_teleport(player_idx, direction, distance)
    local player = game.players[player_idx]
    
    if direction ~= nil or
	  (player.riding_state ~= nil and player.riding_state.acceleration == defines.riding.acceleration.accelerating) or
	  (player.walking_state ~= nil and player.walking_state.walking == true) then
		
		if direction == nil then
			if player.riding_state and player.vehicle and player.vehicle.valid then
				direction = player.riding_state.direction
				
				if direction == defines.riding.direction.straight then
					local dir = player.vehicle.orientation * 360.0
					
					if dir < 0 then
						direction = nil
						-- 0.0°
					elseif dir <= 22.5 then
						direction = defines.direction.north
						-- 22.5°
					elseif dir <= 67.5 then
						direction = defines.direction.northeast
						-- 67.5°
					elseif dir <= 112.5 then
						direction = defines.direction.east
						-- 112.5°
					elseif dir <= 157.5 then
						direction = defines.direction.southeast
						-- 157.5°
					elseif dir <= 202.5 then
						direction = defines.direction.south
						-- 202.5°
					elseif dir <= 247.5 then
						direction = defines.direction.southwest
						-- 247.5°
					elseif dir <= 292.5 then
						direction = defines.direction.west
						-- 292.5°
					elseif dir <= 337.5 then
						direction = defines.direction.northwest
						-- 337.5°
					elseif dir <= 360.0 then
						direction = defines.direction.north
						-- 360.0°
					else
						direction = nil
					end
				elseif direction == defines.riding.direction.right then
					direction = defines.direction.east
				elseif direction == defines.riding.direction.left then
					direction = defines.direction.west
				end
			else
				direction = player.walking_state.direction
			end
		end
		
		local pos_x = player.position.x
		local pos_y = player.position.y
		
		if direction == nil or distance <= 0 then
			equip_teleport_tool(player_idx)
		elseif direction == defines.direction.north then
			pos_y = pos_y - distance
		elseif direction == defines.direction.northeast then
			pos_x = pos_x + distance/2
			pos_y = pos_y - distance/2
		elseif direction == defines.direction.east then
			pos_x = pos_x + distance
		elseif direction == defines.direction.southeast then
			pos_x = pos_x + distance/2
			pos_y = pos_y + distance/2
		elseif direction == defines.direction.south then
			pos_y = pos_y + distance
		elseif direction == defines.direction.southwest then
			pos_x = pos_x - distance/2
			pos_y = pos_y + distance/2
		elseif direction == defines.direction.west then
			pos_x = pos_x - distance
		elseif direction == defines.direction.northwest then
			pos_x = pos_x - distance/2
			pos_y = pos_y - distance/2
		end
		
		if player.vehicle and player.vehicle.valid then
			player.vehicle.teleport({pos_x, pos_y})
        else
			player.teleport({pos_x, pos_y})
		end
    end
end

function named_teleport(player_idx, tag_name)
    if tag_name ~= nil and tag_name ~= "" then
		local player = game.players[player_idx]
		
		local surface = player.surface
		local tags = player.force.find_chart_tags(surface)
		
		for i = 1, #tags do
			if string.lower(tags[i].text) == string.lower(tag_name) then
				local position = tags[i].surface.find_non_colliding_position("character", tags[i].position, 20, 2)
				if not position then
					position=tags[i].position
				end
				
				if player.vehicle and player.vehicle.valid then
					player.vehicle.teleport(position)
				else
					player.teleport(position)
				end
				
				break
			end
		end
    end
end

function equip_teleport_tool(player_idx)
    local player = game.players[player_idx]
    
    if player.clean_cursor() then
		player.cursor_stack.set_stack("teleport-destination-blueprint")
	
		if player.game_view_settings.show_entity_info then
			player.cursor_stack.set_blueprint_entities({
				{entity_number = 1, name = "teleport-destination-any", position = {x=0, y=0}}
			})
		else
			player.cursor_stack.set_blueprint_entities({
				{entity_number = 1, name = "teleport-destination", position = {x=0, y=0}}
			})
		end
    end
end

script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "teleport-tag-gui-btn" then
		local input_window = game.players[event.player_index].gui.center["teleport-tag-gui"]
        named_teleport(event.player_index, input_window["teleport-tag-gui-txt"].text)
		input_window.visible=false
		input_window.enabled=false
    end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "teleport-shortcut" then
        equip_teleport_tool(event.player_index)
    end
end)

script.on_event("teleport-bp", function(event)
	equip_teleport_tool(event.player_index)
end)

script.on_event("teleport-dir-down", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-short"].value
	directed_teleport(event.player_index, defines.direction.south, distance)
end)

script.on_event("teleport-dir-down-plus", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-large"].value
	directed_teleport(event.player_index, defines.direction.south, distance)
end)

script.on_event("teleport-dir-left", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-short"].value
	directed_teleport(event.player_index, defines.direction.west, distance)
end)

script.on_event("teleport-dir-left-plus", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-large"].value
	directed_teleport(event.player_index, defines.direction.west, distance)
end)

script.on_event("teleport-dir-right", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-short"].value
	directed_teleport(event.player_index, defines.direction.east, distance)
end)

script.on_event("teleport-dir-right-plus", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-large"].value
	directed_teleport(event.player_index, defines.direction.east, distance)
end)

script.on_event("teleport-dir-up", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-short"].value
	directed_teleport(event.player_index, defines.direction.north, distance)
end)

script.on_event("teleport-dir-up-plus", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-large"].value
	directed_teleport(event.player_index, defines.direction.north, distance)
end)

script.on_event("teleport-move", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-short"].value
	directed_teleport(event.player_index, nil, distance)
end)

script.on_event("teleport-move-plus", function(event)
	local distance = settings.get_player_settings(game.players[event.player_index])["teleport-distance-large"].value
	directed_teleport(event.player_index, nil, distance)
end)

script.on_event("teleport-tag", function(event)
	local gui = game.players[event.player_index].gui
	
	if not gui.center["teleport-tag-gui"] then
		local frame = gui.center.add(teleport_win)
		frame.add(teleport_txt)
		frame.add(teleport_btn)
	end
	
	local input_window = gui.center["teleport-tag-gui"]
	input_window.visible=true
	input_window.enabled=true
	input_window.focus()
end)

script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    local player = game.players[event.player_index]

    if entity.name ~= "entity-ghost" then return end
    
    if entity.ghost_name == "teleport-destination-any" then
		if not player.game_view_settings.show_entity_info then
			equip_teleport_tool(event.player_index)
		end
    elseif entity.ghost_name == "teleport-destination" then
		if player.game_view_settings.show_entity_info then
			equip_teleport_tool(event.player_index)
		end
    else return end
    
    local position = entity.position
  --local surface = entity.surface
    entity.destroy()
    
    local nt = global.next_teleport[event.player_index]
    if not nt or nt < event.tick then
        global.next_teleport[event.player_index] = event.tick + 10
		
        if player.vehicle and player.vehicle.valid then
			player.vehicle.teleport(position)
        else
			player.teleport(position)
		end
    end
end)
