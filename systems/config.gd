# Autoloaded as Config
extends Node

# Loggie presets.
var enabled_preset: LoggiePreset = Loggie.preset("Enabled").color(Constants.Color_Green)
var disabled_preset: LoggiePreset = Loggie.preset("Disabled").color(Constants.Color_Red)
var state_preset: LoggiePreset = Loggie.preset("State").color(Constants.Color_Sky)

var analytics_preset: LoggiePreset = Loggie.preset("Analytics").domain("Analytics")

const GAME_NAME = "incremental-game"

class AnalyticsProperties: 
	const GameName = "game_name"
	const GameVersion = "game_version"

func _ready() -> void:
	_setup_post_hog()
	call_deferred("_setup_console")

func _setup_post_hog() -> void:
	Loggie.set_domain_enabled("Analytics", OS.has_feature("analytics"))

	PostHog.auto_include_properties[AnalyticsProperties.GameName] = GAME_NAME
	PostHog.auto_include_properties[AnalyticsProperties.GameVersion] = ProjectSettings.get_setting("application/config/version", "0.0.0")

	PostHog.enabled = OS.has_feature("analytics")
	if PostHog.enabled:
		Loggie.msg("PostHog enabled").preset("Enabled").info()
	else:
		Loggie.msg("PostHog disabled").preset("Disabled").info()


func _setup_console() -> void:
	LimboConsole.enabled = OS.is_debug_build()

	LimboConsole.register_command(_get_player_stat, "player_stat", "Get a player stat")
	LimboConsole.add_argument_autocomplete_source("player_stat", 1, func(): return Save.player_stats.Keys()) # This doesn't seem to work?

	LimboConsole.register_command(_get_statistic, "statistics", "Get the value of a statistic")
	LimboConsole.add_argument_autocomplete_source("statistics", 1, func(): return Save.statistics.Keys())

func _get_player_stat(stat_name: String) -> void:
	LimboConsole.info(str(Save.player_stats.Get(stat_name)))

func _get_statistic(stat_name: String) -> void:
	LimboConsole.info(str(Save.statistics.Get(stat_name)))
