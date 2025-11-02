class_name EnemySpawner
extends Node2D

## The enemy scene to spawn.
var enemy_scene: PackedScene = preload("res://entities/enemy/enemy.tscn")

## Spawn rate in seconds. Set to 0 to disable automatic spawning.
@export var spawn_rate: float = 2.0

## Minimum distance from center (0,0) to spawn enemies.
@export var min_spawn_distance: float = 500.0

## Additional margin beyond visible screen to ensure enemies spawn off-screen.
@export var spawn_margin: float = 100.0

var _spawn_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spawn_rate > 0.0:
		_spawn_timer += delta
		if _spawn_timer >= spawn_rate:
			_spawn_timer = 0.0
			spawn_enemy()


## Spawns a single enemy at a random position around the origin (0,0).
func spawn_enemy() -> void:
	var spawn_position = get_circular_spawn_position()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	# Add to the same parent as the spawner (typically the Game scene)
	get_parent().add_child(enemy)


## Calculates a spawn position in a circle around the origin (0,0).
## Returns a position that is outside the visible screen area.
func get_circular_spawn_position() -> Vector2:
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	
	# Calculate the visible world bounds
	var viewport_size = viewport.get_visible_rect().size
	var max_distance_from_center = 0.0
	
	if camera != null:
		# Account for camera zoom
		var zoom_factor = camera.zoom.x  # Assume uniform zoom
		var world_size = viewport_size / zoom_factor
		# Distance from center to corner of visible area
		max_distance_from_center = (world_size.length() / 2.0) + spawn_margin
	else:
		# Fallback: use viewport size directly
		max_distance_from_center = (viewport_size.length() / 2.0) + spawn_margin
	
	# Ensure minimum spawn distance
	max_distance_from_center = max(max_distance_from_center, min_spawn_distance)
	
	# Random angle around the circle
	var angle = randf() * TAU  # TAU = 2 * PI
	
	# Random distance between min and max
	var distance = randf_range(min_spawn_distance, max_distance_from_center)
	
	# Calculate position relative to origin (0,0)
	return Vector2(cos(angle), sin(angle)) * distance
