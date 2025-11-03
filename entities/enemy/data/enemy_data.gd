class_name EnemyData
extends Resource

## Movement speed in pixels per second.
@export var speed: float = 100.0

## Maximum health 
@export var health: float = 1.0

## Sprite texture.
## TODO: This is ignored by the EnemySwarmManager since it has its own texture. Reimplement in there later.
@export var sprite: Texture2D = null

## Sprite scale. Also multiplies the collision radius.
@export var scale: Vector2 = Vector2.ONE

## Sprite offset.
@export var sprite_offset: Vector2 = Vector2.ZERO

## Collision shape radius.
@export var collision_radius: float = 15.0