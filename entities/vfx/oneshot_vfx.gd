## Simple class for playing a one-shot VFX and then freeing itself. Make sure to set up the animation as autoplay, and one_shot = true.
class_name OneshotVFX
extends GPUParticles2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if animation_player == null:
		Loggie.error("Oneshot VFX requires an animation player in the scene tree")
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()
