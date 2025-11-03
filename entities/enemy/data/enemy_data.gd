class_name EnemyData
extends Resource

## Movement speed in pixels per second.
@export var speed: float = 100.0

## Health in pixels per second.
@export var health: float = 100.0

## Sprite texture.
## TODO: This is ignored by the EnemySwarmManager since it has its own texture.
@export var sprite: Texture2D = null

## Sprite scale.
@export var scale: Vector2 = Vector2.ONE

## Sprite offset.
@export var sprite_offset: Vector2 = Vector2.ZERO

# TODO: Collision shape radius