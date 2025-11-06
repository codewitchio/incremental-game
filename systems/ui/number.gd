extends Label

@export var store_key: String
# enum StoreType { PLAYER, STATISTICS }
# @export var store_type: StoreType = StoreType.PLAYER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Save.statistics.Subscribe(store_key, _update_text)
	_update_text(Save.statistics.Get(store_key))

func _update_text(value: Variant) -> void:
	self.text = str(format_score(value))


func format_score(score: float) -> String:
	# TODO: Remove .0 decimal places if they are 0
	return "$%s" % snapped(score, 0)