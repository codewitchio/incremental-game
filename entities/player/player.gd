class_name Player
extends CharacterBody2D

# Currently simplifying to end the round the first time you take damage.
# Health etc. can be added later.

# @export var max_health: float = 10.0 # this is a player stat that should be in the store
# @export var current_health: float = max_health

const DAMAGE_ON_ENEMY_COLLISION: float = 1.0

func _ready() -> void:
	Signals.enemy_collision_with_player.connect(_on_enemy_collision_with_player)

func _on_enemy_collision_with_player(_enemy_instance: EnemyInstance) -> void:
	# TODO: VFX, etc.
	# Loggie.info("Ouch")
	# current_health -= DAMAGE_ON_ENEMY_COLLISION
	# if current_health <= 0:
	_handle_death()

func _handle_death() -> void:
	# TODO: VFX, etc.
	Signals.player_died.emit()
