extends Area2D

# TODO: Resource
@export var speed: float = 1000.0
@export var damage: float = 1.0
## How long the projectile exists before being destroyed.
@export var lifetime: float = 3.0

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

	area_shape_entered.connect(_on_area_shape_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_lifetime_timeout() -> void:
	queue_free()


func _on_area_shape_entered(area_id: RID, _area: Area2D, _area_shape_index: int, _body_shape_index: int) -> void:
	if area_id.is_valid():
		Signals.attack_colission_with_enemy.emit(area_id, damage)
		# Loggie.debug("Area shape entered:",area_id, area, area_shape_index, body_shape_index)
