extends Node3D

@export var projectile_speed = 4  # Speed of the projectile

# Call this function to shoot a projectile whenever needed
func shoot_projectile() -> void:
	# Get the shoot direction (the character is assumed to be facing the Z direction)
	var shoot_direction = global_transform.basis.z.normalized()
	var shoot_position = global_transform.origin + Vector3(0.0, 0.2, 0.0)

	# Preload and instantiate the projectile scene
	var projectile_scene = preload("res://scenes/bullet.tscn")  # Ensure the path to the bullet scene is correct
	var projectile = projectile_scene.instantiate() as CharacterBody3D

	# Set the projectile's initial position
	projectile.position = shoot_position

	# Set the projectile's direction and speed
	projectile.direction = shoot_direction
	projectile.speed = projectile_speed  # Use the defined projectile speed

	# Set the projectile's basis/rotation to match the shooter
	projectile.rotation = rotation  # Rotate to match the shooter's rotation

	# Add the projectile to the current scene
	get_tree().current_scene.add_child(projectile)
