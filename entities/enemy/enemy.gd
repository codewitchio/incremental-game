class_name Enemy
extends CharacterBody2D

## Movement speed in pixels per second.
@export var speed: float = 100.0

## The target position to move towards (default is center/origin).
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	target_position = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	# Calculate direction to target
	var direction = (target_position - global_position).normalized()
	
	# Set velocity towards target
	velocity = direction * speed
	
	# Move the character
	move_and_slide()

