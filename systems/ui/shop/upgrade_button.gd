@tool

## A button that allows the player to purchase an upgrade.
extends Button

@export var upgrade: Upgrade:
	set(value):
		upgrade = value
		_set_text()

func _ready() -> void:
	# TODO: Tooltips etc.
	_set_text()
	update_disabled_state()
	pressed.connect(_on_pressed)
	Save.player_stats.Subscribe(Strings.PlayerStat_Money, _on_money_changed)

# No idea how this affects performance, but we should probably listen to the Shop's "enable" instead. Let's add that when we move this to a centralised upgrades list.
func _on_money_changed(_value: Variant) -> void:
	update_disabled_state()

func _set_text() -> void:
	text = "%s - $%s" % [upgrade.name, upgrade.cost]

func update_disabled_state() -> void:
	if Save.upgrades.can_purchase_upgrade(upgrade):
		disabled = false
	else:
		disabled = true

func _on_pressed() -> void:
	if not Save.upgrades.try_purchase_upgrade(upgrade):
		Loggie.error("Failed to purchase upgrade %s, despite UI allowing the action." % upgrade.name)
	else:
		update_disabled_state()
