class_name Upgrades
extends Resource

# TODO: https://github.com/derkork/godot-resource-groups
@export var all_upgrades: Dictionary[Upgrade, int] = {}

func reset_and_apply_all() -> void:
	Save.reset_player_stats()
	for upgrade in all_upgrades:
		upgrade.apply()

## Bypasses costs and adds the upgrade to the list.
func add_upgrade(upgrade: Upgrade) -> void:
	if not all_upgrades.has(upgrade):
		all_upgrades[upgrade] = 0
	all_upgrades[upgrade] += 1
	upgrade.apply()

## Tries to purchase the upgrade, returns true if successful.
func try_purchase_upgrade(upgrade: Upgrade) -> bool:
	if Save.player_stats.Get(Strings.PlayerStat_Money) <= upgrade.cost:
		return false
	add_upgrade(upgrade)
	Save.player_stats.Increment(Strings.PlayerStat_Money, -upgrade.cost)
	return true
