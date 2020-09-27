local water_list = {
    "deepwater",
    "deepwater-green",
    "water",
    "water-green"
}

for _, item in pairs(data.raw.item) do
    if item and item["place_as_tile"] then
        for _, water_name in pairs(water_list) do
            if item.place_as_tile.result == water_name then
                item.place_as_tile.result = water_name.."-tmp"
                
                if not item.place_as_tile["condition"] then item.place_as_tile["condition"] = {} end
                table.insert(item.place_as_tile.condition, "player-layer")
            end
        end
    end
end
