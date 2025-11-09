extends Control

@export var animation_player: AnimationPlayer

var state_enabler: StateEnabler = StateEnabler.new(self, [GameState.BetweenRounds])

var _is_enabled: bool = false

func _ready() -> void:
	if animation_player == null:
		Loggie.error("Animation player is not set")

func enable() -> void:
	_is_enabled = true
	animation_player.play("enter")

func disable() -> void:
	# Only trigger exit animation if the UI is currently shown.
	if _is_enabled:
		_is_enabled = false
		animation_player.play_backwards("enter")
