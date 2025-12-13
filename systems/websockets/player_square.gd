class_name PlayerSquare
extends ColorRect

var player_id: String
var input_store_value: StoreValue

const PLAYER_SPEED = 650.0

func _init(_player_id: String, store_value: StoreValue) -> void:
    player_id = _player_id
    input_store_value = store_value


func _ready() -> void:
    var rect := ColorRect.new()
    rect.size = Vector2(48, 48)
    rect.color = Color.from_hsv(randf(), 0.8, 0.95)
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    rect.pivot_offset = rect.size * 0.5

    add_child(rect)

func _process(delta: float) -> void:
    _update_position(delta)

func _update_position(delta: float) -> void:
    # var input: Vector2 = input_store.Get(id)
    var input: Vector2 = input_store_value.get_value()

    # print("Input: %s" % input)

    if input.length() == 0:
        return
    position.x += input.x * PLAYER_SPEED * delta
    position.y += input.y * PLAYER_SPEED * delta