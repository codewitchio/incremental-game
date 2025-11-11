
# Autoloaded as PaletteManager
# class_name PaletteManager
extends Node

# If you change these, also change LevelData.gd
const PALETTE: Dictionary = {
	"white": Color("#eeeeee"),
	"black": Color("#0b0b0b"),
	"blue": Color("#0100ff"),
	"red": Color("#b0002c"),
	"yellow": Color("#feff00")
}

# Default two colours
const DEFAULT_BACKGROUND = PALETTE["black"]
const DEFAULT_FOREGROUND = PALETTE["white"]

const color_overlay_material: Material = preload("res://systems/palette/color_overlay_material.tres")

func _ready() -> void:
	reset_palette()

	LimboConsole.register_command(reset_palette, "reset_palette", "Reset the palette to the default colors")
	LimboConsole.register_command(set_palette, "set_palette", "Set the palette to the specified colors")
	LimboConsole.add_argument_autocomplete_source("set_palette", 1, func(): return PALETTE.keys())

func reset_palette() -> void:
	_update_shader_material(DEFAULT_BACKGROUND, DEFAULT_FOREGROUND)

func set_palette(color_1: String, color_2: String) -> void:
	_update_shader_material(PALETTE[color_1], PALETTE[color_2])

func set_palette_from_level(level: LevelData) -> void:
	_update_shader_material(PALETTE[level.background_color], PALETTE[level.foreground_color])

func _update_shader_material(background_color: Color, foreground_color: Color) -> void:
	color_overlay_material.set_shader_parameter("background_color", background_color)
	color_overlay_material.set_shader_parameter("foreground_color", foreground_color)
