class_name Attack
extends Area2D

# TODO: Resource
@export var speed: float = 1000.0
@export var damage: float = 1.0
## How long the projectile exists before being destroyed.
@export var lifetime: float = 1.0

@export var start_scale: float = 0.1
@export var end_scale: float = 12.5

## Timer to handle projectile lifetime.
var lifetime_timer: Timer

## Direction vector for the attack movement (normalized)
var direction: Vector2 = Vector2.UP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create and configure lifetime timer
	lifetime_timer = Timer.new()
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	add_child(lifetime_timer)
	lifetime_timer.start()

	Signals.game_state_changed.connect(_on_game_state_changed)
	area_shape_entered.connect(_on_area_shape_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * speed * delta

	# Rotate to match direction.
	rotation = direction.angle()

	# Slowly grow in size over lifetime. 
	var ratio = 1 - lifetime_timer.time_left / lifetime 
	scale = Vector2.ONE * lerp(start_scale, end_scale, ratio)

func _on_lifetime_timeout() -> void:
	queue_free()


func _on_area_shape_entered(area_id: RID, _area: Area2D, _area_shape_index: int, _body_shape_index: int) -> void:
	if area_id.is_valid():
		Signals.attack_colission_with_enemy.emit(area_id, damage)
		# Loggie.debug("Area shape entered:",area_id, area, area_shape_index, body_shape_index)


func _on_game_state_changed(state: StringName) -> void:
	if state == GameState.RoundEnding:
		remove_gracefully()

func remove_gracefully() -> void:
	# TODO: Fade out with an animation or similar.
	queue_free()