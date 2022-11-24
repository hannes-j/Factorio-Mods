local main_name = "solidified-fluids"
local main_path = "__SolidifiedFluids__/"
local main_suffix_liquid = "--liquefied"
local main_suffix_solid = "--solidified"


function validate_recipes_for_techs()
    for _, force in pairs(game.forces) do
        if force and force.technologies then
            for _, tech in pairs(force.technologies) do validate_recipes_for_tech(tech) end
        end
    end
end

function validate_recipes_for_tech(tech)
    if tech.force and tech.force.technologies[main_name] then
        local is_active = tech.researched and tech.force.technologies[main_name].researched

        for _, effect in ipairs(tech.effects) do
            if effect.type == "unlock-recipe" and tech.force.recipes[effect.recipe.."--"..main_name] then
                tech.force.recipes[effect.recipe.."--"..main_name].enabled = is_active
            end
            if effect.type == "unlock-recipe" and tech.force.recipes[effect.recipe..main_suffix_liquid] then
                tech.force.recipes[effect.recipe..main_suffix_liquid].enabled = is_active
            end
            if effect.type == "unlock-recipe" and tech.force.recipes[effect.recipe..main_suffix_solid] then
                tech.force.recipes[effect.recipe..main_suffix_solid].enabled = is_active
            end
        end
    end
end


script.on_init(function()
    validate_recipes_for_techs()
end)

script.on_configuration_changed(function(configuration_changed_data)
    validate_recipes_for_techs()
end)

script.on_event({defines.events.on_research_finished, defines.events.on_research_reversed}, function(event)
    local tech = event.research

    if tech.name == main_name then validate_recipes_for_techs()
    else validate_recipes_for_tech(tech) end
end)

script.on_event({defines.events.on_technology_effects_reset}, function(event)
    validate_recipes_for_techs()
end)
