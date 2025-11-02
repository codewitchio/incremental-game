class_name StoreValue

var _value: Variant
signal value_changed(value: Variant)

func _init(value: Variant) -> void:
    _value = value

func get_value() -> Variant:
    return _value

func set_value(value: Variant) -> void:
    _value = value
    value_changed.emit(_value)

# func increment(amount: float) -> void:
#     _value += amount
#     value_changed.emit(_value)