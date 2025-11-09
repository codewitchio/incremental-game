extends Control

@export var animation_player: AnimationPlayer

func _ready() -> void:
	if animation_player == null:
		Loggie.error("Animation player is not set")

	Signals.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(state: StringName) -> void:
	if state == GameState.BetweenRounds:
		animation_player.play("enter")
	# TODO: Play exit animation but only on leaving the BETWEEN_ROUNDS state. XSM would make this easier.
	# else:
		# play enter animation in reverse
		# animation_player.play_backwards("enter")
