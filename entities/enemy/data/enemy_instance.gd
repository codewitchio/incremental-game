class_name EnemyInstance
extends EnemyData

## Default enemy data resource used when no data is provided.
static var default_data: EnemyData = preload("res://entities/enemy/data/default_enemy.tres")

var position: Vector2 = Vector2.ZERO
var current_health: float = health

## PhysicsServer2D area RID for collision detection.
var collision_area_rid: RID = RID()

func _init(world_space: RID, pos: Vector2 = Vector2.ZERO, data: EnemyData = default_data) -> void:
	self.position = pos
	
	# Use provided data or fall back to default
	
	# Copy enemy data properties
	speed = data.speed
	health = data.health
	sprite = data.sprite
	scale = data.scale
	sprite_offset = data.sprite_offset
	collision_radius = data.collision_radius
	current_health = data.health
	
	# Create collision area for this enemy instance
	_setup_collision_area()
	_add_to_physics_space(world_space)

## Sets up the collision area for this enemy instance.
func _setup_collision_area() -> void:
	# Calculate enemy collision radius (scale collision radius by sprite scale)
	var enemy_radius = collision_radius * max(scale.x, scale.y)
	
	# Create circle shape for this enemy
	var shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, enemy_radius)
	
	# Create area for this enemy (areas are lighter than bodies and perfect for collision detection)
	collision_area_rid = PhysicsServer2D.area_create()
	PhysicsServer2D.area_add_shape(collision_area_rid, shape_rid)
	
	# Set collision layer so areas are detected by queries
	PhysicsServer2D.area_set_collision_layer(collision_area_rid, Constants.CollisionLayer_Enemies)
	PhysicsServer2D.area_set_collision_mask(collision_area_rid, 0)  # Enemies don't need to detect anything
	
	# Set initial transform
	var area_transform = Transform2D.IDENTITY
	area_transform.origin = position
	PhysicsServer2D.area_set_transform(collision_area_rid, area_transform)

## Adds the collision area to the world's physics space.
func _add_to_physics_space(world_space: RID) -> void:
	if collision_area_rid.is_valid():
		PhysicsServer2D.area_set_space(collision_area_rid, world_space)

## Updates the collision area position to match the enemy's current position.
func update_collision_position() -> void:
	if collision_area_rid.is_valid():
		var area_transform = Transform2D.IDENTITY
		area_transform.origin = position
		PhysicsServer2D.area_set_transform(collision_area_rid, area_transform)

## Cleans up the collision area and shape resources.
func cleanup_collision() -> void:
	if collision_area_rid.is_valid():
		# Get all shapes attached to this area to clean them up
		var shape_count = PhysicsServer2D.area_get_shape_count(collision_area_rid)
		for i in range(shape_count):
			var shape_rid = PhysicsServer2D.area_get_shape(collision_area_rid, i)
			PhysicsServer2D.free_rid(shape_rid)
		
		# Free the area
		PhysicsServer2D.free_rid(collision_area_rid)
		collision_area_rid = RID()
