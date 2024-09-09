extends Camera3D

@export var player: NodePath  # The player node to follow
@export var buffer_width: float = 5.0  # Horizontal buffer zone size
@export var buffer_height: float = 3.0  # Vertical buffer zone size
@export var catchup_speed: float = 5.0  # Speed at which the camera catches up

@onready var player_node = get_node(player) as CharacterBody3D  # The player node reference

var camera_target_position: Vector3
@export var offset: Vector3 = Vector3(0,0,-5.0)

func _ready() -> void:
	# Initialize the camera's target position
	camera_target_position = global_transform.origin + offset

func _process(delta: float) -> void:
	if not player_node:
		return

	# Calculate the player's position relative to the camera
	var player_position = player_node.global_transform.origin
	var camera_position = global_transform.origin + offset
	var relative_position = player_position - camera_position

	# Determine the buffer bounds (left, right, top, bottom)
	var buffer_left = -buffer_width / 2
	var buffer_right = buffer_width / 2
	var buffer_top = buffer_height / 2
	var buffer_bottom = -buffer_height / 2

	# Check if the player is outside the buffer zone
	var target_offset = Vector3.ZERO

	if relative_position.x < buffer_left:
		target_offset.x = relative_position.x - buffer_left
	elif relative_position.x > buffer_right:
		target_offset.x = relative_position.x - buffer_right

	if relative_position.z < buffer_bottom:
		target_offset.z = relative_position.z - buffer_bottom
	elif relative_position.z > buffer_top:
		target_offset.z = relative_position.z - buffer_top

	# Smoothly catch up to the target position
	camera_target_position += target_offset * delta * catchup_speed

	# Update the camera's position to move smoothly towards the target
	global_transform.origin = global_transform.origin.lerp(camera_target_position, delta * catchup_speed)
