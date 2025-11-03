class_name EnemyData
extends Resource

## Movement speed in pixels per second.
@export var speed: float = 100.0

## Health in pixels per second.
@export var health: float = 100.0

## Sprite texture.
@export var sprite: Texture2D = null

## Sprite scale.
@export var scale: Vector2 = Vector2.ONE

## Sprite offset.
@export var offset: Vector2 = Vector2.ZERO

# TODO: Collission shape radius