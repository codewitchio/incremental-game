## A tool script used to preview EnemyData sprites and scaling in the editor.
@tool
extends Node2D

@export var enemy_data: EnemyData = null:
	set(value):
		if enemy_data != value:
			enemy_data = value
			# Redraw when enemy_data changes
			if Engine.is_editor_hint():
				queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# In editor, redraw periodically to catch changes to enemy_data properties
	# (Resources don't emit signals when their properties change)
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if enemy_data == null:
		return
	
	# Calculate collision radius (same logic as EnemyData.get_scaled_collision_radius())
	# Done inline to avoid placeholder instance issues in editor
	var collision_radius = EnemyData.get_scaled_collision_radius(enemy_data.collision_radius, enemy_data.scale)
	draw_circle(Vector2.ZERO, collision_radius, Color(1.0, 0.0, 0.0, 0.3))  # Semi-transparent red
	draw_arc(Vector2.ZERO, collision_radius, 0.0, TAU, 32, Color(1.0, 0.0, 0.0, 0.6), 1.0)
	
	# Draw sprite if available
	if enemy_data.sprite != null:
		var sprite_texture = enemy_data.sprite
		
		# Calculate sprite size and position with offset
		var sprite_size = sprite_texture.get_size() * enemy_data.scale
		var sprite_pos = -sprite_size / 2.0 + enemy_data.sprite_offset
		
		# Draw the sprite
		draw_texture_rect(
			sprite_texture,
			Rect2(sprite_pos, sprite_size),
			false,
			Color.WHITE
		)
	
	# Draw sprite offset indicator
	if enemy_data.sprite_offset != Vector2.ZERO:
		# Draw line from origin to offset position
		draw_line(Vector2.ZERO, enemy_data.sprite_offset, Color(0.0, 1.0, 1.0, 0.8), 0.5)
		# Draw circle at offset position
		draw_circle(enemy_data.sprite_offset, 0.7, Color(0.0, 1.0, 1.0, 0.8))