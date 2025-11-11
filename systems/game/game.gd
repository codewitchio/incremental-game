class_name Game
extends Node2D

@export var levels: Array[LevelData] = []

## Level duration in seconds.
@export var level_duration: float = 10.0 

# var current_level: LevelData = null
var current_level_index: int = 0

# TODO: Just subscribe to regular state events instead. We want to disable the timer on round ending, reset colours on round starting, and start the timer on PlayingRound
var state_enabler: StateEnabler = StateEnabler.new(self, [GameState.PlayingRound])
var _is_enabled: bool = false

var level_timer: Timer

func _ready() -> void:
	PostHog.capture("game_started")

	level_timer = Timer.new()
	level_timer.one_shot = true
	level_timer.wait_time = level_duration
	level_timer.timeout.connect(_next_level)
	add_child(level_timer)

func enable() -> void:
	if _is_enabled:
		return

	_is_enabled = true
	Loggie.msg("Enabled").preset("Enabled").debug()
	current_level_index = 0
	Save.current_level = levels[current_level_index]
	level_timer.start()
	PaletteManager.set_palette_from_level(Save.current_level)


func disable() -> void:
	if not _is_enabled:
		return

	_is_enabled = false
	Loggie.msg("Disabled").preset("Disabled").debug()
	level_timer.stop()
	# Save.current_level = null
	# current_level_index = 0
	# PaletteManager.reset_palette()

func _next_level() -> void:

	if current_level_index >= levels.size() - 1:
		Loggie.debug("No more levels")
		return

	current_level_index += 1
	Save.current_level = levels[current_level_index]
	level_timer.start()

	PaletteManager.set_palette_from_level(Save.current_level)

	Signals.level_changed.emit()
