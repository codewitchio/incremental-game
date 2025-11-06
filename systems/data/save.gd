# Autoloaded as Save
extends Node

const PlayerStatsPath = "user://player_stats.tres"
const StatisticsPath = "user://statistics.tres"

var statistics: Store

var INITIAL_STATISTICS = {
    Strings.Stat_EnemiesKilled: 0.0 
} as Dictionary

func _ready() -> void:
    # TODO: Save and load from disk. Saving and loading resources directly as-is doesn't seem to work,
    # something about having to disable caching?
    statistics = Store.new(INITIAL_STATISTICS)