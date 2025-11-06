class_name EnemySpawner
extends Node2D

## Spawn rate in seconds. Set to 0 to disable automatic spawning.
@export var spawn_rate: float = 0.2

## Minimum distance from center (0,0) to spawn enemies.
@export var min_spawn_distance: float = 500.0

## Additional margin beyond visible screen to ensure enemies spawn off-screen.
@export var spawn_margin: float = 50.0

var _spawn_timer: float = 0.0

var base_viewport_size: Vector2

signal spawn_enemy(enemy_instance: EnemyInstance)

var world_space: RID 

var _is_enabled: bool = true

func enable() -> void:
	_is_enabled = true
	Loggie.info("Enabled")

func disable() -> void:
	_is_enabled = false
	Loggie.info("Disabled")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	base_viewport_size = get_tree().root.content_scale_size
	world_space = get_world_2d().get_space()

	Signals.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(state: Game.GameState) -> void:
	if state == Game.GameState.ROUND_ENDING:
		disable()
	elif state == Game.GameState.PLAYING_ROUND:
		enable()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not _is_enabled:
		return
	
	if spawn_rate > 0.0:
		_spawn_timer += delta
		if _spawn_timer >= spawn_rate:
			_spawn_timer = 0.0
			queue_spawn_enemy()


## Spawns a single enemy at a random position around the origin (0,0).
func queue_spawn_enemy() -> void:
	var spawn_position = get_circular_spawn_position()
	var enemy_instance = EnemyInstance.new(world_space, spawn_position)
	spawn_enemy.emit(enemy_instance)


## Calculates a spawn position in a circle around the origin (0,0).
## Returns a position that is outside the visible screen area.
func get_circular_spawn_position() -> Vector2:
	# Use base viewport size instead of current viewport size. 
	# This means the spawn radius stays consistent regardless of window size and resolution.
	var distance_from_center_to_edge = (base_viewport_size.length() / 2.0) + spawn_margin
	
	# Random angle around the circle
	var angle = randf() * TAU # TAU = 2 * PI
	
	# Random distance between min and max
	# var distance = randf_range(min_spawn_distance, distance_from_center_to_edge)
	
	# Calculate position relative to origin (0,0)
	return Vector2(cos(angle), sin(angle)) * distance_from_center_to_edge
