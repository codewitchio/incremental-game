# Autoloaded as Save
extends Node

# const PlayerStatsPath = "user://player_stats.tres"
# const StatisticsPath = "user://statistics.tres"

var statistics: Store
var player_stats: Store
var upgrades: Upgrades

# This null feels dangerous, watch out for errors.
var current_level: LevelData = null

# I guess this could be a resource if we changed some things. Easier without StoreValue.
# Store is already a resource, so it could @export an initial data dictionary.
var INITIAL_STATISTICS = {
    Strings.Stat_EnemiesKilled: 0.0,
    Strings.Stat_PlayerDeaths: 0.0
} as Dictionary

var INITIAL_PLAYER_STATS = {
    Strings.PlayerStat_MaxHealth: 1.0,
    Strings.PlayerStat_CurrentHealth: 1.0,
    Strings.PlayerStat_AttackSpeed: 1.0,
    Strings.PlayerStat_AttackDamage: 1.0,
    Strings.PlayerStat_AttackArc: 30.0,
    Strings.PlayerStat_Money: 0.0
} as Dictionary

func _ready() -> void:
    # TODO: Save and load from disk. Saving and loading resources directly as-is doesn't seem to work,
    # something about having to disable caching?
    statistics = Store.new(INITIAL_STATISTICS)
    player_stats = Store.new(INITIAL_PLAYER_STATS)
    upgrades = Upgrades.new()

    Signals.enemy_died.connect(_on_enemy_died)

func reset_statistics() -> void:
    statistics = Store.new(INITIAL_STATISTICS)

func reset_player_stats() -> void:
    player_stats = Store.new(INITIAL_PLAYER_STATS)

# Maybe PlayerStats should be its own class, like Upgrades?

## PlayerStat_AttackSpeed is stored as attacks per second, this function converts it to seconds per attack.
func calculate_attack_timer() -> float:
    return 1.0 / player_stats.Get(Strings.PlayerStat_AttackSpeed)
    # My previous implementation of this is nicer at the call site, example: PlayerStats.HealthRegen.value

func _on_enemy_died(_enemy_instance: EnemyInstance) -> void:
    # Currently handled in StatisticsTracker, not sure if we'll still need that though.
    # statistics.Increment(Strings.Stat_EnemiesKilled, 1)
    player_stats.Increment(Strings.PlayerStat_Money, 1 * Save.current_level.money_reward_multiplier)