local name = "logistic-teleport-chest"
local tint = {a = 1.00, b = 0.65, g = 0.50, r = 0.35}

local entity = table.deepcopy(data.raw["logistic-container"]["logistic-chest-buffer"])
entity.name = name
entity.minable.result = name
entity.animation.layers[1]["tint"] = tint
entity.animation.layers[1].hr_version["tint"] = tint

local item = table.deepcopy(data.raw.item["logistic-chest-buffer"])
item.name = name
item.place_result = name
item.order = "b[x-storage]-d["..name.."]"
item.icons = {{icon = item.icon, tint = tint}}

local recipe = table.deepcopy(data.raw.recipe["logistic-chest-buffer"])
recipe.name = name
recipe.result = name
recipe.ingredients = {
    {"processing-unit", 100},
    {"logistic-chest-buffer", 1}
}

data:extend({ entity, item, recipe })
