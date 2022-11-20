local main_name = "solidified-fluids"
local main_path = "__SolidifiedFluids__/"
local main_suffix_liquid = "--liquefied"
local main_suffix_solid = "--solidified"


for _, fluid in pairs(data.raw.fluid) do
    if not data.raw.recipe["empty-"..fluid.name.."-barrel"] then goto fluid_continue end

    local tech = data.raw.technology[main_name]
    table.insert(tech.effects, {type = "unlock-recipe", recipe = fluid.name..main_suffix_solid})
    table.insert(tech.effects, {type = "unlock-recipe", recipe = fluid.name..main_suffix_liquid})

    ::fluid_continue::
end


if settings.startup[main_name.."-alt"].value then
    for _, recipe in pairs(data.raw.recipe) do
        local has_fluid = false

        if string.find(recipe.name, main_suffix_solid) then goto recipe_continue end
        if string.find(recipe.name, main_suffix_liquid) then goto recipe_continue end

        if recipe.ingredients then
            for _, ingredient in ipairs(recipe.ingredients) do
                if ingredient.type and ingredient.type == "fluid" then has_fluid = true end
            end
        end

        if recipe.normal and recipe.normal.ingredients then
            for _, ingredient in ipairs(recipe.normal.ingredients) do
                if ingredient.type and ingredient.type == "fluid" then has_fluid = true end
            end
        end

        if recipe.expensive and recipe.expensive.ingredients then
            for _, ingredient in ipairs(recipe.expensive.ingredients) do
                if ingredient.type and ingredient.type == "fluid" then has_fluid = true end
            end
        end

        if not has_fluid then goto recipe_continue end

        local recipe_alt = table.deepcopy(recipe)
        recipe_alt.name = recipe.name.."--"..main_name

        if not recipe.localised_name then
            if recipe.expensive and recipe.expensive.results then
                if #recipe.expensive.results > 1 then
                    if not recipe.expensive.main_product or recipe.expensive.main_product == "" then
                        recipe_alt.localised_name = {"", {"recipe-name."..recipe.name}}
                    end
                else
                    local res_name  = ""
                    local prototype = nil

                    if recipe.expensive.results[1]["type"] then
                        res_name  = recipe.expensive.results[1]["name"]
                        prototype = data.raw[recipe.expensive.results[1]["type"]][res_name]
                    else
                        res_name  = recipe.expensive.results[1][1]
                        prototype = data.raw.item[res_name]
                    end

                    if res_name and not prototype then
                        for key, prototypes in pairs(data.raw) do
                            if key ~= "recipe" and key ~= "technology" and prototypes[res_name] then
                                prototype = prototypes[res_name]
                            end
                        end
                    end

                    if prototype and prototype.localised_name then
                        recipe_alt.localised_name = prototype.localised_name
                    elseif res_name and res_name ~= "" then
                        recipe_alt.expensive.main_product = res_name

                        if recipe.normal and recipe.normal.results then recipe_alt.normal.main_product = res_name end
                        if recipe.results                          then recipe_alt.main_product        = res_name end
                    end
                end
            elseif recipe.results then
                if #recipe.results > 1 then
                    if not recipe.main_product or recipe.main_product == "" then
                        recipe_alt.localised_name = {"", {"recipe-name."..recipe.name}}
                    end
                else
                    local res_name  = ""
                    local prototype = nil

                    if recipe.results[1]["type"] then
                        res_name  = recipe.results[1]["name"]
                        prototype = data.raw[recipe.results[1]["type"]][res_name]
                    else
                        res_name  = recipe.results[1][1]
                        prototype = data.raw.item[res_name]
                    end

                    if res_name and not prototype then
                        for key, prototypes in pairs(data.raw) do
                            if key ~= "recipe" and key ~= "technology" and prototypes[res_name] then
                                prototype = prototypes[res_name]
                            end
                        end
                    end

                    if prototype and prototype.localised_name then
                        recipe_alt.localised_name = prototype.localised_name
                    elseif res_name and res_name ~= "" then
                        recipe_alt.main_product = res_name
                    end
                end
            end
        end

        local amt_fac = 0.20

        if recipe_alt.ingredients then
            for _, ingredient in ipairs(recipe_alt.ingredients) do
                if ingredient.type and ingredient.type == "fluid" then
                    if not data.raw.recipe["empty-"..ingredient.name.."-barrel"] then recipe_alt.hidden = true end

                    ingredient.type = "item"
                    ingredient.name = ingredient.name..main_suffix_solid
                    ingredient.amount = math.ceil(ingredient.amount * amt_fac)
                end
            end

            recipe_alt.allow_intermediates = true
            recipe_alt.allow_as_intermediate = true

            recipe_alt.hide_from_player_crafting = settings.startup[main_name.."-hide"].value
            if settings.startup[main_name.."-alt-ex"].value then
                recipe_alt.hide_from_player_crafting = false

                if not recipe_alt.hidden then recipe.hide_from_player_crafting = true end
            end

            has_fluid = false
            if recipe_alt.results then
                for _, result in ipairs(recipe_alt.results) do
                    if result.type and result.type == "fluid" then has_fluid = true end
                end
            end
            if recipe_alt.category == "crafting-with-fluid" and not has_fluid then recipe_alt.category = "crafting" end
        end

        if recipe_alt.normal and recipe_alt.normal.ingredients then
            for _, ingredient in ipairs(recipe_alt.normal.ingredients) do
                if ingredient.type and ingredient.type == "fluid" then
                    if not data.raw.recipe["empty-"..ingredient.name.."-barrel"] then recipe_alt.normal.hidden = true end

                    ingredient.type = "item"
                    ingredient.name = ingredient.name..main_suffix_solid
                    ingredient.amount = math.ceil(ingredient.amount * amt_fac)
                end
            end

            recipe_alt.normal.allow_intermediates = true
            recipe_alt.normal.allow_as_intermediate = true

            recipe_alt.normal.hide_from_player_crafting = settings.startup[main_name.."-hide"].value
            if settings.startup[main_name.."-alt-ex"].value then
                recipe_alt.normal.hide_from_player_crafting = false

                if not recipe_alt.normal.hidden then recipe.normal.hide_from_player_crafting = true end
            end

            has_fluid = false
            if recipe_alt.normal.results then
                for _, result in ipairs(recipe_alt.normal.results) do
                    if result.type and result.type == "fluid" then has_fluid = true end
                end
            end
            if recipe_alt.category == "crafting-with-fluid" and not has_fluid then recipe_alt.category = "crafting" end
        end

        if recipe_alt.expensive and recipe_alt.expensive.ingredients then
            for _, ingredient in ipairs(recipe_alt.expensive.ingredients) do
                if ingredient.type and ingredient.type == "fluid" then
                    if not data.raw.recipe["empty-"..ingredient.name.."-barrel"] then recipe_alt.expensive.hidden = true end

                    ingredient.type = "item"
                    ingredient.name = ingredient.name..main_suffix_solid
                    ingredient.amount = math.ceil(ingredient.amount * amt_fac)
                end
            end

            recipe_alt.expensive.allow_intermediates = true
            recipe_alt.expensive.allow_as_intermediate = true

            recipe_alt.expensive.hide_from_player_crafting = settings.startup[main_name.."-hide"].value
            if settings.startup[main_name.."-alt-ex"].value then
                recipe_alt.expensive.hide_from_player_crafting = false

                if not recipe_alt.expensive.hidden then recipe.expensive.hide_from_player_crafting = true end
            end

            has_fluid = false
            if recipe_alt.expensive.results then
                for _, result in ipairs(recipe_alt.expensive.results) do
                    if result.type and result.type == "fluid" then has_fluid = true end
                end
            end
            if recipe_alt.category == "crafting-with-fluid" and not has_fluid then recipe_alt.category = "crafting" end
        end

        if not recipe_alt.icon and not recipe_alt.icons then
            local res_name = ""
            if     recipe_alt.main_product then res_name = recipe_alt.main_product
            elseif recipe_alt.results      then res_name = recipe_alt.results[1].name
            elseif recipe_alt.result       then res_name = recipe_alt.result end

            if recipe_alt.expensive then
                if     recipe_alt.expensive.main_product then res_name = recipe_alt.expensive.main_product
                elseif recipe_alt.expensive.results      then res_name = recipe_alt.expensive.results[1].name
                elseif recipe_alt.expensive.result       then res_name = recipe_alt.expensive.result end
            end

            for key, prototypes in pairs(data.raw) do
                if key ~= "recipe" and key ~= "technology" and prototypes[res_name] then
                    if prototypes[res_name].icon         then recipe_alt.icon          = prototypes[res_name].icon         end
                    if prototypes[res_name].icon_mipmaps then recipe_alt.icon_mipmaps  = prototypes[res_name].icon_mipmaps end
                    if prototypes[res_name].icon_size    then recipe_alt.icon_size     = prototypes[res_name].icon_size    end
                    if prototypes[res_name].icons        then recipe_alt.icons         = prototypes[res_name].icons        end
                end
            end

            if recipe_alt.icons then
                for _, layer in ipairs(recipe_alt.icons) do
                    if not layer.icon_mipmaps then layer.icon_mipmaps = recipe_alt.icon_mipmaps or 4  end
                    if not layer.icon_size    then layer.icon_size    = recipe_alt.icon_size    or 64 end
                end
            end
        end
        if not recipe_alt.icons then
            recipe_alt.icons = {{icon = recipe_alt.icon, icon_mipmaps = recipe_alt.icon_mipmaps or 4, icon_size = recipe_alt.icon_size or 64}}
        end
        table.insert(recipe_alt.icons,
            {icon = main_path.."graphics/box-overlay_64.png",           icon_size = 64,
             scale = 0.30, shift = {0, -8}, tint = {a = 0.96, b = 0.93, g = 0.96, r = 0.90}})
        table.insert(recipe_alt.icons,
            {icon = main_path.."graphics/compress-overlay-alt_64.png",  icon_size = 64,
             scale = 0.25, shift = {0, -8}, tint = {a = 0.96, b = 0.93, g = 0.96, r = 0.90}})

        data:extend({ recipe_alt })
        ::recipe_continue::
    end
end
