class_name StatisticsTracker
extends Node

func _ready() -> void:
	Signals.enemy_died.connect(_on_enemy_died)


func _on_enemy_died(_enemy_instance: EnemyInstance) -> void:
	Save.statistics.Increment(Strings.Stat_EnemiesKilled, 1)
