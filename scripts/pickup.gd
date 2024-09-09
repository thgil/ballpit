extends Node3D

class_name Pickup

@export var duration: float = 5.0  # Duration of the power-up effect
@export var is_permanent: bool = false  # Flag for permanent power-ups
@export var pickup_sound: AudioStream  # Sound to play when picked up

var picked_up: bool = false  # Flag to prevent multiple pickups

# Called when the player picks up the power-up
func apply_to(player: Player) -> void:
	if picked_up:
		return  # Prevent multiple pickups
	picked_up = true
	
	# Hide the pickup's visual representation immediately
	hide_visual()
	
	# Disable collision to prevent further pickups
	set_pickup_collision(false)
	
	# Play pickup sound
	if pickup_sound:
		var sound_player = AudioStreamPlayer3D.new()
		sound_player.stream = pickup_sound
		add_child(sound_player)
		sound_player.play()

		# Connect to the `finished` signal to remove the pickup after the sound
		sound_player.finished.connect(_on_sound_finished)
	else:
		# No sound to play, remove the pickup immediately
		queue_free()

	# Apply the power-up effect
	if is_permanent:
		apply_permanent(player)
	else:
		apply_temporary(player)

# Function to apply a permanent power-up
func apply_permanent(_player: Player) -> void:
	# To be implemented by specific permanent power-ups
	pass

# Function to apply a temporary power-up
func apply_temporary(player: Player) -> void:
	# Schedule the expiration of the power-up effect
	apply_power_up_effect(player)
	await get_tree().create_timer(duration).timeout
	on_expire(player)

# Called when the power-up duration expires
func on_expire(_player: Player) -> void:
	# To be implemented by specific temporary power-ups
	pass

func apply_power_up_effect(_player: Player) -> void:
	# To be implemented in specific power-up subclasses
	pass

# Called when the pickup is touched by the player
func _on_pickup_body_entered(body: Node3D) -> void:
	if body is Player:
		apply_to(body)

# Called when the pickup sound finishes playing
func _on_sound_finished() -> void:
	# Remove the pickup after the sound has finished playing
	queue_free()

# Hides the visual representation of the pickup
func hide_visual() -> void:
	# Loop through the children of the pickup and hide any visual elements
	for child in get_children():
		if child is MeshInstance3D or child is Sprite3D:  # Adjust based on your visual nodes
			child.visible = false

# Disables or enables the collision shapes of the pickup
func set_pickup_collision(enabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = not enabled
