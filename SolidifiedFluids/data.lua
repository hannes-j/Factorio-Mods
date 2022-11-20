local main_name = "solidified-fluids"
local main_path = "__SolidifiedFluids__/"
local main_suffix_liquid = "--liquefied"
local main_suffix_solid = "--solidified"


local subgroup = table.deepcopy(data.raw["item-subgroup"]["barrel"])
subgroup.name = main_name
subgroup.order = "czz-d"

local subgroup1 = table.deepcopy(data.raw["item-subgroup"]["fill-barrel"])
subgroup1.name = main_name..main_suffix_solid
subgroup1.order = "dzz-e"

local subgroup1x = table.deepcopy(data.raw["item-subgroup"]["fill-barrel"])
subgroup1x.name = main_name..main_suffix_solid.."-adv"
subgroup1x.order = "dzz-x-e"

local subgroup2 = table.deepcopy(data.raw["item-subgroup"]["empty-barrel"])
subgroup2.name = main_name..main_suffix_liquid
subgroup2.order = "ezz-f"

data:extend({ subgroup, subgroup1, subgroup1x, subgroup2 })


local tech = table.deepcopy(data.raw.technology["coal-liquefaction"])
tech.name = main_name
tech.icon = data.raw.technology["lubricant"].icon
tech.icons = data.raw.technology["lubricant"].icons
if not tech.icons then
    tech.icons = {{icon = tech.icon, icon_mipmaps = 4, icon_size = 256,               tint = {a = 1.00, b = 0.75, g = 0.70, r = 0.80}}}
end
table.insert(tech.icons,
    {icon = main_path.."graphics/box-overlay_256.png", icon_size = 256, scale = 1.25, tint = {a = 0.75, b = 1.00, g = 1.00, r = 1.00}})

tech.prerequisites = {"coal-liquefaction", "utility-science-pack"}
tech.unit = {
    count = tech.unit.count * 2.0,
    ingredients =
    {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
    },
    time = tech.unit.time
}
tech.effects = {}

data:extend({ tech })


if settings.startup[main_name.."-tech"].value then
    local tech = data.raw.technology[main_name]
    tech.prerequisites = {"oil-processing"}
    tech.unit.count = tech.unit.count * 0.5
    tech.unit.ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
    }
end


if settings.startup[main_name.."-adv"].value then
    local tech = table.deepcopy(data.raw.technology[main_name])
    tech.name = main_name.."-adv"
    tech.prerequisites = {main_name}
    tech.unit.count = tech.unit.count * 1.5

    data:extend({ tech })
end
