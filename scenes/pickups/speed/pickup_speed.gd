extends Pickup

@export var speed_increase: float = 1.5  # Speed multiplier
@export var speed_duration: float = 5.0  # Duration of the speed boost

# Override the apply_power_up_effect function to increase the player's speed
func apply_power_up_effect(player: Player) -> void:
	# Apply the speed boost by modifying the player's speed
	player.SPEED *= speed_increase
	#player.apply_speed_boost_effect()  # Optional visual/audio feedback

# Called when the speed boost duration expires (only for temporary boosts)
func on_expire(player: Player) -> void:
	# Reset the player's speed back to normal
	player.SPEED /= speed_increase
	player.remove_speed_boost_effect()  # Optional feedback removal
