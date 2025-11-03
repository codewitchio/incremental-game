class_name Enemy
extends CharacterBody2D

var default_data: EnemyData = preload("res://entities/enemy/data/default_enemy.tres")

## Enemy resource for speed, health, sprite, etc. 
@export var data: EnemyData = default_data

## The target position to move towards (default is center/origin).
var target_position: Vector2 = Constants.PlayerPosition

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	target_position = Constants.PlayerPosition

	# Set sprite
	sprite.texture = data.sprite
	sprite.scale = data.scale
	sprite.position = data.offset

func _physics_process(_delta: float) -> void:
	# Calculate direction to target
	var direction = (target_position - global_position).normalized()
	
	# Set velocity towards target
	velocity = direction * data.speed
	
	# Move the character
	move_and_slide()
