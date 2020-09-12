local mod_path = "__TeleportShortcutsAndHotkeys__/"

local chr = data.raw.character.character

data:extend({
    {
        type = "blueprint",
        name = "teleport-destination-blueprint",
        icon = mod_path.."teleport_shortcut_icon.png",
        icon_size = 64,
        flags = { "hidden", "not-stackable", "only-in-cursor" },
        stack_size = 1,
        selection_color = {0, 1, 0},
        alt_selection_color = {0, 1, 0},
        selection_mode = { "blueprint" },
        alt_selection_mode = { "blueprint" },
        selection_cursor_box_type = "logistics",
        alt_selection_cursor_box_type = "logistics"
    },
    {
        type = "item",
        name = "teleport-destination",
        icon = mod_path.."teleport_shortcut_icon.png",
        icon_size = 64,
        order = "tele-i1",
		flags = { "hidden" },
        place_result = "teleport-destination",
        stack_size = 1
    },
	{
        type = "item",
        name = "teleport-destination-any",
        icon = mod_path.."teleport_shortcut_icon.png",
        icon_size = 64,
		order = "tele-i2",
		flags = { "hidden" },
        place_result = "teleport-destination-any",
        stack_size = 1
    },
	{
        type = "simple-entity-with-owner",
        name = "teleport-destination",
        icon = mod_path.."teleport_shortcut_icon.png",
        icon_size = 64,
        flags = { "hidden", "not-on-map", "placeable-off-grid", "placeable-player", "player-creation" },
        collision_mask = { "player-layer" },
        collision_box = util.table.deepcopy(chr.collision_box),
        selection_box = util.table.deepcopy(chr.selection_box),
        placeable_by = { item = "teleport-destination", count = 1 },
        picture = util.table.deepcopy(chr.animations[1].idle)
    },
	{
        type = "simple-entity-with-owner",
        name = "teleport-destination-any",
        icon = mod_path.."teleport_shortcut_icon.png",
        icon_size = 64,
        flags = { "hidden", "not-on-map", "placeable-off-grid", "placeable-player", "player-creation" },
        collision_mask = { },
        collision_box = util.table.deepcopy(chr.collision_box),
        selection_box = util.table.deepcopy(chr.selection_box),
        placeable_by = { item = "teleport-destination", count = 1 },
        picture = util.table.deepcopy(chr.animations[1].idle)
    },
    {
        type = "shortcut",
        name = "teleport-shortcut",
        order = "tele-sc",
        action = "lua",
        toggleable = false,
        icon =
        {
            filename = mod_path.."teleport_shortcut_icon.png",
            priority = "extra-high-no-scale",
            size = 64,
            scale = 0.5,
            flags = { "gui-icon" }
        },
    },
    {
        type = "custom-input",
        name = "teleport-bp",
		order = "tele-ip-bp",
        key_sequence = "CONTROL + SHIFT + T",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-dir-down",
		order = "tele-ip-d1-2",
        key_sequence = "SHIFT + S",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-dir-down-plus",
		order = "tele-ip-d2-2",
        key_sequence = "CONTROL + S",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-dir-left",
		order = "tele-ip-d1-3",
        key_sequence = "SHIFT + A",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-dir-left-plus",
		order = "tele-ip-d2-3",
        key_sequence = "CONTROL + A",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-dir-right",
		order = "tele-ip-d1-4",
        key_sequence = "SHIFT + D",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-dir-right-plus",
		order = "tele-ip-d2-4",
        key_sequence = "CONTROL + D",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-dir-up",
		order = "tele-ip-d1-1",
        key_sequence = "SHIFT + W",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-dir-up-plus",
		order = "tele-ip-d2-1",
        key_sequence = "CONTROL + W",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-move",
		order = "tele-ip-m1",
        key_sequence = "LSHIFT",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-move-plus",
		order = "tele-ip-m2",
        key_sequence = "LCTRL",
		consuming = "none"
    },
	{
        type = "custom-input",
        name = "teleport-tag",
		order = "tele-ip-t",
        key_sequence = "CONTROL + SHIFT + ALT + T",
		consuming = "none"
    }
})
