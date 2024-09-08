extends CharacterBody3D

# Constants for movement
const SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
const GRAVITY = Vector3(0, -9.8, 0)
const PROJECTILE_SPEED = 20.0

# Reference to the AnimationPlayer node and character mesh
@onready var animation_player = $AnimationPlayer
@onready var character_mesh = $"character-soldier" # Replace with the actual path to your character's mesh

# Variable to track the current animation state
var current_animation: String = "idle"

func _ready() -> void:
	# Play idle animation at start
	play_animation("idle", true)

func _physics_process(delta: float) -> void:
	# Add gravity to the velocity
	if not is_on_floor():
		velocity.y += GRAVITY.y * delta
	else:
		# Handle jump
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
			play_animation("jump", false)

	# Get the input direction and handle movement
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		# Set velocity based on direction and speed
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Rotate character mesh to face direction of movement smoothly
		if velocity.length() > 0.1:
			var target_rotation = character_mesh.global_transform.looking_at(global_transform.origin - velocity, Vector3.UP).basis
			character_mesh.global_transform.basis = character_mesh.global_transform.basis.slerp(target_rotation, 0.3)

		# Play walk animation
		if is_on_floor() and current_animation != "walk":
			play_animation("walk", true)
	else:
		# Gradually stop the character
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

		# Play idle animation when not moving
		if is_on_floor() and velocity.x == 0 and velocity.z == 0 and current_animation != "idle":
			play_animation("idle", true)

	# Check for shooting input
	if Input.is_action_just_pressed("ui_shoot"):
		shoot()

	# Apply movement and slide
	move_and_slide()

func shoot() -> void:
	# Play shooting animation
	play_animation("shoot", false)

	# Spawn projectile and shoot it forward
	var projectile_instance = projectile_scene.instantiate()
	var projectile_position = character_mesh.global_transform.origin + character_mesh.global_transform.basis.z * 2 # Offset the spawn point forward
	projectile_instance.global_transform.origin = projectile_position

	# Set the velocity of the projectile in the direction the character is facing
	var shoot_direction = character_mesh.global_transform.basis.z.normalized()
	projectile_instance.shoot(shoot_direction * PROJECTILE_SPEED)

	# Add projectile to the scene
	get_tree().current_scene.add_child(projectile_instance)

func play_animation(anim_name: String, should_loop: bool = false) -> void:
	animation_player.play(anim_name)
	current_animation = anim_name
