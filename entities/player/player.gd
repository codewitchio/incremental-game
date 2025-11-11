class_name Player
extends CharacterBody2D

# Currently simplifying to end the round the first time you take damage.
# Health etc. can be added later.

var current_health: float

@export var animation_player: AnimationPlayer

var _is_alive: bool = true

# TODO: Enemy variety
const DAMAGE_ON_ENEMY_COLLISION: float = 1.0

func _ready() -> void:
	Signals.enemy_collision_with_player.connect(_on_enemy_collision_with_player)
	Signals.game_state_changed.connect(_on_game_state_changed)

	current_health = Save.player_stats.Get(Strings.PlayerStat_MaxHealth)
	
	visible = false

	if animation_player == null:
		Loggie.error("Animation player is not set")

func _on_game_state_changed(state: StringName) -> void:
	if state == GameState.StartingNewRound:
		reset()

func _on_enemy_collision_with_player(_enemy_instance: EnemyInstance) -> void:
	if _is_alive:
		current_health -= DAMAGE_ON_ENEMY_COLLISION * Save.current_level.enemy_damage_multiplier
		if current_health <= 0:
			_handle_death()
		else:
			_handle_damage()

func _handle_damage() -> void:
	Loggie.debug("Player took damage without dying")
	pass
	# TODO: Animation/VFX
	# animation_player.play("damage")

func _handle_death() -> void:
	_is_alive = false
	Signals.player_died.emit()
	animation_player.play("death")

# Could this be solved with the StateEnabler? I guess. But it breaks semantics.
func reset() -> void:
	_is_alive = true
	visible = true
	current_health = Save.player_stats.Get(Strings.PlayerStat_MaxHealth)
	animation_player.play("respawn")
