data:extend({
    {
        type = "int-setting",
        name = "teleport-provider-interval",
        setting_type = "startup",
        minimum_value = 30,
        maximum_value = 600,
        default_value = 120,
        order = "tele-prvdr-itrvl"
    },
    
    {
        type = "int-setting",
        name = "teleport-provider-distance",
        setting_type = "runtime-global",
        minimum_value = 0,
        maximum_value = 50000,
        default_value = 50,
        order = "tele-prvdr-dstnc"
    },
    {
        type = "int-setting",
        name = "teleport-provider-penalty",
        setting_type = "runtime-global",
        minimum_value = 0,
        maximum_value = 50000,
        default_value = 50,
        order = "tele-prvdr-pnlty"
    }
})
