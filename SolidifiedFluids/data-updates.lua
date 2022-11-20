local main_name = "solidified-fluids"
local main_path = "__SolidifiedFluids__/"
local main_suffix_liquid = "--liquefied"
local main_suffix_solid = "--solidified"


for _, fluid in pairs(data.raw.fluid) do
    local item = table.deepcopy(data.raw.item["water-barrel"])
    item.name = fluid.name..main_suffix_solid
    item.icon = fluid.icon
    item.icons = fluid.icons
    if not item.icons then
        item.icons = {{icon = item.icon, icon_mipmaps = 4, icon_size = 64}}
    end
    table.insert(item.icons,
        {icon = main_path.."graphics/box-overlay_64.png",  icon_size = 64, scale = 0.75, tint = {a = 0.75, b = 1.00, g = 1.00, r = 1.00}})

    item.subgroup = main_name
    item.stack_size = item.stack_size * 10
    if settings.startup[main_name.."-stack"].value >= 1 then
        item.stack_size = settings.startup[main_name.."-stack"].value
    end
    item.localised_name = {"", {"item-name."..main_name}, " ", {"fluid-name."..fluid.name}}

    data:extend({ item })

    local recipe1 = table.deepcopy(data.raw.recipe["fill-water-barrel"])
    recipe1.name = fluid.name..main_suffix_solid
    recipe1.icon = fluid.icon
    recipe1.icons = fluid.icons
    if not recipe1.icons then
        recipe1.icons = {{icon = recipe1.icon, icon_mipmaps = 4,   icon_size = 64}}
    end
    table.insert(recipe1.icons,
        {icon = main_path.."graphics/compress-overlay-alt_64.png", icon_size = 64, scale = 0.70, tint = {a = 0.80, b = 0.85, g = 0.85, r = 0.80}})

    recipe1.show_amount_in_title = false
    recipe1.subgroup = main_name..main_suffix_solid
    recipe1.localised_name = {"", {"recipe-name.fluid"..main_suffix_solid}, " ", {"fluid-name."..fluid.name}}

    recipe1.category = "chemistry"
    recipe1.energy_required = 0.1
    recipe1.ingredients = {
        {type = "fluid", name = fluid.name, amount = 5}
    }
    recipe1.main_product = nil
    recipe1.result_count = 1
    recipe1.result = nil
    recipe1.results = {
        {type = "item", name = item.name, amount = 1}
    }
    recipe1.always_show_products = true
    recipe1.crafting_machine_tint =
    {
        primary =    {a = 0.65, b = 0.80, g = 0.80, r = 0.75},
        secondary =  {a = 0.65, b = 0.80, g = 0.80, r = 0.75},
        tertiary =   {a = 0.65, b = 0.80, g = 0.80, r = 0.75},
        quaternary = {a = 0.65, b = 0.80, g = 0.80, r = 0.75}
    }
    recipe1.hide_from_player_crafting = settings.startup[main_name.."-hide"].value

    local recipe2 = table.deepcopy(data.raw.recipe["empty-water-barrel"])
    recipe2.name = fluid.name..main_suffix_liquid
    recipe2.icon = fluid.icon
    recipe2.icons = fluid.icons
    if not recipe2.icons then
        recipe2.icons = {{icon = recipe2.icon, icon_mipmaps = 4,     icon_size = 64}}
    end
    table.insert(recipe2.icons,
        {icon = main_path.."graphics/decompress-overlay-alt_64.png", icon_size = 64, scale = 0.70, tint = {a = 0.80, b = 0.85, g = 0.85, r = 0.80}})

    recipe2.show_amount_in_title = false
    recipe2.subgroup = main_name..main_suffix_liquid
    recipe2.localised_name = {"", {"recipe-name.item"..main_suffix_liquid}, " ", {"fluid-name."..fluid.name}}

    recipe2.category = "chemistry"
    recipe2.energy_required = 0.1
    recipe2.ingredients = {
        {type = "item", name = item.name, amount = 1}
    }
    recipe2.main_product = nil
    recipe2.result_count = 1
    recipe2.result = nil
    recipe2.results = {
        {type = "fluid", name = fluid.name, amount = 5}
    }
    recipe2.always_show_products = true
    recipe2.crafting_machine_tint =
    {
        primary =    {a = 0.65, b = 0.80, g = 0.80, r = 0.75},
        secondary =  {a = 0.65, b = 0.80, g = 0.80, r = 0.75},
        tertiary =   {a = 0.65, b = 0.80, g = 0.80, r = 0.75},
        quaternary = {a = 0.65, b = 0.80, g = 0.80, r = 0.75}
    }
    recipe2.hide_from_player_crafting = settings.startup[main_name.."-hide"].value

    data:extend({ recipe1, recipe2 })
end


if settings.startup[main_name.."-adv"].value then
    local tech = data.raw.technology[main_name.."-adv"]

    local transformations = {
        {eng = 2.0, in_fld = "water",     in_amt = 10, out_rcp = "crude-oil"..main_suffix_solid,     out_amt = 1},
        {eng = 0.5, in_fld = "crude-oil", in_amt =  5, out_rcp = "heavy-oil"..main_suffix_solid,     out_amt = 1},
        {eng = 0.4, in_fld = "crude-oil", in_amt =  5, out_rcp = "light-oil"..main_suffix_solid,     out_amt = 1},
        {eng = 0.4, in_fld = "crude-oil", in_amt =  5, out_rcp = "petroleum-gas"..main_suffix_solid, out_amt = 1},
        {eng = 0.5, in_fld = "heavy-oil", in_amt =  5, out_rcp = "lubricant"..main_suffix_solid,     out_amt = 1}
    }
    for _, trans in ipairs(transformations) do
        local recipe = table.deepcopy(data.raw.recipe[trans.out_rcp])
        recipe.name = recipe.name.."-adv"
        table.insert(recipe.icons,
            {icon = data.raw.fluid[trans.in_fld].icon, icon_mipmaps = 4, icon_size = 64,
             scale = 0.25, shift = {0, -10}, tint = {a = 1.00, b = 0.95, g = 0.95, r = 0.95}})

        recipe.subgroup = main_name..main_suffix_solid.."-adv"
        recipe.localised_name = {"", {"recipe-name.fluid"..main_suffix_solid.."-to"}, " ", {"fluid-name."..recipe.ingredients[1].name}}

        recipe.energy_required = trans.eng
        recipe.ingredients[1].name = trans.in_fld
        recipe.ingredients[1].amount = trans.in_amt
        recipe.results[1].amount = trans.out_amt

        data:extend({ recipe })
        table.insert(tech.effects, {type = "unlock-recipe", recipe = recipe.name})
    end
end
