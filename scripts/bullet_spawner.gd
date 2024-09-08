extends Node3D

@export var projectile_speed = 4
@export var path_speed = 5.0  # Speed of the spawner along the path
@export var path: NodePath  # Exported path to assign the PathFollow3D from the editor
@export var bpm = 120  # Beats per minute of the music

var path_follow: PathFollow3D
var moving_forward: bool = true
var beat_interval: float = 0.0  # Default interval
var next_shoot_interval: float = 0.0

func _ready() -> void:
	# Calculate the default beat interval from the BPM
	beat_interval = 60.0 / bpm

	# Get the PathFollow3D node from the assigned path
	if path:
		path_follow = get_node(path) as PathFollow3D
	
	# Start the timer for shooting projectiles
	$Timer.start(beat_interval)

func _process(delta: float) -> void:
	# Move along the path if PathFollow3D is assigned
	if path_follow:
		# Adjust path progress based on direction
		if moving_forward:
			path_follow.progress += delta * path_speed
			# If we reach the end of the path, start moving backward
			if path_follow.progress_ratio >= 1.0:
				moving_forward = false
		else:
			path_follow.progress -= delta * path_speed
			# If we reach the start of the path, start moving forward
			if path_follow.progress_ratio <= 0.0:
				moving_forward = true
		
		# Update the position of the bullet spawner to follow the path
		global_transform.origin = path_follow.global_transform.origin

func _on_timer_timeout() -> void:
	# Randomize shoot interval for more variety
	next_shoot_interval = beat_interval * randf_range(0.5, 1.5)  # Vary between half-beat and one and a half beats
	$Timer.start(next_shoot_interval)

	# Spawn the projectile
	spawn_projectile()

func spawn_projectile() -> void:
	# Get the shoot direction (the character is assumed to be facing the Z direction)
	var shoot_direction = global_transform.basis.z.normalized()
	var shoot_position = global_transform.origin + Vector3(0.0, 0.2, 0.0)

	# Preload and instantiate the projectile scene
	var projectile_scene = preload("res://scenes/bullet.tscn")  # Ensure the path is correct
	var projectile = projectile_scene.instantiate() as CharacterBody3D

	# Set the projectile's initial position
	projectile.position = shoot_position

	# Set the projectile's direction and speed
	projectile.direction = shoot_direction
	projectile.speed = projectile_speed  # Use the adjusted speed, affected by power-ups

	# Set the projectile's basis/rotation to match the character
	projectile.rotation = rotation  # Rotate to match the shooter's rotation

	# Add the projectile to the current scene
	get_tree().current_scene.add_child(projectile)
