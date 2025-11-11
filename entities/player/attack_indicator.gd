class_name AttackIndicator
extends Node2D

## Color of the indicator lines
@export var indicator_color: Color = Color(1.0, 1.0, 1.0, 1.0)

## Maximum distance to draw lines (calculated to be beyond screen border)
var max_draw_distance: float = 0.0

## Additional margin beyond visible screen to ensure lines extend off-screen
@export var distance_margin: float = 100.0

var mouse_position: Vector2 = Vector2.ZERO
var center_position: Vector2 = Constants.PlayerPosition

var _is_enabled: bool = false
var state_enabler: StateEnabler = StateEnabler.new(self, [GameState.PlayingRound])

func enable() -> void:
	if _is_enabled:
		return
	_is_enabled = true
	visible = true
	Loggie.msg("Enabled").preset("Enabled").debug()

func disable() -> void:
	if not _is_enabled:
		return
	visible = false
	_is_enabled = false
	Loggie.msg("Disabled").preset("Disabled").debug()
	
func _ready() -> void:
	# Ensure this draws on top of other game elements
	z_index = 10
	visible = false

	# Calculate max_draw_distance 
	_update_max_distance()
	get_viewport().size_changed.connect(_update_max_distance)

func _update_max_distance() -> void:
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	
	# Calculate the visible world bounds
	var viewport_size = viewport.get_visible_rect().size
	var calculated_distance = 0.0
	
	if camera != null:
		# Account for camera zoom
		var zoom_factor = camera.zoom.x # Assume uniform zoom
		var world_size = viewport_size / zoom_factor
		# Distance from center to corner of visible area
		calculated_distance = (world_size.length() / 2.0) + distance_margin
	else:
		# Fallback: use viewport size directly
		calculated_distance = (viewport_size.length() / 2.0) + distance_margin
	
	max_draw_distance = calculated_distance

func _process(_delta: float) -> void:
	# Update mouse position in world coordinates
	mouse_position = get_global_mouse_position()
	
	# Queue redraw to update indicator
	queue_redraw()

func _draw() -> void:
	# Calculate angle from center to mouse
	var direction_to_mouse = (mouse_position - center_position).normalized()
	var mouse_angle = direction_to_mouse.angle()
	
	# Calculate the two edge angles of the arc
	# Convert to radians
	var attack_arc = deg_to_rad(Save.player_stats.Get(Strings.PlayerStat_AttackArc))
	var half_angle = attack_arc / 2.0
	var left_angle = mouse_angle - half_angle
	var right_angle = mouse_angle + half_angle
	
	# Calculate end points for both lines
	var left_end = center_position + Vector2(cos(left_angle), sin(left_angle)) * max_draw_distance
	var right_end = center_position + Vector2(cos(right_angle), sin(right_angle)) * max_draw_distance
	
	# Draw the two lines
	draw_line(center_position, left_end, indicator_color, 2.0, true)
	draw_line(center_position, right_end, indicator_color, 2.0, true)
	
	# Draw arc connecting the lines
	# This is outside the screen, but 
	# can be extended later to fill the section
	draw_arc(
		center_position,
		50.0, # Small radius for arc visualization
		left_angle,
		right_angle,
		32, # Number of points
		indicator_color,
		2.0
	)
