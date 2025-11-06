class_name Game
extends Node2D

enum GameState {
    FIRST_START,
    PAUSE_MENU,
    PLAYING_ROUND,
    ROUND_ENDING,
    BETWEEN_ROUNDS,
    ENDED
}

var state: GameState = GameState.FIRST_START:
    get:
        return state
    set(value):
        if state != value:
            state = value
            Loggie.info("Game state changed to:", GameState.keys()[value])

func _ready() -> void:
    Signals.player_died.connect(_on_player_died)

func _on_player_died() -> void:
    Loggie.info("Player died")
    state = GameState.ROUND_ENDING
