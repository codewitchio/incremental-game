class_name EnemyInstance
extends EnemyData

## Default enemy data resource used when no data is provided.
static var default_data: EnemyData = preload("res://entities/enemy/data/default_enemy.tres")

var position: Vector2 = Vector2.ZERO
var current_health: float = health


func _init(pos: Vector2 = Vector2.ZERO, data: EnemyData = default_data) -> void:
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