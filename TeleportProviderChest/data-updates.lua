local tech = data.raw.technology["logistic-system"]
tech.effects[#tech.effects + 1] = {
    type = "unlock-recipe",
    recipe = "logistic-teleport-chest"
}
