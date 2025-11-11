class_name LevelData
extends Resource

@export var enemy_speed_multiplier: float = 1.0
@export var enemy_spawn_rate_multiplier: float = 1.0
@export var enemy_health_multiplier: float = 1.0
@export var enemy_damage_multiplier: float = 1.0

@export var money_reward_multiplier: float = 1.0

@export_enum("white", "black", "blue", "red", "yellow") var background_color: String = "black"
@export_enum("white", "black", "blue", "red", "yellow") var foreground_color: String = "white"
