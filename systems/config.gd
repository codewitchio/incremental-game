# Autoloaded as Config
extends Node

# Loggie presets.
var enabled_preset: LoggiePreset = Loggie.preset("Enabled").color(Constants.Color_Green)
var disabled_preset: LoggiePreset = Loggie.preset("Disabled").color(Constants.Color_Red)
var state_preset: LoggiePreset = Loggie.preset("State").color(Constants.Color_Sky)

func _ready() -> void:
    _setup_post_hog()


func _setup_post_hog() -> void:
    PostHog.auto_include_properties["game_name"] = "incremental-game"
    PostHog.auto_include_properties["game_version"] = ProjectSettings.get_setting("application/config/version", "0.0.0")

    PostHog.enabled = OS.has_feature("analytics")
    if PostHog.enabled:
        Loggie.msg("PostHog enabled").preset("Enabled").info()
    else:
        Loggie.msg("PostHog disabled").preset("Disabled").info()