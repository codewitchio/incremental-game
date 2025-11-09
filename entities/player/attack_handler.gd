## Handles input and spawns attacks from the player.
class_name AttackHandler
extends Node2D

@export var attack_scene: PackedScene = preload("res://entities/attacks/basic_attack.tscn") as PackedScene

var _is_enabled: bool = false
var state_enabler: StateEnabler = StateEnabler.new(self, [GameState.PlayingRound])

func enable() -> void:
	if _is_enabled:
		return
	_is_enabled = true
	Loggie.msg("Enabled").preset("Enabled").debug()

func disable() -> void:
	if not _is_enabled:
		return
	remove_all_attacks()
	_is_enabled = false
	Loggie.msg("Disabled").preset("Disabled").debug()

var _attack_timer: float = 0.0

func _attack_is_ready() -> bool:
	# return _attack_timer >= 1.0 / attack_speed
	return _attack_timer == 0.0

func _start_attack_timer() -> void:
	_attack_timer = Save.calculate_attack_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer = max(0.0, _attack_timer - delta)
	
	# Check for continuous attack input while button is held
	if Input.is_action_pressed("attack") and _attack_is_ready() and _is_enabled:
		_spawn_attack()

## Spawns an attack instance aiming towards the mouse cursor.
func _spawn_attack() -> void:
	if attack_scene == null:
		Loggie.error("Attack scene is not set")
		return
	
	# Get mouse position in world coordinates
	var mouse_position = get_global_mouse_position()
	
	# Calculate direction from player position to mouse
	var player_position = Constants.PlayerPosition
	var direction = (mouse_position - player_position).normalized()
	
	# If direction is zero (mouse exactly on player), default to up
	if direction.length_squared() < 0.001:
		direction = Vector2.UP
	
	# Instantiate the attack scene
	var attack_instance = attack_scene.instantiate()
	if attack_instance == null:
		return
	
	# Set attack position and direction
	attack_instance.global_position = player_position
	attack_instance.direction = direction
	
	# Add to scene tree (use owner or get_tree().current_scene)
	add_child(attack_instance)

	_start_attack_timer()

func remove_all_attacks() -> void:
	for child in get_children():
		if child is Attack:
			child.remove_gracefully()
