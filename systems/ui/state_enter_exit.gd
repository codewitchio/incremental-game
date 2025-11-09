## Simple class that calls enter/exit animations based on the game state.
## Alternative to StateEnabler for simpler cases.
class_name StateEnterExit
extends AnimationPlayer

@export var enter_animation: StringName = "ui_animations/enter"
# @export var exit_animation: StringName = "ui_animations/exit"

@export var enter_states: Array[StringName] = []
var state_enabler: StateEnabler

@export var also_toggle_visible: bool = true

var _is_enabled: bool = false

var parent_node: Node

func _ready() -> void:
    state_enabler = StateEnabler.new(self, enter_states)
    parent_node = get_parent()
    if also_toggle_visible and parent_node != null:
        parent_node.visible = false

func enable() -> void:
    if _is_enabled:
        return

    Loggie.msg("%s enabled" % parent_node.name).preset("Enabled").debug()
    _is_enabled = true

    play(enter_animation)

    if also_toggle_visible:
        parent_node.visible = true

func disable() -> void:
    if not _is_enabled:
        return

    Loggie.msg("%s disabled" % parent_node.name).preset("Disabled").debug()
    _is_enabled = false

    play_backwards(enter_animation) # TODO: Add proper exit animation.

    if also_toggle_visible:
        parent_node.visible = false