## A multimesh instance that displays enemy_instances and handles collision detection.
class_name EnemySwarmManager
extends MultiMeshInstance2D

@export var spawner: EnemySpawner

## Dictionary mapping collision area RIDs to EnemyInstance objects.
var enemy_instances: Dictionary = {}

## Target position for enemy_instances to move towards (default is player position).
var target_position: Vector2 = Constants.PlayerPosition

## Reference to player's collision shape node.
@export var player_collision_shape: CollisionShape2D

## VFX scene to use on enemy death. Must be GPUParticles2D.
const ENEMY_DEATH_VFX_SCENE: PackedScene = preload("res://entities/vfx/enemy_death_vfx.tscn") # This could be defined in the EnemyData

## PhysicsServer2D space state for collision queries (uses world's default space).
var space_state: PhysicsDirectSpaceState2D = null

var _is_enabled: bool = true

var state_enabler: StateEnabler = StateEnabler.new(self, [GameState.PlayingRound])

func enable() -> void:
	if _is_enabled:
		return
	_is_enabled = true
	Loggie.msg("Enabled").preset("Enabled").info()
	spawner.enable()

func disable() -> void:
	if not _is_enabled:
		return
	_erase_all_enemies()
	_is_enabled = false
	Loggie.msg("Disabled").preset("Disabled").info()
	spawner.disable()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if spawner == null:
		Loggie.error("EnemySwarmManager requires a spawner to be configured in the editor")

	if player_collision_shape == null:
		Loggie.error("EnemySwarmManager requires a player_collision_shape to be configured in the editor")
	
	if multimesh == null:
		Loggie.error("MultiMeshInstance2D requires a MultiMesh resource to be configured in the editor")

	spawner.spawn_enemy.connect(_on_spawn_enemy)
	Performance.add_custom_monitor("enemies/count", func(): return enemy_instances.size())
	
	# Use the world's default physics space (same space the player is in)
	var world_space = get_world_2d().get_space()
	space_state = PhysicsServer2D.space_get_direct_state(world_space)

	Signals.attack_colission_with_enemy.connect(_handle_attack_colission_with_enemy)

func _process(delta: float) -> void:
	if not _is_enabled:
		return
	
	target_position = Constants.PlayerPosition
	_update_enemy_positions(delta)
	_check_collisions()
	_update_multimesh()

func _exit_tree() -> void:
	# Clean up physics resources
	_cleanup_physics_collision()

## Handles new enemy spawns from the spawner.
func _on_spawn_enemy(enemy_instance: EnemyInstance) -> void:
	if not _is_enabled:
		return
	
	# Register enemy instance in dictionary
	enemy_instances[enemy_instance.collision_area_rid] = enemy_instance

## Updates enemy positions based on movement logic.
func _update_enemy_positions(delta: float) -> void:
	for enemy in enemy_instances.values():
		# Calculate direction to target
		var direction = (target_position - enemy.position).normalized()
		
		# Update position based on speed
		enemy.position += direction * enemy.speed * delta
		
		# Update physics collision position
		enemy.update_collision_position()

## Updates the multimesh instance with current enemy positions and transforms.
func _update_multimesh() -> void:
	if multimesh == null:
		return
	
	var instance_count = enemy_instances.size()
	
	# Set instance count (multimesh will resize if needed)
	multimesh.instance_count = instance_count
	
	# Update transform for each enemy instance
	var i = 0
	for enemy in enemy_instances.values():
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
		i += 1

## Checks for collisions between enemy_instances and the player using PhysicsServer2D.
func _check_collisions() -> void:
	if not space_state:
		return
	
	var player_position = Constants.PlayerPosition
	
	# Collect enemy_instances to remove (avoid modifying array while iterating)
	var enemies_to_remove: Array[EnemyInstance] = []
	
	# To be honest, we could do this with a _on_area_shape_entered on the player.
	# Not sure how big the performance difference is, but I wanted to try this approach.
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = player_collision_shape.shape
	query.transform = Transform2D.IDENTITY
	query.transform.origin = player_position
	query.collision_mask = Constants.CollisionLayer_Enemies
	query.collide_with_areas = true # Query areas instead of bodies
	query.exclude = [] # Don't exclude - we filter by checking enemy_instances.
	
	# Query for intersecting areas
	var results = space_state.intersect_shape(query)
	
	# Process collision results
	for result in results:
		var rid = result.rid
		# Check if this is one of our enemy areas
		if enemy_instances.has(rid):
			# Loggie.debug("Collision with enemy")
			var enemy = enemy_instances[rid]
			_handle_enemy_collision_with_player(enemy)
			enemies_to_remove.append(enemy)
	
	# Remove collided enemy_instances
	for enemy in enemies_to_remove:
		_erase_enemy(enemy)
	
	# Update multimesh instance count if any enemy_instances were removed
	if enemies_to_remove.size() > 0:
		multimesh.instance_count = enemy_instances.size()

func _handle_enemy_collision_with_player(_enemy_instance: EnemyInstance) -> void:
	Signals.enemy_collision_with_player.emit(_enemy_instance)

func _handle_attack_colission_with_enemy(enemy_rid: RID, damage: float) -> void:
	if enemy_rid.is_valid() and enemy_instances.has(enemy_rid):
		var enemy: EnemyInstance = enemy_instances[enemy_rid]
		enemy.take_damage(damage)
		if enemy.is_dead():
			_spawn_enemy_death_vfx(enemy)
			Signals.enemy_died.emit(enemy)
			_erase_enemy(enemy)

func _spawn_enemy_death_vfx(enemy_instance: EnemyInstance) -> void:
	if ENEMY_DEATH_VFX_SCENE == null:
		Loggie.error("Enemy death VFX scene is not set")
		return
	var vfx: GPUParticles2D = ENEMY_DEATH_VFX_SCENE.instantiate()
	vfx.global_position = enemy_instance.position
	vfx.global_scale = enemy_instance.scale
	add_child(vfx)

## Erases an enemy and cleans up its collision area.
func _erase_enemy(enemy_instance: EnemyInstance) -> void:
	enemy_instances.erase(enemy_instance.collision_area_rid)
	enemy_instance.cleanup_collision()

## Cleans up all physics resources.
func _cleanup_physics_collision() -> void:
	# Remove all enemy collision areas
	for enemy in enemy_instances.values():
		enemy.cleanup_collision()
	enemy_instances.clear()
	
	space_state = null


# Simply deletes all enemies.
func _erase_all_enemies() -> void:
	# TODO: Stagger death vfx? Based on proximity to player. Not sure if that's difficult to do. 
	for enemy in enemy_instances.values():
		_spawn_enemy_death_vfx(enemy)
		_erase_enemy(enemy)
	
	multimesh.instance_count = 0
