extends CharacterBody3D

@export var speed: float = 10.0
@export var lifetime: float = 5.0  # Time until the projectile is removed
@export var damage: int = 10  # Damage dealt by the projectile
@export var bounce: bool = true

var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Set a timer to remove the projectile after its lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Ensure direction is always constrained to the XZ plane
	direction.y = 0
	direction = direction.normalized()  # Ensure direction is normalized

	# Calculate velocity
	velocity = direction * speed

	# Move the projectile and check for collision
	var collision = move_and_collide(velocity * delta)

	# If a collision is detected, handle reflection based on collision normal
	if collision:
		var normal = collision.get_normal()
		
		var collider = collision.get_collider()
		
		# Check if the collider is a player and not the shooter
		if collider != null and collider is Player:
			collider.apply_damage(damage)  # Apply damage to the player hit
			queue_free()  # Destroy the projectile after hitting the player

		if bounce:
			# Reflect direction using collision normal, then re-normalize to maintain speed
			direction = direction.bounce(normal)
			direction.y = 0  # Ensure Y component stays zero for XZ plane
			direction = direction.normalized()  # Normalize direction to maintain consistent speed
			
			# Adjust the rotation to face the new direction in the XZ plane
			if direction.length() > 0.01:
				look_at(position + direction, Vector3.UP)

	# Ensure the projectile always faces the direction it's moving in
	if direction.length() > 0.01:
		look_at(position - direction, Vector3.UP)
