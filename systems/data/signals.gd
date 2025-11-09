# Autoloaded as Signals
extends Node

signal attack_colission_with_enemy(enemy_rid: RID, damage: float)
signal enemy_collision_with_player(enemy_instance: EnemyInstance)

signal enemy_died(enemy_instance: EnemyInstance)

signal player_died()

signal game_state_changed(state: StringName)