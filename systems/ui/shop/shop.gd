extends Control

@export var animation_player: AnimationPlayer
@export var next_round_button: Button

var state_enabler: StateEnabler = StateEnabler.new(self, [GameState.BetweenRounds])

var _is_enabled: bool = false

func _ready() -> void:
	visible = false

	if animation_player == null:
		Loggie.error("Animation player is not set")
	if next_round_button == null:
		Loggie.error("Next round button is not set")

	next_round_button.pressed.connect(_on_next_round_button_pressed)

func enable() -> void:
	Loggie.msg("Enabled").preset("Enabled").info()
	visible = true
	_is_enabled = true
	animation_player.play("enter")

func disable() -> void:
	Loggie.msg("Disabled").preset("Disabled").info()
	visible = false

	# Only trigger exit animation if the UI is currently shown.
	# if _is_enabled:
	# 	_is_enabled = false
	# 	animation_player.play_backwards("enter")

func _on_next_round_button_pressed() -> void:
	animation_player.play_backwards("enter")
	await animation_player.animation_finished

	Signals.done_shopping.emit()
