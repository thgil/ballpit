extends Node

@onready var role_label = $ColorRect/RoleLabel  # Replace with the correct path to the Label node
var is_server = false  # Default role, will be changed later

func _ready():
	# Check if the current instance is the server or the client
	if multiplayer.is_server():
		is_server = true
		role_label.text = "Server - Player ID: " + str(multiplayer.get_unique_id())
	else:
		is_server = false
		role_label.text = "Client - Player ID: " + str(multiplayer.get_unique_id())
	
	# Listen for peers joining/disconnecting
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Add additional information (like showing when players connect or disconnect)
	if is_server:
		print("This instance is the server")
	else:
		print("This instance is a client")

func _on_peer_connected(peer_id):
	if is_server:
		print("Client with ID " + str(peer_id) + " connected")

func _on_peer_disconnected(peer_id):
	if is_server:
		print("Client with ID " + str(peer_id) + " disconnected")
