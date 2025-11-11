# Autoloaded as Signals
extends Node

signal attack_colission_with_enemy(enemy_rid: RID, damage: float)
signal enemy_collision_with_player(enemy_instance: EnemyInstance)

# During FirstStart
signal dismiss_tutorial()

# During PlayingRound
signal enemy_died(enemy_instance: EnemyInstance)
signal level_changed()
signal player_died()

# During BetweenRounds
signal game_state_changed(state: StringName)
signal done_shopping()