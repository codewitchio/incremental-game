class_name Game
extends Node2D

# TODO: Maybe this is easier with XSM actually. 
enum GameState {
    FIRST_START,
    PAUSE_MENU,
    PLAYING_ROUND,
    ROUND_ENDING,
    BETWEEN_ROUNDS,
    ENDED
}

@export var _round_ending_timer: Timer

var state: GameState = GameState.FIRST_START:
    get:
        return state
    set(value):
        if state != value:
            state = value
            Loggie.info("Game state:", GameState.keys()[value])
            Signals.game_state_changed.emit(state)

func _ready() -> void:
    Signals.player_died.connect(_on_player_died)
    _round_ending_timer.timeout.connect(_on_round_ending_timeout)

func _on_player_died() -> void:
    _end_round()

func _end_round() -> void:
    state = GameState.ROUND_ENDING
    _round_ending_timer.start()


func _on_round_ending_timeout() -> void:
    state = GameState.BETWEEN_ROUNDS