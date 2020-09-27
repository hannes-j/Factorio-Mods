if settings.startup["WaterSafety-enable-waterfill"].value then
    local tech = data.raw.technology["cliff-explosives"]
    
    tech.effects[#tech.effects + 1] = {
        type = "unlock-recipe",
        recipe = "WaterSafety-waterfill"
    }
end
