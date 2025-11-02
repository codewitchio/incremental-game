extends Button

@export var store_key: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if store_key == null:
		print("Button is missing a store key")
		return

	self.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	Store.Increment(store_key, 1)
