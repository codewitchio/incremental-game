class_name Upgrade
extends Resource

enum UpgradeFormat {
	PERCENTAGE, # +10% attack speed
	NUMBER, # +10 attack damage
	MULTIPLIER, # x2 attack damage
	ANGLE, # +10 degrees attack arc
}

@export var name: String = ""
@export var description: String = ""
@export var format: UpgradeFormat = UpgradeFormat.NUMBER

@export var cost: int = 0

@export var stat: StringName = ""
@export var change: float = 0.0

func apply() -> void:
	if not Save.player_stats.Has(stat):
		Loggie.error("%s is not a valid player stat" % stat)
		return
	Save.player_stats.Increment(stat, change)


# TODO: Implement nice formatting for the description, that includes the value of the change.
# Maybe even a tooltip. Wait shit maybe the stats themselves should be resources for that reason


# TODO: Implement Upgrade Tree
# @export var position: Vector2 = Vector2.ZERO
# @export var requires: Upgrade = null
# @export var max_level: int = 1
# func can_buy() -> bool: # check money and level. or let Upgrades do that, depends where we store the count.