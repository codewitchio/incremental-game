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
    pressed.connect(_on_pressed)

func _set_text() -> void:
    text = "%s - $%s" % [upgrade.name, upgrade.cost]

func _on_pressed() -> void:
    if Save.upgrades.try_purchase_upgrade(upgrade):
        text = "Purchased"
        disabled = true
    else:
        text = "Not enough money"
        disabled = false
