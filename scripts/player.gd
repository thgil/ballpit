extends CharacterBody3D

class_name Player

signal health_changed(health: int)
signal player_died()

@export var hit_sound : AudioStream  # Expose the sound effect to the editor
@export var hit_particles_scene : PackedScene  # Scene for hit particles

@export var invulnerability_time: float = 0.2  # Time (in seconds) for invulnerability after taking damage
var is_invulnerable: bool = false

# Constants for movement
@export var SPEED: float = 3.0
@export var JUMP_VELOCITY = 12
@export var GRAVITY: float = 60.0
@export var PROJECTILE_SPEED_BASE = 10.0
var projectile_speed: float

# Reference to the AnimationPlayer node and character mesh
@onready var animation_player = $AnimationPlayer
@onready var character_mesh = $"character-soldier"
@onready var hit_sound_player: AudioStreamPlayer = $hit_sound_player

# Double jump related variables
@export var can_double_jump: bool = false  # Whether the player can double jump
var has_double_jumped: bool = false  # To track if a double jump has been used

# Power-up related variables
var power_up_active = false
var power_up_speed_bonus = 1.0
var health: int = 100

# Variable to track the current animation state
var current_animation: String = "idle"

var original_materials = []
var white_material : Material

func _ready() -> void:
	# Set the base projectile speed
	projectile_speed = PROJECTILE_SPEED_BASE
	play_animation("idle")
	
	# Initialize the white material once
	white_material = StandardMaterial3D.new()
	white_material.albedo_color = Color(1, 1, 1, 1)  # White color

	# Store all original materials for the meshes in the character
	store_original_materials()
	
	health_changed.emit(health)

func _physics_process(delta: float) -> void:
	# Handle gravity
	if not is_on_floor():
		velocity.y += Vector3(0, -GRAVITY, 0).y * delta
	else:
		# Reset double jump when the player lands
		has_double_jumped = false

	# Handle jumping
	handle_jumping()

	# Handle movement input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Get the target direction on the XZ plane (ignore Y-axis)
		var target_position = global_transform.origin - Vector3(velocity.x, 0, velocity.z)
		var target_rotation = character_mesh.global_transform.looking_at(target_position, Vector3.UP).basis
		
		# Smoothly rotate the character to face the movement direction on the XZ plane
		character_mesh.basis = character_mesh.basis.slerp(target_rotation, 0.3)

		# Play walk animation
		if is_on_floor() and current_animation != "walk":
			play_animation("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if is_on_floor() and velocity.x == 0 and velocity.z == 0 and current_animation != "idle":
			play_animation("idle")

	# Handle shooting
	if Input.is_action_just_pressed("ui_shoot"):
		shoot()

	# Apply movement and slide
	move_and_slide()

func handle_jumping() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			# Regular jump
			velocity.y = JUMP_VELOCITY
			play_animation("jump")
		elif can_double_jump and not has_double_jumped:
			# Double jump logic
			velocity.y = JUMP_VELOCITY
			has_double_jumped = true
			play_animation("jump")

func shoot() -> void:
	# Get the shoot direction (the character is assumed to be facing the Z direction)
	var shoot_direction = character_mesh.global_transform.basis.z.normalized()
	var shoot_position = character_mesh.global_transform.origin + Vector3(0.0, 0.2 , 0.0)
	var adjusted_projectile_speed = projectile_speed * power_up_speed_bonus
	
	# Preload and instantiate the projectile scene
	var projectile_scene = preload("res://scenes/bullet.tscn")  # Ensure the path is correct
	var projectile = projectile_scene.instantiate() as CharacterBody3D
	
	# Set the projectile's initial position
	projectile.position = shoot_position
	
	# Set the projectile's direction and speed
	projectile.direction = shoot_direction
	projectile.speed = adjusted_projectile_speed  # Use the adjusted speed, affected by power-ups
	
	# Set the projectile's basis/rotation to match the character
	projectile.rotation = character_mesh.rotation  # Rotate to match the shooter's rotation
	
	# Set the projectile's collision layers to ignore the player
	projectile.add_collision_exception_with(self)

	# Add the projectile to the current scene
	get_tree().current_scene.add_child(projectile)

func play_animation(anim_name: String) -> void:
	animation_player.play(anim_name)
	current_animation = anim_name

func apply_damage(damage: int) -> void:
	if is_invulnerable:
		return  # Ignore damage if the player is invulnerable

	play_hit_sound()
	flash_white()
	scale_effect()
	emit_hit_particles()
	
	health -= damage
	health_changed.emit(health)
	if health <= 0:
		die()
	else:
		# Trigger invulnerability after taking damage
		start_invulnerability()

func start_invulnerability() -> void:
	is_invulnerable = true

	# Make the player flash or turn semi-transparent for visual feedback
	flash_white()

	# Start a timer to end invulnerability after `invulnerability_time`
	var timer = Timer.new()
	timer.wait_time = invulnerability_time
	timer.one_shot = true
	timer.timeout.connect(_end_invulnerability)
	add_child(timer)
	timer.start()

func _end_invulnerability() -> void:
	is_invulnerable = false
	_reset_materials()  # Reset the character materials

func die() -> void:
	player_died.emit()
	queue_free()  # Remove the player from the scene (or respawn, etc.)

# Function to store the original materials of all MeshInstance3D nodes
func store_original_materials():
	original_materials.clear()  # Clear if needed
	# Loop through all children recursively to find MeshInstance3D nodes
	for child in get_tree().get_nodes_in_group("mesh_group"):  # We'll group all meshes for easier reference
		if child is MeshInstance3D:
			var material = child.get_active_material(0)
			original_materials.append(material)

func flash_white():
	# Apply the white material to all MeshInstance3D nodes
	for child in get_tree().get_nodes_in_group("mesh_group"):
		if child is MeshInstance3D:
			child.set_surface_override_material(0, white_material)
	
	# Use a Tween to gradually transition back to the original material
	var tween = create_tween()  # Create a tween using the new method
	tween.tween_callback(_reset_materials).set_delay(invulnerability_time)

func scale_effect():
	# Create a scaling effect
	var tween = create_tween()

	# Scale up to 1.2x size
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), invulnerability_time/2.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)

	# Scale back down to original size
	tween.tween_property(self, "scale", Vector3(1, 1, 1), invulnerability_time/2.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)

func play_hit_sound():
	if hit_sound_player and hit_sound_player.stream:
		hit_sound_player.play()

func emit_hit_particles():
	# Emit hit particles if available
	if hit_particles_scene:
		var particles = hit_particles_scene.instantiate()
		add_child(particles)
		
		particles.emitting = true
		
		await get_tree().create_timer(particles.lifetime).timeout
		particles.queue_free()

func _reset_materials():
	# Reset the original material for all MeshInstance3D nodes
	var i = 0
	for child in get_tree().get_nodes_in_group("mesh_group"):
		if child is MeshInstance3D:
			child.set_surface_override_material(0, original_materials[i])
			i += 1

func _on_body_entered(body: Node) -> void:
	if body is Pickup:
		print('hit pickup')
		
		# Apply the power-up to the player
		body.apply_to(self)

		# Remove the power-up from the scene
		body.queue_free()
