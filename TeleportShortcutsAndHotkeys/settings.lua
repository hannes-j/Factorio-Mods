data:extend({
	{
        type = "int-setting",
        name = "teleport-distance-large",
        setting_type = "runtime-per-user",
		minimum_value = 20,
		maximum_value = 100,
        default_value = 100,
		order = "tele-s2"
    },
    {
        type = "int-setting",
        name = "teleport-distance-short",
        setting_type = "runtime-per-user",
		minimum_value = 1,
		maximum_value = 10,
        default_value = 10,
		order = "tele-s1"
    }
})
