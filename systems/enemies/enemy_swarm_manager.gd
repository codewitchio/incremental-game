## A multimesh instance that displays enemies and handles collision detection.
class_name EnemySwarmManager
extends MultiMeshInstance2D

@export var spawner: EnemySpawner

## Array of active enemy instances.
var enemies: Array[EnemyInstance] = []

## Target position for enemies to move towards (default is player position).
var target_position: Vector2 = Constants.PlayerPosition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if spawner == null:
		push_error("EnemySwarmManager requires a spawner to be configured in the editor")

	spawner.spawn_enemy.connect(_on_spawn_enemy)
	
	# Initialize multimesh if not already configured
	if multimesh == null:
		push_error("MultiMeshInstance2D requires a MultiMesh resource to be configured in the editor")

func _process(delta: float) -> void:
	target_position = Constants.PlayerPosition
	_update_enemy_positions(delta)
	_update_multimesh()

## Handles new enemy spawns from the spawner.
func _on_spawn_enemy(enemy_instance: EnemyInstance) -> void:
	enemies.append(enemy_instance)

## Updates enemy positions based on movement logic.
func _update_enemy_positions(delta: float) -> void:
	for enemy in enemies:
		# Calculate direction to target
		var direction = (target_position - enemy.position).normalized()
		
		# Update position based on speed
		enemy.position += direction * enemy.speed * delta

## Updates the multimesh instance with current enemy positions and transforms.
func _update_multimesh() -> void:
	if multimesh == null:
		return
	
	var instance_count = enemies.size()
	
	# Set instance count (multimesh will resize if needed)
	multimesh.instance_count = instance_count
	
	# Update transform for each enemy instance
	for i in range(instance_count):
		var enemy = enemies[i]
		
		# Calculate direction to target and rotation angle
		var direction = (target_position - enemy.position)
		var direction_angle = direction.angle() if direction.length() > 0.0 else 0.0
		
		# Adjust angle: triangle texture points up (-PI/2) by default,
		# so we rotate it to point in the direction angle
		# In Godot: angle() returns angle from positive X axis (counterclockwise)
		# Up is -PI/2, so to rotate from up to direction: direction_angle - (-PI/2)
		var angle = direction_angle - PI / 2.0
		
		# Create transform: start with identity, rotate, scale, then translate
		var instance_transform = Transform2D.IDENTITY
		instance_transform = instance_transform.rotated(angle)
		instance_transform = instance_transform.scaled(enemy.scale)
		instance_transform.origin = enemy.position
		
		# Apply sprite offset if needed (rotated by the enemy's angle)
		if enemy.sprite_offset != Vector2.ZERO:
			instance_transform.origin += instance_transform.basis_xform(enemy.sprite_offset)
		
		multimesh.set_instance_transform_2d(i, instance_transform) 