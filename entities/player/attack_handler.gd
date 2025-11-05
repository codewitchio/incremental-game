## Handles input and spawns attacks from the player.
class_name AttackHandler
extends Node2D

@export var attack_scene: PackedScene = preload("res://entities/attacks/basic_circle_attack.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


## Handles input for attack actions.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
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
