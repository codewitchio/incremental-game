@tool 

class_name GameState
extends State

# Make sure these line up with the states in the editor.
const FirstStart = &"FirstStart"
const PauseMenu = &"PauseMenu"
const StartingNewRound = &"StartingNewRound" # Use this for resetting systems before a new round and animations.
const PlayingRound = &"PlayingRound"
const RoundEnding = &"RoundEnding"
const BetweenRounds = &"BetweenRounds"
const Ended = &"Ended"

func _ready() -> void:
    super._ready()
    
    if not Engine.is_editor_hint():
        PostHog.capture("game_started")
        self.state_changed.connect(_on_state_changed)

        Signals.player_died.connect(_on_player_died)
        Signals.done_shopping.connect(_on_done_shopping)
        Signals.dismiss_tutorial.connect(_on_dismiss_tutorial)

        change_state(FirstStart)

func _on_state_changed(_sender: State, new_state: State) -> void:
    Loggie.msg("Changed to: %s" % new_state.name).preset("State").info()
    Signals.game_state_changed.emit(new_state.name)

# Not sure I love listing these here, but idk where else it makes sense.
# Alternative is to call a set_state (or as a request_state_change signal) from the relevant nodes.

func _on_dismiss_tutorial() -> void:
    change_state(StartingNewRound)

func _on_player_died() -> void:
    change_state(RoundEnding)

func _on_done_shopping() -> void:
    change_state(StartingNewRound)
