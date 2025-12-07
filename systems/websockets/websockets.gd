extends Node

# The URL we will connect to.
# Use "ws://localhost:9080" if testing with the minimal server example below.
# `wss://` is used for secure connections,
# while `ws://` is used for plain text (insecure) connections.
@export var websocket_url = "wss://echo.websocket.org"
@export var room_code = "ABCD"

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()

@onready var StateLabel: Label = %StateLabel

func _ready():
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
		"playerInput":
			# type: "playerInput"
			# roomCode: string
			# playerId: string
			# direction: "left" | "right"
			print("Player input: %s" % message.direction)
