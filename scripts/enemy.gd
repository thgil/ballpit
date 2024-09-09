extends CharacterBody3D

@export var movement_speed: float = 5.0
@export var slow_down_distance: float = 2.5  # Distance at which the AI starts to slow down
@export var target: NodePath  # Assign the player or the node to follow
@export var path_desired_distance: float = 1.0  # How close to the path points we need to be
@export var target_reached_distance: float = 1.5  # Distance to consider the player "reached"

@onready var navigation_agent = $NavigationAgent3D  # Get the NavigationAgent3D
var player: CharacterBody3D  # Reference to the player
var navigation_ready: bool = false  # Flag to check if the navigation map is ready

func _ready() -> void:
	# Ensure the target (player) is assigned
	if target:
		player = get_node(target) as CharacterBody3D
	else:
		push_warning("No target assigned to the AI!")

	# Set the NavigationAgent's path_desired_distance
	navigation_agent.path_desired_distance = path_desired_distance

	# Connect signals for pathfinding events
	navigation_agent.target_reached.connect(_on_target_reached)

	# Listen for map changes to know when the navigation map is ready
	NavigationServer3D.map_changed.connect(_on_navigation_map_ready)

	# Check if the map is already ready
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) != 0:
		navigation_ready = true

func _physics_process(delta: float) -> void:
	# If the navigation map isn't ready, don't proceed
	if not navigation_ready:
		return

	if not player:
		return

	# Set the player's position as the target position for pathfinding
	navigation_agent.target_position = player.global_transform.origin

	# Get the next position to move towards
	var next_position = navigation_agent.get_next_path_position()

	# Check if we have arrived or move towards the next position
	if navigation_agent.is_target_reached():
		_on_target_reached()
	else:
		move_towards_position(next_position, delta)

# Moves the AI towards the next path position
func move_towards_position(next_position: Vector3, _delta: float) -> void:
	# Calculate the distance to the next path position
	var distance_to_target = global_transform.origin.distance_to(next_position)

	# Gradually reduce speed when approaching the target
	var current_speed = movement_speed
	if distance_to_target < slow_down_distance:
		current_speed = movement_speed * (distance_to_target / slow_down_distance)

	# Get the direction to the next path position
	var direction = global_transform.origin.direction_to(next_position).normalized()

	# Set velocity and move the AI smoothly
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	move_and_slide()

# Called when the target is reached
func _on_target_reached() -> void:
	# Smoothly slow down when reaching the target
	velocity = velocity.move_toward(Vector3.ZERO, movement_speed * 0.1)

# Called when the navigation map is ready
func _on_navigation_map_ready(map_id: RID) -> void:  # Updated to accept RID instead of int
	if map_id == navigation_agent.get_navigation_map():
		navigation_ready = true
