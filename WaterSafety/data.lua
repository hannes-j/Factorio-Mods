local water_list = {
    "deepwater",
    "deepwater-green",
    "water",
    "water-green"
}

local template = data.raw.tile["water-shallow"]

for _, tile_name in pairs(water_list) do
    local tile = table.deepcopy(data.raw.tile[tile_name])
    tile.name = tile_name.."-tmp"
    tile.localised_name = "__TILE__"..tile_name.."__"
    
    tile.collision_mask = template.collision_mask
    tile.layer = template.layer
    
    tile.walking_speed_modifier = template.walking_speed_modifier * 5.00 / 8.00
    
    data:extend({ tile })
end

if settings.startup["WaterSafety-enable-waterfill"].value then
    local item = table.deepcopy(data.raw.item["landfill"])
    item.name = "WaterSafety-waterfill"
    item.order = "c[waterfill]"
    item.place_as_tile = {
        result = "water",
        condition_size = 1,
        condition = {}
    }
    item.icons = {{icon = "__base__/graphics/icons/cliff-explosives.png", tint = {a = 0.90, b = 1.00, g = 0.35, r = 0.25}}}
    
    local recipe = table.deepcopy(data.raw.recipe["landfill"])
    recipe.name = item.name
    recipe.result = item.name
    recipe.ingredients = {
        {"water-barrel", 5},
        {"cliff-explosives", 1}
    }
    
    data:extend({ item, recipe })
end
