## Simple class for playing a one-shot VFX and then freeing itself. Make sure to set one_shot = true.
class_name OneshotVFX
extends GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finished.connect(_on_finished)
	restart()

func _on_finished() -> void:
	queue_free()
