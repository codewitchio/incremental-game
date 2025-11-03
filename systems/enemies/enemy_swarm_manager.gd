## A multimesh instance that displays enemies and handles collision detection.
class_name EnemySwarmManager
extends MultiMeshInstance2D

@export var spawner: EnemySpawner

## Array of active enemy instances.
var enemies: Array[EnemyInstance] = []

## Target position for enemies to move towards (default is player position).
var target_position: Vector2 = Constants.PlayerPosition

## Player collision radius for collision detection.
@export var player_collision_radius: float = 50.0
# TODO: Collision radius is a player stat and should be in some type of Store.

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
	_check_collisions()
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

## Checks for collisions between enemies and the player.
func _check_collisions() -> void:
	var player_position = Constants.PlayerPosition
	
	# Collect enemies to remove (avoid modifying array while iterating)
	var enemies_to_remove: Array[EnemyInstance] = []
	
	for enemy in enemies:
		# Calculate collision radius for this enemy (scale collision radius by sprite scale)
		var enemy_radius = enemy.collision_radius * max(enemy.scale.x, enemy.scale.y)
		var combined_radius = player_collision_radius + enemy_radius
		var combined_radius_squared = combined_radius * combined_radius
		
		var distance_squared = enemy.position.distance_squared_to(player_position)
		
		if distance_squared <= combined_radius_squared:
			_handle_enemy_collision_with_player(enemy)
			enemies_to_remove.append(enemy)
	
	# Remove collided enemies
	for enemy in enemies_to_remove:
		enemies.erase(enemy)
	
	# Update multimesh instance count if any enemies were removed
	if enemies_to_remove.size() > 0:
		multimesh.instance_count = enemies.size()

func _handle_enemy_collision_with_player(_enemy_instance: EnemyInstance) -> void:
	# TODO: Damage, VFX, etc.
	pass