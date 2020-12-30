local name = "logistic-teleport-chest"
local tint = {a = 1.00, b = 0.65, g = 0.50, r = 0.35}

local entity = table.deepcopy(data.raw["logistic-container"]["logistic-chest-buffer"])
entity.name = name
entity.minable.result = name
entity.render_not_in_network_icon = false
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
    {"logistic-chest-buffer", 1},
    {"radar", 1}
}
if settings.startup["teleport-provider-recipe-bat"].value >= 1 then
    recipe.ingredients[#recipe.ingredients + 1] = {"battery", settings.startup["teleport-provider-recipe-bat"].value}
end
if settings.startup["teleport-provider-recipe-pu"].value >= 1 then
    recipe.ingredients[#recipe.ingredients + 1] = {"processing-unit", settings.startup["teleport-provider-recipe-pu"].value}
end

data:extend({ entity, item, recipe })
