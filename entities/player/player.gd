class_name Player
extends CharacterBody2D

# Currently simplifying to end the round the first time you take damage.
# Health etc. can be added later.

# @export var max_health: float = 10.0 # this is a player stat that should be in the store
# @export var current_health: float = max_health

@export var animation_player: AnimationPlayer

var _is_alive: bool = true

const DAMAGE_ON_ENEMY_COLLISION: float = 1.0

func _ready() -> void:
	Signals.enemy_collision_with_player.connect(_on_enemy_collision_with_player)

	if animation_player == null:
		Loggie.error("Animation player is not set")

func _on_enemy_collision_with_player(_enemy_instance: EnemyInstance) -> void:
	# TODO: VFX, etc.
	if _is_alive:
		_handle_death()

func _handle_death() -> void:
	_is_alive = false
	Signals.player_died.emit()
	animation_player.play("death")
	# TODO: VFX, etc.
