extends Node

# The URL we will connect to.
# Use "ws://localhost:9080" if testing with the minimal server example below.
# `wss://` is used for secure connections,
# while `ws://` is used for plain text (insecure) connections.
@export var websocket_url = "wss://echo.websocket.org"
@export var room_code = "ABCD"
@export var player_speed := 350.0
@export var spawn_origin := Vector2(160, 360)
@export var spawn_spacing := 90.0

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()
var players: Dictionary = {}

@onready var StateLabel: Label = %StateLabel
@onready var PlayersRoot: Node2D = %Players

func _ready():
	randomize()

	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url + "?roomCode=" + room_code + "&role=host")
	if err == OK:
		print("Connecting to %s" % websocket_url)
		# Wait for the socket to connect.
		await get_tree().create_timer(1).timeout

		# Send data.
		# print("> Sending test packet.")
		# socket.send_text("Test packet")
	else:
		push_error("Unable to connect.")
		set_process(false)


func _process(_delta):
	# Call this in `_process()` or `_physics_process()`.
	# Data transfer and state updates will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	if StateLabel != null:
		StateLabel.text = str(state)

	# `WebSocketPeer.STATE_OPEN` means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			if socket.was_string_packet():
				# print("Raw packet: %s" % packet)
				var packet_text = packet.get_string_from_utf8()
				print("< Got text data from server: %s" % packet_text)

				# Parse the packet as JSON, extract "message" field
				var json = JSON.new()
				var error = json.parse(packet_text)
				if error == OK:
					var data_received = json.data
					if typeof(data_received) == TYPE_DICTIONARY:
						handle_message(data_received)
						# print(data_received)
						# print("Player: %s" % data_received.playerId)
						# print("Direction: %s" % data_received.direction)
					else:
						print("Unexpected data")
				else:
					print("JSON Parse Error: ", json.get_error_message(), " in ", packet_text, " at line ", json.get_error_line())
			else:
				print("< Got binary data from server: %d bytes" % packet.size())

		# Move all known players every frame while connected.
		_update_player_positions(_delta)

	# `WebSocketPeer.STATE_CLOSING` means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# `WebSocketPeer.STATE_CLOSED` means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be `-1` if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.


func handle_message(message: Dictionary) -> void:
	match message.type:
		"playerJoin":
			# type: "playerJoin"
			# roomCode: string
			# playerId: string
			# playerCount: number
			print("Player joined: %s" % message.playerId)
			_ensure_player(message.playerId)
		"playerLeave":
			# type: "playerJoin"
			# roomCode: string
			# playerId: string
			# playerCount: number
			print("Player left: %s" % message.playerId)
			_remove_player(message.playerId)
		"playerInput":
			# type: "playerInput"
			# roomCode: string
			# playerId: string
			# direction: "left" | "right"
			print("Player input: %s" % message.direction)
			_update_player_direction(message.playerId, message.direction)


func _ensure_player(player_id: String) -> void:
	if players.has(player_id):
		return

	var rect := ColorRect.new()
	rect.size = Vector2(48, 48)
	rect.color = Color.from_hsv(randf(), 0.8, 0.95)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.pivot_offset = rect.size * 0.5

	var spawn_x := spawn_origin.x + PlayersRoot.get_child_count() * spawn_spacing
	rect.position = Vector2(spawn_x, spawn_origin.y)

	PlayersRoot.add_child(rect)
	players[player_id] = {
		"node": rect,
		"direction": 0.0,
	}

func _remove_player(player_id: String) -> void:
	if not players.has(player_id):
		return

	var player_state = players[player_id]
	player_state.node.queue_free()
	players.erase(player_id)

func _update_player_direction(player_id: String, direction: String) -> void:
	_ensure_player(player_id)

	var direction_sign := 0.0
	if direction == "left":
		direction_sign = -1.0
	elif direction == "right":
		direction_sign = 1.0
	elif direction == "none":
		direction_sign = 0.0

	players[player_id].direction = direction_sign


func _update_player_positions(delta: float) -> void:
	for player_state in players.values():
		var node: ColorRect = player_state.node
		if node == null:
			continue
		var direction_sign: float = player_state.direction
		if direction_sign == 0.0:
			continue
		node.position.x += direction_sign * player_speed * delta
