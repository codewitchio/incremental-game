## A tool for changing the game's color palette, including texture modulation and control nodes.
# I don't like this having to exist as a node, but it will need references to things inside the game.. 
class_name PaletteManager
extends Node

const PALETTE: Dictionary = {
    "white": Color("#eeeeee"),
    "black": Color("#0b0b0b"),
    "blue": Color("#0100ff"),
    "red": Color("#b0002c"),
    "yellow": Color("#feff00")
}

# Default two colours
var COLOR_BACKGROUND = PALETTE["black"]
var COLOR_FOREGROUND = PALETTE["white"]

var color_overlay_material: Material = preload("res://systems/color_overlay_material.tres")

func _ready() -> void:
    reset_palette()

    LimboConsole.register_command(reset_palette, "reset_palette", "Reset the palette to the default colors")
    LimboConsole.register_command(set_palette, "set_palette", "Set the palette to the specified colors")
    LimboConsole.add_argument_autocomplete_source("set_palette", 1, func(): return PALETTE.keys())

func reset_palette() -> void:
    COLOR_BACKGROUND = PALETTE["black"]
    COLOR_FOREGROUND = PALETTE["white"]
    _update_shader_material()

func set_palette(color_1: String, color_2: String) -> void:
    COLOR_BACKGROUND = PALETTE[color_1]
    COLOR_FOREGROUND = PALETTE[color_2]
    _update_shader_material()


func _update_shader_material() -> void:
    color_overlay_material.set_shader_parameter("background_color", COLOR_BACKGROUND)
    color_overlay_material.set_shader_parameter("foreground_color", COLOR_FOREGROUND)

