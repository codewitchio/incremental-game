# Hmm not sure how I feel about this. Pausing and disabling is different for different nodes. 
# I guess there could be two separate lists?

# This works, but it might be premature generalization. 

## A simple class that calls `enable()`/`disable()` on a node when the game state changes.
##
## Example: `var state_enabler: StateEnabler = StateEnabler.new(self, [GameState.PlayingRound])`
class_name StateEnabler
extends RefCounted

## See GameState.gd for list of states.
@export var active_states: Array[StringName] = [] 

var caller: Node

func _init(n: Node, states: Array[StringName]):
    active_states = states
    caller = n
    Signals.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(state: StringName):
    var enabled = state in active_states

    # Call enable()/disable() if present
    if caller.has_method("enable") and caller.has_method("disable"):
        if enabled:
            # caller.call_deferred("enable")
            caller.enable()
        else:
            # caller.call_deferred("disable")
            caller.disable()
        return
    else:
        Loggie.error("%s does not have enable() or disable() methods" % caller.name)
