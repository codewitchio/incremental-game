extends Label

@export var store_key: String
# enum StoreType { PLAYER, STATISTICS }
# @export var store_type: StoreType = StoreType.PLAYER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Save.statistics.Subscribe(store_key, _update_text)

func _update_text(value: Variant) -> void:
	self.text = str(format_score(value))


func format_score(score: float) -> String:
	return "$%s" % score