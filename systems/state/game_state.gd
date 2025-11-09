@tool 

class_name GameState
extends State

# Make sure these line up with the states in the editor.
const FirstStart = &"FirstStart"
const PauseMenu = &"PauseMenu"
const PlayingRound = &"PlayingRound"
const RoundEnding = &"RoundEnding"
const BetweenRounds = &"BetweenRounds"
const Ended = &"Ended"

func _ready() -> void:
    super._ready()
    PostHog.capture("game_started")

    self.state_changed.connect(_on_state_changed)
    Signals.player_died.connect(_on_player_died)

func _on_player_died() -> void:
    change_state("RoundEnding")

func _on_state_changed(_sender: State, new_state: State) -> void:
    Loggie.info("Changed to: %s" % new_state.name)
    Signals.game_state_changed.emit(new_state.name)

